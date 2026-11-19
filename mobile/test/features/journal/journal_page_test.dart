import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/local_store.dart';
import 'package:forged_and_sent/src/design/fs_button.dart';
import 'package:forged_and_sent/src/design/fs_hero_header.dart';
import 'package:forged_and_sent/src/features/journal/domain/journal_entry.dart';
import 'package:forged_and_sent/src/features/journal/presentation/journal_entry_page.dart';
import 'package:forged_and_sent/src/features/journal/presentation/journal_page.dart';
import 'package:forged_and_sent/src/features/settings/presentation/settings_page.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';

import '../../support/fs_test_support.dart';

/// Puts an entry straight into the store, as if saved on [at].
Future<void> _seed(
  WidgetTester tester,
  LocalStore store,
  String entryId,
  String text, {
  required DateTime at,
  JournalSource source = JournalSource.pen,
  String prompt = '',
}) async {
  await tester.runAsync(
    () => store.journal.apply(
      JournalChange.save(
        id: 'seed-$entryId',
        ownerId: store.ownerId,
        entryId: entryId,
        text: text,
        source: source,
        at: at,
        prompt: prompt,
      ),
    ),
  );
}

Finder _row(String entryId) =>
    find.byKey(ValueKey<String>('fs-journal-entry-$entryId'));

String _typed(WidgetTester tester) =>
    tester.widget<TextField>(entryBox).controller!.text;

String? _message(WidgetTester tester) => entryMessage.evaluate().isEmpty
    ? null
    : tester.widget<Text>(entryMessage).data;

final Finder _newEntry = find.byKey(const ValueKey<String>('fs-journal-new'));

