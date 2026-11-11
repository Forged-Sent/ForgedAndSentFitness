import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/design/fs_button.dart';
import 'package:forged_and_sent/src/design/fs_card.dart';
import 'package:forged_and_sent/src/design/fs_colors.dart';
import 'package:forged_and_sent/src/design/fs_hero_header.dart';
import 'package:forged_and_sent/src/design/fs_icons.dart';
import 'package:forged_and_sent/src/design/fs_label_caps.dart';
import 'package:forged_and_sent/src/design/fs_shell.dart';
import 'package:forged_and_sent/src/design/fs_theme.dart';
import 'package:forged_and_sent/src/design/fs_tokens.dart';
import 'package:forged_and_sent/src/design/fs_typography.dart';

import '../support/fs_test_support.dart';

/// Puts [child] on a page in one of the two themes.
Future<void> _pump(
  WidgetTester tester,
  Widget child, {
  bool dark = true,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: dark ? FsTheme.dark : FsTheme.light,
      home: Scaffold(
        body: Align(alignment: Alignment.topLeft, child: child),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

ShapeBorder? _shapeOf(WidgetTester tester, Finder button) => tester
    .widget<Material>(
      find.descendant(of: button, matching: find.byType(Material)),
    )
    .shape;

void main() {
  setUpAll(loadAppFonts);

  group('FsLabelCaps', () {
    testWidgets('shows capitals but is read aloud as written', (tester) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const FsLabelCaps('Coming next'));
      final text = tester.widget<Text>(find.text('COMING NEXT'));
      expect(text.semanticsLabel, 'Coming next');
      expect(text.style?.fontFamily, FsFonts.display);
      expect(text.style?.letterSpacing, FsText.labelCaps.letterSpacing);
      expect(text.style?.color, FsColors.dark.text);
      expect(find.bySemanticsLabel('Coming next'), findsOneWidget);
      handle.dispose();
    });

    testWidgets('takes a color and a smaller style', (tester) async {
      await _pump(
        tester,
        const FsLabelCaps(
          'Stewardship of the body',
          style: FsText.kicker,
          color: FsColors.heroKicker,
        ),
      );
      final text = tester.widget<Text>(find.text('STEWARDSHIP OF THE BODY'));
      expect(text.style?.fontSize, 12.5);
      expect(text.style?.color, FsColors.heroKicker);
    });
  });

  group('FsCard', () {
    for (final dark in <bool>[true, false]) {
      testWidgets('is a bordered surface (${dark ? 'dark' : 'light'})', (
        tester,
      ) async {
        final colors = dark ? FsColors.dark : FsColors.light;
        await _pump(tester, const FsCard(child: Text('Inside')), dark: dark);
        final box = tester.widget<DecoratedBox>(
          find.descendant(
            of: find.byType(FsCard),
            matching: find.byType(DecoratedBox),
          ),
        );
        final decoration = box.decoration as BoxDecoration;
        expect(decoration.color, colors.surface);
        expect(decoration.border, Border.all(color: colors.hairline));
        expect(decoration.borderRadius, BorderRadius.circular(FsRadius.card));
        // 14 points of padding on every side.
        final card = tester.getRect(find.byType(FsCard));
        final inside = tester.getRect(find.text('Inside'));
        expect(inside.left - card.left, FsSpacing.card);
        expect(inside.top - card.top, FsSpacing.card);
      });
    }
  });

  group('FsButton', () {
    testWidgets('primary is the same orange in both themes and taps once', (
      tester,
    ) async {
      for (final dark in <bool>[true, false]) {
        var taps = 0;
        await _pump(
          tester,
          FsButton(label: 'Start', onPressed: () => taps++),
          dark: dark,
        );
        final material = tester.widget<Material>(
          find.descendant(
            of: find.byType(FsButton),
            matching: find.byType(Material),
          ),
        );
        expect(material.color, FsColors.gold);
        final label = tester.widget<Text>(find.text('START'));
        expect(label.style?.color, FsColors.onGold);
        expect(
          tester.getSize(find.byType(FsButton)).height,
          greaterThanOrEqualTo(FsSizes.buttonHeight),
        );
        await tester.tap(find.byType(FsButton));
        expect(taps, 1);
      }
    });

    testWidgets('ghost is outlined in the theme hairline', (tester) async {
      for (final dark in <bool>[true, false]) {
        final colors = dark ? FsColors.dark : FsColors.light;
        await _pump(
          tester,
          FsButton.ghost(label: 'Build status', onPressed: () {}),
          dark: dark,
        );
        final shape =
            _shapeOf(tester, find.byType(FsButton)) as RoundedRectangleBorder;
        expect(shape.side.color, colors.hairline);
        expect(shape.side.width, 1.5);
        expect(shape.borderRadius, BorderRadius.circular(FsRadius.base));
        expect(
          tester.widget<Text>(find.text('BUILD STATUS')).style?.color,
          colors.text,
        );
      }
    });

    testWidgets('mini is small, and accented when selected', (tester) async {
      await _pump(
        tester,
        Row(
          children: <Widget>[
            FsButton.mini(label: 'Today', onPressed: () {}, selected: true),
            FsButton.mini(label: 'This week', onPressed: () {}),
          ],
        ),
      );
      final on = tester.widget<Text>(find.text('TODAY'));
      final off = tester.widget<Text>(find.text('THIS WEEK'));
      expect(on.style?.color, FsColors.dark.accent);
      expect(off.style?.color, FsColors.dark.textMuted);
      expect(on.style?.fontSize, FsText.buttonMini.fontSize);
      expect(
        tester.getSize(find.byType(FsButton).first).height,
        FsSizes.miniButtonHeight,
      );
    });

    testWidgets('a button with nothing to do is disabled, not hidden', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const FsButton(label: 'Save', onPressed: null));
      expect(
        tester.getSemantics(find.byType(FsButton)),
        isSemantics(
          label: 'Save',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
      await tester.tap(find.byType(FsButton), warnIfMissed: false);
      expect(tester.takeException(), isNull);
      handle.dispose();
    });

    testWidgets('a long label wraps instead of overflowing', (tester) async {
      await _pump(
        tester,
        SizedBox(
          width: 160,
          child: FsButton(
            label: 'Ask a brother to be your Timothy',
            onPressed: () {},
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(FsButton)).height,
        greaterThan(FsSizes.buttonHeight),
      );
    });
  });

  group('FsHeroHeader', () {
    const actions = <FsHeroAction>[
      FsHeroAction(FsHeroActionKind.search, label: 'Search'),
      FsHeroAction(FsHeroActionKind.help, label: 'How this page works'),
      FsHeroAction(FsHeroActionKind.journal, label: 'New journal entry'),
      FsHeroAction(FsHeroActionKind.tags, label: 'Tags'),
      FsHeroAction(FsHeroActionKind.profile, label: 'Your profile'),
    ];

    testWidgets('shows the small caps line, the title and the line under it', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const FsHeroHeader(
          large: true,
          kicker: 'Tuesday, November 10',
          title: 'Today’s Mission',
          subtitle: 'Faith. Fitness. Brotherhood.',
          actions: actions,
        ),
      );
      expect(find.text('TUESDAY, NOVEMBER 10'), findsOneWidget);
      final title = tester.widget<Text>(find.text('TODAY’S MISSION'));
      expect(title.style?.fontSize, FsText.heroTitleLarge.fontSize);
      expect(title.style?.color, FsColors.heroInk);
      expect(find.text('FAITH. FITNESS. BROTHERHOOD.'), findsOneWidget);
      expect(
        tester.getSemantics(find.text('TODAY’S MISSION')),
        isSemantics(label: 'Today’s Mission', isHeader: true),
      );
      // Today's layout: the buttons sit on their own row under the date.
      final date = tester.getRect(find.text('TUESDAY, NOVEMBER 10'));
      final firstIcon = tester.getRect(find.byType(FsIcon).first);
      expect(firstIcon.top, greaterThan(date.bottom));
      handle.dispose();
    });

    testWidgets('other pages put the buttons beside the small caps line', (
      tester,
    ) async {
      await _pump(
        tester,
        const FsHeroHeader(
          kicker: 'Carry each other',
          title: 'Standings',
          actions: actions,
        ),
      );
      final title = tester.widget<Text>(find.text('STANDINGS'));
      expect(title.style?.fontSize, FsText.heroTitle.fontSize);
      final kicker = tester.getRect(find.text('CARRY EACH OTHER'));
      final firstIcon = tester.getRect(find.byType(FsIcon).first);
      expect(firstIcon.left, greaterThan(kicker.right));
      expect(firstIcon.center.dy, closeTo(kicker.center.dy, 14));
      // The orange rule closes the header.
      final rule = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(FsHeroHeader),
          matching: find.byWidgetPredicate(
            (w) => w is ColoredBox && w.color == FsColors.gold,
          ),
        ),
      );
      expect(rule.color, FsColors.gold);
    });

    testWidgets('without the help buttons the small caps line sits lower', (
      tester,
    ) async {
      // As in the prototype: centered against the buttons on pages that
      // have search and help, on the buttons' text baseline on Walk.
      Future<double> kickerTop(List<FsHeroAction> shown) async {
        await _pump(
          tester,
          FsHeroHeader(
            kicker: 'Walk with your brothers',
            title: 'Walk',
            actions: shown,
          ),
        );
        return tester.getRect(find.text('WALK WITH YOUR BROTHERS')).top;
      }

      // The row of buttons starts 18 points down and is 40 tall, the height
      // of the profile button.
      final withHelp = await kickerTop(actions);
      final lineHeight = tester
          .getSize(find.text('WALK WITH YOUR BROTHERS'))
          .height;
      expect(
        withHelp,
        closeTo(FsSpacing.heroTop + (40 - lineHeight) / 2, 0.01),
      );
      final walk = await kickerTop(actions.sublist(2));
      expect(walk, closeTo(FsSpacing.heroTop + 18, 0.01));
      // With no buttons at all there is nothing to line up with.
      final alone = await kickerTop(const <FsHeroAction>[]);
      expect(alone, closeTo(FsSpacing.heroTop, 0.01));
    });

    testWidgets('buttons with no action are drawn but not announced', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(tester, const FsHeroHeader(title: 'Fuel', actions: actions));
      // Three line icons (search, journal, tags), the person, and the "i".
      expect(find.byType(FsIcon), findsNWidgets(4));
      expect(find.text('i'), findsOneWidget);
      for (final action in actions) {
        expect(find.bySemanticsLabel(action.label), findsNothing);
      }
      handle.dispose();
    });

    testWidgets('a button with an action is announced and can be tapped', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var opened = 0;
      await _pump(
        tester,
        FsHeroHeader(
          title: 'Fuel',
          actions: <FsHeroAction>[
            FsHeroAction(
              FsHeroActionKind.journal,
              label: 'New journal entry',
              onPressed: () => opened++,
            ),
          ],
        ),
      );
      expect(find.bySemanticsLabel('New journal entry'), findsOneWidget);
      await tester.tap(find.byType(FsIcon));
      expect(opened, 1);
      handle.dispose();
    });

    testWidgets('the journal ring follows the theme; the rest do not', (
      tester,
    ) async {
      for (final dark in <bool>[true, false]) {
        final colors = dark ? FsColors.dark : FsColors.light;
        await _pump(
          tester,
          const FsHeroHeader(title: 'Fuel', actions: actions),
          dark: dark,
        );
        final icons = tester.widgetList<FsIcon>(find.byType(FsIcon)).toList();
        expect(icons[0].color, FsColors.heroButtonInk); // search
        expect(icons[1].color, colors.accent); // journal
        expect(icons[2].color, FsColors.heroButtonInk); // tags
        expect(icons[3].color, colors.text); // profile
      }
    });

    testWidgets('grows with long text instead of clipping it', (tester) async {
      await _pump(
        tester,
        const SizedBox(
          width: 320,
          child: FsHeroHeader(
            kicker: 'Stewardship of the body and of the day',
            title: 'A title long enough to take two lines',
            subtitle: 'And a line under it that also runs on past one line',
            actions: actions,
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(
        tester.getSize(find.byType(FsHeroHeader)).height,
        greaterThan(160),
      );
    });
  });

  group('FsIcon', () {
    testWidgets('every icon draws at its size', (tester) async {
      const icons = <FsIconData>[
        FsIcons.today,
        FsIcons.fuel,
        FsIcons.train,
        FsIcons.walk,
        FsIcons.board,
        FsIcons.rally,
        FsIcons.search,
        FsIcons.journal,
        FsIcons.bell,
        FsIcons.person,
        FsIcons.shield,
      ];
      await _pump(
        tester,
        Wrap(
          children: <Widget>[
            for (final icon in icons) FsIcon(icon, color: FsColors.tabActive),
          ],
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byType(FsIcon), findsNWidgets(icons.length));
      // Each path stays inside the box it is written for.
      for (final icon in icons) {
        final bounds = icon.path().getBounds();
        expect(bounds.left, greaterThanOrEqualTo(0));
        expect(bounds.top, greaterThanOrEqualTo(0));
        expect(bounds.right, lessThanOrEqualTo(icon.viewBox.width));
        expect(bounds.bottom, lessThanOrEqualTo(icon.viewBox.height));
      }
      // The shield is taller than it is wide; the rest are square.
      expect(
        tester.getSize(find.byType(FsIcon).last),
        const Size(24, 24 * 150 / 132),
      );
      expect(tester.getSize(find.byType(FsIcon).first), const Size(24, 24));
    });
  });

  group('FsShell', () {
    testWidgets('reports the tapped tab and marks the current one', (
      tester,
    ) async {
      final tapped = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          theme: FsTheme.light,
          home: FsShell(
            destinations: const <FsShellDestination>[
              FsShellDestination(label: 'Today', icon: FsIcons.today),
              FsShellDestination(label: 'Fuel', icon: FsIcons.fuel),
            ],
            currentIndex: 1,
            onSelect: tapped.add,
            child: const Text('Page'),
          ),
        ),
      );
      expect(find.text('Page'), findsOneWidget);
      expect(find.text('FORGED & SENT'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('FUEL')).style?.color,
        FsColors.tabActive,
      );
      expect(
        tester.widget<Text>(find.text('TODAY')).style?.color,
        FsColors.tabInactive,
      );
      await tester.tap(tab('Today'));
      await tester.tap(tab('Fuel'));
      expect(tapped, <int>[0, 1]);
    });

    testWidgets('the bars cover the status bar and the home indicator', (
      tester,
    ) async {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(390, 844),
            padding: EdgeInsets.only(top: 47, bottom: 34),
          ),
          child: MaterialApp(
            theme: FsTheme.dark,
            home: FsShell(
              destinations: const <FsShellDestination>[
                FsShellDestination(label: 'Today', icon: FsIcons.today),
              ],
              currentIndex: 0,
              onSelect: (_) {},
              child: const SizedBox.expand(key: ValueKey<String>('page')),
            ),
          ),
        ),
      );
      final brand = tester.getRect(find.text('FORGED & SENT'));
      expect(brand.top, greaterThan(47));
      final page = tester.getRect(find.byKey(const ValueKey<String>('page')));
      expect(page.top, 47 + FsSizes.brandBar);
      final tabRect = tester.getRect(tab('Today'));
      final screen = tester.getRect(find.byType(FsShell));
      expect(screen.bottom - tabRect.bottom, 34);
      // The page ends exactly where the tab bar begins.
      expect(page.bottom, tabRect.top);
    });
  });
}
