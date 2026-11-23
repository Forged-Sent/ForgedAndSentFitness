import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/local_store.dart';
import '../../../core/clock.dart';
import '../../../core/date_text.dart';
import '../../../core/event_id.dart';
import '../../../core/local_date.dart';
import '../data/workout_library.dart';
import '../data/workout_repository.dart';
import '../domain/prescription.dart';
import '../domain/workout_plan.dart';
import '../domain/workout_session.dart';

/// The member's plan. He gets one, with the default settings, the first
/// time a screen asks for it; after that it is his stored plan.
final workoutPlanProvider = StreamProvider<WorkoutPlan>((ref) async* {
  final store = ref.watch(localStoreProvider);
  final today = LocalDate.of(ref.read(clockProvider).now());
  yield await store.workouts.ensurePlan(
    store.ownerId,
    () => WorkoutPlan.startingFor(today),
  );
  await for (final plan in store.workouts.watchPlan(store.ownerId)) {
    if (plan != null) yield plan;
  }
});

/// The member's plan as it is stored, or null if he has none yet. Reading
/// this never gives him one: [workoutPlanProvider] does that, when Train
/// or a workout page is opened.
final storedPlanProvider = StreamProvider<WorkoutPlan?>((ref) {
  final store = ref.watch(localStoreProvider);
  return store.workouts.watchPlan(store.ownerId);
});

/// "Plan starts Monday, November 16" and the like: the prototype's
/// `rowLabel`.
({String title, String detail}) planDayLabel(
  PlanDay planDay,
  WorkoutPlan plan,
) {
  switch (planDay.kind) {
    case PlanDayKind.before:
      return (title: 'Plan starts ${weekdayName(plan.start)}', detail: '');
    case PlanDayKind.over:
      return (title: 'Plan complete', detail: '');
    case PlanDayKind.rest:
      return (title: 'Sabbath', detail: 'Rest, worship, family');
    case PlanDayKind.off:
      return (title: 'Rest day', detail: 'Optional day is off');
    case PlanDayKind.train:
      final workout = planDay.workout!;
      return (
        title: workout.title,
        detail: workout.minutes > 0
            ? '${workout.sessionType} · ${workout.minutes} min'
            : workout.sessionType,
      );
  }
}

/// What Today's Workout box says on a day the member's plan holds no
/// workout, or null on a day that has one. Today asks.
///
/// "Rest day" on a rest day ([PlanDay.isRest]), as Train's first card says.
/// Before the plan starts and after it ends, Train's own words for the day:
/// "Plan starts Monday", "Plan complete".
///
/// Null for a member with no plan yet: nothing says which days are his.
/// Null, too, if the plan or the program cannot be read. Today must still
/// open then, and Train is where that failure shows.
final dayWithoutWorkoutProvider = FutureProvider<String?>((ref) async {
  final today = ref.watch(todayDateProvider);
  try {
    final plan = await ref.watch(storedPlanProvider.future);
    if (plan == null) return null;
    final library = await ref.watch(workoutLibraryProvider.future);
    final planDay = library.dayFor(plan, today);
    if (planDay.isTrain) return null;
    return planDay.isRest ? 'Rest day' : planDayLabel(planDay, plan).title;
  } catch (_) {
    return null;
  }
});

/// The session started on one local day, straight from the store.
final sessionForDayProvider = StreamProvider.family<WorkoutSession?, LocalDate>(
  (ref, day) {
    final store = ref.watch(localStoreProvider);
    return store.workouts.watchSession(store.ownerId, day);
  },
);

/// The most recently started session of a day before today that is not
/// finished. Today's own session is not it: Train shows that one on
/// today's card, and an earlier one beside it.
final earlierOpenSessionProvider = StreamProvider<WorkoutSession?>((ref) {
  final store = ref.watch(localStoreProvider);
  final today = ref.watch(todayDateProvider);
  return store.workouts.watchOpenSession(store.ownerId, before: today);
});

/// One exercise of a day that has no session yet: what the plan asks for.
class PlannedLine {
  const PlannedLine({
    required this.name,
    required this.prescription,
    this.supersetLabel,
  });

  final String name;
  final String prescription;

  /// "A1" or "A2" for an exercise of the day's superset, else null.
  final String? supersetLabel;
}

/// Everything the workout page shows for one local day.
class WorkoutView {
  const WorkoutView({
    required this.day,
    required this.today,
    required this.planDay,
    required this.planned,
    required this.session,
    required this.lastTimes,
    required this.durable,
    this.supersetLabels = const <String?>[],
  });

