import 'dart:async';

import '../../../core/local_date.dart';
import '../../today/data/day_repository.dart';
import '../../today/domain/completion_event.dart';
import '../domain/prescription.dart';
import '../domain/workout_plan.dart';
import '../domain/workout_session.dart';
import 'workout_repository.dart';

/// The member's plan and sessions held in memory only. Everything is gone
/// when the app closes.
///
/// Used where there is no SQLite file: the web preview (ADR-0005: web is a
/// development preview and must not claim to save) and widget tests. It
/// follows the same rules as the Drift store; the shared contract test
/// runs against both.
class MemoryWorkoutRepository implements WorkoutRepository {
  /// [days] is the store the day's boxes are kept in: finishing a session
  /// checks the Workout box there.
  MemoryWorkoutRepository(this._days);

  final DayRepository _days;
  final Map<String, WorkoutPlan> _plans = <String, WorkoutPlan>{};
  final List<WorkoutSession> _sessions = <WorkoutSession>[];
  final StreamController<void> _changes = StreamController<void>.broadcast();

  /// Completes when the change being made now is done. Null when no change
  /// is being made.
  Future<void>? _busy;

  /// Runs [change] when every change asked for before it is done.
  ///
  /// SQLite does one write transaction at a time, so in the Drift store a
  /// finish and an edit can never overlap: one is complete before the
  /// other starts. Finishing here waits for the day's store in the middle,
  /// so without this an edit, or a second finish, could slip in between
  /// its two halves. Taking turns gives this store the same rule.
  ///
  /// When nothing is being changed, [change] starts at once, with no wait
  /// on an earlier future. A widget test relies on that: it calls the
  /// store both under its fake clock and in real time, and a future made
  /// under one never completes for a caller waiting under the other.
  Future<T> _inTurn<T>(Future<T> Function() change) async {
    // Those waiting are woken in the order they came. The first takes its
    // turn before the next looks, so the next waits again, behind it.
    while (_busy != null) {
      await _busy;
    }
    final done = Completer<void>();
    _busy = done.future;
    try {
      return await change();
    } finally {
      _busy = null;
      done.complete();
    }
  }

  @override
  bool get durable => false;

  @override
  Stream<WorkoutPlan?> watchPlan(String ownerId) =>
      _watch(() => _plans[ownerId]);

  @override
  Future<WorkoutPlan> ensurePlan(
    String ownerId,
    WorkoutPlan Function() create,
  ) => _inTurn(() async {
    final stored = _plans[ownerId];
    if (stored != null) return stored;
    final plan = create();
    _plans[ownerId] = plan;
    _changes.add(null);
    return plan;
  });

  @override
  Future<void> savePlan(String ownerId, WorkoutPlan plan) => _inTurn(() async {
    _plans[ownerId] = plan;
    _changes.add(null);
  });

  @override
  Stream<WorkoutSession?> watchSession(String ownerId, LocalDate day) =>
      _watch(() => _find(ownerId, day));

  @override
  Future<WorkoutSession?> readSession(String ownerId, LocalDate day) =>
      _inTurn(() async => _find(ownerId, day));

  @override
  Stream<WorkoutSession?> watchOpenSession(
    String ownerId, {
    LocalDate? before,
  }) => _watch(() {
    WorkoutSession? latest;
    for (final session in _sessions) {
      if (session.ownerId != ownerId || session.finished) continue;
      if (before != null && session.day.compareTo(before) >= 0) continue;
      if (latest == null || session.startedAtUtc.isAfter(latest.startedAtUtc)) {
        latest = session;
      }
    }
    return latest;
  });

  @override
  Future<WorkoutSession> startSession(NewSession session) => _inTurn(() async {
    final existing = _find(session.ownerId, session.day);
    if (existing != null) return existing;
    final started = WorkoutSession(
      id: session.id,
      ownerId: session.ownerId,
      day: session.day,
      program: session.program,
      planDay: session.planDay,
      planWeek: session.planWeek,
      title: session.title,
      sessionType: session.sessionType,
      minutes: session.minutes,
      startedAtUtc: session.startedAt.toUtc(),
      startUtcOffset: session.startedAt.timeZoneOffset,
      finishEventId: session.finishEventId,
      exercises: List<SessionExercise>.unmodifiable(session.exercises),
    );
    _sessions.add(started);
    _changes.add(null);
    return started;
  });

  @override
  Future<void> setReps(String setId, int? reps) => _inTurn(
    () async => _changeSet(
      setId,
      (set) => SessionSet(
        id: set.id,
        position: set.position,
        target: set.target,
        reps: reps,
        weightLb: set.weightLb,
        ticked: set.ticked,
      ),
    ),
  );

