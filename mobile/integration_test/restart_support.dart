import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/main.dart' as app;
import 'package:forged_and_sent/src/design/fs_box_row.dart';
import 'package:forged_and_sent/src/design/fs_button.dart';
import 'package:forged_and_sent/src/features/devotional/presentation/devotional_page.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';

/// Shared by the two halves of the restart test (P05 acceptance 6:
/// complete, kill, relaunch, on the Android emulator).
///
/// A test cannot outlive the app it runs in, so the test is two files, run
/// one after the other with the app's process stopped in between. Each
/// starts the real app: `main()`, the real SQLite file in the app's own
/// folder, the phone's own clock.
///
///     flutter test integration_test/restart_1_complete_test.dart -d <device> --no-uninstall
///     flutter test integration_test/restart_2_verify_test.dart -d <device>
///
/// `--no-uninstall` on the first keeps the app and its data on the device;
/// the test runner stops the app's process when the run ends. The second
/// installs over it, starts a new process, and checks what that process
/// finds. It uninstalls the app afterwards.
///
/// Both must run on the same local day: a box checked before midnight is,
/// correctly, not checked on the next day.

final Finder devotionalBox = find.byKey(
  const ValueKey<String>('fs-box-t_devo'),
);
final Finder amenButton = find.byKey(const ValueKey<String>('fs-amen'));

Finder scrollableOf(Type page) =>
    find.descendant(of: find.byType(page), matching: find.byType(Scrollable));

/// Starts the app as the launcher does and waits for Today's boxes.
Future<void> startApp(WidgetTester tester) async {
  await app.main();
  await tester.pumpAndSettle();
  for (var i = 0; i < 100 && find.byType(FsBoxRow).evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.byType(TodayPage), findsOneWidget);
  expect(find.byType(FsBoxRow), findsWidgets);
}

Future<void> showDevotionalBox(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    devotionalBox,
    120,
    scrollable: scrollableOf(TodayPage).first,
  );
  await tester.pumpAndSettle();
}

bool devotionalChecked(WidgetTester tester) =>
    tester.widget<FsBoxRow>(devotionalBox).checked;

/// Scrolls the reading down with a finger until Amen has a tap to offer.
Future<void> readToTheEnd(WidgetTester tester) async {
  final reading = scrollableOf(DevotionalPage).first;
  for (var i = 0; i < 30; i++) {
    final button = amenButton.evaluate().isEmpty
        ? null
        : tester.widget<FsButton>(amenButton);
    if (button != null && button.onPressed != null) return;
    await tester.drag(reading, const Offset(0, -400));
    await tester.pumpAndSettle();
  }
  fail('The end of the reading was never reached.');
}
