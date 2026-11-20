import 'dart:io';

import 'package:drift/drift.dart';
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
    'version 1 migrates to version 3 with exactly the frozen schema',
    () async {
      final connection = await verifier.startAt(1);
      final database = AppDatabase(connection);
      addTearDown(database.close);

      await verifier.migrateAndValidate(database, 3);
    },
  );

  test('a new install is created at version 3 with the same schema', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);

    await verifier.migrateAndValidate(database, 3);

    final version = await database
        .customSelect('PRAGMA user_version')
        .getSingle();
    expect(version.read<int>('user_version'), 3);
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
      await verifier.migrateAndValidate(database, 3);

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

  test('version 2 migrates to version 3 with exactly the frozen schema, and '
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
    await verifier.migrateAndValidate(database, 3);

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