  @override
  Future<void> setWeight(String setId, double? weightLb) => _inTurn(
    () async => _changeSet(
      setId,
      (set) => SessionSet(
        id: set.id,
        position: set.position,
        target: set.target,
        reps: set.reps,
        weightLb: weightLb,
        ticked: set.ticked,
      ),
    ),
  );

  @override
  Future<void> setTicked(String setId, {required bool ticked}) => _inTurn(
    () async => _changeSet(
      setId,
      (set) => SessionSet(
        id: set.id,
        position: set.position,
        target: set.target,
        reps: set.reps,
        weightLb: set.weightLb,
        ticked: ticked,
      ),
    ),
  );

  @override
  Future<bool> addSet(String exerciseId, {required String setId}) =>
      _inTurn(() async {
        for (var i = 0; i < _sessions.length; i++) {
          final session = _sessions[i];
          // A finished session is locked.
          if (session.finished) continue;
          final found = session.exercises.where((e) => e.id == exerciseId);
          if (found.isEmpty) continue;
          final exercise = found.first;
          if (!exercise.canAddSet) return false;
          final last = exercise.sets.last;
          _replaceSets(i, exerciseId, <SessionSet>[
            ...exercise.sets,
            SessionSet(
              id: setId,
              position: last.position + 1,
              target: last.target,
            ),
          ]);
          return true;
        }
        return false;
      });

  @override
  Future<bool> removeSet(String setId) => _inTurn(() async {
    for (var i = 0; i < _sessions.length; i++) {
      final session = _sessions[i];
      // A finished session is locked.
      if (session.finished) continue;
      for (final exercise in session.exercises) {
        final found = exercise.sets.where((s) => s.id == setId);
        if (found.isEmpty) continue;
        final set = found.first;
        if (!exercise.canRemove(set)) return false;
        _replaceSets(i, exercise.id, <SessionSet>[
          for (final other in exercise.sets)
            if (other.id != setId)
              // The rows after it move up.
              other.position > set.position
                  ? SessionSet(
                      id: other.id,
                      position: other.position - 1,
                      target: other.target,
                      reps: other.reps,
                      weightLb: other.weightLb,
                      ticked: other.ticked,
                    )
                  : other,
        ]);
        return true;
      }
    }
    return false;
  });

  /// Gives one exercise of the session at [index] the rows [sets].
  void _replaceSets(int index, String exerciseId, List<SessionSet> sets) {
    final session = _sessions[index];
    _sessions[index] = _withExercises(session, <SessionExercise>[
      for (final exercise in session.exercises)
        exercise.id == exerciseId
            ? _copyExercise(
                exercise,
                restBaseSeconds: exercise.restBaseSeconds,
                restEndsAtUtc: exercise.restEndsAtUtc,
                restPausedSeconds: exercise.restPausedSeconds,
                sets: sets,
              )
            : exercise,
    ]);
    _changes.add(null);
  }

  @override
  Future<void> setRest(
    String exerciseId, {
    required int baseSeconds,
    DateTime? endsAtUtc,
    int? pausedSeconds,
  }) => _inTurn(() async {
    for (var i = 0; i < _sessions.length; i++) {
      final session = _sessions[i];
      // A finished session is locked.
      if (session.finished) continue;
      if (!session.exercises.any((e) => e.id == exerciseId)) continue;
      _sessions[i] = _withExercises(session, <SessionExercise>[
        for (final exercise in session.exercises)
          exercise.id == exerciseId
              ? _copyExercise(
                  exercise,
                  restBaseSeconds: baseSeconds,
                  restEndsAtUtc: endsAtUtc?.toUtc(),
                  restPausedSeconds: pausedSeconds,
                )
              : exercise,
      ]);
      _changes.add(null);
      return;
    }
  });

  @override
  Future<FinishOutcome> finishSession(String sessionId, DateTime now) =>
      _inTurn(() async {
        final index = _sessions.indexWhere((s) => s.id == sessionId);
        if (index < 0) {
          throw StateError('There is no workout session with this id.');
        }
        final session = _sessions[index];
        if (session.finished) return FinishOutcome.alreadyFinished;

        // The completion first: if it cannot be stored, the session stays
        // unfinished, as the Drift store's transaction leaves it. Nothing
        // else can change the session while this waits: every change
        // takes its turn in the queue.
        await _days.record(
          CompletionEvent(
            id: session.finishEventId,
            ownerId: session.ownerId,
            day: session.day,
            item: DayItems.workout,
            done: true,
            tappedAtUtc: now.toUtc(),
            utcOffset: now.timeZoneOffset,
          ),
        );
        _sessions[index] = WorkoutSession(
          id: session.id,
          ownerId: session.ownerId,
          day: session.day,
          program: session.program,
          planDay: session.planDay,
          planWeek: session.planWeek,
          title: session.title,
          sessionType: session.sessionType,
          minutes: session.minutes,
          startedAtUtc: session.startedAtUtc,
          startUtcOffset: session.startUtcOffset,
          finishedAtUtc: now.toUtc(),
          finishUtcOffset: now.timeZoneOffset,
          finishEventId: session.finishEventId,
          exercises: List<SessionExercise>.unmodifiable(<SessionExercise>[
            // A rest timer left running stops with the workout.
            for (final exercise in session.exercises)
              _copyExercise(
                exercise,
                restBaseSeconds: exercise.restBaseSeconds,
                restEndsAtUtc: null,
                restPausedSeconds: null,
              ),
          ]),
        );
        _changes.add(null);
        return FinishOutcome.finished;
      });

