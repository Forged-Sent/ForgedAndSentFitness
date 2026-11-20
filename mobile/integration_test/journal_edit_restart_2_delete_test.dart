import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/features/journal/presentation/journal_view_model.dart';
import 'package:integration_test/integration_test.dart';

import 'journal_edit_restart_support.dart';
import 'journal_restart_support.dart';
import 'restart_support.dart';

/// Part 2 of the journal's edit and delete test on a device: a new process,
/// after part 1 changed an entry and the app was killed. See
/// `journal_edit_restart_support.dart`.
///
/// The change is there. Then the entry is deleted, and the test runner
/// stops the app's process again.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('after the app was killed and started again, the change is '
      'there; then the entry is deleted', (tester) async {
    await startApp(tester);
    await openJournalFromToday(tester);
    expect(find.text(journalNotSavedNotice), findsNothing);

    // Exactly one entry with the changed words, and none with the first.
    expect(rowsWith(editEntryAfter), findsOneWidget);
    expect(rowsWith(editEntryBefore), findsNothing);

    // Opened, it holds every word of the change, and nothing else.
    await tester.tap(rowsWith(editEntryAfter).first);
    await tester.pumpAndSettle();
    expect(openEntryWords(tester), editEntryAfter);

    // Deleted: it is gone from the list.
    await deleteOpenEntry(tester);
    expect(rowsWith(editEntryAfter), findsNothing);
    expect(rowsWith(editEntryBefore), findsNothing);
  });
}
