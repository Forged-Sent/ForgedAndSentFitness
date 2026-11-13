import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/local_store.dart';
import '../../../core/clock.dart';
import '../../../core/event_id.dart';
import '../../../core/local_date.dart';
import '../data/workout_library.dart';
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

/// The session started on one local day, straight from the store.
final sessionForDayProvider = StreamProvider.family<WorkoutSession?, LocalDate>(
  (ref, day) {
    final store = ref.watch(localStoreProvider);
    return store.workouts.watchSession(store.ownerId, day);
  },
);

/// The most recently started session that is not finished.
final openSessionProvider = StreamProvider<WorkoutSession?>((ref) {
  final store = ref.watch(localStoreProvider);
  return store.workouts.watchOpenSession(store.ownerId);
});

/// One exercise of a day that has no session yet: what the plan asks for.
class PlannedLine {
  const PlannedLine({required this.name, required this.prescription});

  final String name;
  final String prescription;
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

  /// A session can be started only on the day itself. The prototype's
  /// rule: the Start button shows for today only.
  bool get canStart => session == null && planDay.isTrain && day == today;

  /// A started session can be logged and finished on any later day too
  /// (review finding U2).
  bool get live => session != null && !session!.finished;

  bool get locked => session?.finished ?? false;
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

  /// The writes still on their way to the store, one after another in the
  /// order they were made.
  Future<void> _pending = Future<void>.value();

  String? _lastTimesSession;
  Map<String, LastTime> _lastTimes = const <String, LastTime>{};

  @override
  Future<WorkoutView> build() async {
    final today = ref.watch(todayDateProvider);
    final store = ref.watch(localStoreProvider);
    final library = await ref.watch(workoutLibraryProvider.future);
    final plan = await ref.watch(workoutPlanProvider.future);
    final session = await ref.watch(sessionForDayProvider(day).future);

    final planDay = library.dayFor(plan, day);
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
          for (final exercise in planDay.workout!.exercises)
            PlannedLine(
              name: library.nameFor(exercise.movementId, plan.equipment),
              prescription: exercise.prescription,
            ),
      ],
      session: session,
      lastTimes: session == null ? const <String, LastTime>{} : _lastTimes,
      durable: store.workouts.durable,
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
    final store = ref.read(localStoreProvider);
    final now = ref.read(clockProvider).now();
    // A session belongs to the local day it starts on (decision Q9).
    if (LocalDate.of(now) != day) {
      ref.read(todayDateProvider.notifier).refresh();
      return StartOutcome.newDay;
    }
    final WorkoutLibrary library;
    final WorkoutPlan plan;
    try {
      library = await ref.read(workoutLibraryProvider.future);
      plan = await ref.read(workoutPlanProvider.future);
    } catch (_) {
      return StartOutcome.failed;
    }
    final planDay = library.dayFor(plan, day);
    final workout = planDay.workout;
    if (!planDay.isTrain || workout == null) return StartOutcome.failed;

    final newId = ref.read(eventIdProvider);
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

  /// Queues one write behind the ones before it. True if it was stored.
  Future<bool> _write(Future<void> Function() write) {
    final result = _pending
        .then((_) => write())
        .then<bool>((_) => true, onError: (Object _) => false);
    _pending = result.then<void>((_) {});
    return result;
  }

  /// Waits until every change made so far is in the store. Called when the
  /// app is paused, so nothing typed is still on its way when the phone
  /// stops the app.
  Future<void> flush() => _pending;

  Future<bool> setReps(String setId, int? reps) =>
      _write(() => ref.read(localStoreProvider).workouts.setReps(setId, reps));

  Future<bool> setWeight(String setId, double? weightLb) => _write(
    () => ref.read(localStoreProvider).workouts.setWeight(setId, weightLb),
  );

  Future<bool> setTicked(String setId, {required bool ticked}) => _write(
    () =>
        ref.read(localStoreProvider).workouts.setTicked(setId, ticked: ticked),
  );

  /// Starts the rest timer, or carries on a paused one. A timer that ran
  /// out starts again from its full length.
  Future<bool> startRest(SessionExercise exercise) {
    final now = ref.read(clockProvider).now().toUtc();
    final rest = exercise.restAt(now);
    final left = rest.over || rest.left <= 0
        ? exercise.restBaseSeconds
        : rest.left;
    return _setRest(
      exercise,
      base: exercise.restBaseSeconds,
      endsAtUtc: now.add(Duration(seconds: left)),
    );
  }

  /// Stops a running rest timer where it stands.
  Future<bool> pauseRest(SessionExercise exercise) {
    final now = ref.read(clockProvider).now().toUtc();
    final rest = exercise.restAt(now);
    if (!rest.running) return Future<bool>.value(true);
    return _setRest(
      exercise,
      base: exercise.restBaseSeconds,
      pausedSeconds: rest.left,
    );
  }

  /// Puts the rest timer back to its full length, not running.
  Future<bool> resetRest(SessionExercise exercise) =>
      _setRest(exercise, base: exercise.restBaseSeconds);

  /// Makes the rest [seconds] longer, or shorter when negative, within
  /// 15 seconds to 10 minutes. A running timer moves by the same amount; a
  /// timer that is not running goes back to its new full length.
  Future<bool> adjustRest(SessionExercise exercise, int seconds) {
    final base = (exercise.restBaseSeconds + seconds).clamp(
      minRestSeconds,
      maxRestSeconds,
    );
    final now = ref.read(clockProvider).now().toUtc();
    final rest = exercise.restAt(now);
    if (!rest.running) return _setRest(exercise, base: base);
    return _setRest(
      exercise,
      base: base,
      endsAtUtc: exercise.restEndsAtUtc!.add(Duration(seconds: seconds)),
    );
  }

  Future<bool> _setRest(
    SessionExercise exercise, {
    required int base,
    DateTime? endsAtUtc,
    int? pausedSeconds,
  }) => _write(
    () => ref
        .read(localStoreProvider)
        .workouts
        .setRest(
          exercise.id,
          baseSeconds: base,
          endsAtUtc: endsAtUtc,
          pausedSeconds: pausedSeconds,
        ),
  );

  /// Finishes the session on this page. It checks the Workout box of the
  /// day the session was started on, also after midnight. Finishing twice
  /// records one completion. Returns false if it could not be saved.
  Future<bool> finish() async {
    final session = state.value?.session;
    if (session == null) return false;
    final saved = await _write(
      () => ref
          .read(localStoreProvider)
          .workouts
          .finishSession(session.id, ref.read(clockProvider).now()),
    );
    if (saved && ref.mounted) {
      // The tap read the clock; make the day on screen agree with it.
      ref.read(todayDateProvider.notifier).refresh();
    }
    return saved;
  }
}
