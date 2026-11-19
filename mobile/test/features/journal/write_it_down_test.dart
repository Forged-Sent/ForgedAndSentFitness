import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/local_store.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/design/fs_button.dart';
import 'package:forged_and_sent/src/design/fs_text_area.dart';
import 'package:forged_and_sent/src/features/devotional/presentation/devotional_page.dart';
import 'package:forged_and_sent/src/features/journal/domain/journal_entry.dart';
import 'package:forged_and_sent/src/features/journal/presentation/journal_page.dart';
import 'package:forged_and_sent/src/features/journal/presentation/journal_view_model.dart';
import 'package:forged_and_sent/src/features/journal/presentation/write_it_down.dart';
import 'package:forged_and_sent/src/features/today/domain/completion_event.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';

import '../../support/fs_test_support.dart';

const LocalDate _nov10 = LocalDate(2026, 11, 10);

String _typed(WidgetTester tester) =>
    tester.widget<TextField>(journalBox).controller!.text;

FsButton _save(WidgetTester tester) => tester.widget<FsButton>(journalSave);

String? _message(WidgetTester tester) => journalMessage.evaluate().isEmpty
    ? null
    : tester.widget<Text>(journalMessage).data;

final Finder _discard = find.byKey(
  const ValueKey<String>('fs-journal-discard'),
);

