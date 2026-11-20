import 'dart:async';

import 'package:drift/drift.dart';

import '../../../core/local_date.dart';
import '../../../storage/app_database.dart';
import '../../today/data/day_repository.dart';
import '../../today/domain/completion_event.dart';
import '../domain/prescription.dart';
import '../domain/workout_plan.dart';
import '../domain/workout_session.dart';
import 'workout_repository.dart';

/// The member's plan and workout sessions in his SQLite file, through
/// Drift.
///
/// Every change to a set is its own write, committed before the call
/// returns, so a killed app loses at most the keystroke in flight.
class DriftWorkoutRepository implements WorkoutRepository {
  /// [days] must be the day repository of the same database: finishing a
  /// session and checking the day's Workout box are one transaction.
  DriftWorkoutRepository(this._db, this._days);

  final AppDatabase _db;
  final DayRepository _days;

  @override
  bool get durable => true;

  @override
  Stream<WorkoutPlan?> watchPlan(String ownerId) {
    final query = _db.select(_db.workoutPlans)
      ..where((t) => t.ownerId.equals(ownerId));
    return query.watchSingleOrNull().map(
      (row) => row == null ? null : _plan(row),
    );
  }

  @override
  Future<WorkoutPlan> ensurePlan(
    String ownerId,
    WorkoutPlan Function() create,
  ) {
    return _db.transaction(() async {
      final stored = await (_db.select(
        _db.workoutPlans,
      )..where((t) => t.ownerId.equals(ownerId))).getSingleOrNull();
      if (stored != null) return _plan(stored);
      final plan = create();
      await _db.into(_db.workoutPlans).insert(_planRow(ownerId, plan));
      return plan;
    });
  }

  @override
  Future<void> savePlan(String ownerId, WorkoutPlan plan) => _db
      .into(_db.workoutPlans)
      .insertOnConflictUpdate(_planRow(ownerId, plan));

  @override
  Stream<WorkoutSession?> watchSession(String ownerId, LocalDate day) =>
      _watch(() => readSession(ownerId, day));

  @override
  Future<WorkoutSession?> readSession(String ownerId, LocalDate day) async {
    final row =
        await (_db.select(_db.workoutSessions)
              ..where((t) => t.ownerId.equals(ownerId) & t.day.equals(day.iso)))
            .getSingleOrNull();
    return row == null ? null : _session(row);
  }

  @override
  Stream<WorkoutSession?> watchOpenSession(String ownerId) {
    return _watch(() async {
      final row =
          await (_db.select(_db.workoutSessions)
                ..where(
                  (t) => t.ownerId.equals(ownerId) & t.finishedAtUtcMs.isNull(),
                )
                ..orderBy([(t) => OrderingTerm.desc(t.startedAtUtcMs)])
                ..limit(1))
              .getSingleOrNull();
      return row == null ? null : _session(row);
    });
  }

  @override
  Future<WorkoutSession> startSession(NewSession session) {
    return _db.transaction(() async {
      final existing =
          await (_db.select(_db.workoutSessions)..where(
                (t) =>
                    t.ownerId.equals(session.ownerId) &
                    t.day.equals(session.day.iso),
              ))
              .getSingleOrNull();
      if (existing != null) return _session(existing);

      await _db
          .into(_db.workoutSessions)
          .insert(
            WorkoutSessionsCompanion.insert(
              id: session.id,
              ownerId: session.ownerId,
              day: session.day.iso,
              program: session.program,
              planDay: session.planDay,
              planWeek: session.planWeek,
              title: session.title,
              sessionType: session.sessionType,
              minutes: session.minutes,
              startedAtUtcMs: session.startedAt.toUtc().millisecondsSinceEpoch,
              startUtcOffsetMinutes: session.startedAt.timeZoneOffset.inMinutes,
              finishEventId: session.finishEventId,
            ),
          );
      await _db.batch((batch) {
        batch.insertAll(_db.workoutExercises, <WorkoutExercisesCompanion>[
          for (final exercise in session.exercises)
            WorkoutExercisesCompanion.insert(
              id: exercise.id,
              sessionId: session.id,
              position: exercise.position,
              movementId: exercise.movementId,
              name: exercise.name,
              prescription: exercise.prescription,
              measure: exercise.measure.name,
              weightMode: exercise.weightMode.name,
              restBaseSeconds: exercise.restBaseSeconds,
            ),
        ]);
        batch.insertAll(_db.workoutSets, <WorkoutSetsCompanion>[
          for (final exercise in session.exercises)
            for (final set in exercise.sets)
              WorkoutSetsCompanion.insert(
                id: set.id,
                exerciseId: exercise.id,
                position: set.position,
                target: set.target,
              ),
        ]);
      });
      final stored = await (_db.select(
        _db.workoutSessions,
      )..where((t) => t.id.equals(session.id))).getSingle();
      return _session(stored);
    });
  }

