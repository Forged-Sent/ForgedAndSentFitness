import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'workout_restart_support.dart';

/// Second half of the device test for adding and removing a set, run after
/// the app's process has been stopped. See
/// `workout_sets_restart_1_add_test.dart`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('after the app was killed and started again, the added set '
      'is there with what he logged, and only an empty added row can be '
      'removed', (tester) async {
    final clock = await startAppOnLiftingDay(tester);

    // The new process finds the rows as he left them.
    final found = await storedSession(tester, clock);
    expect(
      found,
      isNotNull,
      reason:
          'No workout is stored for this day. Run '
          'workout_sets_restart_1_add_test first, with --no-uninstall, on '
          'the same day.',
    );
    final planned = found!.exercises.first.plannedSets;
    expect(found.exercises.first.sets, hasLength(planned + 1));

    await openTodaysWorkout(tester);
    await pumpUntilFound(tester, workoutClock);
    await showOnWorkoutPage(tester, repsField(0, planned));
    expect(shownIn(tester, repsField(0, planned)), addedSet.$1);
    expect(shownIn(tester, weightField(0, planned)), addedSet.$2);
    expect(repsField(0, planned + 1), findsNothing);

    // Nothing offers to remove a row from the plan, or the row he logged.
    for (var set = 0; set <= planned; set++) {
      expect(removeSetButton(0, set), findsNothing);
    }

    // He clears the added row; only then can it be removed.
    await typeNumber(tester, repsField(0, planned), '');
    await typeNumber(tester, weightField(0, planned), '');
    await pumpUntilFound(tester, removeSetButton(0, planned));
    await showOnWorkoutPage(tester, removeSetButton(0, planned));
    await tester.tap(removeSetButton(0, planned));
    await pumpUntilGone(tester, repsField(0, planned));

    final lift = (await storedSession(tester, clock))!.exercises.first;
    expect(lift.sets, hasLength(planned));
    expect(lift.sets.every((s) => s.isBlank), isTrue);
    debugPrint(
      'DEVICE TEST: the added set survived the restart and was removed.',
    );
  });
}
