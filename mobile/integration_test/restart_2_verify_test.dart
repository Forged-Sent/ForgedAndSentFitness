import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/design/fs_box_row.dart';
import 'package:integration_test/integration_test.dart';

import 'restart_support.dart';

/// Second half of the restart test. Run it after `restart_1_complete_test`
/// has checked the box and the app's process has been stopped. See
/// `restart_support.dart`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'after the app was killed and started again, the box is still checked',
    (tester) async {
      await startApp(tester);
      await showDevotionalBox(tester);

      expect(devotionalChecked(tester), isTrue);
      expect(tester.widget<FsBoxRow>(devotionalBox).subtitle, 'Read today');
    },
  );
}