  /// Only a set of a session that is still in progress can change. A
  /// finished session is locked here, not just on the screen.
  static const String _inOpenSession =
      'exercise_id IN (SELECT e.id FROM workout_exercises e '
      'JOIN workout_sessions s ON s.id = e.session_id '
      'WHERE s.finished_at_utc_ms IS NULL)';

  Future<void> _updateSet(String column, String setId, Variable<Object> value) {
    return _db.customUpdate(
      'UPDATE workout_sets SET $column = ? WHERE id = ? AND $_inOpenSession',
      variables: <Variable<Object>>[value, Variable<String>(setId)],
      updates: {_db.workoutSets},
      updateKind: UpdateKind.update,
    );
  }

  @override
  Future<void> setReps(String setId, int? reps) =>
      _updateSet('reps', setId, Variable<int>(reps));

  @override
  Future<void> setWeight(String setId, double? weightLb) =>
      _updateSet('weight_lb', setId, Variable<double>(weightLb));

  @override
  Future<void> setTicked(String setId, {required bool ticked}) =>
      _updateSet('ticked', setId, Variable<bool>(ticked));

  @override
  Future<void> setRest(
    String exerciseId, {
    required int baseSeconds,
    DateTime? endsAtUtc,
    int? pausedSeconds,
  }) {
    return _db.customUpdate(
      'UPDATE workout_exercises SET rest_base_seconds = ?, '
      'rest_ends_at_utc_ms = ?, rest_paused_seconds = ? '
      'WHERE id = ? AND session_id IN (SELECT id FROM workout_sessions '
      'WHERE finished_at_utc_ms IS NULL)',
      variables: <Variable<Object>>[
        Variable<int>(baseSeconds),
        Variable<int>(endsAtUtc?.toUtc().millisecondsSinceEpoch),
        Variable<int>(pausedSeconds),
        Variable<String>(exerciseId),
      ],
      updates: {_db.workoutExercises},
      updateKind: UpdateKind.update,
    );
  }

  @override
  Future<FinishOutcome> finishSession(String sessionId, DateTime now) {
    return _db.transaction(() async {
      final row = await (_db.select(
        _db.workoutSessions,
      )..where((t) => t.id.equals(sessionId))).getSingleOrNull();
      if (row == null) {
        throw StateError('There is no workout session with this id.');
      }
      if (row.finishedAtUtcMs != null) return FinishOutcome.alreadyFinished;

      await (_db.update(
        _db.workoutSessions,
      )..where((t) => t.id.equals(sessionId))).write(
        WorkoutSessionsCompanion(
          finishedAtUtcMs: Value(now.toUtc().millisecondsSinceEpoch),
          finishUtcOffsetMinutes: Value(now.timeZoneOffset.inMinutes),
        ),
      );
      // A rest timer left running stops with the workout.
      await (_db.update(
        _db.workoutExercises,
      )..where((t) => t.sessionId.equals(sessionId))).write(
        const WorkoutExercisesCompanion(
          restEndsAtUtcMs: Value(null),
          restPausedSeconds: Value(null),
        ),
      );
      // The same database and the same transaction: the session is never
      // finished without its completion, or the reverse. The box belongs
      // to the day the session started on, whatever day it is now.
      await _days.record(
        CompletionEvent(
          id: row.finishEventId,
          ownerId: row.ownerId,
          day: LocalDate.parse(row.day),
          item: DayItems.workout,
          done: true,
          tappedAtUtc: now.toUtc(),
          utcOffset: now.timeZoneOffset,
        ),
      );
      return FinishOutcome.finished;
    });
  }

  @override
  Future<Map<String, LastTime>> lastTimes(
    String ownerId, {
    required LocalDate before,
    required Iterable<String> movementIds,
  }) async {
    final ids = movementIds.toSet();
    if (ids.isEmpty) return const <String, LastTime>{};
    final sets = _db.workoutSets;
    final exercises = _db.workoutExercises;
    final sessions = _db.workoutSessions;
    final query =
        _db.select(sets).join(<Join>[
            innerJoin(exercises, exercises.id.equalsExp(sets.exerciseId)),
            innerJoin(sessions, sessions.id.equalsExp(exercises.sessionId)),
          ])
          ..where(
            sessions.ownerId.equals(ownerId) &
                sessions.day.isSmallerThanValue(before.iso) &
                exercises.movementId.isIn(ids) &
                exercises.measure.equals(SetMeasure.reps.name) &
                sets.reps.isBiggerThanValue(0),
          )
          ..orderBy(<OrderingTerm>[
            OrderingTerm.desc(sessions.day),
            OrderingTerm.asc(exercises.position),
            OrderingTerm.asc(sets.position),
          ]);

    final latestDay = <String, String>{};
    final found = <String, List<LastSet>>{};
    for (final row in await query.get()) {
      final movement = row.readTable(exercises).movementId;
      final day = row.readTable(sessions).day;
      // Rows come newest day first; only that day's sets are "last time".
      if (latestDay.putIfAbsent(movement, () => day) != day) continue;
      final set = row.readTable(sets);
      found
          .putIfAbsent(movement, () => <LastSet>[])
          .add(
            LastSet(
              position: set.position,
              reps: set.reps!,
              weightLb: set.weightLb,
            ),
          );
    }
    return <String, LastTime>{
      for (final entry in found.entries)
        entry.key: LastTime(
          day: LocalDate.parse(latestDay[entry.key]!),
          sets: List<LastSet>.unmodifiable(entry.value),
        ),
    };
  }

