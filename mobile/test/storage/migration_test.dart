import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/open_local_store_native.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/features/today/domain/completion_event.dart';
import 'package:forged_and_sent/src/features/workout/domain/workout_plan.dart';
import 'package:forged_and_sent/src/storage/app_database.dart';
import 'package:forged_and_sent/src/storage/native_storage.dart';

import '../features/workout/workout_repository_contract.dart';
import 'generated_migrations/schema.dart';
import 'generated_migrations/schema_v1.dart' as v1;
import 'generated_migrations/schema_v2.dart' as v2;
import 'generated_migrations/schema_v3.dart' as v3;

/// Schema migrations, tested against the frozen schema of every version
/// in `drift_schemas/`.
///
/// When a table changes:
/// 1. raise `schemaVersion` and add a step to `_upgradeSteps` in
///    `app_database.dart`;
/// 2. `dart run build_runner build`;
/// 3. `dart run drift_dev schema dump lib/src/storage/app_database.dart drift_schemas/`;
/// 4. `dart run drift_dev schema steps drift_schemas/ lib/src/storage/app_database.steps.dart`;
/// 5. `dart run drift_dev schema generate --data-classes --companions drift_schemas/ test/storage/generated_migrations/`;
/// 6. add the new version to the tests below.
void main() {
  late SchemaVerifier verifier;

  setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

  /// What a member who used build step S1 has in his file: the devotional
  /// checked on one day, checked and cleared on another, and the preview
  /// points switch turned on.
  Future<void> writeS1Rows(v1.DatabaseAtV1 old, {required String owner}) async {
    Future<void> event(
      String id,
      String day,
      int counter, {
      required bool done,
      String? replaces,
    }) => old
        .into(old.completionEvents)
        .insert(
          v1.CompletionEventsCompanion.insert(
            id: id,
            ownerId: owner,
            day: day,
            item: 'devotional',
            done: done ? 1 : 0,
            counter: counter,
            tappedAtUtcMs: 1794560000000 + counter,
            utcOffsetMinutes: -300,
            replacesEventId: Value(replaces),
          ),
        );
    Future<void> state(String day, String latest, int counter, bool done) => old
        .into(old.dayStates)
        .insert(
          v1.DayStatesCompanion.insert(
            ownerId: owner,
            day: day,
            item: 'devotional',
            done: done ? 1 : 0,
            latestEventId: latest,
            latestCounter: counter,
          ),
        );

    await event('e1', '2026-11-11', 1, done: true);
    await state('2026-11-11', 'e1', 1, true);
    await event('e2', '2026-11-12', 2, done: true);
    await event('e3', '2026-11-12', 3, done: false, replaces: 'e2');
    await state('2026-11-12', 'e3', 3, false);
    await old
        .into(old.appSettings)
        .insert(
          v1.AppSettingsCompanion.insert(
            key: 'show_preview_points',
            value: 'true',
          ),
        );
  }

  test(
    'version 1 migrates to version 4 with exactly the frozen schema',
    () async {
      final connection = await verifier.startAt(1);
      final database = AppDatabase(connection);
      addTearDown(database.close);

      await verifier.migrateAndValidate(database, 4);
    },
  );

  test('a new install is created at version 4 with the same schema', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await verifier.migrateAndValidate(database, 4);

    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.read<int>('user_version'), 4);
  });

  test(
    'the rows of version 1 are all still there after the migration',
    () async {
      final schema = await verifier.schemaAt(1);
      final old = v1.DatabaseAtV1(schema.newConnection());
      await writeS1Rows(old, owner: 'local-a');
      await old.close();

      final database = AppDatabase(schema.newConnection());
      addTearDown(database.close);
      await verifier.migrateAndValidate(database, 4);

      final events = await (database.select(
        database.completionEvents,
      )..orderBy([(t) => OrderingTerm.asc(t.counter)])).get();
      expect(events.map((e) => e.id), <String>['e1', 'e2', 'e3']);
      expect(events.map((e) => e.done), <bool>[true, true, false]);
      expect(events.map((e) => e.day), <String>[
        '2026-11-11',
        '2026-11-12',
        '2026-11-12',
      ]);
      expect(events.last.replacesEventId, 'e2');
      expect(events.first.tappedAtUtcMs, 1794560000001);
      expect(events.first.utcOffsetMinutes, -300);

      final states = await (database.select(
        database.dayStates,
      )..orderBy([(t) => OrderingTerm.asc(t.day)])).get();
      expect(
        states.map((s) => (s.day, s.done, s.latestEventId)),
        <(String, bool, String)>[
          ('2026-11-11', true, 'e1'),
          ('2026-11-12', false, 'e3'),
        ],
      );

      final settings = await database.select(database.appSettings).get();
      expect(settings.single.key, 'show_preview_points');
      expect(settings.single.value, 'true');

      // The new tables are there and empty.
      expect(await database.select(database.workoutPlans).get(), isEmpty);
      expect(await database.select(database.workoutSessions).get(), isEmpty);
      expect(await database.select(database.workoutExercises).get(), isEmpty);
      expect(await database.select(database.workoutSets).get(), isEmpty);
    },
  );

  test('version 2 migrates to version 4 with exactly the frozen schema, and '
      'the journal and the rows of version 1 are all still there', () async {
    final schema = await verifier.schemaAt(2);
    final old = v2.DatabaseAtV2(schema.newConnection());
    await old.customStatement(
      'INSERT INTO completion_events VALUES '
      "('e1', 'local-a', '2026-11-12', 'devotional', 1, 1, 1794483000000, "
      '-300, NULL)',
    );
    await old.customStatement(
      'INSERT INTO day_states VALUES '
      "('local-a', '2026-11-12', 'devotional', 1, 'e1', 1)",
    );
    await old.customStatement(
      "INSERT INTO app_settings VALUES ('show_preview_points', 'true')",
    );
    await old.customStatement(
      'INSERT INTO journal_entries (id, owner_id, day, created_at_utc_ms, '
      'utc_offset_minutes, body, body_format, source, prompt, '
      'edited_at_utc_ms, deleted_at_utc_ms, revision) VALUES '
      "('j1', 'local-a', '2026-11-19', 1795089600000, -420, "
      "'Written before the workout tables.', 'plain', 'pen', '', NULL, NULL, 1)",
    );
    await old.customStatement(
      'INSERT INTO journal_changes (id, owner_id, entry_id, kind, revision, '
      'counter, at_utc_ms, utc_offset_minutes) VALUES '
      "('c1', 'local-a', 'j1', 'save', 1, 1, 1795089600000, -420)",
    );
    await old.close();

    final database = AppDatabase(schema.newConnection());
    addTearDown(database.close);
    await verifier.migrateAndValidate(database, 4);

    final entry = (await database.select(database.journalEntries).get()).single;
    expect(
      (entry.id, entry.ownerId, entry.day, entry.body, entry.revision),
      ('j1', 'local-a', '2026-11-19', 'Written before the workout tables.', 1),
    );
    expect(entry.createdAtUtcMs, 1795089600000);
    final change =
        (await database.select(database.journalChanges).get()).single;
    expect((change.id, change.entryId, change.kind), ('c1', 'j1', 'save'));
    final event =
        (await database.select(database.completionEvents).get()).single;
    expect((event.id, event.done), ('e1', true));
    final state = (await database.select(database.dayStates).get()).single;
    expect((state.day, state.latestEventId), ('2026-11-12', 'e1'));
    final setting = (await database.select(database.appSettings).get()).single;
    expect((setting.key, setting.value), ('show_preview_points', 'true'));

    // The new tables are there and empty.
    expect(await database.select(database.workoutPlans).get(), isEmpty);
    expect(await database.select(database.workoutSessions).get(), isEmpty);
    expect(await database.select(database.workoutExercises).get(), isEmpty);
    expect(await database.select(database.workoutSets).get(), isEmpty);
  });

  /// What a member who used build step S3 has in his file: one workout in
  /// progress, with two exercises and a set logged. Written as that build
  /// wrote it: the sessions table has no superset column yet.
  Future<void> writeS3Workout(
    v3.DatabaseAtV3 old, {
    required String owner,
  }) async {
    await old.customStatement(
      'INSERT INTO workout_sessions (id, owner_id, day, program, plan_day, '
      'plan_week, title, session_type, minutes, started_at_utc_ms, '
      'start_utc_offset_minutes, finished_at_utc_ms, '
      'finish_utc_offset_minutes, finish_event_id) VALUES '
      "('s1', ?, '2026-11-09', 'Forged', 1, 1, 'Full Body A: Back Squat', "
      "'Core', 45, 1794272400000, -420, NULL, NULL, 's1-finish')",
      <Object?>[owner],
    );
    await old.customStatement(
      'INSERT INTO workout_exercises (id, session_id, position, movement_id, '
      'name, prescription, measure, weight_mode, rest_base_seconds, '
      'rest_ends_at_utc_ms, rest_paused_seconds) VALUES '
      "('e0', 's1', 0, 'Cable Curl', 'Cable Curl', "
      "'Superset A1: 3 x 12 (RIR 3). Go straight to A2', 'reps', 'required', "
      "90, NULL, NULL), "
      "('e1', 's1', 1, 'Overhead Triceps Extension', "
      "'Cable Overhead Triceps Extension', "
      "'Superset A2: 3 x 12 (RIR 3). Rest 45 to 60 sec, then back to A1', "
      "'reps', 'required', 60, NULL, NULL)",
    );
    await old.customStatement(
      'INSERT INTO workout_sets (id, exercise_id, position, target, reps, '
      'weight_lb, ticked) VALUES '
      "('e0-s0', 'e0', 0, '12', 12, 40.0, 0), ('e0-s1', 'e0', 1, '12', NULL, "
      "NULL, 0), ('e1-s0', 'e1', 0, '12', NULL, NULL, 0)",
    );
  }

  test('version 3 migrates to version 4 with exactly the frozen schema: a '
      'workout already in the file is as it was, and its new column is '
      'empty', () async {
    final schema = await verifier.schemaAt(3);
    final old = v3.DatabaseAtV3(schema.newConnection());
    await writeS3Workout(old, owner: 'local-a');
    await old.close();

    final database = AppDatabase(schema.newConnection());
    addTearDown(database.close);
    await verifier.migrateAndValidate(database, 4);

    final session =
        (await database.select(database.workoutSessions).get()).single;
    expect(
      (session.id, session.ownerId, session.day, session.planDay),
      ('s1', 'local-a', '2026-11-09', 1),
    );
    expect(session.title, 'Full Body A: Back Squat');
    expect(session.startedAtUtcMs, 1794272400000);
    expect(session.finishedAtUtcMs, isNull);
    expect(session.finishEventId, 's1-finish');
    // The row was started without a mark and is not given one.
    expect(session.supersetPlaces, isNull);

    final exercises = await (database.select(
      database.workoutExercises,
    )..orderBy([(t) => OrderingTerm.asc(t.position)])).get();
    expect(exercises.map((e) => (e.id, e.movementId, e.restBaseSeconds)), [
      ('e0', 'Cable Curl', 90),
      ('e1', 'Overhead Triceps Extension', 60),
    ]);
    final sets = await (database.select(
      database.workoutSets,
    )..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
    expect(sets.map((s) => (s.id, s.reps, s.weightLb)), [
      ('e0-s0', 12, 40.0),
      ('e0-s1', null, null),
      ('e1-s0', null, null),
    ]);
  });

  test('a version 3 file on disk opens in this build as the app opens it: '
      'the workout he started is still his to log, with no superset group, '
      'and the next one he starts keeps its mark', () async {
    final folder = await Directory.systemTemp.createTemp('fs-v4-migrate-');
    addTearDown(() async {
      if (await folder.exists()) await folder.delete(recursive: true);
    });
    // The file an S3 build left behind: version 3, under his profile id.
    final owner = await loadOrCreateLocalProfileId(folder);
    final file = databaseFileFor(folder, owner);
    final old = v3.DatabaseAtV3(NativeDatabase(file));
    await writeS3Workout(old, owner: owner);
    expect(
      (await old.customSelect('PRAGMA user_version').getSingle()).read<int>(
        'user_version',
      ),
      3,
    );
    await old.close();

    // This build starts: the same call `main` makes.
    final store = await openLocalStoreIn(folder, background: false);
    addTearDown(store.close);
    const nov9 = LocalDate(2026, 11, 9);

    final before = (await store.workouts.watchSession(owner, nov9).first)!;
    expect(before.finished, isFalse);
    expect(before.exercises.first.sets.first.reps, 12);
    expect(before.exercises.first.sets.first.weightLb, 40);
    // Its prescriptions say "Superset", and still it has no mark: the
    // update does not fill one in.
    expect(before.superset, isEmpty);
    expect(before.supersetLabels, <String?>[null, null]);

    // It can still be logged and finished.
    await store.workouts.setReps('e0-s1', 11);
    await store.workouts.finishSession('s1', DateTime.utc(2026, 11, 10, 2));
    final after = (await store.workouts.watchSession(owner, nov9).first)!;
    expect(after.finished, isTrue);
    expect(after.finishedAtUtc!.isAfter(after.startedAtUtc), isTrue);
    expect(after.exercises.first.sets[1].reps, 11);
    expect(after.superset, isEmpty);

    // A workout started by this build keeps its mark.
    await store.workouts.startSession(
      newSession(
        's2',
        DateTime(2026, 11, 12, 18, 10),
        owner: owner,
        superset: <int>[0, 1],
      ),
    );
    expect(
      (await store.workouts.watchSession(owner, nov12).first)!.superset,
      <int>[0, 1],
    );
  });

  test('a version 1 file on disk opens in this build as the app opens it: '
      'what he checked is still checked, and he can log a workout', () async {
    final folder = await Directory.systemTemp.createTemp('fs-s3-migrate-');
    addTearDown(() async {
      if (await folder.exists()) await folder.delete(recursive: true);
    });
    // The file an S1 build left behind: version 1, under his profile id.
    final owner = await loadOrCreateLocalProfileId(folder);
    final file = databaseFileFor(folder, owner);
    final old = v1.DatabaseAtV1(NativeDatabase(file));
    await writeS1Rows(old, owner: owner);
    expect(
      (await old.customSelect('PRAGMA user_version').getSingle()).read<int>(
        'user_version',
      ),
      1,
    );
    await old.close();

    // The S3 build starts: the same call `main` makes.
    final store = await openLocalStoreIn(folder, background: false);
    addTearDown(store.close);

    expect(store.ownerId, owner);
    const nov11 = LocalDate(2026, 11, 11);
    expect(
      (await store.days.watchDay(owner, nov11).first).isDone(
        DayItems.devotional,
      ),
      isTrue,
    );
    expect(
      (await store.days.watchDay(owner, nov12).first).isDone(
        DayItems.devotional,
      ),
      isFalse,
    );
    expect(
      await store.days.eventsFor(owner, nov12, DayItems.devotional),
      hasLength(2),
    );
    expect(await store.days.watchDoneByDay(owner).first, {
      nov11: {DayItems.devotional},
    });
    expect(await store.settings.watchShowPreviewPoints().first, isTrue);

    // The counter carries on from where version 1 left it, and the new
    // tables work.
    await store.workouts.ensurePlan(
      owner,
      () => WorkoutPlan.startingFor(nov12),
    );
    await store.workouts.startSession(
      newSession('s1', DateTime(2026, 11, 12, 18, 10), owner: owner),
    );
    await store.workouts.setReps('s1-squat-s0', 5);
    await store.workouts.finishSession('s1', DateTime(2026, 11, 12, 18, 52));
    final day = await store.days.watchDay(owner, nov12).first;
    expect(day.isDone(DayItems.workout), isTrue);
    expect(day.items[DayItems.workout]!.latestCounter, 4);
  });

  test('a migrated file opens again without migrating twice', () async {
    final folder = await Directory.systemTemp.createTemp('fs-s3-migrate-');
    addTearDown(() async {
      if (await folder.exists()) await folder.delete(recursive: true);
    });
    final owner = await loadOrCreateLocalProfileId(folder);
    final old = v1.DatabaseAtV1(NativeDatabase(databaseFileFor(folder, owner)));
    await writeS1Rows(old, owner: owner);
    await old.close();

    final first = await openLocalStoreIn(folder, background: false);
    await first.workouts.startSession(
      newSession('s1', DateTime(2026, 11, 12, 18, 10), owner: owner),
    );
    await first.close();

    final second = await openLocalStoreIn(folder, background: false);
    addTearDown(second.close);
    expect((await second.workouts.watchSession(owner, nov12).first)!.id, 's1');
    expect(
      await second.days.eventsFor(owner, nov12, DayItems.devotional),
      hasLength(2),
    );
  });
}