  @override
  Future<Map<String, LastTime>> lastTimes(
    String ownerId, {
    required LocalDate before,
    required Iterable<String> movementIds,
  }) async {
    final wanted = movementIds.toSet();
    final earlier =
        _sessions
            .where((s) => s.ownerId == ownerId && s.day.compareTo(before) < 0)
            .toList()
          ..sort((a, b) => b.day.compareTo(a.day));
    final found = <String, LastTime>{};
    for (final session in earlier) {
      final onThisDay = <String, List<LastSet>>{};
      for (final exercise in session.exercises) {
        if (!wanted.contains(exercise.movementId)) continue;
        if (found.containsKey(exercise.movementId)) continue;
        if (exercise.measure != SetMeasure.reps) continue;
        for (final set in exercise.sets) {
          if ((set.reps ?? 0) <= 0) continue;
          onThisDay
              .putIfAbsent(exercise.movementId, () => <LastSet>[])
              .add(
                LastSet(
                  position: set.position,
                  reps: set.reps!,
                  weightLb: set.weightLb,
                ),
              );
        }
      }
      for (final entry in onThisDay.entries) {
        found[entry.key] = LastTime(
          day: session.day,
          sets: List<LastSet>.unmodifiable(entry.value),
        );
      }
    }
    return found;
  }

  WorkoutSession? _find(String ownerId, LocalDate day) {
    for (final session in _sessions) {
      if (session.ownerId == ownerId && session.day == day) return session;
    }
    return null;
  }

  void _changeSet(String setId, SessionSet Function(SessionSet) change) {
    for (var i = 0; i < _sessions.length; i++) {
      final session = _sessions[i];
      // A finished session is locked.
      if (session.finished) continue;
      final holds = session.exercises.any(
        (e) => e.sets.any((s) => s.id == setId),
      );
      if (!holds) continue;
      _sessions[i] = _withExercises(session, <SessionExercise>[
        for (final exercise in session.exercises)
          _copyExercise(
            exercise,
            restBaseSeconds: exercise.restBaseSeconds,
            restEndsAtUtc: exercise.restEndsAtUtc,
            restPausedSeconds: exercise.restPausedSeconds,
            sets: <SessionSet>[
              for (final set in exercise.sets)
                set.id == setId ? change(set) : set,
            ],
          ),
      ]);
      _changes.add(null);
      return;
    }
  }

  static WorkoutSession _withExercises(
    WorkoutSession session,
    List<SessionExercise> exercises,
  ) => WorkoutSession(
    id: session.id,
    ownerId: session.ownerId,
    day: session.day,
    program: session.program,
    planDay: session.planDay,
    planWeek: session.planWeek,
    title: session.title,
    sessionType: session.sessionType,
    minutes: session.minutes,
    startedAtUtc: session.startedAtUtc,
    startUtcOffset: session.startUtcOffset,
    finishedAtUtc: session.finishedAtUtc,
    finishUtcOffset: session.finishUtcOffset,
    finishEventId: session.finishEventId,
    exercises: List<SessionExercise>.unmodifiable(exercises),
  );

  static SessionExercise _copyExercise(
    SessionExercise exercise, {
    required int restBaseSeconds,
    required DateTime? restEndsAtUtc,
    required int? restPausedSeconds,
    List<SessionSet>? sets,
  }) => SessionExercise(
    id: exercise.id,
    position: exercise.position,
    movementId: exercise.movementId,
    name: exercise.name,
    prescription: exercise.prescription,
    measure: exercise.measure,
    weightMode: exercise.weightMode,
    restBaseSeconds: restBaseSeconds,
    restEndsAtUtc: restEndsAtUtc,
    restPausedSeconds: restPausedSeconds,
    sets: List<SessionSet>.unmodifiable(sets ?? exercise.sets),
  );

  /// The current value at once, then again after every change.
  Stream<T> _watch<T>(T Function() read) {
    return Stream<T>.multi((controller) {
      controller.add(read());
      final changes = _changes.stream.listen((_) => controller.add(read()));
      controller.onCancel = changes.cancel;
    });
  }
}