  /// The value of [read] at once, then again after every change to a
  /// workout table. Reads run one after another, so an older read can
  /// never arrive after a newer one.
  Stream<T> _watch<T>(Future<T> Function() read) {
    return Stream<T>.multi((controller) {
      var pending = Future<void>.value();
      void emit() {
        pending = pending.then((_) async {
          if (controller.isClosed) return;
          try {
            final value = await read();
            if (!controller.isClosed) controller.add(value);
          } catch (error, stack) {
            if (!controller.isClosed) controller.addError(error, stack);
          }
        });
      }

      final updates = _db
          .tableUpdates(
            TableUpdateQuery.onAllTables(
              <ResultSetImplementation<Object?, Object?>>[
                _db.workoutSessions,
                _db.workoutExercises,
                _db.workoutSets,
              ],
            ),
          )
          .listen((_) => emit());
      emit();
      controller.onCancel = updates.cancel;
    });
  }

  Future<WorkoutSession> _session(WorkoutSessionRow row) async {
    final exerciseRows =
        await (_db.select(_db.workoutExercises)
              ..where((t) => t.sessionId.equals(row.id))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    final setRows =
        await (_db.select(_db.workoutSets)
              ..where((t) => t.exerciseId.isIn(exerciseRows.map((e) => e.id)))
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    final setsByExercise = <String, List<SessionSet>>{};
    for (final set in setRows) {
      setsByExercise
          .putIfAbsent(set.exerciseId, () => <SessionSet>[])
          .add(
            SessionSet(
              id: set.id,
              position: set.position,
              target: set.target,
              reps: set.reps,
              weightLb: set.weightLb,
              ticked: set.ticked,
            ),
          );
    }
    return WorkoutSession(
      id: row.id,
      ownerId: row.ownerId,
      day: LocalDate.parse(row.day),
      program: row.program,
      planDay: row.planDay,
      planWeek: row.planWeek,
      title: row.title,
      sessionType: row.sessionType,
      minutes: row.minutes,
      // The instants and the offsets come back as they were stored.
      startedAtUtc: DateTime.fromMillisecondsSinceEpoch(
        row.startedAtUtcMs,
        isUtc: true,
      ),
      startUtcOffset: Duration(minutes: row.startUtcOffsetMinutes),
      finishedAtUtc: row.finishedAtUtcMs == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
              row.finishedAtUtcMs!,
              isUtc: true,
            ),
      finishUtcOffset: row.finishUtcOffsetMinutes == null
          ? null
          : Duration(minutes: row.finishUtcOffsetMinutes!),
      finishEventId: row.finishEventId,
      exercises: List<SessionExercise>.unmodifiable(<SessionExercise>[
        for (final exercise in exerciseRows)
          SessionExercise(
            id: exercise.id,
            position: exercise.position,
            movementId: exercise.movementId,
            name: exercise.name,
            prescription: exercise.prescription,
            measure: SetMeasure.values.byName(exercise.measure),
            weightMode: WeightMode.values.byName(exercise.weightMode),
            restBaseSeconds: exercise.restBaseSeconds,
            restEndsAtUtc: exercise.restEndsAtUtcMs == null
                ? null
                : DateTime.fromMillisecondsSinceEpoch(
                    exercise.restEndsAtUtcMs!,
                    isUtc: true,
                  ),
            restPausedSeconds: exercise.restPausedSeconds,
            sets: List<SessionSet>.unmodifiable(
              setsByExercise[exercise.id] ?? const <SessionSet>[],
            ),
          ),
      ]),
    );
  }

  static WorkoutPlan _plan(WorkoutPlanRow row) => WorkoutPlan(
    program: row.program,
    equipment: row.equipment,
    restWeekday: row.restWeekday,
    liftWeekdays: <int>[
      for (final part in row.liftWeekdays.split(',')) int.parse(part),
    ],
    fourthDay: row.fourthDay,
    start: LocalDate.parse(row.startDay),
  );

  static WorkoutPlansCompanion _planRow(String ownerId, WorkoutPlan plan) =>
      WorkoutPlansCompanion.insert(
        ownerId: ownerId,
        program: plan.program,
        equipment: plan.equipment,
        restWeekday: plan.restWeekday,
        liftWeekdays: plan.liftWeekdays.join(','),
        fourthDay: plan.fourthDay,
        startDay: plan.start.iso,
      );
}