void main() {
  setUpAll(loadAppFonts);

  group('the question a draft answers', () {
    ProviderContainer container() {
      final made = ProviderContainer(
        overrides: [localStoreProvider.overrideWithValue(testStore())],
      );
      addTearDown(made.dispose);
      return made;
    }

    test('is let go when he empties the box before any save: the next words '
        'answer the question on screen then', () {
      final drafts = container();
      final draft = drafts.read(devotionalDraftProvider.notifier);

      draft.typed('Started last night.', prompt: 'Yesterday\'s question?');
      expect(
        drafts.read(devotionalDraftProvider).prompt,
        'Yesterday\'s question?',
      );

      // He clears the box. Nothing was saved, so this is starting over.
      draft.typed('', prompt: 'Today\'s question?');
      expect(drafts.read(devotionalDraftProvider).prompt, isNull);

      draft.typed('New words.', prompt: 'Today\'s question?');
      expect(drafts.read(devotionalDraftProvider).prompt, 'Today\'s question?');
    });

    test('is kept while there are words in the box, whatever is on screen', () {
      final drafts = container();
      final draft = drafts.read(devotionalDraftProvider.notifier);

      draft.typed('Started last night.', prompt: 'Yesterday\'s question?');
      draft.typed(
        'Started last night, and more.',
        prompt: 'Today\'s question?',
      );

      expect(
        drafts.read(devotionalDraftProvider).prompt,
        'Yesterday\'s question?',
      );
    });
  });

  testWidgets('the box starts from the reading\'s reflection question', (
    tester,
  ) async {
    await pumpApp(tester);
    await openDevotional(tester);
    final reading = loadBundledLibrary().forDate(_nov10)!;

    expect(find.text('// WRITE IT DOWN'), findsOneWidget);
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey<String>('fs-journal-prompt')))
          .data,
      reading.reflect,
    );
    expect(_typed(tester), isEmpty);
    expect(_save(tester).label, WriteItDownText.save);
    expect(_message(tester), isNull);
    expect(find.text(WriteItDownText.note), findsOneWidget);
  });

  testWidgets('"Save to my journal" saves one private entry', (tester) async {
    final app = await pumpApp(tester);
    final journal = app.store.journal as TestJournalRepository;
    final reading = loadBundledLibrary().forDate(_nov10)!;

    await writeItDown(tester, '  My truck has too much of it.  ');

    expect(_message(tester), WriteItDownText.saved);
    // The box is empty again, ready for another entry.
    expect(_typed(tester), isEmpty);
    expect(journal.attempts, 1);
    final entry = (await app.savedJournal(tester)).single;
    expect(entry.text, 'My truck has too much of it.');
    expect(entry.ownerId, app.ownerId);
    expect(entry.day, _nov10);
    expect(entry.source, JournalSource.devotional);
    expect(entry.prompt, reading.reflect);
    expect(entry.createdAtUtc, referenceTime.toUtc());
    // He is still on the reading: saving does not say Amen for him.
    expect(find.byType(DevotionalPage), findsOneWidget);
    expect(
      (await app.savedDay(tester, _nov10)).isDone(DayItems.devotional),
      isFalse,
    );
  });

  testWidgets('"Saved" is shown only after the save has been stored', (
    tester,
  ) async {
    final journal = TestJournalRepository()..gate = Completer<void>();
    final app = await pumpApp(tester, store: testStore(journal: journal));
    await openDevotional(tester);
    await typeInto(tester, journalBox, 'Still on its way.');
    await tester.ensureVisible(journalSave);
    await tester.pumpAndSettle();

    await tester.tap(journalSave);
    await tester.pump();

    // On its way: nothing says saved, and a second tap does nothing.
    expect(_save(tester).label, WriteItDownText.saving);
    expect(_save(tester).onPressed, isNull);
    expect(_message(tester), isNull);
    expect(_typed(tester), 'Still on its way.');
    expect(await app.savedJournal(tester), isEmpty);
    await tester.tap(journalSave, warnIfMissed: false);
    await tester.pump();
    expect(journal.attempts, 1);

    journal.gate!.complete();
    await tester.pumpAndSettle();

    expect(_message(tester), WriteItDownText.saved);
    expect(await app.savedJournal(tester), hasLength(1));
  });

  testWidgets('with nothing written, Save asks for something first', (
    tester,
  ) async {
    final app = await pumpApp(tester);
    final journal = app.store.journal as TestJournalRepository;
    await openDevotional(tester);

    await tapVisible(tester, journalSave);
    expect(_message(tester), WriteItDownText.empty);
    await typeInto(tester, journalBox, '   \n ');
    expect(_message(tester), isNull);
    await tapVisible(tester, journalSave);

    expect(_message(tester), WriteItDownText.empty);
    expect(journal.attempts, 0);
    expect(await app.savedJournal(tester), isEmpty);
  });

  group('a save that fails (P06 acceptance 2)', () {
    testWidgets(
      'keeps his text, says so, and the retry saves exactly one entry',
      (tester) async {
        final clock = TestClock();
        final journal = TestJournalRepository()..failWrites = true;
        final app = await pumpApp(
          tester,
          store: testStore(journal: journal),
          clock: clock,
        );

        await writeItDown(tester, 'I was short with my son.');

        // The failure is on screen and nothing is stored.
        expect(_message(tester), WriteItDownText.failed);
        expect(_typed(tester), 'I was short with my son.');
        expect(find.text(WriteItDownText.retryNote), findsOneWidget);
        expect(find.text(WriteItDownText.saved), findsNothing);
        expect(journal.attempts, 1);
        expect(await app.savedJournal(tester), isEmpty);

        // He adds a line and tries again a few minutes later. It fails again.
        clock.time = referenceTime.add(const Duration(minutes: 4));
        await typeInto(tester, journalBox, 'I was short with my son. Twice.');
        expect(_message(tester), WriteItDownText.failed);
        await tapVisible(tester, journalSave);
        expect(_message(tester), WriteItDownText.failed);
        expect(await app.savedJournal(tester), isEmpty);

        // The disk is fine again.
        journal.failWrites = false;
        clock.time = referenceTime.add(const Duration(minutes: 9));
        await tapVisible(tester, journalSave);

        expect(_message(tester), WriteItDownText.saved);
        expect(_typed(tester), isEmpty);
        final entries = await app.savedJournal(tester);
        expect(entries, hasLength(1));
        expect(entries.single.text, 'I was short with my son. Twice.');
        // Every attempt named the same entry, with the time of the first.
        expect(journal.sent, hasLength(3));
        expect(journal.sent.map((c) => c.entryId).toSet(), hasLength(1));
        expect(journal.sent.map((c) => c.atUtc).toSet(), <DateTime>{
          referenceTime.toUtc(),
        });
        expect(entries.single.id, journal.sent.first.entryId);
        expect(entries.single.createdAtUtc, referenceTime.toUtc());
      },
    );

    testWidgets(
      'that was stored after all still leaves exactly one entry after the retry',
      (tester) async {
        final journal = TestJournalRepository()..throwAfterStoring = true;
        final app = await pumpApp(tester, store: testStore(journal: journal));

        await writeItDown(tester, 'Stored, but the answer was lost.');
        expect(_message(tester), WriteItDownText.failed);
        expect(_typed(tester), 'Stored, but the answer was lost.');
        expect(await app.savedJournal(tester), hasLength(1));

        journal.throwAfterStoring = false;
        await tapVisible(tester, journalSave);

        expect(_message(tester), WriteItDownText.saved);
        final entries = await app.savedJournal(tester);
        expect(entries, hasLength(1));
        expect(entries.single.text, 'Stored, but the answer was lost.');
        expect(journal.sent.map((c) => c.entryId).toSet(), hasLength(1));
        // The retry sent the very same change, so it was not written twice.
        expect(journal.sent.map((c) => c.id).toSet(), hasLength(1));
        expect(entries.single.revision, 1);
        expect(entries.single.editedAtUtc, isNull);
        expect(
          await tester.runAsync(
            () => journal.changesFor(app.ownerId, entries.single.id),
          ),
          hasLength(1),
        );
      },
    );

    group('that was stored after all, and he then changed that entry in his '
        'journal', () {
      // The overwrite case: the first save was stored and its answer lost,
      // so the box still holds the draft. He finds the entry in his journal
      // and changes it there, then comes back to the box.
      Future<(AppHarness, TestJournalRepository)> draftThenEdit(
        WidgetTester tester,
      ) async {
        final journal = TestJournalRepository()..throwAfterStoring = true;
        final app = await pumpApp(tester, store: testStore(journal: journal));
        await writeItDown(tester, 'First words.');
        expect(_message(tester), WriteItDownText.failed);
        journal.throwAfterStoring = false;
        final entryId = (await app.savedJournal(tester)).single.id;

        // He goes to his journal, on the Walk tab, and changes the entry.
        await systemBack(tester);
        await openTab(tester, 'Walk');
        await tester.tap(
          find.byKey(ValueKey<String>('fs-journal-entry-$entryId')),
        );
        await tester.pumpAndSettle();
        await typeInto(tester, entryBox, 'Edited in the journal.');
        await tapVisible(tester, entrySave);
        expect(
          (await app.savedJournal(tester)).single.text,
          'Edited in the journal.',
        );

        // Back to the reading, where the box still holds the draft.
        await openTab(tester, 'Today');
        await openDevotional(tester);
        expect(_typed(tester), 'First words.');
        return (app, journal);
      }

      testWidgets('saving other words from the box does not replace the '
          'edit: it says so, and the next save is a separate entry', (
        tester,
      ) async {
        final (app, journal) = await draftThenEdit(tester);

        await typeInto(tester, journalBox, 'First words, changed.');
        await tapVisible(tester, journalSave);

        // Nothing was written over his edit, and he is told why.
        expect(_message(tester), WriteItDownText.separate);
        expect(find.text(WriteItDownText.retryNote), findsNothing);
        expect(_typed(tester), 'First words, changed.');
        final afterRefusal = await app.savedJournal(tester);
        expect(afterRefusal.single.text, 'Edited in the journal.');
        expect(afterRefusal.single.revision, 2);

        // His words in the box are not lost either: saving again writes
        // them as an entry of their own.
        await tapVisible(tester, journalSave);
        expect(_message(tester), WriteItDownText.saved);
        final entries = await app.savedJournal(tester);
        expect(entries.map((e) => e.text).toSet(), <String>{
          'Edited in the journal.',
          'First words, changed.',
        });
        expect(entries.map((e) => e.id).toSet(), hasLength(2));
        expect(journal.sent.last.entryId, isNot(journal.sent.first.entryId));
      });

      testWidgets('saving the same words again changes nothing: the edit '
          'stands', (tester) async {
        final (app, _) = await draftThenEdit(tester);

        await tapVisible(tester, journalSave);

        expect(_message(tester), WriteItDownText.saved);
        final entry = (await app.savedJournal(tester)).single;
        expect(entry.text, 'Edited in the journal.');
        expect(entry.revision, 2);
      });
    });

    testWidgets(
      'the draft can be discarded, with a second tap, to start another entry',
      (tester) async {
        final journal = TestJournalRepository()..failWrites = true;
        final app = await pumpApp(tester, store: testStore(journal: journal));
        await writeItDown(tester, 'First try.');
        expect(
          tester.widget<FsButton>(_discard).label,
          WriteItDownText.discard,
        );

        // One tap only asks.
        await tapVisible(tester, _discard);
        expect(
          tester.widget<FsButton>(_discard).label,
          WriteItDownText.discardSure,
        );
        expect(_typed(tester), 'First try.');

        await tapVisible(tester, _discard);
        expect(_typed(tester), isEmpty);
        expect(_message(tester), isNull);
        expect(_discard, findsNothing);

        // What he writes next is a different entry.
        journal.failWrites = false;
        await typeInto(tester, journalBox, 'Second try.');
        await tapVisible(tester, journalSave);
        expect(_message(tester), WriteItDownText.saved);
        expect(journal.sent.last.entryId, isNot(journal.sent.first.entryId));
        expect((await app.savedJournal(tester)).single.text, 'Second try.');
      },
    );
  });

  testWidgets(
    'a retry with different words is a new change to the same entry',
    (tester) async {
      final journal = TestJournalRepository()..failWrites = true;
      final app = await pumpApp(tester, store: testStore(journal: journal));
      await writeItDown(tester, 'First wording.');
      await tapVisible(tester, journalSave);
      // Twice the same words: the same change both times.
      expect(journal.sent.map((c) => c.id).toSet(), hasLength(1));

      journal.failWrites = false;
      await typeInto(tester, journalBox, 'Second wording.');
      await tapVisible(tester, journalSave);

      expect(journal.sent.map((c) => c.id).toSet(), hasLength(2));
      expect(journal.sent.map((c) => c.entryId).toSet(), hasLength(1));
      final entry = (await app.savedJournal(tester)).single;
      expect(entry.text, 'Second wording.');
      expect(entry.revision, 1);
    },
  );

  testWidgets(
    'an entry answers the question he began with, also when midnight passes '
    'before he saves',
    (tester) async {
      final clock = TestClock(DateTime(2026, 11, 10, 23, 58));
      final app = await pumpApp(tester, clock: clock);
      final library = loadBundledLibrary();
      final first = library.forDate(_nov10)!.reflect;
      final next = library.forDate(_nov10.addDays(1))!.reflect;
      expect(first, isNot(next));
      await openDevotional(tester);
      await typeInto(tester, journalBox, 'Begun before midnight.');

      // Midnight passes with the reading open; the page moves to the next.
      clock.time = DateTime(2026, 11, 11, 0, 1);
      await backgroundAndResume(tester);
      expect(find.text(newDayNotice), findsOneWidget);
      expect(_typed(tester), 'Begun before midnight.');
      // The box still shows the question he was answering.
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey<String>('fs-journal-prompt')),
            )
            .data,
        first,
      );

      await tapVisible(tester, journalSave);

      expect(_message(tester), WriteItDownText.saved);
      final entry = (await app.savedJournal(tester)).single;
      expect(entry.prompt, first);
      // Filed under the day he saved it (decision Q9).
      expect(entry.day, _nov10.addDays(1));
      // The box is empty again and shows today's question.
      expect(
        tester
            .widget<Text>(
              find.byKey(const ValueKey<String>('fs-journal-prompt')),
            )
            .data,
        next,
      );
    },
  );

  group(
    'the 4000 limit is counted the same way by the box and by the save',
    () {
      test('what does not fit is dropped a whole character at a time', () {
        expect(FsCodeUnitLimit.fit('abc', 4000), 'abc');
        expect(FsCodeUnitLimit.fit('a' * 4001, 4000), hasLength(4000));
        // A thumbs-up is two code units: 2000 of them fit exactly.
        expect(FsCodeUnitLimit.fit('👍' * 2001, 4000), '👍' * 2000);
        // One letter, then emoji: the last emoji would be cut in half, so it
        // is left out whole.
        final mixed = FsCodeUnitLimit.fit('a${'👍' * 2000}', 4000);
        expect(mixed, 'a${'👍' * 1999}');
        expect(mixed.length, 3999);
        // A family emoji is one character made of eleven code units.
        const family = '👨‍👩‍👧‍👦';
        expect(family.length, 11);
        expect(FsCodeUnitLimit.fit(family * 2, 12), family);
      });

      test('an edit that does not fit never drops words already there', () {
        const limit = FsCodeUnitLimit(10);
        const full = TextEditingValue(
          text: 'abcdefghij',
          selection: TextSelection.collapsed(offset: 0),
        );
        // Typed at the start of a full box: refused, the box is unchanged.
        expect(
          limit.formatEditUpdate(
            full,
            const TextEditingValue(
              text: 'Xabcdefghij',
              selection: TextSelection.collapsed(offset: 1),
            ),
          ),
          full,
        );
        // Pasted into the middle of a box with room for less than the paste.
        const part = TextEditingValue(
          text: 'abcdefgh',
          selection: TextSelection.collapsed(offset: 4),
        );
        expect(
          limit.formatEditUpdate(
            part,
            const TextEditingValue(
              text: 'abcdXYZefgh',
              selection: TextSelection.collapsed(offset: 7),
            ),
          ),
          part,
        );
        // Added at the end: what fits is kept, as before.
        final atEnd = limit.formatEditUpdate(
          part,
          const TextEditingValue(
            text: 'abcdefghXYZ',
            selection: TextSelection.collapsed(offset: 11),
          ),
        );
        expect(atEnd.text, 'abcdefghXY');
        expect(atEnd.selection, const TextSelection.collapsed(offset: 10));
        // An accent typed after the last letter of a full box is dropped on
        // its own; the letter it would have joined stays.
        final accent = limit.formatEditUpdate(
          full,
          const TextEditingValue(
            text: 'abcdefghij\u0301',
            selection: TextSelection.collapsed(offset: 11),
          ),
        );
        expect(accent.text, 'abcdefghij');
        // An emoji that would be cut in half at the end is left out whole.
        final emoji = limit.formatEditUpdate(
          const TextEditingValue(text: 'abcdefghi'),
          const TextEditingValue(text: 'abcdefghi👍'),
        );
        expect(emoji.text, 'abcdefghi');
        // An edit that fits is passed through untouched.
        const fits = TextEditingValue(
          text: 'abXcdefgh',
          selection: TextSelection.collapsed(offset: 3),
        );
        expect(limit.formatEditUpdate(part, fits), fits);
      });

      testWidgets('the journal box asks the keyboard not to learn from it', (
        tester,
      ) async {
        await pumpApp(tester);
        await writeItDown(tester, 'A private line.');

        final boxes = tester.widgetList<TextField>(find.byType(TextField));
        expect(boxes, isNotEmpty);
        for (final box in boxes) {
          expect(box.enableIMEPersonalizedLearning, isFalse);
        }
      });

      testWidgets('an entry of emoji at the limit fits the box and saves', (
        tester,
      ) async {
        final app = await pumpApp(tester);
        await writeItDown(tester, '👍' * 2001);

        expect(_message(tester), WriteItDownText.saved);
        final entry = (await app.savedJournal(tester)).single;
        expect(entry.text, '👍' * 2000);
        expect(entry.text.length, JournalText.maxLength);
      });

      testWidgets('typing past the limit stops at the limit', (tester) async {
        await pumpApp(tester);
        await openDevotional(tester);
        await typeInto(tester, journalBox, 'a' * 4100);
        expect(_typed(tester), hasLength(4000));
      });
    },
  );

  testWidgets('two saves make two entries', (tester) async {
    final app = await pumpApp(tester);
    await writeItDown(tester, 'One.');
    await typeInto(tester, journalBox, 'Two.');
    expect(_message(tester), isNull);
    await tapVisible(tester, journalSave);

    final entries = await app.savedJournal(tester);
    expect(entries.map((e) => e.text).toSet(), <String>{'One.', 'Two.'});
    expect(entries.map((e) => e.id).toSet(), hasLength(2));
  });

  testWidgets(
    'what he has typed is still there when he comes back to the reading',
    (tester) async {
      final app = await pumpApp(tester);
      await openDevotional(tester);
      await typeInto(tester, journalBox, 'Not saved yet.');

      await systemBack(tester);
      expect(find.byType(TodayPage), findsOneWidget);
      await openDevotional(tester);

      expect(_typed(tester), 'Not saved yet.');
      expect(await app.savedJournal(tester), isEmpty);
    },
  );

  group('the devotional does not depend on the journal (P06 acceptance 5)', () {
    testWidgets('Amen works with the box empty, and writes no entry', (
      tester,
    ) async {
      final app = await pumpApp(tester);
      final journal = app.store.journal as TestJournalRepository;

      await completeDevotional(tester);

      expect(find.byType(TodayPage), findsOneWidget);
      expect(
        (await app.savedDay(tester, _nov10)).isDone(DayItems.devotional),
        isTrue,
      );
      expect(journal.attempts, 0);
      expect(await app.savedJournal(tester), isEmpty);
    });

    testWidgets(
      'Amen works with an unsaved draft in the box, and does not save it',
      (tester) async {
        final app = await pumpApp(tester);
        await openDevotional(tester);
        await typeInto(tester, journalBox, 'Only a draft.');
        await scrollReaderToEnd(tester);
        await tester.tap(amenButton);
        await tester.pumpAndSettle();

        expect(
          (await app.savedDay(tester, _nov10)).isDone(DayItems.devotional),
          isTrue,
        );
        expect(await app.savedJournal(tester), isEmpty);
      },
    );

    testWidgets('Amen works when the journal cannot save at all', (
      tester,
    ) async {
      final journal = TestJournalRepository()..failWrites = true;
      final app = await pumpApp(tester, store: testStore(journal: journal));
      await writeItDown(tester, 'This will not save.');
      expect(_message(tester), WriteItDownText.failed);

      await scrollReaderToEnd(tester);
      await tester.tap(amenButton);
      await tester.pumpAndSettle();

      expect(find.byType(TodayPage), findsOneWidget);
      expect(
        (await app.savedDay(tester, _nov10)).isDone(DayItems.devotional),
        isTrue,
      );
    });

    testWidgets('typing in the box does not unlock Amen', (tester) async {
      await pumpApp(tester);
      await openDevotional(tester);
      expect(readerPosition(tester).pixels, 0);
      expect(tester.widget<FsButton>(amenButton).onPressed, isNull);

      // The box scrolls inside itself once it is full. Its end is not the
      // reading's end.
      await tester.enterText(journalBox, 'line\n' * 30);
      await tester.pumpAndSettle();
      readerPosition(tester).jumpTo(0);
      await tester.pumpAndSettle();

      expect(tester.widget<FsButton>(amenButton).onPressed, isNull);
      expect(find.text('Read it all the way through.'), findsOneWidget);
    });
  });

  testWidgets(
    '"My journal" after a save opens the Journal page with the entry',
    (tester) async {
      await pumpApp(tester);
      await writeItDown(tester, 'My truck has too much of it.');

      await tapVisible(
        tester,
        find.byKey(const ValueKey<String>('fs-journal-open')),
      );

      expect(find.byType(JournalPage), findsOneWidget);
      expect(find.text('My truck has too much of it.'), findsOneWidget);
      expect(find.text('TODAY · DEVOTIONAL'), findsOneWidget);
    },
  );

  testWidgets(
    'a screen reader hears the box by name and the result of a save',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await pumpApp(tester);
      await writeItDown(tester, 'Heard, not seen.');

      expect(find.bySemanticsLabel(RegExp('Your journal entry')), findsWidgets);
      final message = tester.getSemantics(journalMessage);
      expect(message.label, WriteItDownText.saved);
      semantics.dispose();
    },
  );

  testWidgets('the web preview says that nothing written is saved', (
    tester,
  ) async {
    await pumpApp(tester, store: LocalStore.inMemory());
    await openDevotional(tester);
    await tester.ensureVisible(journalSave);
    await tester.pumpAndSettle();

    expect(find.text('Nothing you write here is saved.'), findsOneWidget);
  });

  for (final scale in <double>[1.3, 2.0]) {
    testWidgets(
      'nothing overflows at $scale times the text size, saved and failed',
      (tester) async {
        final journal = TestJournalRepository()..failWrites = true;
        await pumpApp(
          tester,
          textScale: scale,
          size: const Size(320, 568),
          store: testStore(journal: journal),
        );
        await writeItDown(
          tester,
          'A long enough line to wrap on a small phone.',
        );
        expect(_message(tester), WriteItDownText.failed);
        await tapVisible(tester, _discard);
        expect(tester.takeException(), isNull);

        journal.failWrites = false;
        await tapVisible(tester, journalSave);
        expect(_message(tester), WriteItDownText.saved);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
