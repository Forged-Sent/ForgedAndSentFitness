import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/design/fs_box_row.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';
import 'package:forged_and_sent/src/features/journal/presentation/journal_view_model.dart';
import 'package:forged_and_sent/src/features/workout/presentation/workout_page.dart';
import 'package:forged_and_sent/src/features/workout/presentation/workout_prayer_dialog.dart';
import 'package:integration_test/integration_test.dart';

import 'journal_restart_support.dart';
import 'restart_support.dart';
import 'upgrade_support.dart';
import 'workout_restart_support.dart' hide scrollableOf;

/// Part 2 of the upgrade test, run from this build, installed over the
/// older one. See `upgrade_support.dart`.
///
/// The first start of this build upgrades the database file. What the
/// older build saved must still be there, and Train must work.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('installed over the older build: the journal and the completed '
      'day are still there, and Train works', (tester) async {
    final clock = await startAppOnLiftingDay(tester);
    // The two clocks follow one rule, written twice: here, now, they give
    // the same day. That says nothing about the day part 1 ran on. What
    // shows part 1's day is this one is the box below: it is checked only
    // if the older build completed the devotional on the day this build
    // now shows.
    expect(
      LocalDate.of(UpgradeLiftingDayClock().now()),
      LocalDate.of(clock.now()),
    );

    // The completed day.
    await showDevotionalBox(tester);
    expect(devotionalChecked(tester), isTrue);
    expect(tester.widget<FsBoxRow>(devotionalBox).subtitle, 'Read today');

    // Both journal entries, and the phone still keeps what is written.
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey<String>('fs-hero-profile')),
      -300,
      scrollable: scrollableOf(TodayPage).first,
    );
    await tester.pumpAndSettle();
    await openJournalFromToday(tester);
    expect(find.text(journalNotSavedNotice), findsNothing);
    expectBothEntries();
    await backToToday(tester);

    // Train: the new tables are there and can be written to.
    await openTodaysWorkout(tester);
    // Without a workout to start, nothing here would be written to the new
    // tables, and the test would prove less than it says.
    expect(
      startWorkoutButton,
      findsOneWidget,
      reason:
          'The day the test moved the clock to has no workout to start. '
          'It should be a Monday, Wednesday or Friday on the plan every '
          'member gets.',
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
    for (var set = 0; set < enteredSets.length; set++) {
      await typeNumber(tester, repsField(0, set), enteredSets[set].$1);
      await typeNumber(tester, weightField(0, set), enteredSets[set].$2);
    }
    expect(find.byType(WorkoutPage), findsOneWidget);
    debugPrint('UPGRADE TEST: a workout was started and two sets were typed.');
  });
}
