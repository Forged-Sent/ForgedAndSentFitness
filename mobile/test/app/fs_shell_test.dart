import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/app/forged_sent_app.dart';
import 'package:forged_and_sent/src/core/date_text.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/design/fs_button.dart';
import 'package:forged_and_sent/src/design/fs_colors.dart';
import 'package:forged_and_sent/src/design/fs_hero_header.dart';
import 'package:forged_and_sent/src/design/fs_shell.dart';
import 'package:forged_and_sent/src/features/devotional/presentation/devotional_page.dart';
import 'package:forged_and_sent/src/features/settings/presentation/settings_page.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';

import '../support/fs_test_support.dart';

/// The six tabs of decision Q1 (v254), with each page's header title.
const List<(String label, String title)> _tabs = <(String, String)>[
  ('Today', 'TODAY’S MISSION'),
  ('Fuel', 'FUEL'),
  ('Train', 'TRAIN'),
  ('Walk', 'WALK'),
  ('Board', 'STANDINGS'),
  ('Rally', 'RALLY'),
];

/// How far the page on screen is scrolled.
double _scrollOffset(WidgetTester tester) => tester
    .state<ScrollableState>(find.byType(Scrollable).first)
    .position
    .pixels;

/// Whether the shell shows [label] as the tab the member is on.
bool _isCurrent(WidgetTester tester, String label) {
  final shell = tester.widget<FsShell>(find.byType(FsShell));
  return shell.destinations[shell.currentIndex].label == label;
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('the bottom bar has the six tabs of decision Q1, in order', (
    tester,
  ) async {
    await pumpApp(tester);
    final shell = tester.widget<FsShell>(find.byType(FsShell));
    expect(shell.destinations.map((d) => d.label), <String>[
      'Today',
      'Fuel',
      'Train',
      'Walk',
      'Board',
      'Rally',
    ]);
    // Left to right on screen, each at least 48 points to tap.
    var previousLeft = -1.0;
    for (final (label, _) in _tabs) {
      final rect = tester.getRect(tab(label));
      expect(rect.left, greaterThan(previousLeft), reason: label);
      expect(rect.width, greaterThanOrEqualTo(48), reason: label);
      expect(rect.height, greaterThanOrEqualTo(48), reason: label);
      previousLeft = rect.left;
    }
    // v254 has no Campaign tab; that is main's older bar.
    expect(find.text('CAMPAIGN'), findsNothing);
  });

  testWidgets('each tab opens its own page and is marked as current', (
    tester,
  ) async {
    await pumpApp(tester);
    expect(_isCurrent(tester, 'Today'), isTrue);
    expect(find.text('TUESDAY, NOVEMBER 10'), findsOneWidget);
    expect(find.byType(TodayPage), findsOneWidget);

    for (final (label, title) in _tabs.skip(1)) {
      await openTab(tester, label);
      expect(find.text(title), findsWidgets, reason: label);
      expect(find.text('NOT BUILT YET'), findsOneWidget, reason: label);
      expect(
        find.text('$label arrives in a later step.'),
        findsOneWidget,
        reason: label,
      );
      expect(_isCurrent(tester, label), isTrue, reason: label);
      expect(_isCurrent(tester, 'Today'), isFalse, reason: label);
      // The brand bar and the tab bar stay put.
      expect(find.text('FORGED & SENT'), findsOneWidget, reason: label);
    }

    await openTab(tester, 'Today');
    expect(find.text('TODAY’S MISSION'), findsOneWidget);
    expect(_isCurrent(tester, 'Today'), isTrue);
  });

  testWidgets('Android back from a nested page returns to its tab', (
    tester,
  ) async {
    await pumpApp(tester);
    await openDevotional(tester);
    expect(find.byType(DevotionalPage), findsOneWidget);
    // The nested page sits inside the shell: the bars are still there.
    expect(find.text('FORGED & SENT'), findsOneWidget);
    expect(_isCurrent(tester, 'Today'), isTrue);

    await systemBack(tester);
    expect(find.byType(DevotionalPage), findsNothing);
    expect(find.byType(TodayPage), findsOneWidget);
    expect(_isCurrent(tester, 'Today'), isTrue);

    // The Back button in the page's own bar does the same.
    await openDevotional(tester);
    await tester.tap(find.widgetWithText(FsButton, '‹ BACK'));
    await tester.pumpAndSettle();
    expect(find.byType(DevotionalPage), findsNothing);
    expect(find.byType(TodayPage), findsOneWidget);
  });

  testWidgets('back from Build status returns to Settings, then to Today', (
    tester,
  ) async {
    await pumpApp(tester);
    await openStatusPage(tester);
    expect(find.byType(FoundationHomeScreen), findsOneWidget);
    expect(find.text('FORGED & SENT'), findsOneWidget);

    await systemBack(tester);
    expect(find.byType(FoundationHomeScreen), findsNothing);
    expect(find.byType(SettingsPage), findsOneWidget);

    await systemBack(tester);
    expect(find.byType(SettingsPage), findsNothing);
    expect(find.text('TODAY’S MISSION'), findsOneWidget);

    // The back arrow in the status page's own bar goes to Settings too.
    await openStatusPage(tester);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsPage), findsOneWidget);
  });

  testWidgets('a tab keeps its own stack while another tab is open', (
    tester,
  ) async {
    await pumpApp(tester);
    await openDevotional(tester);

    await openTab(tester, 'Fuel');
    expect(find.byType(DevotionalPage), findsNothing);
    expect(find.text('FUEL'), findsWidgets);

    // Back on Today, the nested page is still open.
    await openTab(tester, 'Today');
    expect(find.byType(DevotionalPage), findsOneWidget);

    // Back from there returns to Today's first page, not to Fuel.
    await systemBack(tester);
    expect(find.byType(TodayPage), findsOneWidget);
    expect(_isCurrent(tester, 'Today'), isTrue);

    // Tapping the tab he is on returns it to its first page.
    await openDevotional(tester);
    await openTab(tester, 'Today');
    expect(find.byType(DevotionalPage), findsNothing);
    expect(find.byType(TodayPage), findsOneWidget);
  });

  testWidgets('each tab keeps its scroll position', (tester) async {
    // A short screen, so both pages are taller than what shows.
    await pumpApp(tester, size: const Size(390, 300));
    expect(_scrollOffset(tester), 0);

    await tester.drag(find.byType(Scrollable).first, const Offset(0, -150));
    await tester.pumpAndSettle();
    final todayOffset = _scrollOffset(tester);
    expect(todayOffset, greaterThan(100));

    await openTab(tester, 'Fuel');
    expect(_scrollOffset(tester), 0);
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -30));
    await tester.pumpAndSettle();
    final fuelOffset = _scrollOffset(tester);
    expect(fuelOffset, greaterThan(10));
    expect(fuelOffset, isNot(todayOffset));

    await openTab(tester, 'Today');
    expect(_scrollOffset(tester), todayOffset);
    await openTab(tester, 'Fuel');
    expect(_scrollOffset(tester), fuelOffset);

    // A third tab and back again changes neither.
    await openTab(tester, 'Rally');
    await openTab(tester, 'Today');
    expect(_scrollOffset(tester), todayOffset);
  });

  for (final scale in <double>[1.3, 2.0]) {
    testWidgets('nothing overflows at $scale times the text size', (
      tester,
    ) async {
      // Any overflow is thrown as an error while the frame is laid out,
      // which fails the test at the line that caused it.
      await pumpApp(tester, textScale: scale);
      expect(tester.takeException(), isNull);
      for (final (label, _) in _tabs.skip(1)) {
        await openTab(tester, label);
        expect(tester.takeException(), isNull, reason: label);
      }
      await openTab(tester, 'Today');
      await openStatusPage(tester);
      expect(tester.takeException(), isNull, reason: 'status page');
      expect(find.byType(FoundationHomeScreen), findsOneWidget);
    });
  }

  testWidgets('the same holds on a small phone at 1.3 times the text size', (
    tester,
  ) async {
    await pumpApp(tester, size: const Size(320, 568), textScale: 1.3);
    expect(tester.takeException(), isNull);
    for (final (label, _) in _tabs.skip(1)) {
      await openTab(tester, label);
      expect(tester.takeException(), isNull, reason: label);
    }
  });

  testWidgets('dark and light follow the phone, and the bars stay dark', (
    tester,
  ) async {
    Color pageColor() =>
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor!;

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.light;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await pumpApp(tester, themeMode: ThemeMode.system);
    expect(pageColor(), FsColors.light.background);

    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    await tester.pumpAndSettle();
    expect(pageColor(), FsColors.dark.background);

    // The tab bar is the same dark surface in both.
    final bar = tester.widget<Material>(
      find.ancestor(of: tab('Today'), matching: find.byType(Material)).first,
    );
    expect(bar.color, FsColors.night);
  });

  testWidgets('a screen reader hears each tab as a button, and which is on', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester);
    expect(
      tester.getSemantics(tab('Today')),
      isSemantics(label: 'Today', isButton: true, isSelected: true),
    );
    expect(
      tester.getSemantics(tab('Walk')),
      isSemantics(label: 'Walk', isButton: true, isSelected: false),
    );
    await openTab(tester, 'Walk');
    expect(
      tester.getSemantics(tab('Walk')),
      isSemantics(label: 'Walk', isButton: true, isSelected: true),
    );
    // The page title is announced as a heading, in its written case.
    expect(find.bySemanticsLabel('Walk'), findsWidgets);
    // The round header buttons do nothing yet, so they are not announced.
    expect(find.bySemanticsLabel('New journal entry'), findsNothing);
    expect(find.bySemanticsLabel('Your profile'), findsNothing);
    handle.dispose();
  });

  testWidgets('a screen reader can open every tab, Settings and Build status', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester);
    // Last to first, so each tab is opened from a different one. No pointer
    // touches the screen: the action goes through the semantics tree.
    for (final (label, title) in _tabs.reversed) {
      await semanticsTap(tester, tab(label));
      expect(_isCurrent(tester, label), isTrue, reason: label);
      expect(find.text(title), findsWidgets, reason: label);
    }
    expect(find.byType(TodayPage), findsOneWidget);

    // The profile button in Today's header opens Settings the same way,
    // and the button there opens the status page.
    await semanticsTap(tester, heroButton(FsHeroActionKind.profile));
    expect(find.byType(SettingsPage), findsOneWidget);
    await semanticsTap(tester, find.widgetWithText(FsButton, 'BUILD STATUS'));
    expect(find.byType(FoundationHomeScreen), findsOneWidget);

    // Activating the tab he is on returns it to its first page, as a tap does.
    await semanticsTap(tester, tab('Today'));
    expect(find.byType(FoundationHomeScreen), findsNothing);
    expect(find.text('TODAY’S MISSION'), findsOneWidget);
    handle.dispose();
  });

  test('the date line reads as the prototype writes it', () {
    expect(heroDateLine(const LocalDate(2026, 11, 10)), 'Tuesday, November 10');
    expect(heroDateLine(const LocalDate(2027, 1, 3)), 'Sunday, January 3');
    expect(
      heroDateLine(const LocalDate(2026, 12, 31)),
      'Thursday, December 31',
    );
  });
}