  /// The day the page is for.
  final LocalDate day;

  final LocalDate today;

  /// What the plan holds for [day].
  final PlanDay planDay;

  /// The plan's exercises for [day], named for the member's equipment.
  /// Shown until a session is started.
  final List<PlannedLine> planned;

  /// The session started on [day], or null.
  final WorkoutSession? session;

  /// What was logged the last time each movement of the session was done,
  /// by movement id.
  final Map<String, LastTime> lastTimes;

  /// False where nothing is kept after the app closes (the web preview).
  final bool durable;

  /// For each exercise of [session], "A1" or "A2" if it is one of the
  /// day's superset, else null. For drawing only; see [supersetLabelsFor].
  /// Empty when there is no session.
  final List<String?> supersetLabels;

  /// A session can be started only on the day itself. The prototype's
  /// rule: the Start button shows for today only.
  bool get canStart => session == null && planDay.isTrain && day == today;

  /// A started session can be logged and finished on any later day too
  /// (review finding U2).
  bool get live => session != null && !session!.finished;

  bool get locked => session?.finished ?? false;
}

/// The changes to workout sessions that are still on their way to the
/// store: one queue for each session, in the order the changes were made.
///
/// A queue belongs to its session and not to the workout page. He can
/// leave the page and open it again while storage is slow and changes are
/// still waiting; the page he comes back to is a new one, and what he
/// changes there must be stored after what he changed before, never ahead
/// of it. So the new page joins the queue the old one left behind.
///
/// A session is named here by its day: a member has at most one session
/// on a day. Its queue is kept only while a change is waiting.
class WorkoutWrites {
  final Map<LocalDate, Future<void>> _waiting = <LocalDate, Future<void>>{};

  /// Queues [write] behind every change already made to the session of
  /// [day]. True if it was stored. A write that fails does not stop the
  /// ones after it.
  Future<bool> add(LocalDate day, Future<void> Function() write) {
    final result = settled(day)
        .then((_) => write())
        .then<bool>((_) => true, onError: (Object _) => false);
    late final Future<void> last;
    last = result.then<void>((_) {
      // Nothing was queued behind this one: the queue is empty again.
      if (identical(_waiting[day], last)) _waiting.remove(day);
    });
    _waiting[day] = last;
    return result;
  }

  /// Completes once every change made so far to the session of [day] has
  /// had its turn, whichever page made it.
  Future<void> settled(LocalDate day) => _waiting[day] ?? Future<void>.value();

  /// How many sessions have a change waiting. Read by tests only.
  @visibleForTesting
  int get waiting => _waiting.length;
}

/// The one [WorkoutWrites] of the store in use. It outlives every workout
/// page; see [WorkoutWrites] for why.
final workoutWritesProvider = Provider<WorkoutWrites>((ref) {
  // The queues are of the writes to this store.
  ref.watch(localStoreProvider);
  return WorkoutWrites();
});

/// What asking the store to remove a set did.
enum SetRemoval {
  /// The row is gone from the store.
  removed,

  /// The store was reached and kept the row: it was not one he added, or
  /// something is entered in it, or the workout is finished.
  kept,

  /// The store could not be reached. The row is still there.
  failed,
}

/// What a tap on Amen in the workout prayer did.
enum StartOutcome {
  /// The session is started and stored.
  started,

  /// The page was no longer today's: midnight passed while it was open.
  /// Nothing was started.
  newDay,

  /// The session could not be stored.
  failed,
}

/// Presentation state for one day's workout page.
///
/// The truth of an in-progress workout is the store, not this object
/// (architecture review 5.7): every change is written at once, and the
/// page is redrawn from what the store then holds.
final workoutViewModelProvider = AsyncNotifierProvider.family
    .autoDispose<WorkoutViewModel, WorkoutView, LocalDate>(
      WorkoutViewModel.new,
      retry: (retryCount, error) => null,
    );

class WorkoutViewModel extends AsyncNotifier<WorkoutView> {
  WorkoutViewModel(this.day);

  final LocalDate day;

  /// The queue of the changes still on their way to the store. It is the
  /// session's, not this page's: see [WorkoutWrites]. Set at the start of
  /// [build], before anything can be asked of this view model.
  late WorkoutWrites _writes;

