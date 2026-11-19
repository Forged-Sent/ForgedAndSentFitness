import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/open_local_store_native.dart';
import 'package:forged_and_sent/src/features/journal/data/drift_journal_repository.dart';
import 'package:forged_and_sent/src/features/journal/data/journal_body_codec.dart';
import 'package:forged_and_sent/src/features/journal/domain/journal_entry.dart';
import 'package:forged_and_sent/src/storage/app_database.dart';
import 'package:forged_and_sent/src/storage/native_storage.dart';

import 'journal_repository_contract.dart';

/// A folder that is deleted when the test ends.
Future<Directory> temporaryFolder() async {
  final folder = await Directory.systemTemp.createTemp('fs-s2-test-');
  addTearDown(() async {
    if (await folder.exists()) await folder.delete(recursive: true);
  });
  return folder;
}

/// A database in a real file in a temporary folder.
Future<AppDatabase> fileDatabase(String name) async {
  final folder = await temporaryFolder();
  final database = openAppDatabase(
    File('${folder.path}/$name.sqlite'),
    background: false,
  );
  addTearDown(database.close);
  return database;
}

/// A stand-in for a codec that encrypts: it stores the text backwards.
class _ReversingCodec implements JournalBodyCodec {
  const _ReversingCodec();

  @override
  String get format => 'reversed-test';

  @override
  String encode(String text) =>
      String.fromCharCodes(text.runes.toList().reversed);

  @override
  String decode(String stored, String format) => format == this.format
      ? String.fromCharCodes(stored.runes.toList().reversed)
      : const PlainJournalBodyCodec().decode(stored, format);
}

