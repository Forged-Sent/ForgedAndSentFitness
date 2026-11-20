import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/design/fs_box_row.dart';
import 'package:forged_and_sent/src/design/fs_button.dart';
import 'package:forged_and_sent/src/features/devotional/presentation/devotional_page.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';
import 'package:integration_test/integration_test.dart';

import 'restart_support.dart';

/// First half of the restart test. See `restart_support.dart` for how the
/// two halves are run.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Amen checks the devotional box', (tester) async {
    await startApp(tester);
    await showDevotionalBox(tester);

    if (devotionalChecked(tester)) {
      // Left over from an earlier run on this device today. Clear it, so
      // this run does the checking itself.
      await tester.tap(devotionalBox);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        amenButton,
        400,
        scrollable: scrollableOf(DevotionalPage).first,
      );
      await tester.tap(amenButton);
      // The undo is stored before the button turns back into Amen.
      await pumpUntil(
        tester,
        () => tester.widget<FsButton>(amenButton).label != 'Amen. Undo',
        what: 'the undo to be saved',
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      await showDevotionalBox(tester);
    }
    expect(devotionalChecked(tester), isFalse);

    await tester.tap(devotionalBox);
    await tester.pumpAndSettle();
    expect(find.byType(DevotionalPage), findsOneWidget);
    expect(tester.widget<FsButton>(amenButton).onPressed, isNull);

    await readToTheEnd(tester);
    await tester.tap(amenButton);
    // Amen saves first and goes back to Today afterwards, so Today is not
    // there the moment the frames settle.
    await pumpUntil(
      tester,
      () => find.byType(TodayPage).evaluate().isNotEmpty,
      what: 'Today, after Amen was saved',
    );

    expect(find.byType(TodayPage), findsOneWidget);
    await showDevotionalBox(tester);
    await pumpUntil(
      tester,
      () => devotionalChecked(tester),
      what: 'the devotional box to be checked',
    );
    expect(devotionalChecked(tester), isTrue);
    expect(tester.widget<FsBoxRow>(devotionalBox).subtitle, 'Read today');
  });
}
