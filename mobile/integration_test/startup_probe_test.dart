import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/main.dart' as app;
import 'package:forged_and_sent/src/app/forged_sent_app.dart';
import 'package:forged_and_sent/src/app/open_local_store.dart';
import 'package:forged_and_sent/src/design/fs_box_row.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

/// A probe, not a test of the app's behavior: it starts the real app
/// exactly as `startApp` in `restart_support.dart` does, with the same
/// waits, and writes down what happened and how long each step took.
///
/// When Today is not on screen at the point where the restart tests give
/// up, it says what is on screen, goes on waiting to see whether Today
/// arrives late, and then tries the storage steps one by one to find the
/// one that fails. Every line starts with `STARTUP PROBE:`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('start-up probe', (tester) async {
    final clock = Stopwatch()..start();
    void say(String message) =>
        debugPrint('STARTUP PROBE: ${clock.elapsedMilliseconds} ms: $message');

    say('calling main');
    await app.main();
    say('main returned');
    await tester.pumpAndSettle();
    say('settled');
    var pumps = 0;
    while (pumps < 100 && find.byType(FsBoxRow).evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 100));
      pumps++;
    }
    final today = find.byType(TodayPage).evaluate().length;
    final boxes = find.byType(FsBoxRow).evaluate().length;
    final status = find.byType(FoundationHomeScreen).evaluate().length;
    final ok = today == 1 && boxes > 0;
    say(
      'where the restart tests look: today=$today boxes=$boxes '
      'statusPage=$status afterPumps=$pumps',
    );

    if (!ok) {
      final texts = tester
          .widgetList<Text>(find.byType(Text))
          .map((Text text) => text.data ?? text.textSpan?.toPlainText() ?? '')
          .where((String text) => text.trim().isNotEmpty)
          .take(30)
          .toList();
      say('on screen: ${texts.join(' | ')}');

      // Does Today arrive late? One more minute.
      var late = 0;
      while (late < 600 && find.byType(TodayPage).evaluate().isEmpty) {
        await tester.pump(const Duration(milliseconds: 100));
        late++;
      }
      say(
        find.byType(TodayPage).evaluate().isEmpty
            ? 'Today did not arrive in a further minute'
            : 'Today arrived late, after ${late * 100} ms more',
      );

      // The storage steps, one by one, as the app takes them.
      try {
        final temp = await getTemporaryDirectory();
        say('temporary directory: ok, exists=${temp.existsSync()}');
      } catch (error) {
        say('temporary directory FAILED: ${error.runtimeType}: $error');
      }
      Directory? support;
      try {
        support = await getApplicationSupportDirectory();
        final names = support.existsSync()
            ? support
                  .listSync()
                  .map((FileSystemEntity e) => e.uri.pathSegments.last)
                  .join(',')
            : '(missing)';
        say('support directory: ok, holds: $names');
      } catch (error) {
        say('support directory FAILED: ${error.runtimeType}: $error');
      }
      try {
        final store = await openLocalStore();
        say('opening the store again: ok');
        await store.close();
      } catch (error) {
        say('opening the store again FAILED: ${error.runtimeType}: $error');
      }
    }

    say('RESULT ${ok ? 'ok' : 'FAILED'}');
    expect(ok, isTrue, reason: 'Today was not on screen with its boxes.');
  });
}
