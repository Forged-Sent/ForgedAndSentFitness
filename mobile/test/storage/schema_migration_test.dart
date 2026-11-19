import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/open_local_store_native.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/features/journal/domain/journal_entry.dart';
import 'package:forged_and_sent/src/storage/app_database.dart';
import 'package:forged_and_sent/src/storage/native_storage.dart';
import 'package:sqlite3/sqlite3.dart';

import 'generated_migrations/schema.dart';
import 'generated_migrations/schema_v1.dart' as v1;

/// The tables of schema version 1 (build step S1), exactly as Drift made
/// them: read from `sqlite_master` of a version 1 database.
const List<String> _version1 = <String>[
  'CREATE TABLE "app_settings" ("key" TEXT NOT NULL, "value" TEXT NOT NULL, '
      'PRIMARY KEY ("key"))',
  'CREATE TABLE "completion_events" ("id" TEXT NOT NULL, '
      '"owner_id" TEXT NOT NULL, "day" TEXT NOT NULL, "item" TEXT NOT NULL, '
      '"done" INTEGER NOT NULL CHECK ("done" IN (0, 1)), '
      '"counter" INTEGER NOT NULL UNIQUE, "tapped_at_utc_ms" INTEGER NOT NULL, '
      '"utc_offset_minutes" INTEGER NOT NULL, "replaces_event_id" TEXT NULL, '
      'PRIMARY KEY ("id"))',
  'CREATE TABLE "day_states" ("owner_id" TEXT NOT NULL, "day" TEXT NOT NULL, '
      '"item" TEXT NOT NULL, "done" INTEGER NOT NULL CHECK ("done" IN (0, 1)), '
      '"latest_event_id" TEXT NOT NULL, "latest_counter" INTEGER NOT NULL, '
      'PRIMARY KEY ("owner_id", "day", "item"))',
];

