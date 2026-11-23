import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/features/workout/presentation/workout_page.dart';
import 'package:forged_and_sent/src/features/workout/presentation/workout_prayer_dialog.dart';
import 'package:integration_test/integration_test.dart';

import 'workout_restart_support.dart';

/// Device test for the superset group: on a real device, the two exercises
/// the program marks as a superset are drawn in one group, labelled A1 and
/// A2, before the workout is started and during it. One file: nothing here
/// has to survive a restart, because the group is drawn and never stored.
///
///     flutter test integration_test/workout_superset_test.dart -d <device>
///
/// It runs on the next lifting day, like the workout restart test, and
/// **starts with the app not installed**: a new member's plan opens on
/// plan day 1 on a Monday, day 3 on a Wednesday and day 5 on a Friday.
/// The pair each of those days must show is written out here, by the
/// names a full gym gives the two movements, and not read from the app:
/// if the app stopped reading the mark, this test fails, on any day.
/// The table is `supersetPairByTitle` in `workout_restart_support.dart`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final group = find.byKey(const ValueKey<String>('fs-superset-group'));
  final a1 = find.byKey(const ValueKey<String>('fs-superset-label-A1'));
  final a2 = find.byKey(const ValueKey<String>('fs-superset-label-A2'));
  Finder inGroup(Finder what) => find.descendant(of: group, matching: what);

  /// Brings onto the screen a widget that stands above what is shown.
  Future<void> showAbove(WidgetTester tester, Finder finder) async {
    await tester.scrollUntilVisible(
      finder,
      -200,
      scrollable: scrollableOf(WorkoutPage).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the day\'s superset is one group, before and during the '
      'workout', (tester) async {
    final clock = await startAppOnLiftingDay(tester);
    await openTodaysWorkout(tester);
    expect(
      await storedSession(tester, clock),
      isNull,
      reason:
          'A workout is already stored for this day. Uninstall the app '
          'from the emulator and run the test again.',
    );

    // Which of the three days this is, by the title on the page.
    final shown = supersetPairByTitle.entries.where(
      (entry) => find.text(entry.key.toUpperCase()).evaluate().isNotEmpty,
    );
    expect(
      shown,
      hasLength(1),
      reason:
          'The page shows none of the three workouts a new plan opens '
          'on. Start with the app not installed.',
    );
    final (first, second) = shown.single.value;
    debugPrint('DEVICE TEST: "${shown.single.key}", $first and $second.');

    Future<void> expectGroup() async {
      await showOnWorkoutPage(tester, group);
      expect(group, findsOneWidget);
      expect(inGroup(find.text(first)), findsOneWidget);
      expect(inGroup(find.text(second)), findsOneWidget);
      await showOnWorkoutPage(tester, a1);
      expect(inGroup(a1), findsOneWidget);
      await showOnWorkoutPage(tester, a2);
      expect(inGroup(a2), findsOneWidget);
      // A1 is the first of the two, above A2.
      expect(
        tester.getTopLeft(find.text(first)).dy,
        lessThan(tester.getTopLeft(find.text(second)).dy),
      );
    }

    // Before it is started.
    await expectGroup();

    // And during it.
    await showAbove(tester, startWorkoutButton);
    await tester.tap(startWorkoutButton);
    await tester.pumpAndSettle();
    expect(find.byType(WorkoutPrayerDialog), findsOneWidget);
    await tester.ensureVisible(prayerAmenButton);
    await tester.pumpAndSettle();
    await tester.tap(prayerAmenButton);
    await tester.pumpAndSettle();
    await pumpUntilFound(tester, workoutClock);
    await pumpUntilFound(tester, repsField(0, 0));
    await expectGroup();

    // The group's rows are rows like any other. On each of the three
    // days the pair is the sixth and seventh exercise: a set typed in the
    // sixth is inside the group and in the database file.
    await showAbove(tester, repsField(5, 0));
    await typeNumber(tester, repsField(5, 0), '12');
    await typeNumber(tester, weightField(5, 0), '40');
    expect(inGroup(repsField(5, 0)), findsOneWidget);
    final session = (await storedSession(tester, clock))!;
    expect(session.exercises[5].name, first);
    expect(session.exercises[6].name, second);
    final stored = session.exercises[5].sets.first;
    expect((stored.reps, stored.weightLb), (12, 40.0));
    debugPrint('DEVICE TEST: the superset group was drawn on the device.');
  });
}
