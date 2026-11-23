import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fs_test_support.dart';

/// Golden images of Train and the workout page at 390x844, the size of the
/// prototype reference screenshots in `docs/design/reference/s3-train-workout/`.
///
/// NOT APPROVED. The maintainer has not yet looked at these beside the
/// prototype (P07 run, 2026-11-12: "draw them and build the comparison
/// sheets, but do not lock them"). Until he approves them they record what
/// the screens look like, not what they should look like.
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
/// `flutter test --update-goldens test/features/workout/workout_golden_test.dart`.
void main() {
  setUpAll(loadAppFonts);

  final skip = !Platform.isWindows;

  /// A Monday evening: the first lifting day of a plan that starts that
  /// day, "Full Body A: Back Squat". The prototype references were
  /// captured with the browser's clock set to the same moment.
  TestClock clock() => TestClock(liftingEvening);

  /// Takes the focus out of the number boxes, so no image depends on
  /// where the blinking cursor was.
  Future<void> unfocus(WidgetTester tester) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();
  }

  for (final (name, themeMode) in <(String, ThemeMode)>[
    ('dark', ThemeMode.dark),
    ('light', ThemeMode.light),
  ]) {
    testWidgets('Train as it opens, $name', (tester) async {
      await pumpApp(tester, themeMode: themeMode, clock: clock());
      await openTab(tester, 'Train');
      await loadHeroPhoto(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/train_$name.png'),
      );
    }, skip: skip);

    testWidgets('Train\'s week, $name', (tester) async {
      await pumpApp(tester, themeMode: themeMode, clock: clock());
      await openTab(tester, 'Train');
      await tester.ensureVisible(
        find.byKey(const ValueKey<String>('fs-week-2026-11-15')),
      );
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/train_week_$name.png'),
      );
    }, skip: skip);

    testWidgets('the workout before it is started, $name', (tester) async {
      await pumpApp(tester, themeMode: themeMode, clock: clock());
      await openTodaysWorkout(tester);
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/workout_before_$name.png'),
      );
    }, skip: skip);

    testWidgets('the workout prayer, $name', (tester) async {
      await pumpApp(tester, themeMode: themeMode, clock: clock());
      await openTodaysWorkout(tester);
      await tester.tap(startWorkoutButton);
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/workout_prayer_$name.png'),
      );
    }, skip: skip);

    testWidgets('logging sets, $name', (tester) async {
      final app = await pumpApp(tester, themeMode: themeMode, clock: clock());
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await typeNumber(tester, repsField(0, 0), '5');
      await typeNumber(tester, weightField(0, 0), '135');
      await typeNumber(tester, repsField(0, 1), '5');
      await unfocus(tester);
      // He adds a fourth set and leaves it empty: it can still be removed.
      await showOnWorkoutPage(tester, addSetButton(0));
      await tester.tap(addSetButton(0));
      await tester.pumpAndSettle();
      // Twelve minutes in, half a minute into the squat's two-minute rest.
      app.clock.time = liftingEvening.add(
        const Duration(minutes: 12, seconds: 4),
      );
      await tester.tap(find.byKey(const ValueKey<String>('fs-rest-go-0')));
      await tester.pumpAndSettle();
      app.clock.time = liftingEvening.add(
        const Duration(minutes: 12, seconds: 34),
      );
      await tester.pump(const Duration(seconds: 1));
      tester.state<ScrollableState>(workoutScrollable).position.jumpTo(0);
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/workout_live_$name.png'),
      );
    }, skip: skip);

    testWidgets('a superset, grouped, $name', (tester) async {
      await pumpApp(tester, themeMode: themeMode, clock: clock());
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      final group = find.byKey(const ValueKey<String>('fs-superset-group'));
      await showOnWorkoutPage(tester, group);
      // The group's top a little under the clock bar.
      await Scrollable.ensureVisible(tester.element(group), alignment: 0.02);
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/workout_superset_$name.png'),
      );
    }, skip: skip);

    testWidgets('the finished workout, locked, $name', (tester) async {
      final app = await pumpApp(tester, themeMode: themeMode, clock: clock());
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      for (final (set, weight) in <(int, String)>[
        (0, '135'),
        (1, '140'),
        (2, '145'),
      ]) {
        await typeNumber(tester, repsField(0, set), '5');
        await typeNumber(tester, weightField(0, set), weight);
      }
      await typeNumber(tester, repsField(1, 0), '8');
      await typeNumber(tester, weightField(1, 0), '50');
      await unfocus(tester);
      app.clock.time = liftingEvening.add(const Duration(minutes: 42));
      await showOnWorkoutPage(tester, finishWorkoutButton);
      await tester.tap(finishWorkoutButton);
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey<String>('fs-finish-anyway')));
      await tester.pumpAndSettle();
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/workout_locked_$name.png'),
      );
    }, skip: skip);
  }
}