  /// The last rest timer change made on this page, by exercise id.
  final Map<String, _Rest> _rest = <String, _Rest>{};

  String? _lastTimesSession;
  Map<String, LastTime> _lastTimes = const <String, LastTime>{};

  @override
  Future<WorkoutView> build() async {
    _writes = ref.watch(workoutWritesProvider);
    final today = ref.watch(todayDateProvider);
    final store = ref.watch(localStoreProvider);
    final library = await ref.watch(workoutLibraryProvider.future);
    final plan = await ref.watch(workoutPlanProvider.future);
    final session = await ref.watch(sessionForDayProvider(day).future);

    final planDay = library.dayFor(plan, day);
    final plannedLabels = planDay.isTrain
        ? supersetLabels(
            planDay.workout!.superset,
            planDay.workout!.exercises.length,
          )
        : const <String?>[];
    if (session != null && session.id != _lastTimesSession) {
      // Looked up once per session, by movement id.
      _lastTimes = await store.workouts.lastTimes(
        store.ownerId,
        before: session.day,
        movementIds: session.exercises.map((e) => e.movementId),
      );
      _lastTimesSession = session.id;
    }

    return WorkoutView(
      day: day,
      today: today,
      planDay: planDay,
      planned: <PlannedLine>[
        if (planDay.isTrain)
          for (var i = 0; i < planDay.workout!.exercises.length; i++)
            PlannedLine(
              name: library.nameFor(
                planDay.workout!.exercises[i].movementId,
                plan.equipment,
              ),
              prescription: planDay.workout!.exercises[i].prescription,
              supersetLabel: plannedLabels[i],
            ),
      ],
      session: session,
      lastTimes: session == null ? const <String, LastTime>{} : _lastTimes,
      durable: store.workouts.durable,
      // Read from the program for drawing only. The session itself still
      // never reads the plan again: nothing here is stored or changes
      // what it holds.
      supersetLabels: session == null
          ? const <String?>[]
          : supersetLabelsFor(
              session,
              library.planDayNumbered(session.program, session.planDay),
            ),
    );
  }

  /// Loads again after an error.
  Future<void> retry() async {
    ref.invalidate(workoutLibraryProvider);
    ref.invalidate(workoutPlanProvider);
    ref.invalidate(sessionForDayProvider(day));
    ref.invalidateSelf();
    await future.then<void>((_) {}, onError: (Object _) {});
  }

  /// Starts today's session. Called when Amen is tapped in the workout
  /// prayer, and at no other time (decision Q11).
  ///
  /// The session takes a copy of what the plan prescribes now: every
  /// exercise's movement id, shown name and prescription text, and one row
  /// per set. From here on it never reads the plan again.
  Future<StartOutcome> start() async {
    // Everything is taken from the ref here, before the first wait: he may
    // leave the page while the session is being stored, and a view model
    // that has been disposed can no longer be asked for anything.
    final store = ref.read(localStoreProvider);
    final now = ref.read(clockProvider).now();
    final newId = ref.read(eventIdProvider);
    final libraryLoading = ref.read(workoutLibraryProvider.future);
    final planLoading = ref.read(workoutPlanProvider.future);
    // A session belongs to the local day it starts on (decision Q9).
    if (LocalDate.of(now) != day) {
      ref.read(todayDateProvider.notifier).refresh();
      return StartOutcome.newDay;
    }
    final WorkoutLibrary library;
    final WorkoutPlan plan;
    try {
      library = await libraryLoading;
      plan = await planLoading;
    } catch (_) {
      return StartOutcome.failed;
    }
    final planDay = library.dayFor(plan, day);
    final workout = planDay.workout;
    if (!planDay.isTrain || workout == null) return StartOutcome.failed;

    final exercises = <SessionExercise>[];
    for (var i = 0; i < workout.exercises.length; i++) {
      final planned = workout.exercises[i];
      final sets = parseSets(planned.prescription);
      exercises.add(
        SessionExercise(
          id: newId(),
          position: i,
          movementId: planned.movementId,
          name: library.nameFor(planned.movementId, plan.equipment),
          prescription: planned.prescription,
          measure: sets?.measure ?? SetMeasure.tick,
          weightMode: sets == null
              ? WeightMode.none
              : library.weightModeOf(planned.movementId, plan.equipment),
          restBaseSeconds: restBaseFor(planned.prescription),
          sets: <SessionSet>[
            if (sets == null)
              SessionSet(id: newId(), position: 0, target: '')
            else
              for (var j = 0; j < sets.count; j++)
                SessionSet(id: newId(), position: j, target: sets.targets[j]),
          ],
        ),
      );
    }

    try {
      await store.workouts.startSession(
        NewSession(
          id: newId(),
          ownerId: store.ownerId,
          program: plan.program,
          planDay: workout.day,
          planWeek: workout.week,
          title: workout.title,
          sessionType: workout.sessionType,
          minutes: workout.minutes,
          startedAt: now,
          finishEventId: newId(),
          exercises: exercises,
        ),
      );
    } catch (_) {
      return StartOutcome.failed;
    }
    return StartOutcome.started;
  }

