import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/open_local_store_native.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/features/journal/domain/journal_entry.dart';
import 'package:forged_and_sent/src/storage/native_storage.dart';
import 'package:sqlite3/sqlite3.dart';

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
void main() {
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
