import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/open_local_store_native.dart';
import 'package:forged_and_sent/src/features/today/data/drift_day_repository.dart';
import 'package:forged_and_sent/src/features/today/domain/completion_event.dart';
import 'package:forged_and_sent/src/features/workout/data/drift_workout_repository.dart';
import 'package:forged_and_sent/src/features/workout/domain/workout_plan.dart';
import 'package:forged_and_sent/src/storage/app_database.dart';
import 'package:forged_and_sent/src/storage/native_storage.dart';

import 'workout_repository_contract.dart';

/// A folder that is deleted when the test ends.
Future<Directory> temporaryFolder() async {
  final folder = await Directory.systemTemp.createTemp('fs-s3-test-');
  addTearDown(() async {
    if (await folder.exists()) await folder.delete(recursive: true);
  });
  return folder;
}

void main() {
  group('DriftWorkoutRepository', () {
    workoutRepositoryContract(() async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      final days = DriftDayRepository(database);
      return (workouts: DriftWorkoutRepository(database, days), days: days);
    });
  });

  group('DriftWorkoutRepository on a real SQLite file', () {
    test('kill mid-set and relaunch: every entered set is there and the '
        'clock is right (P07 acceptance 1)', () async {
      final folder = await temporaryFolder();
      final first = await openLocalStoreIn(folder, background: false);
      final owner = first.ownerId;
      expect(first.workouts.durable, isTrue);

      final started = DateTime(2026, 11, 12, 18, 10);
      await first.workouts.ensurePlan(
        owner,
        () => WorkoutPlan.startingFor(nov12),
      );
      await first.workouts.startSession(
        newSession('s1', started, owner: owner),
      );
      await first.workouts.setReps('s1-squat-s0', 5);
      await first.workouts.setWeight('s1-squat-s0', 135);
      await first.workouts.setReps('s1-squat-s1', 5);
      await first.workouts.setWeight('s1-squat-s1', 137.5);
      // Mid-set: the third set has its reps and not yet its weight.
      await first.workouts.setReps('s1-squat-s2', 4);
      final restEnds = DateTime.utc(2026, 11, 13, 0, 30);
      await first.workouts.setRest(
        's1-squat',
        baseSeconds: 120,
        endsAtUtc: restEnds,
      );

      // The app is killed: its database is never closed. A new process
      // opens the same file. Drift warns about two databases in one
      // process; here that is the point.
      driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;
      addTearDown(
        () => driftRuntimeOptions.dontWarnAboutMultipleDatabases = false,
      );
      final relaunched = await openLocalStoreIn(folder, background: false);
      addTearDown(first.close);
      addTearDown(relaunched.close);

      expect(relaunched.ownerId, owner);
      final session = (await relaunched.workouts
          .watchSession(owner, nov12)
          .first)!;
      expect(session.finished, isFalse);
      final squat = session.exercises.first;
      expect(squat.sets.map((s) => (s.reps, s.weightLb)), <(int?, double?)>[
        (5, 135),
        (5, 137.5),
        (4, null),
      ]);
      expect(squat.movementId, 'Back Squat');
      expect(squat.prescription, '3 x 5 (RPE 7, rest 2 min)');
      // The clock is worked out from the stored start, so it has kept
      // running while the app was gone.
      expect(session.startedAtUtc, started.toUtc());
      expect(
        session.elapsedAt(started.add(const Duration(minutes: 17, seconds: 5))),
        const Duration(minutes: 17, seconds: 5),
      );
      // So has the rest timer.
      expect(squat.restEndsAtUtc, restEnds);
      expect(
        squat.restAt(restEnds.subtract(const Duration(seconds: 45))).left,
        45,
      );
      expect(
        (await relaunched.workouts.watchOpenSession(owner).first)!.id,
        's1',
      );
      expect((await relaunched.workouts.watchPlan(owner).first)!.start, nov9);
    });

    test('finish, close the database, reopen: finished, and the Workout '
        'box is checked', () async {
      final folder = await temporaryFolder();
      final first = await openLocalStoreIn(folder, background: false);
      final owner = first.ownerId;
      await first.workouts.startSession(
        newSession('s1', DateTime(2026, 11, 12, 18, 10), owner: owner),
      );
      await first.workouts.finishSession('s1', DateTime(2026, 11, 12, 18, 52));
      await first.close();

      final reopened = await openLocalStoreIn(folder, background: false);
      addTearDown(reopened.close);

      final session = (await reopened.workouts
          .watchSession(owner, nov12)
          .first)!;
      expect(session.finished, isTrue);
      expect(
        (await reopened.days.watchDay(owner, nov12).first).isDone(
          DayItems.workout,
        ),
        isTrue,
      );
      // Finishing again after a reopen still records nothing more.
      await reopened.workouts.finishSession('s1', DateTime(2026, 11, 13, 7));
      expect(
        await reopened.days.eventsFor(owner, nov12, DayItems.workout),
        hasLength(1),
      );
    });

    test('if the Workout box cannot be checked, the session is not '
        'finished either', () async {
      final folder = await temporaryFolder();
      final database = openAppDatabase(
        File('${folder.path}/atomic.sqlite'),
        background: false,
      );
      addTearDown(database.close);
      final days = DriftDayRepository(database);
      final workouts = DriftWorkoutRepository(database, days);
      await workouts.startSession(
        newSession('s1', DateTime(2026, 11, 12, 18, 10)),
      );
      await database.customStatement(
        'CREATE TRIGGER refuse_day_state BEFORE INSERT ON day_states '
        "BEGIN SELECT RAISE(ABORT, 'refused by the test'); END;",
      );

      await expectLater(
        workouts.finishSession('s1', DateTime(2026, 11, 12, 18, 52)),
        throwsA(anything),
      );

      final session = (await workouts.watchSession(ownerA, nov12).first)!;
      expect(session.finished, isFalse);
      expect(await database.select(database.completionEvents).get(), isEmpty);
      expect(await database.select(database.dayStates).get(), isEmpty);
    });

    test('a session and its exercises and sets are stored together', () async {
      final folder = await temporaryFolder();
      final database = openAppDatabase(
        File('${folder.path}/together.sqlite'),
        background: false,
      );
      addTearDown(database.close);
      final workouts = DriftWorkoutRepository(
        database,
        DriftDayRepository(database),
      );
      // Create the schema, then make every write of a set fail.
      await database.select(database.workoutSets).get();
      await database.customStatement(
        'CREATE TRIGGER refuse_set BEFORE INSERT ON workout_sets '
        "BEGIN SELECT RAISE(ABORT, 'refused by the test'); END;",
      );

      await expectLater(
        workouts.startSession(newSession('s1', DateTime(2026, 11, 12, 18, 10))),
        throwsA(anything),
      );

      expect(await database.select(database.workoutSessions).get(), isEmpty);
      expect(await database.select(database.workoutExercises).get(), isEmpty);
    });

    test('the database refuses a set that belongs to no exercise', () async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);

      await expectLater(
        database
            .into(database.workoutSets)
            .insert(
              WorkoutSetsCompanion.insert(
                id: 'orphan',
                exerciseId: 'no-such-exercise',
                position: 0,
                target: '5',
              ),
            ),
        throwsA(anything),
      );
    });
  });
}
