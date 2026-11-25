import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/design/fs_box_row.dart';
import 'package:forged_and_sent/src/design/fs_number_field.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';
import 'package:forged_and_sent/src/features/workout/presentation/workout_page.dart';
import 'package:integration_test/integration_test.dart';

import 'workout_restart_support.dart';

/// Second half of the workout restart test (P07 acceptance 5). Run it
/// after `workout_restart_1_start_test` has logged two sets and the app's
/// process has been stopped. See `workout_restart_support.dart`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('after the app was killed and started again, the two sets '
      'are there, the clock has kept running, and the workout finishes', (
    tester,
  ) async {
    final clock = await startAppOnLiftingDay(tester);
    final day = LocalDate.of(clock.now());

    // The new process finds the workout in the database file.
    final found = await storedSession(tester, clock);
    expect(
      found,
      isNotNull,
      reason:
          'No workout is stored for this day. Run '
          'workout_restart_1_start_test first, with --no-uninstall, on the '
          'same day.',
    );
    expect(found!.finished, isFalse);
    expect(
      found.exercises.first.sets.take(2).map((s) => (s.reps, s.weightLb)),
      <(int?, double?)>[(5, 135), (4, 137.5)],
    );
    expect(await workoutBoxStored(tester, day), isFalse);

    // Train says it is in progress, and opens it.
    await openTodaysWorkout(tester);
    await pumpUntilFound(tester, workoutClock);
    expect(startWorkoutButton, findsNothing);

    // The clock is worked out from the stored start, so it shows the real
    // time since Amen in the first run: the kill and the relaunch
    // included.
    final sinceStart = clock.now().toUtc().difference(found.startedAtUtc);
    final shown = clockSeconds(tester.widget<Text>(workoutClock).data!);
    expect(sinceStart.inSeconds, greaterThanOrEqualTo(5));
    expect((shown - sinceStart.inSeconds).abs(), lessThanOrEqualTo(5));

    // The boxes hold what was typed before the kill.
    for (var set = 0; set < enteredSets.length; set++) {
      await showOnWorkoutPage(tester, repsField(0, set));
      expect(shownIn(tester, repsField(0, set)), enteredSets[set].$1);
      expect(shownIn(tester, weightField(0, set)), enteredSets[set].$2);
    }
    await showOnWorkoutPage(tester, repsField(0, 2));
    expect(shownIn(tester, repsField(0, 2)), '');

    // Finish. The other sets are blank, so the app asks first.
    await showOnWorkoutPage(tester, finishWorkoutButton);
    await tester.tap(finishWorkoutButton);
    await tester.pumpAndSettle();
    final anyway = find.byKey(const ValueKey<String>('fs-finish-anyway'));
    expect(anyway, findsOneWidget);
    await tester.tap(anyway);
    await tester.pumpAndSettle();

    // A locked summary, and the session is finished in the file.
    await pumpUntilFound(tester, lockedSummary);
    expect(find.byType(FsNumberField), findsNothing);
    expect(find.text('5 reps × 135 lb'), findsOneWidget);
    expect(find.text('4 reps × 137.5 lb'), findsOneWidget);
    final finished = (await storedSession(tester, clock))!;
    expect(finished.finished, isTrue);
    expect(finished.id, found.id);
    expect(finished.day, day);
    expect(await workoutBoxStored(tester, day), isTrue);

    // The Workout box on Today has checked itself.
    await tester.tap(todayTab);
    await tester.pumpAndSettle();
    expect(find.byType(TodayPage), findsOneWidget);
    await tester.scrollUntilVisible(
      workoutBox,
      120,
      scrollable: scrollableOf(TodayPage).first,
    );
    await tester.pumpAndSettle();
    final box = tester.widget<FsBoxRow>(workoutBox);
    expect(box.checked, isTrue);
    expect(box.subtitle, 'Finished in Train');
    expect(find.byType(WorkoutPage), findsNothing);
  });
}
