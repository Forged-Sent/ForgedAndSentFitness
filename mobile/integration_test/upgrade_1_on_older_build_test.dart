import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/design/fs_box_row.dart';
import 'package:forged_and_sent/src/features/devotional/presentation/devotional_page.dart';
import 'package:forged_and_sent/src/features/journal/presentation/journal_entry_page.dart';
import 'package:forged_and_sent/src/features/journal/presentation/journal_page.dart';
import 'package:forged_and_sent/src/features/journal/presentation/write_it_down.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';
import 'package:integration_test/integration_test.dart';

import 'journal_restart_support.dart';
import 'restart_support.dart';
import 'upgrade_support.dart';

/// Part 1 of the upgrade test, run from the older build. See
/// `upgrade_support.dart`.
///
/// Writes two journal entries, one under the reading and one from the
/// journal, and completes the day's devotional.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('the older build: two journal entries and a completed day', (
    tester,
  ) async {
    final clock = await startOlderAppOnLiftingDay(tester);
    debugPrint(
      'UPGRADE TEST: the older build ran on ${LocalDate.of(clock.now()).iso}.',
    );

    // A new install: none of this test's entries, and the box not checked.
    await openJournalFromToday(tester);
    expect(rowsWith(upgradeEntryUnderReading), findsNothing);
    expect(rowsWith(upgradeEntryFromJournal), findsNothing);
    await backToToday(tester);
    await showDevotionalBox(tester);
    expect(devotionalChecked(tester), isFalse);

    // The first entry, under today's reading.
    await tester.tap(devotionalBox);
    await tester.pumpAndSettle();
    expect(find.byType(DevotionalPage), findsOneWidget);
    final box = fieldIn('fs-journal-box');
    await tester.scrollUntilVisible(
      box,
      300,
      scrollable: scrollableOf(DevotionalPage).first,
    );
    await tester.pumpAndSettle();
    await tester.enterText(box, upgradeEntryUnderReading);
    await tester.pumpAndSettle();
    // The keyboard is open and the page is short. Save goes to the middle
    // of what is left of it: at the foot it can lie under the tab bar,
    // where a tap does not reach it.
    await Scrollable.ensureVisible(
      tester.element(journalSaveButton),
      alignment: 0.5,
    );
    await tester.pumpAndSettle();
    await tester.tap(journalSaveButton);
    for (var i = 0; i < 100 && journalMessage.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();
    expect(tester.widget<Text>(journalMessage).data, WriteItDownText.saved);
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    // The day's devotional: read to the end, Amen.
    await readToTheEnd(tester);
    await tester.ensureVisible(amenButton);
    await tester.pumpAndSettle();
    await tester.tap(amenButton);
    await tester.pumpAndSettle();
    expect(find.byType(TodayPage), findsOneWidget);
    await showDevotionalBox(tester);
    expect(devotionalChecked(tester), isTrue);
    expect(tester.widget<FsBoxRow>(devotionalBox).subtitle, 'Read today');

    // The second entry, from the journal's own "New entry".
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('fs-hero-profile')),
      -300,
      scrollable: scrollableOf(TodayPage).first,
    );
    await tester.pumpAndSettle();
    await openJournalFromToday(tester);
    await tester.tap(newEntryButton);
    await tester.pumpAndSettle();
    expect(find.byType(JournalEntryPage), findsOneWidget);
    await tester.enterText(fieldIn('fs-entry-box'), upgradeEntryFromJournal);
    await tester.pumpAndSettle();
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(entrySaveButton);
    await tester.pumpAndSettle();
    await tester.tap(entrySaveButton);
    for (
      var i = 0;
      i < 100 && find.byType(JournalEntryPage).evaluate().isNotEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await waitForJournal(tester);

    expect(find.byType(JournalPage), findsOneWidget);
    expectBothEntries();
  });
}
