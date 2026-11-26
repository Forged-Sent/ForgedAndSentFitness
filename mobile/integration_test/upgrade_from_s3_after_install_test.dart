import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:integration_test/integration_test.dart';

import 'workout_restart_support.dart';

/// The upgrade from the build before a session kept its superset mark
/// (database schema version 3, build step S3) to this one (version 4).
///
/// The first half is not in this file: it is the workout restart test's
/// first half, run from a checkout of the S3 build, which starts today's
/// workout and logs two sets. This file is then run from this checkout,
/// installed over that build without uninstalling:
///
///     (the S3 build)  flutter test integration_test/workout_restart_1_start_test.dart -d <device> --no-uninstall
///     (this checkout) flutter test integration_test/upgrade_from_s3_after_install_test.dart -d <device>
///
/// Start with the app not installed, and run both on the same real day.
/// Both move their clock to the next lifting day in the same way. It ends
/// by uninstalling the app: run it only on an emulator or simulator.
///
/// What it shows: the first start of this build adds the new column to the
/// sessions table; the workout already in the file is still his to log;
/// and it has no superset group, because the update does not give a
/// session a mark it was not started with.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final group = find.byKey(const ValueKey<String>('fs-superset-group'));

  testWidgets('installed over the S3 build: the workout in progress is '
      'still there with its sets, is drawn with no superset group, and '
      'can be finished', (tester) async {
    final clock = await startAppOnLiftingDay(tester);
    final day = LocalDate.of(clock.now());

    // The new process, on the upgraded file, finds the workout.
    final found = await storedSession(tester, clock);
    expect(
      found,
      isNotNull,
      reason:
          'No workout is stored for this day. Run '
          'workout_restart_1_start_test from a checkout of the S3 build '
          'first, with --no-uninstall, on the same day.',
    );
    expect(found!.finished, isFalse);
    expect(
      found.exercises.first.sets.take(2).map((s) => (s.reps, s.weightLb)),
      <(int?, double?)>[(5, 135), (4, 137.5)],
    );
    // It was started without a mark, and the update gives it none.
    expect(found.superset, isEmpty);
    expect(found.supersetLabels, everyElement(isNull));

    await openTodaysWorkout(tester);
    await pumpUntilFound(tester, workoutClock);
    for (var set = 0; set < enteredSets.length; set++) {
      await showOnWorkoutPage(tester, repsField(0, set));
      expect(shownIn(tester, repsField(0, set)), enteredSets[set].$1);
      expect(shownIn(tester, weightField(0, set)), enteredSets[set].$2);
    }

    // Its sixth and seventh exercises are a superset in the program, and
    // their prescriptions say so. Here they are two exercises like any
    // other: no group anywhere down the page.
    final last = found.exercises.length - 1;
    for (final place in <int>[last - 1, last]) {
      await showOnWorkoutPage(tester, repsField(place, 0));
      expect(group, findsNothing);
      expect(find.text('SUPERSET'), findsNothing);
    }
    expect(
      found.exercises[last - 1].prescription,
      startsWith('Superset A1'),
      reason: 'This day should be one the program marks a superset on.',
    );

    // It is still his to log and to finish.
    await typeNumber(tester, repsField(last, 0), '12');
    await typeNumber(tester, weightField(last, 0), '40');
    await showOnWorkoutPage(tester, finishWorkoutButton);
    await tester.tap(finishWorkoutButton);
    await tester.pumpAndSettle();
    final anyway = find.byKey(const ValueKey<String>('fs-finish-anyway'));
    expect(anyway, findsOneWidget);
    await tester.tap(anyway);
    await tester.pumpAndSettle();
    await pumpUntilFound(tester, lockedSummary);

    final finished = (await storedSession(tester, clock))!;
    expect(finished.finished, isTrue);
    expect(finished.id, found.id);
    expect(finished.superset, isEmpty);
    final logged = finished.exercises[last].sets.first;
    expect((logged.reps, logged.weightLb), (12, 40.0));
    expect(await workoutBoxStored(tester, day), isTrue);
    debugPrint(
      'UPGRADE TEST: the S3 workout was kept, drawn with no group, and '
      'finished.',
    );
  });
}
