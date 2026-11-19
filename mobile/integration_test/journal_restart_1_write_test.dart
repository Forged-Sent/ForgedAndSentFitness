import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/features/devotional/presentation/devotional_page.dart';
import 'package:forged_and_sent/src/features/journal/presentation/journal_page.dart';
import 'package:forged_and_sent/src/features/journal/presentation/journal_view_model.dart';
import 'package:forged_and_sent/src/features/journal/presentation/write_it_down.dart';
import 'package:integration_test/integration_test.dart';

import 'journal_restart_support.dart';
import 'restart_support.dart';

/// First half of the journal's restart test. See
/// `journal_restart_support.dart` for how the two halves are run.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('"Write it down" saves an entry to the journal', (tester) async {
    await startApp(tester);

    // This test's own entries left over from an earlier run are deleted, so
    // this run does the writing itself and ends with exactly one of them.
    // Nothing else in the journal is opened, counted or deleted.
    await openJournalFromToday(tester);
    for (var i = 0; i < 10 && restartEntryRows.evaluate().isNotEmpty; i++) {
      await tester.tap(restartEntryRows.first);
      await tester.pumpAndSettle();
      expect(openEntryWords(tester), restartEntryWords);
      // The link asks for a second tap before it deletes.
      for (var tap = 0; tap < 2; tap++) {
        await tester.ensureVisible(entryDelete);
        await tester.pumpAndSettle();
        await tester.tap(entryDelete);
        await tester.pumpAndSettle();
      }
      await waitForJournal(tester);
    }
    expect(restartEntryRows, findsNothing);
    // The phone keeps what is written: the journal does not say otherwise.
    expect(find.text(journalNotSavedNotice), findsNothing);
    await backToToday(tester);

    // Write it down, under today's reading.
    await showDevotionalBox(tester);
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
    expect(find.text(journalNotSavedNotice), findsNothing);
    await tester.enterText(box, restartEntryWords);
    await tester.pumpAndSettle();
    await tester.ensureVisible(journalSaveButton);
    await tester.pumpAndSettle();
    await tester.tap(journalSaveButton);
    for (var i = 0; i < 100 && journalMessage.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pumpAndSettle();

    // "Saved" is the store's word, shown only once the row is written.
    expect(tester.widget<Text>(journalMessage).data, WriteItDownText.saved);

    // It is in the journal, once.
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
    await tester.ensureVisible(journalOpenButton);
    await tester.pumpAndSettle();
    await tester.tap(journalOpenButton);
    await tester.pumpAndSettle();
    await waitForJournal(tester);
    expect(find.byType(JournalPage), findsOneWidget);
    expect(restartEntryRows, findsOneWidget);
  });
}