void main() {
  setUpAll(loadAppFonts);

  group('the Journal page', () {
    testWidgets('with nothing written says how to start', (tester) async {
      await pumpApp(tester);
      await openJournal(tester);

      expect(find.byType(JournalPage), findsOneWidget);
      expect(find.text('MY JOURNAL'), findsOneWidget);
      expect(find.text(journalEmptyText), findsOneWidget);
    });

    testWidgets('lists his entries newest first, with when each was written', (
      tester,
    ) async {
      final store = testStore();
      // Today is Tuesday, November 10, half past seven.
      await _seed(
        tester,
        store,
        'j1',
        'A week ago.',
        at: DateTime(2026, 11, 3, 6),
      );
      await _seed(
        tester,
        store,
        'j2',
        'Yesterday evening.',
        at: DateTime(2026, 11, 9, 21),
      );
      await _seed(
        tester,
        store,
        'j3',
        'Under the reading.',
        at: DateTime(2026, 11, 10, 6, 45),
        source: JournalSource.devotional,
        prompt: 'A question.',
      );
      await _seed(
        tester,
        store,
        'j4',
        'From the pen.',
        at: DateTime(2026, 11, 10, 7, 5),
      );
      await pumpApp(tester, store: store);
      await openJournal(tester);

      expect(find.text('TODAY · 7:05 AM'), findsOneWidget);
      expect(find.text('TODAY · DEVOTIONAL'), findsOneWidget);
      expect(find.text('YESTERDAY'), findsOneWidget);
      expect(find.text('TUE, NOV 3'), findsOneWidget);
      final tops = <String, double>{
        for (final id in <String>['j4', 'j3', 'j2', 'j1'])
          id: tester.getTopLeft(_row(id)).dy,
      };
      expect(tops['j4']!, lessThan(tops['j3']!));
      expect(tops['j3']!, lessThan(tops['j2']!));
      expect(tops['j2']!, lessThan(tops['j1']!));
      expect(find.text(journalEmptyText), findsNothing);
    });

    testWidgets('shows the start of a long entry, as the prototype does', (
      tester,
    ) async {
      final store = testStore();
      await _seed(
        tester,
        store,
        'j1',
        'a' * 300,
        at: DateTime(2026, 11, 10, 7),
      );
      await pumpApp(tester, store: store);
      await openJournal(tester);

      expect(find.text('${'a' * 220}…'), findsOneWidget);
    });

    testWidgets('Back returns to Today; so does Android back', (tester) async {
      await pumpApp(tester);
      await openJournal(tester);
      await tester.tap(find.widgetWithText(FsButton, '‹ BACK'));
      await tester.pumpAndSettle();
      expect(find.byType(TodayPage), findsOneWidget);

      await openJournal(tester);
      await systemBack(tester);
      expect(find.byType(TodayPage), findsOneWidget);
    });

    testWidgets('is opened from Settings', (tester) async {
      await pumpApp(tester);
      await openSettings(tester);
      expect(find.byType(SettingsPage), findsOneWidget);
      await tapVisible(
        tester,
        find.byKey(const ValueKey<String>('fs-settings-journal')),
      );
      expect(find.byType(JournalPage), findsOneWidget);
    });
  });

  group('editing an entry (P06 acceptance 3)', () {
    testWidgets('opens with his words and saves the change to the same entry', (
      tester,
    ) async {
      final store = testStore();
      await _seed(
        tester,
        store,
        'j1',
        'As first written.',
        at: DateTime(2026, 11, 9, 21),
        source: JournalSource.devotional,
        prompt: 'What possession has too much of your heart?',
      );
      final app = await pumpApp(tester, store: store);
      await openJournal(tester);

      await tester.tap(_row('j1'));
      await tester.pumpAndSettle();
      expect(find.byType(JournalEntryPage), findsOneWidget);
      expect(find.text('Edit your entry'), findsOneWidget);
      expect(find.text('MON, NOV 9 · 9:00 PM'), findsOneWidget);
      expect(
        find.text('What possession has too much of your heart?'),
        findsOneWidget,
      );
      expect(_typed(tester), 'As first written.');

      await typeInto(tester, entryBox, 'As changed.');
      await tapVisible(tester, entrySave);

      // Back on the list, which shows the change.
      expect(find.byType(JournalPage), findsOneWidget);
      expect(find.text('As changed.'), findsOneWidget);
      expect(find.text('As first written.'), findsNothing);
      final entry = (await app.savedJournal(tester)).single;
      expect(entry.id, 'j1');
      expect(entry.text, 'As changed.');
      expect(entry.revision, 2);
      expect(entry.editedAtUtc, referenceTime.toUtc());
      // Where and when it was first written do not change.
      expect(entry.source, JournalSource.devotional);
      expect(entry.createdAtUtc, DateTime(2026, 11, 9, 21).toUtc());
    });

    testWidgets('a failed save keeps his text on screen and the retry works', (
      tester,
    ) async {
      final journal = TestJournalRepository();
      final store = testStore(journal: journal);
      await _seed(
        tester,
        store,
        'j1',
        'As first written.',
        at: DateTime(2026, 11, 9, 21),
      );
      final app = await pumpApp(tester, store: store);
      await openJournal(tester);
      await tester.tap(_row('j1'));
      await tester.pumpAndSettle();

      journal.failWrites = true;
      await typeInto(tester, entryBox, 'A change that fails first.');
      await tapVisible(tester, entrySave);

      expect(find.byType(JournalEntryPage), findsOneWidget);
      expect(_message(tester), JournalEntryText.failed);
      expect(_typed(tester), 'A change that fails first.');
      expect((await app.savedJournal(tester)).single.text, 'As first written.');

      journal.failWrites = false;
      await tapVisible(tester, entrySave);

      expect(find.byType(JournalPage), findsOneWidget);
      final entries = await app.savedJournal(tester);
      expect(entries, hasLength(1));
      expect(entries.single.text, 'A change that fails first.');
    });

    testWidgets('emptying it is not a save', (tester) async {
      final store = testStore();
      await _seed(
        tester,
        store,
        'j1',
        'Still here.',
        at: DateTime(2026, 11, 9, 21),
      );
      final app = await pumpApp(tester, store: store);
      await openJournal(tester);
      await tester.tap(_row('j1'));
      await tester.pumpAndSettle();

      await typeInto(tester, entryBox, '  ');
      await tapVisible(tester, entrySave);

      expect(_message(tester), JournalEntryText.empty);
      expect((await app.savedJournal(tester)).single.text, 'Still here.');
    });

    testWidgets('Close leaves the entry as it was', (tester) async {
      final store = testStore();
      await _seed(
        tester,
        store,
        'j1',
        'Unchanged.',
        at: DateTime(2026, 11, 9, 21),
      );
      final app = await pumpApp(tester, store: store);
      await openJournal(tester);
      await tester.tap(_row('j1'));
      await tester.pumpAndSettle();
      await typeInto(tester, entryBox, 'Typed, then closed.');

      await tapVisible(
        tester,
        find.byKey(const ValueKey<String>('fs-entry-close')),
      );

      expect(find.byType(JournalPage), findsOneWidget);
      expect((await app.savedJournal(tester)).single.text, 'Unchanged.');
      // Opening it again shows what is saved, not what was typed.
      await tester.tap(_row('j1'));
      await tester.pumpAndSettle();
      expect(_typed(tester), 'Unchanged.');
    });

    testWidgets('Android back from an entry returns to the list', (
      tester,
    ) async {
      final store = testStore();
      await _seed(
        tester,
        store,
        'j1',
        'Unchanged.',
        at: DateTime(2026, 11, 9, 21),
      );
      await pumpApp(tester, store: store);
      await openJournal(tester);
      await tester.tap(_row('j1'));
      await tester.pumpAndSettle();

      await systemBack(tester);

      expect(find.byType(JournalPage), findsOneWidget);
    });

    testWidgets('one entry\'s words never appear in another entry\'s box', (
      tester,
    ) async {
      final store = testStore();
      await _seed(
        tester,
        store,
        'j1',
        'The first.',
        at: DateTime(2026, 11, 8, 21),
      );
      await _seed(
        tester,
        store,
        'j2',
        'The second.',
        at: DateTime(2026, 11, 9, 21),
      );
      await pumpApp(tester, store: store);
      await openJournal(tester);

      await tester.tap(_row('j1'));
      await tester.pumpAndSettle();
      await typeInto(tester, entryBox, 'Typed into the first.');
      await systemBack(tester);
      await tester.tap(_row('j2'));
      await tester.pumpAndSettle();

      expect(_typed(tester), 'The second.');
    });
  });

  group('deleting an entry (P06 acceptance 3)', () {
    testWidgets('takes a second tap, then the entry is gone', (tester) async {
      final store = testStore();
      await _seed(
        tester,
        store,
        'j1',
        'To be deleted.',
        at: DateTime(2026, 11, 9, 21),
      );
      await _seed(
        tester,
        store,
        'j2',
        'To be kept.',
        at: DateTime(2026, 11, 8, 21),
      );
      final app = await pumpApp(tester, store: store);
      await openJournal(tester);
      await tester.tap(_row('j1'));
      await tester.pumpAndSettle();
      expect(
        tester.widget<FsButton>(entryDelete).label,
        JournalEntryText.delete,
      );

      // One tap only asks.
      await tapVisible(tester, entryDelete);
      expect(
        tester.widget<FsButton>(entryDelete).label,
        JournalEntryText.deleteSure,
      );
      expect(await app.savedJournal(tester), hasLength(2));

      await tapVisible(tester, entryDelete);

      expect(find.byType(JournalPage), findsOneWidget);
      expect(find.text('To be deleted.'), findsNothing);
      expect(find.text('To be kept.'), findsOneWidget);
      expect((await app.savedJournal(tester)).single.id, 'j2');
    });

    testWidgets('a delete that fails says so and leaves the entry', (
      tester,
    ) async {
      final journal = TestJournalRepository();
      final store = testStore(journal: journal);
      await _seed(
        tester,
        store,
        'j1',
        'Still here.',
        at: DateTime(2026, 11, 9, 21),
      );
      final app = await pumpApp(tester, store: store);
      await openJournal(tester);
      await tester.tap(_row('j1'));
      await tester.pumpAndSettle();

      journal.failWrites = true;
      await tapVisible(tester, entryDelete);
      await tapVisible(tester, entryDelete);

      expect(find.byType(JournalEntryPage), findsOneWidget);
      expect(_message(tester), JournalEntryText.deleteFailed);
      expect(_typed(tester), 'Still here.');
      expect(await app.savedJournal(tester), hasLength(1));

      // It asks again before it deletes.
      journal.failWrites = false;
      await tapVisible(tester, entryDelete);
      expect(await app.savedJournal(tester), hasLength(1));
      await tapVisible(tester, entryDelete);
      expect(await app.savedJournal(tester), isEmpty);
      expect(find.text(journalEmptyText), findsOneWidget);
    });
  });

  group('a new entry from the pen', () {
    testWidgets('on Today opens an empty entry and saves it', (tester) async {
      final app = await pumpApp(tester);

      await tester.tap(heroButton(FsHeroActionKind.journal));
      await tester.pumpAndSettle();
      expect(find.byType(JournalEntryPage), findsOneWidget);
      expect(find.text('Journal'), findsOneWidget);
      expect(find.text('TUE, NOV 10 · 7:30 AM'), findsOneWidget);
      expect(find.text(JournalEntryText.private), findsOneWidget);
      expect(_typed(tester), isEmpty);
      // There is nothing to delete yet.
      expect(entryDelete, findsNothing);

      await typeInto(tester, entryBox, 'Squatted 225 for five.');
      await tapVisible(tester, entrySave);

      expect(find.byType(JournalPage), findsOneWidget);
      expect(find.text('Squatted 225 for five.'), findsOneWidget);
      final entry = (await app.savedJournal(tester)).single;
      expect(entry.source, JournalSource.pen);
      expect(entry.prompt, isEmpty);
      expect(entry.createdAtUtc, referenceTime.toUtc());
    });

    testWidgets(
      'a failed save keeps the text; retries make exactly one entry',
      (tester) async {
        final journal = TestJournalRepository()..failWrites = true;
        final app = await pumpApp(tester, store: testStore(journal: journal));
        await openJournal(tester);
        await tester.tap(_newEntry);
        await tester.pumpAndSettle();

        await typeInto(tester, entryBox, 'Will not save at first.');
        await tapVisible(tester, entrySave);
        await tapVisible(tester, entrySave);

        expect(_message(tester), JournalEntryText.failed);
        expect(_typed(tester), 'Will not save at first.');
        expect(await app.savedJournal(tester), isEmpty);

        journal.failWrites = false;
        await tapVisible(tester, entrySave);

        expect(find.byType(JournalPage), findsOneWidget);
        expect(await app.savedJournal(tester), hasLength(1));
        expect(journal.sent, hasLength(3));
        expect(journal.sent.map((c) => c.entryId).toSet(), hasLength(1));
      },
    );

    testWidgets(
      'a save that was stored after all is not stored twice by the retry',
      (tester) async {
        final journal = TestJournalRepository()..throwAfterStoring = true;
        final app = await pumpApp(tester, store: testStore(journal: journal));
        await openJournal(tester);
        await tester.tap(_newEntry);
        await tester.pumpAndSettle();
        await typeInto(tester, entryBox, 'Stored, answer lost.');
        await tapVisible(tester, entrySave);
        expect(_message(tester), JournalEntryText.failed);

        journal.throwAfterStoring = false;
        await tapVisible(tester, entrySave);

        expect(find.byType(JournalPage), findsOneWidget);
        final entry = (await app.savedJournal(tester)).single;
        expect(entry.revision, 1);
        expect(journal.sent.map((c) => c.id).toSet(), hasLength(1));
        expect(
          await tester.runAsync(
            () => journal.changesFor(app.ownerId, entry.id),
          ),
          hasLength(1),
        );
      },
    );

    testWidgets('with nothing written is not saved', (tester) async {
      final app = await pumpApp(tester);
      await openJournal(tester);
      await tester.tap(_newEntry);
      await tester.pumpAndSettle();

      await tapVisible(tester, entrySave);

      expect(_message(tester), JournalEntryText.empty);
      expect(await app.savedJournal(tester), isEmpty);
    });
  });

  for (final scale in <double>[1.3, 2.0]) {
    testWidgets(
      'nothing overflows at $scale times the text size on a small phone',
      (tester) async {
        final store = testStore();
        await _seed(
          tester,
          store,
          'j1',
          'A long enough entry to wrap over several lines on a small phone.',
          at: DateTime(2026, 11, 9, 21),
          source: JournalSource.devotional,
          prompt: 'What possession has too much of your heart?',
        );
        await pumpApp(
          tester,
          store: store,
          textScale: scale,
          size: const Size(320, 568),
        );
        await openJournal(tester);
        expect(tester.takeException(), isNull);
        await tester.tap(_row('j1'));
        await tester.pumpAndSettle();
        await tapVisible(tester, entryDelete);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