/// ADR-0005 left migration unproved while the schema was at version 1.
/// Build step S2 is the first change to the schema.
///
/// Each version's schema is frozen as a file in `drift_schemas/`, and the
/// first group below checks the migration against those files. When a
/// table changes, `mobile/README.md` ("Changing the database") has the
/// commands that freeze the new version and regenerate
/// `generated_migrations/`.
void main() {
  group('against the frozen schema of each version', () {
    late SchemaVerifier verifier;

    setUpAll(() => verifier = SchemaVerifier(GeneratedHelper()));

    test('version 1 migrates to exactly the frozen version 2', () async {
      final connection = await verifier.startAt(1);
      final database = AppDatabase(connection);
      addTearDown(database.close);

      await verifier.migrateAndValidate(database, 2);
    });

    test(
      'a new install is created at version 2 with the same schema',
      () async {
        final database = AppDatabase(NativeDatabase.memory());
        addTearDown(database.close);

        await verifier.migrateAndValidate(database, 2);

        final version = await database
            .customSelect('PRAGMA user_version')
            .getSingle();
        expect(version.read<int>('user_version'), 2);
      },
    );

    test('the rows of version 1 are all still there, and the journal tables '
        'are there and empty', () async {
      final schema = await verifier.schemaAt(1);
      final old = v1.DatabaseAtV1(schema.newConnection());
      await old
          .into(old.completionEvents)
          .insert(
            v1.CompletionEventsCompanion.insert(
              id: 'e1',
              ownerId: 'local-a',
              day: '2026-11-12',
              item: 'devotional',
              done: 1,
              counter: 1,
              tappedAtUtcMs: 1794483000000,
              utcOffsetMinutes: -300,
              replacesEventId: const Value(null),
            ),
          );
      await old
          .into(old.dayStates)
          .insert(
            v1.DayStatesCompanion.insert(
              ownerId: 'local-a',
              day: '2026-11-12',
              item: 'devotional',
              done: 1,
              latestEventId: 'e1',
              latestCounter: 1,
            ),
          );
      await old
          .into(old.appSettings)
          .insert(
            v1.AppSettingsCompanion.insert(
              key: 'show_preview_points',
              value: 'true',
            ),
          );
      await old.close();

      final database = AppDatabase(schema.newConnection());
      addTearDown(database.close);
      await verifier.migrateAndValidate(database, 2);

      final event =
          (await database.select(database.completionEvents).get()).single;
      expect(event.id, 'e1');
      expect(event.done, isTrue);
      expect(event.tappedAtUtcMs, 1794483000000);
      expect(event.utcOffsetMinutes, -300);
      final state = (await database.select(database.dayStates).get()).single;
      expect(
        (state.day, state.done, state.latestEventId),
        ('2026-11-12', true, 'e1'),
      );
      final setting =
          (await database.select(database.appSettings).get()).single;
      expect((setting.key, setting.value), ('show_preview_points', 'true'));
      expect(await database.select(database.journalEntries).get(), isEmpty);
      expect(await database.select(database.journalChanges).get(), isEmpty);
    });
  });

  test('a build from before the journal cannot open a version 2 file, and '
      'leaves it as it was', () async {
    final folder = await Directory.systemTemp.createTemp('fs-s2-older-');
    addTearDown(() async {
      if (await folder.exists()) await folder.delete(recursive: true);
    });
    final first = await openLocalStoreIn(folder, background: false);
    final ownerId = first.ownerId;
    await first.journal.apply(
      JournalChange.save(
        id: 'c1',
        ownerId: ownerId,
        entryId: 'j1',
        text: 'Written before the older build was tried.',
        source: JournalSource.pen,
        at: DateTime(2026, 11, 19, 7),
      ),
    );
    await first.close();

    // The S1 build: schema version 1, and no rule for a newer file.
    final older = v1.DatabaseAtV1(
      NativeDatabase(databaseFileFor(folder, ownerId)),
    );
    await expectLater(older.select(older.appSettings).get(), throwsA(anything));
    await older.close();

    // This build opens the file again and finds everything.
    final again = await openLocalStoreIn(folder, background: false);
    addTearDown(again.close);
    expect(
      (await again.journal.watchEntries(ownerId).first).single.text,
      'Written before the older build was tried.',
    );
    final check = sqlite3.open(databaseFileFor(folder, ownerId).path);
    addTearDown(check.close);
    expect(check.select('PRAGMA user_version').single.values.single, 2);
  });

  test('an update that was cut off after the first new table still opens, and '
      'finishes the job', () async {
    final folder = await Directory.systemTemp.createTemp('fs-s2-partial-');
    addTearDown(() async {
      if (await folder.exists()) await folder.delete(recursive: true);
    });
    final ownerId = await loadOrCreateLocalProfileId(folder);
    final file = databaseFileFor(folder, ownerId);

    // Version 1, plus the first journal table, with the version number
    // never moved on: what a phone that died mid-update could hold.
    final old = sqlite3.open(file.path);
    for (final table in _version1) {
      old.execute(table);
    }
    old.execute(
      'CREATE TABLE "journal_entries" ("id" TEXT NOT NULL, '
      '"owner_id" TEXT NOT NULL, "day" TEXT NOT NULL, '
      '"created_at_utc_ms" INTEGER NOT NULL, '
      '"utc_offset_minutes" INTEGER NOT NULL, "body" TEXT NOT NULL, '
      '"body_format" TEXT NOT NULL, "source" TEXT NOT NULL, '
      '"prompt" TEXT NOT NULL, "edited_at_utc_ms" INTEGER NULL, '
      '"deleted_at_utc_ms" INTEGER NULL, "revision" INTEGER NOT NULL, '
      'PRIMARY KEY ("id"))',
    );
    old.execute(
      "INSERT INTO app_settings VALUES ('show_preview_points', 'true')",
    );
    old.execute('PRAGMA user_version = 1');
    old.close();

    // Twice: the first open finishes the update, the second finds it done.
    for (var launch = 0; launch < 2; launch++) {
      final store = await openLocalStoreIn(folder, background: false);
      expect(await store.settings.watchShowPreviewPoints().first, isTrue);
      await store.journal.apply(
        JournalChange.save(
          id: 'c$launch',
          ownerId: ownerId,
          entryId: 'j$launch',
          text: 'Entry $launch.',
          source: JournalSource.pen,
          at: DateTime(2026, 11, 19, 7, launch),
        ),
      );
      expect(
        await store.journal.watchEntries(ownerId).first,
        hasLength(launch + 1),
      );
      await store.close();
    }

    final check = sqlite3.open(file.path);
    addTearDown(check.close);
    expect(check.select('PRAGMA user_version').single.values.single, 2);
  });

  test(
    'a database from build step S1 gains the journal and keeps what it had',
    () async {
      final folder = await Directory.systemTemp.createTemp('fs-s2-migrate-');
      addTearDown(() async {
        if (await folder.exists()) await folder.delete(recursive: true);
      });
      final ownerId = await loadOrCreateLocalProfileId(folder);
      final file = databaseFileFor(folder, ownerId);

      // A phone that ran S1: one devotional done, one setting changed.
      final old = sqlite3.open(file.path);
      for (final table in _version1) {
        old.execute(table);
      }
      old.execute(
        'INSERT INTO completion_events VALUES '
        "('e1', ?, '2026-11-12', 'devotional', 1, 1, 1794483000000, -300, NULL)",
        <Object?>[ownerId],
      );
      old.execute(
        'INSERT INTO day_states VALUES '
        "(?, '2026-11-12', 'devotional', 1, 'e1', 1)",
        <Object?>[ownerId],
      );
      old.execute(
        "INSERT INTO app_settings VALUES ('show_preview_points', 'true')",
      );
      old.execute('PRAGMA user_version = 1');
      old.close();

      final store = await openLocalStoreIn(folder, background: false);
      addTearDown(store.close);

      // What S1 saved is still there.
      const nov12 = LocalDate(2026, 11, 12);
      final day = await store.days.watchDay(ownerId, nov12).first;
      expect(day.isDone('devotional'), isTrue);
      expect(
        await store.days.eventsFor(ownerId, nov12, 'devotional'),
        hasLength(1),
      );
      expect(await store.settings.watchShowPreviewPoints().first, isTrue);

      // And the journal works.
      expect(await store.journal.watchEntries(ownerId).first, isEmpty);
      await store.journal.apply(
        JournalChange.save(
          id: 'c1',
          ownerId: ownerId,
          entryId: 'j1',
          text: 'First entry after the update.',
          source: JournalSource.pen,
          at: DateTime(2026, 11, 19, 7),
        ),
      );
      expect(
        (await store.journal.watchEntries(ownerId).first).single.text,
        'First entry after the update.',
      );
      await store.close();

      final check = sqlite3.open(file.path);
      addTearDown(check.close);
      expect(check.select('PRAGMA user_version').single.values.single, 2);
    },
  );
}
