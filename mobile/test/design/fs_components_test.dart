import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/design/fs_balanced.dart';
import 'package:forged_and_sent/src/design/fs_button.dart';
import 'package:forged_and_sent/src/design/fs_card.dart';
import 'package:forged_and_sent/src/design/fs_colors.dart';
import 'package:forged_and_sent/src/design/fs_hero_header.dart';
import 'package:forged_and_sent/src/design/fs_icons.dart';
import 'package:forged_and_sent/src/design/fs_label_caps.dart';
import 'package:forged_and_sent/src/design/fs_ruled.dart';
import 'package:forged_and_sent/src/design/fs_shell.dart';
import 'package:forged_and_sent/src/design/fs_tag.dart';
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

    testWidgets('a screen reader can press each kind of button', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      final pressed = <String>[];
      await _pump(
        tester,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            FsButton(label: 'Start', onPressed: () => pressed.add('primary')),
            FsButton.ghost(
              label: 'Build status',
              onPressed: () => pressed.add('ghost'),
            ),
            FsButton.mini(
              label: 'This week',
              onPressed: () => pressed.add('mini'),
            ),
            const FsButton(label: 'Save', onPressed: null),
          ],
        ),
      );
      // Through the semantics tree, with no pointer on the screen.
      await semanticsTap(tester, find.widgetWithText(FsButton, 'START'));
      expect(pressed, <String>['primary']);
      await semanticsTap(tester, find.widgetWithText(FsButton, 'BUILD STATUS'));
      await semanticsTap(tester, find.widgetWithText(FsButton, 'THIS WEEK'));
      expect(pressed, <String>['primary', 'ghost', 'mini']);

      // A disabled button offers no tap, so there is nothing to activate.
      final disabled = tester.semantics.find(
        find.widgetWithText(FsButton, 'SAVE'),
      );
      expect(
        disabled.getSemanticsData().hasAction(SemanticsAction.tap),
        isFalse,
      );
      expect(
        () => tester.semantics.tap(
          find.semantics.byPredicate(
            (SemanticsNode node) => node.id == disabled.id,
          ),
        ),
        throwsStateError,
      );
      expect(pressed, hasLength(3));
      handle.dispose();
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

    testWidgets('balances the line under the title, as the prototype does', (
      tester,
    ) async {
      const line =
          'Confess it, drop it, move forward. '
          'Grace covers the man who gets back up.';
      await _pump(
        tester,
        const SizedBox(
          width: 390,
          child: FsHeroHeader(
            large: true,
            kicker: 'Thursday, November 12',
            title: 'Today’s Mission',
            subtitle: line,
            actions: actions,
          ),
        ),
      );
      // Flutter alone would fill the first line as far as "GRACE COVERS".
      expect(linesOf(tester, find.text(line.toUpperCase())), <String>[
        'CONFESS IT, DROP IT, MOVE FORWARD.',
        'GRACE COVERS THE MAN WHO GETS BACK UP.',
      ]);
      expect(find.byType(FsBalanced), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('every bundled mission line is drawn whole', (tester) async {
      final lines =
          ((json.decode(File('assets/content/missions.json').readAsStringSync())
                      as Map<String, dynamic>)['lines']
                  as List<dynamic>)
              .cast<String>();
      expect(lines, hasLength(14));
      for (final width in <double>[390, 320]) {
        for (final line in lines) {
          await _pump(
            tester,
            SizedBox(
              width: width,
              child: FsHeroHeader(
                large: true,
                kicker: 'Thursday, November 12',
                title: 'Today’s Mission',
                subtitle: line,
                actions: actions,
              ),
            ),
          );
          expect(tester.takeException(), isNull, reason: '$width: $line');
          final drawn = linesOf(tester, find.text(line.toUpperCase()));
          // No word is lost or cut, and balancing adds no line.
          expect(drawn.join(' '), line.toUpperCase(), reason: '$width: $line');
          expect(drawn.length, lessThanOrEqualTo(3), reason: '$width: $line');
          final right = tester.getRect(find.text(line.toUpperCase())).right;
          expect(right, lessThanOrEqualTo(width - FsSpacing.page));
        }
      }
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
      // And through the semantics tree, as a screen reader does it.
      await semanticsTap(tester, find.byType(FsIcon));
      expect(opened, 2);
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

  group('FsReadingHeader', () {
    const tag = FsTag(label: 'Sent: take it to someone', icon: FsIcons.sent);

    testWidgets('sets the headline under the date and the tags under it', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await _pump(
        tester,
        const FsReadingHeader(
          kicker: 'January · New Start',
          title: 'January 7',
          headline: 'No condemnation. Not one ounce.',
          tags: <FsTag>[tag],
          note: 'A line about the month.',
        ),
      );

      final headline = tester.widget<Text>(
        find.text('NO CONDEMNATION. NOT ONE OUNCE.'),
      );
      expect(headline.semanticsLabel, 'No condemnation. Not one ounce.');
      expect(headline.style?.fontFamily, FsFonts.display);
      expect(headline.style?.fontSize, 22);
      expect(headline.style?.fontWeight, FontWeight.w700);
      expect(headline.style?.color, FsColors.heroInk);
      expect(
        tester.getSemantics(find.text('January 7')),
        isSemantics(label: 'January 7', isHeader: true),
      );

      // The prototype's spacing: 8 under the date, 12 above the tags, 10
      // above the line about the month.
      final date = tester.getRect(find.text('January 7'));
      final words = tester.getRect(
        find.text('NO CONDEMNATION. NOT ONE OUNCE.'),
      );
      final pill = tester.getRect(find.byType(FsTag));
      final note = tester.getRect(find.text('A line about the month.'));
      expect(words.top - date.bottom, moreOrLessEquals(8, epsilon: 0.01));
      expect(pill.top - words.bottom, moreOrLessEquals(12, epsilon: 0.01));
      expect(note.top - pill.bottom, moreOrLessEquals(10, epsilon: 0.01));
      // One line of 22-point type at a line height of 1.15.
      expect(words.height, moreOrLessEquals(25.3, epsilon: 0.5));
      handle.dispose();
    });

    testWidgets('keeps its earlier spacing where there is no headline', (
      tester,
    ) async {
      await _pump(
        tester,
        const FsReadingHeader(
          kicker: 'November · Gratitude and Contentment',
          title: 'November 12',
          note: 'A line about the month.',
        ),
      );
      final kicker = tester.getRect(
        find.text('NOVEMBER · GRATITUDE AND CONTENTMENT'),
      );
      final date = tester.getRect(find.text('November 12'));
      final note = tester.getRect(find.text('A line about the month.'));
      expect(date.top - kicker.bottom, moreOrLessEquals(6, epsilon: 0.01));
      expect(note.top - date.bottom, moreOrLessEquals(6, epsilon: 0.01));
      expect(find.byType(FsTag), findsNothing);
    });

    testWidgets('a series line stands between the date and the headline', (
      tester,
    ) async {
      await _pump(
        tester,
        const FsReadingHeader(
          kicker: 'February · Love',
          title: 'February 7',
          series: 'A series of readings',
          headline: 'A headline',
        ),
      );
      final date = tester.getRect(find.text('February 7'));
      final series = tester.getRect(find.text('A SERIES OF READINGS'));
      final words = tester.getRect(find.text('A HEADLINE'));
      expect(series.top - date.bottom, moreOrLessEquals(8, epsilon: 0.01));
      expect(words.top - series.bottom, moreOrLessEquals(14, epsilon: 0.01));
    });

    testWidgets('a series line with no headline has 12 above the month line', (
      tester,
    ) async {
      // The prototype gives the series line a margin of 6 below it, on top
      // of the header's gap of 6: 12 to the line about the month, measured
      // in v254 with its headline hidden. Step S1 had 6 here. No bundled
      // reading is in this case, because every one has a headline.
      await _pump(
        tester,
        const FsReadingHeader(
          kicker: 'February · Love',
          title: 'February 7',
          series: 'A series of readings',
          note: 'A line about the month.',
        ),
      );
      final date = tester.getRect(find.text('February 7'));
      final series = tester.getRect(find.text('A SERIES OF READINGS'));
      final note = tester.getRect(find.text('A line about the month.'));
      expect(series.top - date.bottom, moreOrLessEquals(8, epsilon: 0.01));
      expect(note.top - series.bottom, moreOrLessEquals(12, epsilon: 0.01));
      expect(find.byType(FsBalanced), findsNothing);
    });

    testWidgets('long words and two tags wrap instead of overflowing', (
      tester,
    ) async {
      await _pump(
        tester,
        const SizedBox(
          width: 240,
          child: FsReadingHeader(
            kicker: 'January · New Start',
            title: 'January 3',
            headline:
                'A headline long enough to need three lines at this width',
            tags: <FsTag>[
              tag,
              FsTag(
                label: 'Spirit-led',
                icon: FsIcons.flame,
                tone: FsTagTone.gold,
              ),
            ],
            note: 'A line about the month.',
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final pills = find.byType(FsTag);
      expect(pills, findsNWidgets(2));
      // The second pill has gone to a line of its own.
      expect(
        tester.getRect(pills.last).top,
        greaterThanOrEqualTo(tester.getRect(pills.first).bottom),
      );
      for (final pill in pills.evaluate()) {
        final box = pill.renderObject! as RenderBox;
        final right = box.localToGlobal(Offset(box.size.width, 0)).dx;
        expect(right, lessThanOrEqualTo(240 - FsSpacing.page));
      }
    });
  });

  group('FsBalanced', () {
    /// The width of each line of the text found by [words].
    List<double> lineWidths(WidgetTester tester, Finder words) {
      final paragraph = tester.renderObject<RenderParagraph>(words);
      final length = paragraph.text.toPlainText().length;
      final boxes = paragraph.getBoxesForSelection(
        TextSelection(baseOffset: 0, extentOffset: length),
      );
      final lines = <double, (double, double)>{};
      for (final box in boxes) {
        final line = lines[box.top];
        lines[box.top] = line == null
            ? (box.left, box.right)
            : (
                box.left < line.$1 ? box.left : line.$1,
                box.right > line.$2 ? box.right : line.$2,
              );
      }
      return <double>[for (final line in lines.values) line.$2 - line.$1];
    }

    const words = 'YOU WERE MADE FOR WORK ALREADY PREPARED';
    final style = FsText.readingHeadline.copyWith(color: FsColors.heroInk);

    testWidgets('evens out two lines without adding a third', (tester) async {
      // First as Flutter breaks it: the first line is filled, and one word
      // is left on the second.
      await _pump(
        tester,
        SizedBox(width: 358, child: Text(words, style: style)),
      );
      final filled = lineWidths(tester, find.text(words));
      expect(filled, hasLength(2));
      expect(filled.first - filled.last, greaterThan(150));
      final height = tester.getSize(find.text(words)).height;

      await _pump(
        tester,
        SizedBox(
          width: 358,
          child: FsBalanced(child: Text(words, style: style)),
        ),
      );
      final balanced = lineWidths(tester, find.text(words));
      expect(balanced, hasLength(2));
      // "YOU WERE MADE FOR" over "WORK ALREADY PREPARED".
      expect((balanced.first - balanced.last).abs(), lessThan(60));
      expect(tester.getSize(find.text(words)).height, height);
      // It starts where it did, and the box keeps the width it was given.
      expect(tester.getTopLeft(find.text(words)).dx, 0);
      expect(tester.getSize(find.byType(FsBalanced)), Size(358, height));
      expect(tester.takeException(), isNull);
    });

    testWidgets('leaves a text that fits on one line as it was', (
      tester,
    ) async {
      await _pump(
        tester,
        SizedBox(
          width: 358,
          child: FsBalanced(child: Text('A SHORT LINE', style: style)),
        ),
      );
      expect(lineWidths(tester, find.text('A SHORT LINE')), hasLength(1));
      expect(tester.getTopLeft(find.text('A SHORT LINE')).dx, 0);
      expect(
        tester.getSize(find.byType(FsBalanced)).height,
        moreOrLessEquals(25.3, epsilon: 0.5),
      );
    });

    for (final (name, cut) in <(String, Text)>[
      (
        'one line with an ellipsis',
        Text(
          '$words $words',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: style,
        ),
      ),
      (
        'no wrapping',
        Text(
          '$words $words',
          softWrap: false,
          overflow: TextOverflow.fade,
          style: style,
        ),
      ),
    ]) {
      testWidgets('leaves a text that is cut off, not wrapped, alone: $name', (
        tester,
      ) async {
        // Making such a text narrower never makes it taller, so there is
        // nothing to balance. It must keep its width, not shrink to nothing.
        await _pump(tester, SizedBox(width: 358, child: cut));
        final alone = tester.getSize(find.byType(RichText));

        await _pump(
          tester,
          SizedBox(width: 358, child: FsBalanced(child: cut)),
        );
        expect(tester.getSize(find.byType(RichText)), alone);
        expect(alone.width, 358);
        expect(tester.getSize(find.byType(FsBalanced)), alone);
        expect(lineWidths(tester, find.byType(RichText)), hasLength(1));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('leaves a child that is not a text at its full size', (
      tester,
    ) async {
      await _pump(
        tester,
        const SizedBox(
          width: 358,
          child: FsBalanced(
            child: ColoredBox(
              color: FsColors.gold,
              child: SizedBox(width: double.infinity, height: 20),
            ),
          ),
        ),
      );
      expect(tester.getSize(find.byType(ColoredBox).last), const Size(358, 20));
      expect(tester.getSize(find.byType(FsBalanced)), const Size(358, 20));
      expect(tester.takeException(), isNull);
    });

    testWidgets('an empty text takes no space and does not fail', (
      tester,
    ) async {
      await _pump(
        tester,
        SizedBox(
          width: 358,
          child: FsBalanced(child: Text('', style: style)),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(FsBalanced)).width, 358);
    });

    testWidgets('can be measured before it is laid out', (tester) async {
      // The reading page asks its content how tall it wants to be.
      await _pump(
        tester,
        SizedBox(
          width: 358,
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[FsBalanced(child: Text(words, style: style))],
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(lineWidths(tester, find.text(words)), hasLength(2));
    });
  });

  group('FsTag', () {
    for (final dark in <bool>[true, false]) {
      testWidgets('is an outlined pill (${dark ? 'dark' : 'light'})', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await _pump(
          tester,
          const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              FsTag(label: 'Sent: take it to someone', icon: FsIcons.sent),
              FsTag(
                label: 'Spirit-led',
                icon: FsIcons.flame,
                tone: FsTagTone.gold,
              ),
            ],
          ),
          dark: dark,
        );
        // The tag stands on the dark header. The dark theme's accent reads
        // well there; the light theme's is a dark orange that does not, so
        // in the light theme the tag takes the ring's bright orange.
        final accent = dark ? FsColors.dark.accent : FsColors.ringValue;
        expect(accent, isNot(FsColors.light.accent));

        // Capitals on screen; the words as written for a screen reader.
        final sent = tester.widget<Text>(find.text('SENT: TAKE IT TO SOMEONE'));
        expect(sent.semanticsLabel, 'Sent: take it to someone');
        expect(sent.style?.color, accent);
        expect(sent.style?.fontSize, FsText.tag.fontSize);
        expect(sent.style?.letterSpacing, FsText.tag.letterSpacing);
        // The Spirit-led orange is the same in both themes.
        expect(
          tester.widget<Text>(find.text('SPIRIT-LED')).style?.color,
          FsColors.ringValue,
        );

        // An outline in the same color, fully rounded, 26 high.
        final outline =
            tester
                    .widget<DecoratedBox>(
                      find
                          .descendant(
                            of: find.byType(FsTag).first,
                            matching: find.byType(DecoratedBox),
                          )
                          .first,
                    )
                    .decoration
                as BoxDecoration;
        expect((outline.border! as Border).top.color, accent);
        expect(outline.color, isNull);
        expect(
          outline.borderRadius,
          const BorderRadius.all(Radius.circular(13)),
        );
        expect(tester.getSize(find.byType(FsTag).first).height, 26);
        expect(tester.getSize(find.byType(FsTag).last).height, 26);

        // The icon is 14 across, in the pill's color, and is not announced.
        final icons = tester.widgetList<FsIcon>(find.byType(FsIcon)).toList();
        expect(icons.map((icon) => icon.size), everyElement(14));
        expect(icons.first.color, accent);
        expect(icons.last.color, FsColors.ringValue);

        // Words to read: no button, nothing to tap.
        expect(
          tester.getSemantics(find.text('SENT: TAKE IT TO SOMEONE')),
          isSemantics(
            label: 'Sent: take it to someone',
            isButton: false,
            hasTapAction: false,
          ),
        );
        handle.dispose();
      });
    }

    testWidgets('a label too long for its space wraps inside the pill', (
      tester,
    ) async {
      await _pump(
        tester,
        const SizedBox(
          width: 120,
          child: Align(
            alignment: Alignment.topLeft,
            child: FsTag(label: 'Sent: take it to someone', icon: FsIcons.sent),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      final pill = tester.getSize(find.byType(FsTag));
      expect(pill.width, lessThanOrEqualTo(120));
      expect(pill.height, greaterThan(FsTag.minHeight));
    });
  });

  group('FsRuled', () {
    testWidgets('sets its content behind a rule in the color given', (
      tester,
    ) async {
      await _pump(
        tester,
        const SizedBox(
          width: 200,
          child: FsRuled(color: FsColors.gold, child: Text('Behind the rule')),
        ),
      );
      final decoration =
          tester
                  .widget<DecoratedBox>(
                    find.descendant(
                      of: find.byType(FsRuled),
                      matching: find.byType(DecoratedBox),
                    ),
                  )
                  .decoration
              as BoxDecoration;
      final rule = (decoration.border! as Border).left;
      expect(rule.color, FsColors.gold);
      expect(rule.width, FsRuled.ruleWidth);
      expect((decoration.border! as Border).top, BorderSide.none);
      // The words start 14 points in from the rule's outer edge.
      expect(
        tester.getTopLeft(find.text('Behind the rule')).dx -
            tester.getTopLeft(find.byType(FsRuled)).dx,
        FsRuled.inset,
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
        FsIcons.sent,
        FsIcons.flame,
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
