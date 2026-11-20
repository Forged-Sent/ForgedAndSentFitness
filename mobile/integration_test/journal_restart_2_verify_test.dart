import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/features/journal/presentation/journal_view_model.dart';
import 'package:integration_test/integration_test.dart';

import 'journal_restart_support.dart';
import 'restart_support.dart';

/// Second half of the journal's restart test. Run it after
/// `journal_restart_1_write_test` has written the entry and the app's
/// process has been stopped. See `journal_restart_support.dart`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'after the app was killed and started again, the entry is in the journal',
    (tester) async {
      await startApp(tester);
      await openJournalFromToday(tester);

      // Exactly the one entry the first half wrote, and the journal does not
      // say it is unsaved.
      expect(restartEntryRows, findsOneWidget);
      expect(find.text(journalNotSavedNotice), findsNothing);

      // Opened, it holds every word that was written.
      await tester.tap(restartEntryRows.first);
      await tester.pumpAndSettle();
      expect(openEntryWords(tester), restartEntryWords);
    },
  );
}
