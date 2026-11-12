import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/forged_sent_app.dart';
import 'package:forged_and_sent/src/design/fs_box_row.dart';
import 'package:forged_and_sent/src/design/fs_hero_header.dart';
import 'package:forged_and_sent/src/features/devotional/domain/devotional.dart';
import 'package:forged_and_sent/src/features/settings/presentation/settings_page.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';

import '../../support/fs_test_support.dart';

final Finder _switch = find.byKey(const ValueKey<String>('fs-preview-points'));

bool _switchOn(WidgetTester tester) => tester.widget<Switch>(_switch).value;

Future<void> _backToToday(WidgetTester tester) async {
  await systemBack(tester);
  expect(find.byType(TodayPage), findsOneWidget);
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('the profile button in Today\'s header opens Settings', (
    tester,
  ) async {
    await pumpApp(tester);
    await openSettings(tester);

    expect(find.byType(SettingsPage), findsOneWidget);
    expect(find.text('SETTINGS'), findsOneWidget);
    expect(find.text('Points'), findsOneWidget);
    expect(find.text('Scripture'), findsOneWidget);
    expect(find.text('This build'), findsOneWidget);
    // Both credit lines, word for word.
    expect(find.text(ScriptureNotices.bsb), findsOneWidget);
    expect(find.text(ScriptureNotices.esv), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('‹ BACK'));
    await tester.pumpAndSettle();
    expect(find.byType(TodayPage), findsOneWidget);
  });

  group('the preview points switch (decision Q5)', () {
    testWidgets('is off by default, and Today shows no point values', (
      tester,
    ) async {
      await pumpApp(tester);
      expect(find.textContaining('PTS'), findsNothing);

      await openSettings(tester);
      expect(_switchOn(tester), isFalse);
      // What the values are is said beside the switch.
      expect(find.textContaining('Preview, not official.'), findsOneWidget);
    });

    testWidgets('turned on, Today shows the prototype\'s values, labelled', (
      tester,
    ) async {
      await pumpApp(tester);
      await openSettings(tester);

      await tester.tap(_switch);
      await tester.pumpAndSettle();
      expect(_switchOn(tester), isTrue);

      await _backToToday(tester);
      await showBox(tester, 't_devo');
      expect(find.text('POINTS: PREVIEW, NOT OFFICIAL'), findsOneWidget);
      expect(tester.widget<FsBoxRow>(box('t_devo')).points, '+2 pts');
      expect(tester.widget<FsBoxRow>(box('t_workout')).points, '+3 pts');
      expect(tester.widget<FsBoxRow>(box('t_steps')).points, '+1 pt');
      // Values per box only. Nothing adds them up.
      expect(find.textContaining('WEEK'), findsNothing);
      expect(find.textContaining('TOTAL'), findsNothing);

      // And off again hides them.
      await scrollTodayToTop(tester);
      await openSettings(tester);
      await tester.tap(_switch);
      await tester.pumpAndSettle();
      await _backToToday(tester);
      expect(find.text('POINTS: PREVIEW, NOT OFFICIAL'), findsNothing);
      expect(tester.widget<FsBoxRow>(box('t_devo')).points, isNull);
    });

    testWidgets('is kept in the member\'s store', (tester) async {
      final app = await pumpApp(tester);
      await openSettings(tester);
      await tester.tap(_switch);
      await tester.pumpAndSettle();

      final stored = await tester.runAsync(
        () => app.store.settings.watchShowPreviewPoints().first,
      );
      expect(stored, isTrue);
    });

    testWidgets('a screen reader hears the switch with its name', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester);
      await semanticsTap(tester, heroButton(FsHeroActionKind.profile));
      expect(find.byType(SettingsPage), findsOneWidget);

      expect(
        tester.getSemantics(_switch),
        isSemantics(
          label: 'Show point values',
          hasToggledState: true,
          isToggled: false,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });

  testWidgets('Build status is reached from Settings', (tester) async {
    await pumpApp(tester);
    await openStatusPage(tester);

    expect(find.byType(FoundationHomeScreen), findsOneWidget);
    expect(
      find.text('Preview mode. No Firebase cloud connection configured.'),
      findsOneWidget,
    );
  });

  testWidgets('storage that could not be opened is explained first', (
    tester,
  ) async {
    await pumpApp(tester, storageFailed: true);

    // The explanation is the first thing on screen.
    expect(find.byType(FoundationHomeScreen), findsOneWidget);
    expect(
      find.text(
        'Local storage could not be opened. Nothing is saved on this device.',
      ),
      findsOneWidget,
    );
    expect(find.text('Close the app and open it again.'), findsOneWidget);
    // It is not mistaken for an emulator problem.
    expect(find.textContaining('emulator'), findsNothing);
  });

  for (final scale in <double>[1.3, 2.0]) {
    testWidgets('nothing overflows at $scale times the text size', (
      tester,
    ) async {
      await pumpApp(tester, textScale: scale);
      await openSettings(tester);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('BUILD STATUS'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
