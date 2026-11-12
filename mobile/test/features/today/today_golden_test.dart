import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';

import '../../support/fs_test_support.dart';

/// Golden images of Today and the day's reading at 390x844, the size of the
/// prototype reference screenshots in `docs/design/reference/s1-today/`.
///
/// A Flutter render cannot match a browser render pixel for pixel. The
/// maintainer approves each image by eye beside the prototype; after that
/// the image is the baseline and any change to it fails here.
///
/// Compared on Windows only. Text is drawn slightly differently on each
/// operating system, so an image made on one fails on another. On other
/// systems these tests are skipped; no CI lane checks the images yet.
///
/// To redraw them:
/// `flutter test --update-goldens test/features/today/today_golden_test.dart`.
void main() {
  setUpAll(loadAppFonts);

  final skip = !Platform.isWindows;

  /// The day the prototype references were captured on, so the date, the
  /// mission line and the reading are the same in both.
  TestClock clock() => TestClock(DateTime(2026, 11, 12, 7, 30));

  for (final (name, themeMode) in <(String, ThemeMode)>[
    ('dark', ThemeMode.dark),
    ('light', ThemeMode.light),
  ]) {
    testWidgets('Today as it opens, $name', (tester) async {
      await pumpApp(tester, themeMode: themeMode, clock: clock());
      await loadHeroPhoto(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/today_$name.png'),
      );
    }, skip: skip);

    testWidgets('Today\'s boxes with the devotional done, $name', (
      tester,
    ) async {
      await pumpApp(tester, themeMode: themeMode, clock: clock());
      await completeDevotional(tester);
      // The card of boxes at the top of the screen.
      final card = find.ancestor(
        of: find.text('Today’s boxes'),
        matching: find.byWidgetPredicate(
          (widget) => widget.runtimeType.toString() == '_BoxesCard',
        ),
      );
      final position = tester.state<ScrollableState>(todayScrollable).position;
      final top = tester.getTopLeft(card).dy;
      final listTop = tester.getTopLeft(find.byType(TodayPage)).dy;
      position.jumpTo(
        (position.pixels + top - listTop - 12).clamp(
          0.0,
          position.maxScrollExtent,
        ),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/today_boxes_$name.png'),
      );
    }, skip: skip);

    testWidgets('the reading as it opens, $name', (tester) async {
      await pumpApp(tester, themeMode: themeMode, clock: clock());
      await openDevotional(tester);
      await loadHeroPhoto(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/reading_$name.png'),
      );
    }, skip: skip);

    testWidgets('the end of the reading, Amen unlocked, $name', (tester) async {
      await pumpApp(tester, themeMode: themeMode, clock: clock());
      await openDevotional(tester);
      await scrollReaderToEnd(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/reading_end_$name.png'),
      );
    }, skip: skip);
  }
}
