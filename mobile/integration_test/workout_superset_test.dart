import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/features/workout/data/workout_library.dart';
import 'package:forged_and_sent/src/features/workout/presentation/workout_prayer_dialog.dart';
import 'package:forged_and_sent/src/features/workout/presentation/workout_view_model.dart';
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
/// starts with the app not installed. What the day's superset is, it reads
/// from the app's own program and plan, so it passes on any plan day: on a
/// day with no superset it expects no group.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  final group = find.byKey(const ValueKey<String>('fs-superset-group'));
  final a1 = find.byKey(const ValueKey<String>('fs-superset-label-A1'));
  final a2 = find.byKey(const ValueKey<String>('fs-superset-label-A2'));
  Finder inGroup(Finder what) => find.descendant(of: group, matching: what);

  testWidgets('the day\'s superset is one group, before and during the '
      'workout', (tester) async {
    final clock = await startAppOnLiftingDay(tester);
    await openTodaysWorkout(tester);

    // What the program marks for today, from the app's own bundle.
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    final library = await container.read(workoutLibraryProvider.future);
    final plan = await container.read(workoutPlanProvider.future);
    final planned = library.dayFor(plan, LocalDate.of(clock.now())).workout!;
    final places = planned.superset;
    debugPrint('DEVICE TEST: plan day ${planned.day}, superset at $places.');

    Future<void> expectGroup() async {
      if (places.isEmpty) {
        expect(group, findsNothing);
        return;
      }
      await showOnWorkoutPage(tester, group);
      expect(group, findsOneWidget);
      for (final place in places) {
        final name = library.nameFor(
          planned.exercises[place].movementId,
          plan.equipment,
        );
        expect(inGroup(find.text(name)), findsOneWidget);
      }
      await showOnWorkoutPage(tester, a1);
      expect(inGroup(a1), findsOneWidget);
      await showOnWorkoutPage(tester, a2);
      expect(inGroup(a2), findsOneWidget);
    }

    // Before it is started.
    await expectGroup();

    // And during it.
    await showOnWorkoutPage(tester, startWorkoutButton);
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

    if (places.isNotEmpty) {
      // The group's rows are rows like any other: a set typed in the
      // first of the two is in the database file.
      await typeNumber(tester, repsField(places.first, 0), '12');
      await typeNumber(tester, weightField(places.first, 0), '40');
      expect(inGroup(repsField(places.first, 0)), findsOneWidget);
      final stored = (await storedSession(
        tester,
        clock,
      ))!.exercises[places.first].sets.first;
      expect((stored.reps, stored.weightLb), (12, 40.0));
    }
    debugPrint('DEVICE TEST: the superset group was drawn on the device.');
  });
}
