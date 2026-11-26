import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/features/workout/presentation/workout_prayer_dialog.dart';
import 'package:integration_test/integration_test.dart';

import 'workout_restart_support.dart';

/// First half of the device test for adding and removing a set. Run like
/// the workout restart test (see `workout_restart_support.dart`), with the
/// app not installed when it starts:
///
///     flutter test integration_test/workout_sets_restart_1_add_test.dart -d <device> --no-uninstall
///     flutter test integration_test/workout_sets_restart_2_verify_test.dart -d <device>
///
/// Starts today's workout, adds two sets to the first lift, logs the
/// second of them and removes the first, which is empty. The test runner
/// then stops the app's process.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('add two sets, log the second, remove the empty first', (
    tester,
  ) async {
    final clock = await startAppOnLiftingDay(tester);
    await openTodaysWorkout(tester);
    expect(
      await storedSession(tester, clock),
      isNull,
      reason:
          'A workout is already stored for this day. Uninstall the app '
          'from the emulator and run both halves again.',
    );

    await tester.tap(startWorkoutButton);
    await tester.pumpAndSettle();
    expect(find.byType(WorkoutPrayerDialog), findsOneWidget);
    await tester.ensureVisible(prayerAmenButton);
    await tester.pumpAndSettle();
    await tester.tap(prayerAmenButton);
    await tester.pumpAndSettle();
    await pumpUntilFound(tester, workoutClock);
    await pumpUntilFound(tester, repsField(0, 0));

    // The rows the plan gave the first lift.
    final planned = (await storedSession(
      tester,
      clock,
    ))!.exercises.first.sets.length;
    expect(repsField(0, planned), findsNothing);

    // Two more.
    await showOnWorkoutPage(tester, addSetButton(0));
    await tester.tap(addSetButton(0));
    await pumpUntilFound(tester, repsField(0, planned));
    await showOnWorkoutPage(tester, addSetButton(0));
    await tester.tap(addSetButton(0));
    await pumpUntilFound(tester, repsField(0, planned + 1));

    // The second of them is logged; the first stays empty.
    await typeNumber(tester, repsField(0, planned + 1), addedSet.$1);
    await typeNumber(tester, weightField(0, planned + 1), addedSet.$2);
    await pumpUntilGone(tester, removeSetButton(0, planned + 1));

    // The empty one is removed, and the logged one moves up.
    await showOnWorkoutPage(tester, removeSetButton(0, planned));
    await tester.tap(removeSetButton(0, planned));
    await pumpUntilGone(tester, repsField(0, planned + 1));

    // All of it is in the database file already.
    final lift = (await storedSession(tester, clock))!.exercises.first;
    expect(lift.sets, hasLength(planned + 1));
    expect(lift.sets.map((s) => s.position), <int>[
      for (var i = 0; i <= planned; i++) i,
    ]);
    expect((lift.sets.last.reps, lift.sets.last.weightLb), (6, 100.0));
    expect(lift.plannedSets, planned);
    debugPrint(
      'DEVICE TEST: two sets added, one logged, the empty one removed.',
    );
  });
}
