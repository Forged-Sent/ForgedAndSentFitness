import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/features/workout/presentation/workout_page.dart';
import 'package:forged_and_sent/src/features/workout/presentation/workout_prayer_dialog.dart';
import 'package:integration_test/integration_test.dart';

import 'workout_restart_support.dart';

/// First half of the workout restart test (P07 acceptance 5). See
/// `workout_restart_support.dart` for how the two halves are run.
///
/// Starts today's workout through the prayer, logs two sets, and ends with
/// the workout in progress. The test runner then stops the app's process.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('start a workout and log two sets', (tester) async {
    final clock = await startAppOnLiftingDay(tester);
    await openTodaysWorkout(tester);

    // A new install: nothing started yet.
    expect(
      await storedSession(tester, clock),
      isNull,
      reason:
          'A workout is already stored for this day. Uninstall the app '
          'from the emulator and run both halves again.',
    );
    expect(startWorkoutButton, findsOneWidget);
    expect(workoutClock, findsNothing);

    // Decision Q11: the prayer first; Amen starts the workout.
    await tester.tap(startWorkoutButton);
    await tester.pumpAndSettle();
    expect(find.byType(WorkoutPrayerDialog), findsOneWidget);
    await tester.ensureVisible(prayerAmenButton);
    await tester.pumpAndSettle();
    await tester.tap(prayerAmenButton);
    await tester.pumpAndSettle();
    expect(find.byType(WorkoutPrayerDialog), findsNothing);
    expect(workoutClock, findsOneWidget);

    // Two sets of the first lift.
    for (var set = 0; set < enteredSets.length; set++) {
      await typeNumber(tester, repsField(0, set), enteredSets[set].$1);
      await typeNumber(tester, weightField(0, set), enteredSets[set].$2);
    }

    // They are in the database file already: nothing waits for a save
    // button, for leaving the page or for the app to be closed.
    final session = (await storedSession(tester, clock))!;
    expect(session.finished, isFalse);
    final lift = session.exercises.first;
    expect(
      lift.sets.take(2).map((s) => (s.reps, s.weightLb)),
      <(int?, double?)>[(5, 135), (4, 137.5)],
    );
    expect(lift.sets[2].reps, isNull);
    expect(lift.movementId, isNotEmpty);
    expect(lift.prescription, isNotEmpty);
    expect(find.byType(WorkoutPage), findsOneWidget);
  });
}
