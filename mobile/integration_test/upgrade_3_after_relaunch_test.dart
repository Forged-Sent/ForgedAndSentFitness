import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/design/fs_box_row.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';
import 'package:integration_test/integration_test.dart';

import 'journal_restart_support.dart';
import 'restart_support.dart';
import 'upgrade_support.dart';
import 'workout_restart_support.dart' hide scrollableOf;

/// Part 3 of the upgrade test: a new process, after the app was killed. See
/// `upgrade_support.dart`.
///
/// Everything part 2 found, and the workout it started, is still there.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('after a kill and relaunch: the journal, the completed day and '
      'the workout in progress are still there', (tester) async {
    final clock = await startAppOnLiftingDay(tester);

    await showDevotionalBox(tester);
    expect(devotionalChecked(tester), isTrue);
    expect(tester.widget<FsBoxRow>(devotionalBox).subtitle, 'Read today');

    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('fs-hero-profile')),
      -300,
      scrollable: scrollableOf(TodayPage).first,
    );
    await tester.pumpAndSettle();
    await openJournalFromToday(tester);
    expectBothEntries();
    await backToToday(tester);

    await openTodaysWorkout(tester);
    // The workout part 2 started is in progress, not offered again, with
    // the two sets as they were typed.
    await pumpUntilFound(tester, workoutClock);
    expect(startWorkoutButton, findsNothing);
    await pumpUntilFound(tester, repsField(0, 0));
    for (var set = 0; set < enteredSets.length; set++) {
      await showOnWorkoutPage(tester, repsField(0, set));
      expect(shownIn(tester, repsField(0, set)), enteredSets[set].$1);
      expect(shownIn(tester, weightField(0, set)), enteredSets[set].$2);
    }
    // And its superset mark, at the same two exercises, with the group
    // drawn from it.
    await expectSupersetOf(tester, (await storedSession(tester, clock))!);
    debugPrint('UPGRADE TEST: the workout in progress kept its two sets.');
  });
}
