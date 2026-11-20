import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/features/journal/presentation/journal_view_model.dart';
import 'package:integration_test/integration_test.dart';

import 'journal_edit_restart_support.dart';
import 'journal_restart_support.dart';
import 'restart_support.dart';

/// Part 3 of the journal's edit and delete test on a device: a new process,
/// after part 2 deleted the entry and the app was killed. See
/// `journal_edit_restart_support.dart`.
///
/// The entry is still gone, in either of its wordings.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('after the app was killed and started again, the deleted entry '
      'is still gone', (tester) async {
    await startApp(tester);
    await openJournalFromToday(tester);
    expect(find.text(journalNotSavedNotice), findsNothing);

    expect(rowsWith(editEntryAfter), findsNothing);
    expect(rowsWith(editEntryBefore), findsNothing);
  });
}