  /// Queues one write behind every change already made to this page's
  /// session, on this page or on an earlier opening of it. True if it was
  /// stored.
  ///
  /// [write] must not read the ref. It runs when the writes before it are
  /// done, and by then he may have left the page and this view model may
  /// have been disposed; a change made before that must still be stored.
  /// So every caller takes what it needs from the ref first, with
  /// [_workouts], and hands [write] the repository itself.
  Future<bool> _write(Future<void> Function() write) => _writes.add(day, write);

  /// Waits until every change made so far is in the store, also one made
  /// on an earlier opening of this page. Called when the app is paused, so
  /// nothing typed is still on its way when the phone stops the app.
  Future<void> flush() {
    flushes++;
    return _writes.settled(day);
  }

  /// How often [flush] was asked for. Read by tests only, to prove the
  /// page asks when the app is paused.
  @visibleForTesting
  int flushes = 0;

  /// The session of this page's day as the store holds it now, read once
  /// every change made so far has had its turn, also one made on an
  /// earlier opening of this page. Throws if it cannot be read.
  ///
  /// The view the page draws from is rebuilt a moment after a write, so it
  /// can be a change behind. What is checked before a workout is locked
  /// must not be.
  Future<WorkoutSession?> storedSession() async {
    final store = ref.read(localStoreProvider);
    await _writes.settled(day);
    return store.workouts.readSession(store.ownerId, day);
  }

  /// The store, read now. See [_write].
  WorkoutRepository get _workouts => ref.read(localStoreProvider).workouts;

  Future<bool> setReps(String setId, int? reps) {
    final workouts = _workouts;
    return _write(() => workouts.setReps(setId, reps));
  }

  Future<bool> setWeight(String setId, double? weightLb) {
    final workouts = _workouts;
    return _write(() => workouts.setWeight(setId, weightLb));
  }

  Future<bool> setTicked(String setId, {required bool ticked}) {
    final workouts = _workouts;
    return _write(() => workouts.setTicked(setId, ticked: ticked));
  }

  /// Adds one set under [exercise]'s rows, with the same target as its
  /// last set. True if the store was reached; the store adds nothing to
  /// an exercise that already has [maxSets] rows.
  ///
  /// It takes its turn behind every change already made, like a change to
  /// a set.
  Future<bool> addSet(SessionExercise exercise) {
    final workouts = _workouts;
    final setId = ref.read(eventIdProvider)();
    return _write(() => workouts.addSet(exercise.id, setId: setId));
  }

  /// Removes a set he added, if nothing is entered in it, and says what
  /// became of it.
  ///
  /// It takes its turn behind every change already made. So if he typed
  /// in the row a moment before, that is stored first, the store then
  /// finds the row is not empty, and nothing is removed. What the store
  /// cannot know is a change to the row that failed to be stored: the
  /// page knows that, and does not ask for the removal then.
  Future<SetRemoval> removeSet(String setId) async {
    final workouts = _workouts;
    var removed = false;
    final reached = await _write(() async {
      removed = await workouts.removeSet(setId);
    });
    if (!reached) return SetRemoval.failed;
    return removed ? SetRemoval.removed : SetRemoval.kept;
  }

  /// Where [exercise]'s rest timer stands as far as this page knows: the
  /// last change made here, or else what the store holds.
  ///
  /// Each change is worked out from the one before it. The page is redrawn
  /// from the store a moment after a change is written, so two quick taps
  /// on "+15" would otherwise both start from the same old value and add
  /// 15 seconds once.
  _Rest _restOf(SessionExercise exercise) =>
      _rest[exercise.id] ??
      _Rest(
        base: exercise.restBaseSeconds,
        endsAtUtc: exercise.restEndsAtUtc,
        pausedSeconds: exercise.restPausedSeconds,
      );

