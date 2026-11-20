import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/features/journal/presentation/journal_entry_page.dart';
import 'package:forged_and_sent/src/features/journal/presentation/journal_view_model.dart';
import 'package:integration_test/integration_test.dart';

import 'journal_edit_restart_support.dart';
import 'journal_restart_support.dart';
import 'restart_support.dart';

/// Part 1 of the journal's edit and delete test on a device. See
/// `journal_edit_restart_support.dart` for how the three parts are run.
///
/// Writes an entry, opens it, changes its words and saves the change. The
/// test runner then stops the app's process.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('an entry is written, then changed', (tester) async {
    await startApp(tester);
    await openJournalFromToday(tester);
    // The phone keeps what is written: the journal does not say otherwise.
    expect(find.text(journalNotSavedNotice), findsNothing);

    // This test's own entries left over from an earlier run are deleted.
    await deleteLeftOver(tester, editEntryBefore);
    await deleteLeftOver(tester, editEntryAfter);
    await deleteLeftOver(tester, editEntryThatStays);

    // The entry that stays.
    await tester.tap(newEntryButton);
    await tester.pumpAndSettle();
    await saveOpenEntryAs(tester, editEntryThatStays);
    expect(rowsWith(editEntryThatStays), findsOneWidget);

    // A new entry, with the first words.
    await tester.tap(newEntryButton);
    await tester.pumpAndSettle();
    await saveOpenEntryAs(tester, editEntryBefore);
    expect(rowsWith(editEntryBefore), findsOneWidget);

    // Opened, it holds those words; they are changed and saved.
    await tester.tap(rowsWith(editEntryBefore).first);
    await tester.pumpAndSettle();
    expect(find.byType(JournalEntryPage), findsOneWidget);
    expect(openEntryWords(tester), editEntryBefore);
    await saveOpenEntryAs(tester, editEntryAfter);

    // One entry, with the new words. The first words are nowhere.
    expect(rowsWith(editEntryAfter), findsOneWidget);
    expect(rowsWith(editEntryBefore), findsNothing);
    expect(rowsWith(editEntryThatStays), findsOneWidget);
  });
}