void main() {
  group('DriftJournalRepository', () {
    journalRepositoryContract(() async {
      final database = AppDatabase(NativeDatabase.memory());
      addTearDown(database.close);
      return DriftJournalRepository(database);
    });
  });

  group('DriftJournalRepository on a real SQLite file', () {
    test('save, close the database, reopen: the entry is there '
        '(P06 acceptance 1)', () async {
      final folder = await temporaryFolder();
      final first = await openLocalStoreIn(folder, background: false);
      final ownerId = first.ownerId;
      expect(first.journal.durable, isTrue);

      await first.journal.apply(
        saveOf('c1', 'j1', 'My truck.', ownerId: ownerId),
      );
      await first.close();

      final reopened = await openLocalStoreIn(folder, background: false);
      addTearDown(reopened.close);

      expect(reopened.ownerId, ownerId);
      final entry = (await reopened.journal.watchEntries(ownerId).first).single;
      expect(entry.id, 'j1');
      expect(entry.text, 'My truck.');
      expect(entry.day, nov12);
      expect(entry.source, JournalSource.devotional);
      expect(entry.prompt, 'What possession has too much of your heart?');
    });

    test(
      'an edit and a delete both survive a restart (P06 acceptance 3)',
      () async {
        final folder = await temporaryFolder();
        var store = await openLocalStoreIn(folder, background: false);
        final ownerId = store.ownerId;
        await store.journal.apply(saveOf('c1', 'j1', 'keep', ownerId: ownerId));
        await store.journal.apply(saveOf('c2', 'j2', 'drop', ownerId: ownerId));
        await store.close();

        store = await openLocalStoreIn(folder, background: false);
        await store.journal.apply(
          saveOf(
            'c3',
            'j1',
            'keep, edited',
            ownerId: ownerId,
            at: DateTime(2026, 11, 13, 7),
          ),
        );
        await store.journal.apply(deleteOf('c4', 'j2', ownerId: ownerId));
        await store.close();

        store = await openLocalStoreIn(folder, background: false);
        addTearDown(store.close);
        final entry = (await store.journal.watchEntries(ownerId).first).single;
        expect(entry.id, 'j1');
        expect(entry.text, 'keep, edited');
        expect(entry.revision, 2);
        expect(entry.editedAtUtc, DateTime(2026, 11, 13, 7).toUtc());
        expect(await store.journal.entry(ownerId, 'j2'), isNull);
        // A deleted entry stays deleted after the restart too.
        expect(
          await store.journal.apply(
            saveOf('c5', 'j2', 'back', ownerId: ownerId),
          ),
          JournalOutcome.entryGone,
        );
      },
    );

    test('replaying a change after a reopen still applies it once', () async {
      final folder = await temporaryFolder();
      final first = await openLocalStoreIn(folder, background: false);
      final change = saveOf('c1', 'j1', 'My truck.', ownerId: first.ownerId);
      await first.journal.apply(change);
      await first.close();

      final reopened = await openLocalStoreIn(folder, background: false);
      addTearDown(reopened.close);

      expect(await reopened.journal.apply(change), JournalOutcome.duplicate);
      expect(
        await reopened.journal.changesFor(reopened.ownerId, 'j1'),
        hasLength(1),
      );
    });

    test('the change and its entry are stored together', () async {
      final database = await fileDatabase('together');
      final journal = DriftJournalRepository(database);

      await journal.apply(saveOf('c1', 'j1', 'My truck.'));

      final entries = await database.select(database.journalEntries).get();
      final changes = await database.select(database.journalChanges).get();
      expect(entries, hasLength(1));
      expect(changes, hasLength(1));
      expect(changes.single.entryId, entries.single.id);
      expect(changes.single.revision, entries.single.revision);
      expect(entries.single.day, '2026-11-12');
      expect(entries.single.bodyFormat, 'plain-v1');
    });

    test('a save that fails stores nothing, and the retry stores exactly one '
        'entry (P06 acceptance 2)', () async {
      final database = await fileDatabase('atomic');
      final journal = DriftJournalRepository(database);
      // Create the schema, then make every write to the change list fail.
      // It is the second write of the transaction, so the entry has
      // already been written when it fails.
      await database.select(database.journalChanges).get();
      await database.customStatement(
        'CREATE TRIGGER refuse_change BEFORE INSERT ON journal_changes '
        "BEGIN SELECT RAISE(ABORT, 'refused by the test'); END;",
      );

      await expectLater(
        journal.apply(saveOf('c1', 'j1', 'My truck.')),
        throwsA(anything),
      );
      expect(await database.select(database.journalEntries).get(), isEmpty);
      expect(await database.select(database.journalChanges).get(), isEmpty);
      expect(await journal.watchEntries(owner).first, isEmpty);

      // The disk is fine again. The retry carries the same entry id.
      await database.customStatement('DROP TRIGGER refuse_change');
      expect(
        await journal.apply(saveOf('c2', 'j1', 'My truck.')),
        JournalOutcome.applied,
      );
      expect(
        await database.select(database.journalEntries).get(),
        hasLength(1),
      );
      expect(
        (await journal.watchEntries(owner).first).single.text,
        'My truck.',
      );
    });

    test('a failed edit leaves the entry as it was', () async {
      final database = await fileDatabase('edit');
      final journal = DriftJournalRepository(database);
      await journal.apply(saveOf('c1', 'j1', 'as it was'));
      await database.customStatement(
        'CREATE TRIGGER refuse_change BEFORE INSERT ON journal_changes '
        "BEGIN SELECT RAISE(ABORT, 'refused by the test'); END;",
      );

      await expectLater(
        journal.apply(saveOf('c2', 'j1', 'changed')),
        throwsA(anything),
      );
      await expectLater(journal.apply(deleteOf('c3', 'j1')), throwsA(anything));

      final entry = (await journal.watchEntries(owner).first).single;
      expect(entry.text, 'as it was');
      expect(entry.revision, 1);
    });

    test('deleting removes the words from the row, and the question', () async {
      final database = await fileDatabase('delete');
      final journal = DriftJournalRepository(database);
      await journal.apply(saveOf('c1', 'j1', 'words to remove'));
      await journal.apply(deleteOf('c2', 'j1'));

      final row = (await database.select(database.journalEntries).get()).single;
      expect(row.body, isEmpty);
      expect(row.prompt, isEmpty);
      expect(row.deletedAtUtcMs, isNotNull);
      expect(row.revision, 2);
    });

    test(
      'printing a row read from the database does not show its words',
      () async {
        final database = await fileDatabase('print');
        await DriftJournalRepository(
          database,
        ).apply(saveOf('c1', 'j1', 'words-that-stay-private'));

        final row =
            (await database.select(database.journalEntries).get()).single;
        expect(row.body, 'words-that-stay-private');
        expect(row.toString(), isNot(contains('words-that-stay-private')));
        expect(row.toString(), isNot(contains('possession')));
        expect(row.toString(), contains('23 stored characters'));
      },
    );

    test('the change list has no column that could hold text', () async {
      final database = await fileDatabase('columns');
      await database.select(database.journalChanges).get();
      final columns = await database
          .customSelect('PRAGMA table_info(journal_changes)')
          .get();
      expect(columns.map((c) => c.data['name']), <String>[
        'id',
        'owner_id',
        'entry_id',
        'kind',
        'revision',
        'counter',
        'at_utc_ms',
        'utc_offset_minutes',
      ]);
    });
  });

  group('the stored form of the text (decision Q8: ready for encryption)', () {
    test(
      'a different codec changes what is in the file, not what he reads',
      () async {
        final database = await fileDatabase('codec');
        final journal = DriftJournalRepository(
          database,
          codec: const _ReversingCodec(),
        );

        await journal.apply(saveOf('c1', 'j1', 'My truck.'));

        final row =
            (await database.select(database.journalEntries).get()).single;
        expect(row.body, '.kcurt yM');
        expect(row.bodyFormat, 'reversed-test');
        expect(
          (await journal.watchEntries(owner).first).single.text,
          'My truck.',
        );
      },
    );

    test(
      'a later codec still reads rows the pilot wrote, and re-writes them',
      () async {
        final database = await fileDatabase('upgrade');
        await DriftJournalRepository(
          database,
        ).apply(saveOf('c1', 'j1', 'written plain'));

        final later = DriftJournalRepository(
          database,
          codec: const _ReversingCodec(),
        );
        expect(
          (await later.watchEntries(owner).first).single.text,
          'written plain',
        );
        await later.apply(saveOf('c2', 'j1', 'written again'));
        final row =
            (await database.select(database.journalEntries).get()).single;
        expect(row.bodyFormat, 'reversed-test');
        expect(
          (await later.watchEntries(owner).first).single.text,
          'written again',
        );
      },
    );

    test(
      'a row in a form this build cannot read is an error, not garbage',
      () async {
        final database = await fileDatabase('unknown');
        final journal = DriftJournalRepository(database);
        await journal.apply(saveOf('c1', 'j1', 'My truck.'));
        await database.customStatement(
          "UPDATE journal_entries SET body_format = 'from-the-future'",
        );

        await expectLater(
          journal.entry(owner, 'j1'),
          throwsA(isA<JournalFormatException>()),
        );
        await expectLater(
          journal.watchEntries(owner).first,
          throwsA(isA<JournalFormatException>()),
        );
        expect(
          const JournalFormatException('from-the-future').toString(),
          isNot(contains('My truck')),
        );
      },
    );
  });
}