  /// Starts the rest timer, or carries on a paused one. A timer that ran
  /// out starts again from its full length.
  Future<bool> startRest(SessionExercise exercise) {
    final now = ref.read(clockProvider).now().toUtc();
    final current = _restOf(exercise);
    final rest = current.at(now);
    if (rest.running) return Future<bool>.value(true);
    final left = rest.over || rest.left <= 0 ? current.base : rest.left;
    return _setRest(
      exercise,
      _Rest(
        base: current.base,
        endsAtUtc: now.add(Duration(seconds: left)),
      ),
    );
  }

  /// Stops a running rest timer where it stands.
  Future<bool> pauseRest(SessionExercise exercise) {
    final now = ref.read(clockProvider).now().toUtc();
    final current = _restOf(exercise);
    final rest = current.at(now);
    if (!rest.running) return Future<bool>.value(true);
    return _setRest(
      exercise,
      _Rest(base: current.base, pausedSeconds: rest.left),
    );
  }

  /// Puts the rest timer back to its full length, not running.
  Future<bool> resetRest(SessionExercise exercise) =>
      _setRest(exercise, _Rest(base: _restOf(exercise).base));

  /// Makes the rest [seconds] longer, or shorter when negative, within
  /// 15 seconds to 10 minutes. A running timer moves by as much as its
  /// full length did; a timer that is not running goes back to its new
  /// full length.
  ///
  /// At either limit the full length does not change, and neither does a
  /// running timer. The prototype's `timerAdj` moves a running timer by
  /// the 15 seconds anyway, so a tap on "+15" at ten minutes makes this
  /// rest longer than ten minutes; that is not carried over.
  Future<bool> adjustRest(SessionExercise exercise, int seconds) {
    final current = _restOf(exercise);
    final base = (current.base + seconds).clamp(minRestSeconds, maxRestSeconds);
    final now = ref.read(clockProvider).now().toUtc();
    if (!current.at(now).running) return _setRest(exercise, _Rest(base: base));
    return _setRest(
      exercise,
      _Rest(
        base: base,
        endsAtUtc: current.endsAtUtc!.add(
          Duration(seconds: base - current.base),
        ),
      ),
    );
  }

  Future<bool> _setRest(SessionExercise exercise, _Rest rest) {
    _rest[exercise.id] = rest;
    final workouts = _workouts;
    return _write(
      () => workouts.setRest(
        exercise.id,
        baseSeconds: rest.base,
        endsAtUtc: rest.endsAtUtc,
        pausedSeconds: rest.pausedSeconds,
      ),
    ).then((bool saved) {
      // What could not be stored is not what the timer is: go back to
      // what the store holds.
      if (!saved && identical(_rest[exercise.id], rest)) {
        _rest.remove(exercise.id);
      }
      return saved;
    });
  }

  /// Finishes the session on this page. It checks the Workout box of the
  /// day the session was started on, also after midnight. Finishing twice
  /// records one completion. Returns false if it could not be saved.
  ///
  /// It takes its turn behind every change already made to the session,
  /// on this page or on an earlier opening of it, whether or not those
  /// were stored: a write that fails does not stop the ones after it. So the page asks for this only once every set change he made is
  /// stored, and after checking [storedSession] (`_finish` in
  /// `workout_page.dart`). The page is what knows which boxes he typed in,
  /// and it forgets them when he leaves, as the boxes then show what is
  /// stored.
  Future<bool> finish() async {
    final session = state.value?.session;
    if (session == null) return false;
    // The finish time is the moment of the tap, not the moment its turn
    // comes behind the writes still queued.
    final workouts = _workouts;
    final now = ref.read(clockProvider).now();
    final saved = await _write(() => workouts.finishSession(session.id, now));
    if (saved && ref.mounted) {
      // The tap read the clock; make the day on screen agree with it.
      ref.read(todayDateProvider.notifier).refresh();
    }
    return saved;
  }
}

/// What is stored for one rest timer.
class _Rest {
  const _Rest({required this.base, this.endsAtUtc, this.pausedSeconds});

  final int base;
  final DateTime? endsAtUtc;
  final int? pausedSeconds;

  RestState at(DateTime nowUtc) => restStateAt(
    nowUtc,
    baseSeconds: base,
    endsAtUtc: endsAtUtc,
    pausedSeconds: pausedSeconds,
  );
}
