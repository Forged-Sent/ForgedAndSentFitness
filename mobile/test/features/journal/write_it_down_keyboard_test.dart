import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/features/devotional/presentation/devotional_page.dart';

import '../../support/fs_test_support.dart';

/// The page's own scroll view.
Finder get _reading => find
    .descendant(
      of: find.byType(DevotionalPage),
      matching: find.byType(Scrollable),
    )
    .first;

/// True if a tap in the middle of [finder] would land on it: it is on the
/// page, inside what the scroll view shows, with nothing over it.
bool _reachable(WidgetTester tester, Finder finder) {
  final box = tester.renderObject<RenderBox>(finder);
  final center = box.localToGlobal(box.size.center(Offset.zero));
  return tester.hitTestOnBinding(center).path.any((e) => e.target == box);
}

/// How far the bottom edge of [finder] lies below the bottom edge of what
/// the reading's scroll view shows. Zero or less: it is in view.
double _below(WidgetTester tester, Finder finder) =>
    tester.getRect(finder).bottom - tester.getRect(_reading).bottom;

/// The keyboard comes up, [height] points tall, as the phone reports it.
Future<void> _showKeyboard(WidgetTester tester, double height) async {
  tester.view.viewInsets = FakeViewPadding(
    bottom: height * tester.view.devicePixelRatio,
  );
  addTearDown(tester.view.resetViewInsets);
  await tester.pumpAndSettle();
}

void main() {
  setUpAll(loadAppFonts);

  group('with the keyboard open, "Save to my journal" is on the page', () {
    for (final (String name, double keyboard) in <(String, double)>[
      ('a keyboard of ordinary height', 300),
      ('a tall keyboard', 350),
    ]) {
      testWidgets('$name: he taps the box, and Save is in view under it, '
          'above the tab bar', (tester) async {
        await pumpApp(tester);
        await openDevotional(tester);
        await tester.ensureVisible(journalBox);
        await tester.pumpAndSettle();

        await tester.tap(journalBox);
        await tester.pump();
        await _showKeyboard(tester, keyboard);

        expect(_below(tester, journalSave), lessThanOrEqualTo(0));
        expect(_reachable(tester, journalSave), isTrue);
        // The box he is writing in is still in view above it.
        expect(_reachable(tester, journalBox), isTrue);
        expect(tester.takeException(), isNull);
      });

      testWidgets('$name: Save is still in view after he has typed a few '
          'words', (tester) async {
        await pumpApp(tester);
        await openDevotional(tester);
        await tester.ensureVisible(journalBox);
        await tester.pumpAndSettle();
        await tester.tap(journalBox);
        await tester.pump();
        await _showKeyboard(tester, keyboard);

        await tester.enterText(journalBox, 'Three words here.');
        await tester.pumpAndSettle();

        expect(_below(tester, journalSave), lessThanOrEqualTo(0));
        expect(_reachable(tester, journalSave), isTrue);
        await tester.tap(journalSave);
        await tester.pumpAndSettle();
        expect(tester.widget<Text>(journalMessage).data, isNotNull);
      });
    }

    testWidgets('when what he has written is too long for both to fit, the '
        'line he is typing wins: the box is never pushed off the page', (
      tester,
    ) async {
      await pumpApp(tester);
      await openDevotional(tester);
      await tester.ensureVisible(journalBox);
      await tester.pumpAndSettle();
      await tester.tap(journalBox);
      await tester.pump();
      await _showKeyboard(tester, 350);

      // Twelve lines: the box at its tallest.
      await tester.enterText(
        journalBox,
        List<String>.filled(12, 'A line of what he wrote.').join('\n'),
      );
      await tester.pumpAndSettle();

      // The end of the text, where he is typing, is in view.
      final box = tester.getRect(journalBox);
      final page = tester.getRect(_reading);
      expect(box.bottom, greaterThan(page.top));
      expect(box.bottom, lessThanOrEqualTo(page.bottom + 1));
      expect(tester.takeException(), isNull);
    });
  });
}
