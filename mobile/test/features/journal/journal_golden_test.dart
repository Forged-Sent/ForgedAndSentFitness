import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/features/journal/domain/journal_entry.dart';

import '../../support/fs_test_support.dart';

/// Golden images of the journal screens at 390x844, dark and light.
///
/// Compared on Windows only, as the Today images are: text is drawn
/// slightly differently on each operating system. On other systems these
/// tests are skipped; no CI lane checks the images yet.
///
/// The images were drawn on Windows on 2026-11-19. A new image is added the
/// same way: an image made on another system would fail on Windows, so
/// until an image exists its comparison is skipped. Draw it on Windows,
/// look at it beside the prototype, and commit:
/// `flutter test --update-goldens test/features/journal/journal_golden_test.dart`.
void main() {
  setUpAll(loadAppFonts);

  /// A comparison runs on Windows once its image exists. Until then it is
  /// skipped, so a normal test run on Windows passes; `--update-goldens`
  /// draws the image.
  bool skipUnlessDrawn(String image) =>
      !Platform.isWindows ||
      !(autoUpdateGoldenFiles ||
          File('test/features/journal/$image').existsSync());

  TestClock clock() => TestClock(DateTime(2026, 11, 12, 7, 30));

  Future<AppHarness> appWithEntries(
    WidgetTester tester,
    ThemeMode themeMode,
  ) async {
    final store = testStore();
    Future<void> seed(
      String id,
      String text,
      DateTime at,
      JournalSource source,
    ) => tester.runAsync(
      () => store.journal.apply(
        JournalChange.save(
          id: 'seed-$id',
          ownerId: store.ownerId,
          entryId: id,
          text: text,
          source: source,
          at: at,
          prompt: source == JournalSource.devotional
              ? 'What possession has too much of your heart?'
              : '',
        ),
      ),
    );
    await seed(
      'j1',
      'Squatted 225 for five. Slept badly, lifted anyway.',
      DateTime(2026, 11, 5, 18, 40),
      JournalSource.pen,
    );
    await seed(
      'j2',
      'I was short with my son at dinner. I need to tell him so.',
      DateTime(2026, 11, 11, 21, 15),
      JournalSource.pen,
    );
    await seed(
      'j3',
      'My truck. I think about it more than I pray.',
      DateTime(2026, 11, 12, 6, 50),
      JournalSource.devotional,
    );
    return pumpApp(tester, themeMode: themeMode, clock: clock(), store: store);
  }

  for (final (name, themeMode) in <(String, ThemeMode)>[
    ('dark', ThemeMode.dark),
    ('light', ThemeMode.light),
  ]) {
    testWidgets('"Write it down" under the reading, $name', (tester) async {
      await pumpApp(tester, themeMode: themeMode, clock: clock());
      await openDevotional(tester);
      await typeInto(
        tester,
        journalBox,
        'My truck. I think about it more than I pray.',
      );
      await tester.ensureVisible(journalSave);
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/write_it_down_$name.png'),
      );
    }, skip: skipUnlessDrawn('goldens/write_it_down_$name.png'));

    testWidgets('the Journal page with three entries, $name', (tester) async {
      await appWithEntries(tester, themeMode);
      await openJournal(tester);
      await loadHeroPhoto(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/journal_$name.png'),
      );
    }, skip: skipUnlessDrawn('goldens/journal_$name.png'));

    testWidgets('the Journal page with nothing written, $name', (tester) async {
      await pumpApp(tester, themeMode: themeMode, clock: clock());
      await openJournal(tester);
      await loadHeroPhoto(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/journal_empty_$name.png'),
      );
    }, skip: skipUnlessDrawn('goldens/journal_empty_$name.png'));

    testWidgets('an entry open to be changed, $name', (tester) async {
      await appWithEntries(tester, themeMode);
      await openJournal(tester);
      await tester.tap(
        find.byKey(const ValueKey<String>('fs-journal-entry-j3')),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/journal_entry_$name.png'),
      );
    }, skip: skipUnlessDrawn('goldens/journal_entry_$name.png'));
  }
}
