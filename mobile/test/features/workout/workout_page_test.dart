import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/design/fs_box_row.dart';
import 'package:forged_and_sent/src/design/fs_button.dart';
import 'package:forged_and_sent/src/design/fs_chevron_row.dart';
import 'package:forged_and_sent/src/design/fs_dialog.dart';
import 'package:forged_and_sent/src/design/fs_number_field.dart';
import 'package:forged_and_sent/src/features/today/domain/completion_event.dart';
import 'package:forged_and_sent/src/features/workout/domain/prescription.dart';
import 'package:forged_and_sent/src/features/workout/domain/workout_session.dart';
import 'package:forged_and_sent/src/features/workout/presentation/train_page.dart';
import 'package:forged_and_sent/src/features/workout/presentation/workout_page.dart';
import 'package:forged_and_sent/src/features/workout/presentation/workout_prayer_dialog.dart';

import '../../support/fs_test_support.dart';
import 'workout_repository_contract.dart' show exercise, newSession;

const LocalDate _monday = LocalDate(2026, 11, 9);

String _text(WidgetTester tester, Finder finder) =>
    tester.widget<Text>(finder).data!;

String _restTime(WidgetTester tester, int exercise) =>
    _text(tester, find.byKey(ValueKey<String>('fs-rest-time-$exercise')));

Finder _rest(String button, int exercise) =>
    find.byKey(ValueKey<String>('fs-rest-$button-$exercise'));

Future<void> _tapOnPage(WidgetTester tester, Finder finder) async {
  await showOnWorkoutPage(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Taps Finish workout and, if sets are blank, "Finish anyway".
Future<void> _finish(WidgetTester tester) async {
  await _tapOnPage(tester, finishWorkoutButton);
  final anyway = find.byKey(const ValueKey<String>('fs-finish-anyway'));
  if (anyway.evaluate().isNotEmpty) {
    await tester.tap(anyway);
    await tester.pumpAndSettle();
  }
}

/// The line that says a change did not save.
final Finder _saveFailedNotice = find.byKey(
  const ValueKey<String>('fs-workout-save-failed'),
);

/// What a number box shows.
String _typed(WidgetTester tester, Finder field) => tester
    .widget<EditableText>(
      find.descendant(of: field, matching: find.byType(EditableText)),
    )
    .controller
    .text;

String _trainStatus(WidgetTester tester) => _text(
  tester,
  find.descendant(
    of: find.byKey(const ValueKey<String>('fs-train-status')),
    matching: find.byType(Text),
  ),
);

void main() {
  setUpAll(loadAppFonts);

  final library = loadBundledWorkoutLibrary();

  group('before it is started', () {
    testWidgets('the page shows what the plan asks for today', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);

      expect(find.text('MONDAY, NOVEMBER 9'), findsOneWidget);
      expect(find.text('WEEK 1 · DAY 1 · 45 MIN'), findsOneWidget);
      expect(find.text('FULL BODY A: BACK SQUAT'), findsOneWidget);
      expect(startWorkoutButton, findsOneWidget);
      expect(
        tester.widget<FsButton>(startWorkoutButton).label,
        'Pray, then train',
      );
      // The exercises, by the names for a full gym, with what to do.
      expect(find.text('Barbell Back Squat'), findsOneWidget);
      expect(find.text('3 x 5 (RPE 7, rest 2 min)'), findsOneWidget);
      // Nothing to type into, no clock, nothing stored.
      expect(find.byType(FsNumberField), findsNothing);
      expect(workoutClock, findsNothing);
      expect(finishWorkoutButton, findsNothing);
      expect(await app.savedSession(tester, _monday), isNull);
    });
  });

  group('the workout prayer (decision Q11)', () {
    testWidgets('comes before starting, with Amen and a visible Not now', (
      tester,
    ) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);

      await tester.tap(startWorkoutButton);
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutPrayerDialog), findsOneWidget);
      expect(find.text('BEFORE YOU TRAIN'), findsOneWidget);
      expect(find.text('WORKOUT PRAYER'), findsOneWidget);
      // The words on screen are the bundled ones, in order.
      for (final line in library.prayerLines.take(5)) {
        expect(find.text(line), findsOneWidget);
      }
      expect(find.text(library.prayerLines.last.toUpperCase()), findsOneWidget);
      expect(tester.widget<FsButton>(prayerAmenButton).label, 'Amen');
      expect(tester.widget<FsButton>(prayerNotNowButton).label, 'Not now');
      expect(tester.widget<FsButton>(prayerNotNowButton).onPressed, isNotNull);
      // Nothing starts until he answers.
      expect(await app.savedSession(tester, _monday), isNull);
    });

    testWidgets('Not now returns without starting', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await tester.tap(startWorkoutButton);
      await tester.pumpAndSettle();

      await tester.tap(prayerNotNowButton);
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutPrayerDialog), findsNothing);
      expect(find.byType(WorkoutPage), findsOneWidget);
      expect(await app.savedSession(tester, _monday), isNull);
      expect(workoutClock, findsNothing);
      // He can still start it when he is ready.
      expect(tester.widget<FsButton>(startWorkoutButton).onPressed, isNotNull);
    });

    testWidgets('Android back does what Not now does', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await tester.tap(startWorkoutButton);
      await tester.pumpAndSettle();

      await systemBack(tester);

      // Back closed the prayer only: he is still on the workout page.
      expect(find.byType(WorkoutPrayerDialog), findsNothing);
      expect(find.byType(WorkoutPage), findsOneWidget);
      expect(await app.savedSession(tester, _monday), isNull);
      expect(tester.widget<FsButton>(startWorkoutButton).onPressed, isNotNull);
    });

    testWidgets('a tap outside the box does nothing', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await tester.tap(startWorkoutButton);
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(8, 8));
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutPrayerDialog), findsOneWidget);
      expect(await app.savedSession(tester, _monday), isNull);
    });

    testWidgets('Amen starts the session and the clock', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);

      await startWorkout(tester);

      expect(find.byType(WorkoutPrayerDialog), findsNothing);
      expect(startWorkoutButton, findsNothing);
      expect(find.text('WORKOUT TIME'), findsOneWidget);
      expect(_text(tester, workoutClock), '0:00');
      expect(
        find.text('Started 6:00 PM. Log each set, then rest.'),
        findsOneWidget,
      );
      final session = (await app.savedSession(tester, _monday))!;
      expect(session.day, _monday);
      expect(session.finished, isFalse);
      expect(session.startedAtUtc, liftingEvening.toUtc());
      expect(session.title, 'Full Body A: Back Squat');
    });

    testWidgets('the prayer scrolls at twice the text size on a small phone', (
      tester,
    ) async {
      await pumpApp(
        tester,
        size: const Size(320, 568),
        textScale: 2,
        clock: TestClock(liftingEvening),
      );
      await openTodaysWorkout(tester);
      await tester.tap(startWorkoutButton);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      // Not now is below the fold; scrolling the box brings it up.
      await tester.ensureVisible(prayerNotNowButton);
      await tester.pumpAndSettle();
      await tester.tap(prayerNotNowButton);
      await tester.pumpAndSettle();

      expect(find.byType(WorkoutPrayerDialog), findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('the session copies the plan when it starts (review finding U3)', () {
    testWidgets('every exercise is stored with its movement id and its '
        'prescription text', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);

      final session = (await app.savedSession(tester, _monday))!;
      final planned = library.days.first.exercises;
      expect(session.planDay, 1);
      expect(session.planWeek, 1);
      expect(
        session.exercises.map((e) => e.movementId),
        planned.map((e) => e.movementId),
      );
      expect(
        session.exercises.map((e) => e.prescription),
        planned.map((e) => e.prescription),
      );
      expect(session.exercises.first.movementId, 'Back Squat');
      expect(session.exercises.first.name, 'Barbell Back Squat');
      expect(session.exercises.first.sets, hasLength(3));
      expect(session.exercises.first.weightMode, WeightMode.required);
      expect(session.exercises.first.restBaseSeconds, 120);
      // The superset's first half has no rest timer; its second has one.
      expect(session.exercises[5].hasRestTimer, isFalse);
      expect(session.exercises[6].hasRestTimer, isTrue);
      expect(session.exercises[6].restBaseSeconds, 60);
    });

    testWidgets('a recovery day has timed sets and tick rows', (tester) async {
      // Tuesday, November 10.
      final app = await pumpApp(tester);
      await openTodaysWorkout(tester);
      await startWorkout(tester);

      final session = (await app.savedSession(
        tester,
        const LocalDate(2026, 11, 10),
      ))!;
      expect(session.sessionType, 'Recovery');
      expect(session.exercises.first.measure, SetMeasure.tick);
      expect(session.exercises.first.sets, hasLength(1));
      expect(session.exercises[1].measure, SetMeasure.seconds);
      expect(session.exercises[1].sets, hasLength(2));

      // A tick row is marked done with one tap, and unmarked with another.
      final tick = find.byKey(const ValueKey<String>('fs-tick-0'));
      await _tapOnPage(tester, tick);
      var stored = (await app.savedSession(
        tester,
        const LocalDate(2026, 11, 10),
      ))!;
      expect(stored.exercises.first.sets.single.ticked, isTrue);
      await _tapOnPage(tester, tick);
      stored = (await app.savedSession(tester, const LocalDate(2026, 11, 10)))!;
      expect(stored.exercises.first.sets.single.ticked, isFalse);

      // A timed set takes seconds and no weight.
      await typeNumber(tester, repsField(1, 0), '25');
      expect(weightField(1, 0), findsNothing);
      stored = (await app.savedSession(tester, const LocalDate(2026, 11, 10)))!;
      expect(stored.exercises[1].sets.first.reps, 25);
      expect(
        stored.exercises[1].isLogged(stored.exercises[1].sets.first),
        isTrue,
      );
    });
  });

  group('logging sets', () {
    testWidgets('every field change is written to the store at once', (
      tester,
    ) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);

      // Each keystroke is stored as it is typed, not when he leaves the
      // box or the page.
      await typeNumber(tester, repsField(0, 0), '5');
      var squat = (await app.savedSession(tester, _monday))!.exercises.first;
      expect(squat.sets[0].reps, 5);
      expect(squat.sets[0].weightLb, isNull);

      await typeNumber(tester, weightField(0, 0), '13');
      squat = (await app.savedSession(tester, _monday))!.exercises.first;
      expect(squat.sets[0].weightLb, 13);

      await typeNumber(tester, weightField(0, 0), '132.5');
      squat = (await app.savedSession(tester, _monday))!.exercises.first;
      expect(squat.sets[0].weightLb, 132.5);

      // Clearing a box clears the stored value.
      await typeNumber(tester, repsField(0, 0), '');
      squat = (await app.savedSession(tester, _monday))!.exercises.first;
      expect(squat.sets[0].reps, isNull);
      expect(squat.sets[0].weightLb, 132.5);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a set\'s mark fills once it has reps and its weight', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      final mark = find.byKey(const ValueKey<String>('fs-logged-0-0'));
      await showOnWorkoutPage(tester, mark);
      expect(
        tester.getSemantics(mark),
        isSemantics(label: 'Set 1 not logged yet'),
      );

      await typeNumber(tester, repsField(0, 0), '5');
      expect(
        tester.getSemantics(mark),
        isSemantics(label: 'Set 1 not logged yet'),
      );

      await typeNumber(tester, weightField(0, 0), '135');
      expect(tester.getSemantics(mark), isSemantics(label: 'Set 1 logged'));
      handle.dispose();
    });

    testWidgets('the boxes take numbers only, within the prototype\'s limits', (
      tester,
    ) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);

      await typeNumber(tester, repsField(0, 0), '12abc');
      await typeNumber(tester, weightField(0, 0), '5000');
      await typeNumber(tester, weightField(0, 1), '132,5');

      final squat = (await app.savedSession(tester, _monday))!.exercises.first;
      // Letters never reach the box; a weight over 2,000 lb is stored as
      // 2,000; a decimal comma is read as a decimal point.
      expect(squat.sets[0].reps, anyOf(isNull, 12));
      expect(squat.sets[0].weightLb, 2000);
      expect(squat.sets[1].weightLb, 132.5);

      // A second decimal digit is not taken, and the stored weight stays.
      await typeNumber(tester, weightField(0, 1), '132.55');
      expect(
        (await app.savedSession(
          tester,
          _monday,
        ))!.exercises.first.sets[1].weightLb,
        132.5,
      );
    });

    testWidgets('the boxes say what they are to a screen reader', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await showOnWorkoutPage(tester, repsField(0, 0));

      expect(find.bySemanticsLabel('Set 1 reps'), findsWidgets);
      expect(find.bySemanticsLabel('Set 1 weight in pounds'), findsWidgets);
      handle.dispose();
    });

    testWidgets('if a change cannot be stored, the page says so', (
      tester,
    ) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      final workouts = app.store.workouts as TestWorkoutRepository;
      final failed = find.byKey(
        const ValueKey<String>('fs-workout-save-failed'),
      );
      expect(failed, findsNothing);

      workouts.failWrites = true;
      await typeNumber(tester, repsField(0, 0), '5');
      await tester.drag(workoutScrollable, const Offset(0, 600));
      await tester.pumpAndSettle();
      expect(failed, findsOneWidget);
      expect(
        (await app.savedSession(tester, _monday))!.exercises.first.sets[0].reps,
        isNull,
      );

      // The same box, typed in again and stored, clears the notice.
      workouts.failWrites = false;
      await typeNumber(tester, repsField(0, 0), '6');
      await tester.drag(workoutScrollable, const Offset(0, 600));
      await tester.pumpAndSettle();
      expect(failed, findsNothing);
      expect(
        (await app.savedSession(tester, _monday))!.exercises.first.sets[0].reps,
        6,
      );
    });

    testWidgets('the notice stays until the change that failed is stored: '
        'other changes being stored do not clear it', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      final workouts = app.store.workouts as TestWorkoutRepository;
      final failed = find.byKey(
        const ValueKey<String>('fs-workout-save-failed'),
      );
      Future<void> expectNotice(Matcher matcher) async {
        await tester.drag(workoutScrollable, const Offset(0, 3000));
        await tester.pumpAndSettle();
        expect(failed, matcher);
      }

      // The reps of set 1 cannot be stored.
      workouts.failWrites = true;
      await typeNumber(tester, repsField(0, 0), '5');
      workouts.failWrites = false;
      await expectNotice(findsOneWidget);

      // Three other changes are stored: the same set's weight, the next
      // set's reps, and a rest timer button.
      await typeNumber(tester, weightField(0, 0), '135');
      await expectNotice(findsOneWidget);
      await typeNumber(tester, repsField(0, 1), '4');
      await expectNotice(findsOneWidget);
      await _tapOnPage(tester, _rest('more', 0));
      await expectNotice(findsOneWidget);
      var squat = (await app.savedSession(tester, _monday))!.exercises.first;
      expect(squat.sets[0].reps, isNull);
      expect(squat.sets[0].weightLb, 135);
      expect(squat.sets[1].reps, 4);
      expect(squat.restBaseSeconds, 135);

      // The reps of set 1, typed again and stored: nothing is unsaved now.
      await typeNumber(tester, repsField(0, 0), '5');
      await expectNotice(findsNothing);
      squat = (await app.savedSession(tester, _monday))!.exercises.first;
      expect(squat.sets[0].reps, 5);
    });

    testWidgets('two changes that failed are each waited for', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      final workouts = app.store.workouts as TestWorkoutRepository;
      final failed = find.byKey(
        const ValueKey<String>('fs-workout-save-failed'),
      );
      Future<void> expectNotice(Matcher matcher) async {
        await tester.drag(workoutScrollable, const Offset(0, 3000));
        await tester.pumpAndSettle();
        expect(failed, matcher);
      }

      // A set's reps and a rest timer button both fail.
      workouts.failWrites = true;
      await typeNumber(tester, repsField(0, 0), '5');
      await _tapOnPage(tester, _rest('more', 0));
      workouts.failWrites = false;
      await expectNotice(findsOneWidget);

      // The timer is stored: the reps are still not.
      await _tapOnPage(tester, _rest('more', 0));
      await expectNotice(findsOneWidget);
      // The timer that failed changed nothing, so this is its first step.
      expect(
        (await app.savedSession(
          tester,
          _monday,
        ))!.exercises.first.restBaseSeconds,
        135,
      );

      // The reps are stored: both are.
      await typeNumber(tester, repsField(0, 0), '5');
      await expectNotice(findsNothing);
    });

    testWidgets('leaving the page while a change is still being written '
        'loses nothing', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      final workouts = app.store.workouts as TestWorkoutRepository;

      // A slow disk: the first keystroke is held, the rest queue behind it.
      workouts.hold();
      await typeNumber(tester, repsField(0, 0), '5');
      await typeNumber(tester, weightField(0, 0), '135');
      await typeNumber(tester, repsField(0, 1), '4');
      expect(
        (await app.savedSession(tester, _monday))!.exercises.first.sets[0].reps,
        isNull,
      );

      // He goes back to Train before any of it is written.
      await systemBack(tester);
      expect(find.byType(WorkoutPage), findsNothing);
      expect(find.byType(TrainPage), findsOneWidget);

      // The disk catches up after the page is gone.
      workouts.release();
      await tester.pumpAndSettle();

      final squat = (await app.savedSession(tester, _monday))!.exercises.first;
      expect(squat.sets.map((s) => (s.reps, s.weightLb)), <(int?, double?)>[
        (5, 135),
        (4, null),
        (null, null),
      ]);
      // And the page shows them when he comes back.
      await tester.tap(trainTodayRow);
      await tester.pumpAndSettle();
      await showOnWorkoutPage(tester, repsField(0, 0));
      expect(
        tester
            .widget<EditableText>(
              find.descendant(
                of: weightField(0, 0),
                matching: find.byType(EditableText),
              ),
            )
            .controller
            .text,
        '135',
      );
    });

    testWidgets('if the session cannot be stored, it is not started', (
      tester,
    ) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      (app.store.workouts as TestWorkoutRepository).failWrites = true;
      await openTodaysWorkout(tester);

      await startWorkout(tester);

      expect(
        find.byKey(const ValueKey<String>('fs-workout-save-failed')),
        findsOneWidget,
      );
      expect(workoutClock, findsNothing);
      expect(tester.widget<FsButton>(startWorkoutButton).onPressed, isNotNull);
      expect(await app.savedSession(tester, _monday), isNull);
    });
  });

  group('adding and removing a set', () {
    Future<SessionExercise> squat(AppHarness app, WidgetTester tester) async =>
        (await app.savedSession(tester, _monday))!.exercises.first;

    testWidgets('"Add set" puts one more row under the exercise, with the '
        'same target, stored at once', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      expect(repsField(0, 3), findsNothing);

      await _tapOnPage(tester, addSetButton(0));

      await showOnWorkoutPage(tester, repsField(0, 3));
      expect(find.text('SET 4'), findsWidgets);
      var stored = await squat(app, tester);
      expect(stored.sets, hasLength(4));
      expect(stored.sets.last.position, 3);
      expect(stored.sets.last.target, stored.sets[2].target);
      expect(stored.sets.last.isBlank, isTrue);
      // Only that exercise gained a row.
      expect(repsField(1, 3), findsNothing);

      // It is logged like any other set.
      await typeNumber(tester, repsField(0, 3), '5');
      await typeNumber(tester, weightField(0, 3), '150');
      stored = await squat(app, tester);
      expect(stored.sets.last.reps, 5);
      expect(stored.sets.last.weightLb, 150);
      expect(stored.isLogged(stored.sets.last), isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('a row he added can be removed while it is empty; a row '
        'from the plan has no Remove', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await _tapOnPage(tester, addSetButton(0));
      await showOnWorkoutPage(tester, removeSetButton(0, 3));

      for (var set = 0; set < 3; set++) {
        expect(removeSetButton(0, set), findsNothing);
      }
      expect(
        find.bySemanticsLabel('Remove set 4, which is empty'),
        findsOneWidget,
      );

      await _tapOnPage(tester, removeSetButton(0, 3));

      expect(repsField(0, 3), findsNothing);
      expect(removeSetButton(0, 3), findsNothing);
      expect((await squat(app, tester)).sets, hasLength(3));
    });

    testWidgets('once anything is typed in a row he added, Remove is gone; '
        'clearing the row brings it back', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await _tapOnPage(tester, addSetButton(0));

      await typeNumber(tester, weightField(0, 3), '45');
      expect(removeSetButton(0, 3), findsNothing);
      await typeNumber(tester, weightField(0, 3), '');
      await typeNumber(tester, repsField(0, 3), '5');
      expect(removeSetButton(0, 3), findsNothing);
      expect((await squat(app, tester)).sets, hasLength(4));

      await typeNumber(tester, repsField(0, 3), '');
      await showOnWorkoutPage(tester, removeSetButton(0, 3));
      expect(removeSetButton(0, 3), findsOneWidget);
    });

    testWidgets('Remove tapped while what he just typed in that row is '
        'still on its way to the store removes nothing', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await _tapOnPage(tester, addSetButton(0));
      await showOnWorkoutPage(tester, removeSetButton(0, 3));
      final workouts = app.store.workouts as TestWorkoutRepository;

      // A slow disk holds the reps he types; the page still shows Remove.
      workouts.hold();
      await typeNumber(tester, repsField(0, 3), '5');
      await _tapOnPage(tester, removeSetButton(0, 3));
      workouts.release();
      await tester.pumpAndSettle();

      final stored = await squat(app, tester);
      expect(stored.sets, hasLength(4));
      expect(stored.sets.last.reps, 5);
      await showOnWorkoutPage(tester, repsField(0, 3));
      expect(_typed(tester, repsField(0, 3)), '5');
      expect(removeSetButton(0, 3), findsNothing);
      expect(_saveFailedNotice, findsNothing);
    });

    testWidgets('from the tap on Remove until the row is gone, the row '
        'takes no typing', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await _tapOnPage(tester, addSetButton(0));
      await showOnWorkoutPage(tester, removeSetButton(0, 3));
      final workouts = app.store.workouts as TestWorkoutRepository;

      // A slow disk holds the removal.
      workouts.hold();
      await tester.tap(removeSetButton(0, 3));
      await tester.pump();

      // He taps the row's boxes meanwhile: neither opens the keyboard, so
      // nothing can be typed into a row that is about to be gone.
      for (final box in <Finder>[repsField(0, 3), weightField(0, 3)]) {
        await showOnWorkoutPage(tester, box);
        await tester.tap(box, warnIfMissed: false);
        await tester.pump();
        expect(tester.testTextInput.hasAnyClients, isFalse);
      }
      // And Remove is not offered twice.
      expect(removeSetButton(0, 3), findsNothing);
      // A row from the plan still takes typing.
      await showOnWorkoutPage(tester, repsField(0, 2));
      await tester.tap(repsField(0, 2));
      await tester.pump();
      expect(tester.testTextInput.hasAnyClients, isTrue);

      workouts.release();
      await tester.pumpAndSettle();
      expect(repsField(0, 3), findsNothing);
      expect((await squat(app, tester)).sets, hasLength(3));
      expect(_saveFailedNotice, findsNothing);
    });

    testWidgets('a row whose typing could not be stored is not offered for '
        'removal: it stays for him to try again', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await _tapOnPage(tester, addSetButton(0));
      final workouts = app.store.workouts as TestWorkoutRepository;

      workouts.failWrites = true;
      await typeNumber(tester, repsField(0, 3), '5');
      workouts.failWrites = false;

      // The store holds an empty row, but he typed in it and that is not
      // stored: removing the row would lose where it goes.
      expect((await squat(app, tester)).sets.last.isBlank, isTrue);
      await showOnWorkoutPage(tester, repsField(0, 3));
      expect(removeSetButton(0, 3), findsNothing);

      // He types it again, and it is stored.
      await typeNumber(tester, repsField(0, 3), '6');
      final stored = await squat(app, tester);
      expect(stored.sets, hasLength(4));
      expect(stored.sets.last.reps, 6);
    });

    testWidgets('Remove tapped while what he typed in the row is still on '
        'its way, and that then fails: the row stays', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await _tapOnPage(tester, addSetButton(0));
      await showOnWorkoutPage(tester, removeSetButton(0, 3));
      final workouts = app.store.workouts as TestWorkoutRepository;

      // A slow disk holds the reps he types, and will refuse them; the
      // removal after it would be stored.
      workouts.hold();
      await typeNumber(tester, repsField(0, 3), '5');
      workouts.failNextWrite = true;
      await _tapOnPage(tester, removeSetButton(0, 3));
      workouts.release();
      await tester.pumpAndSettle();

      expect((await squat(app, tester)).sets, hasLength(4));
      await tester.drag(workoutScrollable, const Offset(0, 600));
      await tester.pumpAndSettle();
      expect(_saveFailedNotice, findsOneWidget);

      // The row is there to type in again, and then the notice goes.
      await typeNumber(tester, repsField(0, 3), '5');
      expect((await squat(app, tester)).sets.last.reps, 5);
      await tester.drag(workoutScrollable, const Offset(0, 600));
      await tester.pumpAndSettle();
      expect(_saveFailedNotice, findsNothing);
    });

    testWidgets('removing an empty row moves the rows after it up, with '
        'what they hold', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await _tapOnPage(tester, addSetButton(0));
      await _tapOnPage(tester, addSetButton(0));
      await typeNumber(tester, repsField(0, 4), '6');
      await typeNumber(tester, weightField(0, 4), '100');

      await _tapOnPage(tester, removeSetButton(0, 3));

      expect(repsField(0, 4), findsNothing);
      await showOnWorkoutPage(tester, repsField(0, 3));
      expect(_typed(tester, repsField(0, 3)), '6');
      expect(_typed(tester, weightField(0, 3)), '100');
      final stored = await squat(app, tester);
      expect(stored.sets, hasLength(4));
      expect(stored.sets.last.reps, 6);
      expect(stored.sets.last.weightLb, 100);
      expect(stored.sets.map((s) => s.position), <int>[0, 1, 2, 3]);
    });

    testWidgets('an exercise takes twelve rows and no more', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);

      for (var rows = 3; rows < maxSets; rows++) {
        await _tapOnPage(tester, addSetButton(0));
      }

      expect((await squat(app, tester)).sets, hasLength(maxSets));
      await showOnWorkoutPage(tester, repsField(0, maxSets - 1));
      expect(addSetButton(0), findsNothing);
      // The next exercise still has its own.
      await showOnWorkoutPage(tester, addSetButton(1));
      expect(tester.takeException(), isNull);
    });

    testWidgets('an exercise that is only marked done has no "Add set"', (
      tester,
    ) async {
      // Tuesday, November 10: a recovery day.
      await pumpApp(tester);
      await openTodaysWorkout(tester);
      await startWorkout(tester);

      await showOnWorkoutPage(
        tester,
        find.byKey(const ValueKey<String>('fs-tick-0')),
      );
      expect(addSetButton(0), findsNothing);
      // A timed exercise has one.
      await showOnWorkoutPage(tester, addSetButton(1));
      expect(addSetButton(1), findsOneWidget);
    });

    testWidgets('last time\'s value stands beside an added set too, by its '
        'place', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await tester.runAsync(() async {
        final workouts = app.store.workouts;
        await workouts.startSession(
          newSession(
            'earlier',
            DateTime(2026, 11, 4, 18),
            owner: app.ownerId,
            exercises: <SessionExercise>[
              exercise('e-squat', position: 0, movementId: 'Back Squat'),
            ],
          ),
        );
        // That day he added a fourth set and logged it.
        await workouts.addSet('e-squat', setId: 'e-squat-extra');
        await workouts.setReps('e-squat-s0', 5);
        await workouts.setWeight('e-squat-s0', 135);
        await workouts.setReps('e-squat-extra', 3);
        await workouts.setWeight('e-squat-extra', 150);
      });
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await showOnWorkoutPage(tester, repsField(0, 0));
      expect(
        _text(tester, find.byKey(const ValueKey<String>('fs-last-0-0'))),
        '135×5',
      );
      expect(find.byKey(const ValueKey<String>('fs-last-0-3')), findsNothing);

      await _tapOnPage(tester, addSetButton(0));

      await showOnWorkoutPage(tester, repsField(0, 3));
      expect(
        _text(tester, find.byKey(const ValueKey<String>('fs-last-0-3'))),
        '150×3',
      );
    });

    testWidgets('if a set cannot be added, the page says so, and that does '
        'not hold Finish up', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      final workouts = app.store.workouts as TestWorkoutRepository;

      workouts.failWrites = true;
      await _tapOnPage(tester, addSetButton(0));
      workouts.failWrites = false;

      expect(repsField(0, 3), findsNothing);
      expect((await squat(app, tester)).sets, hasLength(3));
      await tester.drag(workoutScrollable, const Offset(0, 600));
      await tester.pumpAndSettle();
      expect(_saveFailedNotice, findsOneWidget);

      // Nothing he entered is missing from the store, so he can finish.
      await _finish(tester);
      expect(lockedSummary, findsOneWidget);
    });

    testWidgets('a finished workout has no "Add set" and no Remove, and '
        'lists the added set he logged', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await _tapOnPage(tester, addSetButton(0));
      await _tapOnPage(tester, addSetButton(0));
      await typeNumber(tester, repsField(0, 3), '4');
      await typeNumber(tester, weightField(0, 3), '155');

      await _finish(tester);

      expect(lockedSummary, findsOneWidget);
      expect(find.text('Add set'), findsNothing);
      expect(find.text('Remove'), findsNothing);
      expect(find.text('4 reps × 155 lb'), findsOneWidget);
      // The empty row he added is still stored: a finished workout is
      // locked as it stood.
      final stored = await squat(app, tester);
      expect(stored.sets, hasLength(5));
      final workouts = app.store.workouts;
      final refused = await tester.runAsync(() async {
        final added = await workouts.addSet(stored.id, setId: 'late');
        final removed = await workouts.removeSet(stored.sets.last.id);
        return added || removed;
      });
      expect(refused, isFalse);
      expect((await squat(app, tester)).sets, hasLength(5));
    });
  });

  group('a superset is drawn as one group', () {
    final group = find.byKey(const ValueKey<String>('fs-superset-group'));
    Finder inGroup(Finder what) => find.descendant(of: group, matching: what);
    final a1 = find.byKey(const ValueKey<String>('fs-superset-label-A1'));
    final a2 = find.byKey(const ValueKey<String>('fs-superset-label-A2'));

    testWidgets('before the workout is started: the two exercises stand in '
        'one group, labelled A1 and A2', (tester) async {
      await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);

      await showOnWorkoutPage(tester, group);
      expect(group, findsOneWidget);
      expect(inGroup(find.text('SUPERSET')), findsOneWidget);
      // Monday, November 9: the curl and the triceps extension.
      expect(inGroup(find.text('Cable Curl')), findsOneWidget);
      expect(
        inGroup(find.text('Cable Overhead Triceps Extension')),
        findsOneWidget,
      );
      expect(inGroup(a1), findsOneWidget);
      expect(inGroup(a2), findsOneWidget);
      expect(_text(tester, a1), 'A1');
      expect(_text(tester, a2), 'A2');
      // A1 stands above A2, and no other exercise is in the group or
      // carries a label.
      expect(tester.getTopLeft(a1).dy, lessThan(tester.getTopLeft(a2).dy));
      expect(inGroup(find.text('Cable Face Pull')), findsNothing);
      expect(a1, findsOneWidget);
      expect(a2, findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('during the workout: the same group, with its set rows, '
        'and the rest timer rules as before', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);

      await showOnWorkoutPage(tester, group);
      expect(group, findsOneWidget);
      expect(inGroup(find.text('Cable Curl')), findsOneWidget);
      expect(
        inGroup(find.text('Cable Overhead Triceps Extension')),
        findsOneWidget,
      );
      await showOnWorkoutPage(tester, repsField(5, 0));
      expect(inGroup(repsField(5, 0)), findsOneWidget);
      await showOnWorkoutPage(tester, repsField(6, 0));
      expect(inGroup(repsField(6, 0)), findsOneWidget);
      expect(inGroup(repsField(4, 0)), findsNothing);
      // The first half still has no timer and the second still has one.
      expect(_rest('go', 5), findsNothing);
      await showOnWorkoutPage(tester, _rest('go', 6));
      expect(inGroup(_rest('go', 6)), findsOneWidget);

      // Nothing about it is stored: the session is as it was.
      final session = (await app.savedSession(tester, _monday))!;
      expect(session.exercises, hasLength(7));
      expect(session.exercises[5].name, 'Cable Curl');
      expect(tester.takeException(), isNull);
    });

    testWidgets('a screen reader hears the group and each label', (
      tester,
    ) async {
      await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await showOnWorkoutPage(tester, group);

      expect(
        find.bySemanticsLabel(
          'Superset of 2 exercises, done one after the other',
        ),
        findsOneWidget,
      );
      await showOnWorkoutPage(tester, a1);
      expect(tester.getSemantics(a1).label, contains('Superset A1'));
      await showOnWorkoutPage(tester, a2);
      expect(tester.getSemantics(a2).label, contains('Superset A2'));
    });

    testWidgets('a day with no superset has no group', (tester) async {
      // Tuesday, November 10: a recovery day.
      await pumpApp(tester);
      await openTodaysWorkout(tester);
      expect(find.byType(WorkoutPage), findsOneWidget);
      expect(group, findsNothing);

      await startWorkout(tester);
      await tester.drag(workoutScrollable, const Offset(0, -2000));
      await tester.pumpAndSettle();
      expect(group, findsNothing);
      expect(find.text('SUPERSET'), findsNothing);
    });

    testWidgets('the finished workout\'s summary is as it was: no group', (
      tester,
    ) async {
      await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await typeNumber(tester, repsField(0, 0), '5');
      await typeNumber(tester, weightField(0, 0), '135');

      await _finish(tester);

      expect(lockedSummary, findsOneWidget);
      await tester.drag(workoutScrollable, const Offset(0, -3000));
      await tester.pumpAndSettle();
      expect(group, findsNothing);
      expect(a1, findsNothing);
    });

    testWidgets('a session that does not hold the program\'s movements at '
        'the marked places is drawn with no group', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      // A session for today's plan day whose exercises are not the
      // program's: as if the program's content had changed since.
      await tester.runAsync(
        () => app.store.workouts.startSession(
          newSession(
            'other',
            liftingEvening,
            owner: app.ownerId,
            exercises: <SessionExercise>[
              for (var i = 0; i < 7; i++)
                exercise('o$i', position: i, movementId: 'Movement $i'),
            ],
          ),
        ),
      );
      await openTodaysWorkout(tester);

      await showOnWorkoutPage(tester, repsField(6, 0));
      expect(group, findsNothing);
      expect(a1, findsNothing);
      expect(tester.takeException(), isNull);
    });
  });

  group('kill mid-set and relaunch (P07 acceptance 1, on the screen)', () {
    testWidgets('every entered set is there and the clock is right', (
      tester,
    ) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await typeNumber(tester, repsField(0, 0), '5');
      await typeNumber(tester, weightField(0, 0), '135');
      await typeNumber(tester, repsField(0, 1), '5');
      await typeNumber(tester, weightField(0, 1), '137.5');
      // Mid-set: reps typed, weight not yet.
      await typeNumber(tester, repsField(0, 2), '4');
      await _tapOnPage(tester, _rest('go', 0));

      // The phone kills the app; 17 minutes later he opens it again.
      app.clock.time = liftingEvening.add(
        const Duration(minutes: 17, seconds: 5),
      );
      await relaunchApp(tester, app);

      // Train knows the workout is in progress.
      await openTab(tester, 'Train');
      expect(
        tester.widget<FsChevronRow>(trainTodayRow).subtitle,
        'Core · 45 min · In progress · Tap to continue',
      );
      await tester.tap(trainTodayRow);
      await tester.pumpAndSettle();

      // The clock has kept running while the app was gone.
      expect(_text(tester, workoutClock), '17:05');
      expect(startWorkoutButton, findsNothing);
      // Every box holds what he typed.
      String shown(Finder field) => tester
          .widget<EditableText>(
            find.descendant(of: field, matching: find.byType(EditableText)),
          )
          .controller
          .text;
      await showOnWorkoutPage(tester, repsField(0, 0));
      expect(shown(repsField(0, 0)), '5');
      expect(shown(weightField(0, 0)), '135');
      expect(shown(repsField(0, 1)), '5');
      expect(shown(weightField(0, 1)), '137.5');
      expect(shown(repsField(0, 2)), '4');
      expect(shown(weightField(0, 2)), '');
      // The rest timer started before the kill ran out long ago.
      await showOnWorkoutPage(tester, _rest('go', 0));
      expect(_restTime(tester, 0), 'GO');
      expect(tester.takeException(), isNull);
    });
  });

  group('last time\'s values (review finding U3)', () {
    testWidgets('stand beside each set, found by movement, not by position', (
      tester,
    ) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      // An earlier workout where the squat came third, after two other
      // lifts, and where the first exercise was a row.
      await tester.runAsync(() async {
        final workouts = app.store.workouts;
        await workouts.startSession(
          newSession(
            'earlier',
            DateTime(2026, 11, 4, 18),
            owner: app.ownerId,
            exercises: <SessionExercise>[
              exercise('e-row', position: 0, movementId: 'Barbell Row'),
              exercise('e-press', position: 1, movementId: 'Overhead Press'),
              exercise('e-squat', position: 2, movementId: 'Back Squat'),
            ],
          ),
        );
        await workouts.setReps('e-row-s0', 8);
        await workouts.setWeight('e-row-s0', 95);
        await workouts.setReps('e-squat-s0', 5);
        await workouts.setWeight('e-squat-s0', 135);
        await workouts.setReps('e-squat-s1', 4);
        await workouts.setWeight('e-squat-s1', 140);
      });

      await openTodaysWorkout(tester);
      await startWorkout(tester);

      // Today the squat is first. Its rows show the squat's numbers, not
      // the numbers of what stood first last time.
      await showOnWorkoutPage(tester, repsField(0, 0));
      expect(find.text('LAST TIME · NOV 4'), findsWidgets);
      expect(
        _text(tester, find.byKey(const ValueKey<String>('fs-last-0-0'))),
        '135×5',
      );
      expect(
        _text(tester, find.byKey(const ValueKey<String>('fs-last-0-1'))),
        '140×4',
      );
      // No third set was logged last time.
      expect(find.byKey(const ValueKey<String>('fs-last-0-2')), findsNothing);
      expect(
        find.text('140 lb × 4 reps on your last working set'),
        findsOneWidget,
      );

      // The row is third today and was first then: still its own numbers.
      await showOnWorkoutPage(tester, repsField(2, 0));
      expect(
        _text(tester, find.byKey(const ValueKey<String>('fs-last-2-0'))),
        '95×8',
      );
      // A lift never done before has nothing beside it.
      await showOnWorkoutPage(tester, repsField(1, 0));
      expect(find.byKey(const ValueKey<String>('fs-last-1-0')), findsNothing);
    });

    testWidgets('stand beside the set they were logged in, when an earlier '
        'set was left empty', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      // An earlier workout where only the squat's second set was logged.
      await tester.runAsync(() async {
        final workouts = app.store.workouts;
        await workouts.startSession(
          newSession(
            'earlier',
            DateTime(2026, 11, 4, 18),
            owner: app.ownerId,
            exercises: <SessionExercise>[
              exercise('e-squat', position: 0, movementId: 'Back Squat'),
            ],
          ),
        );
        await workouts.setReps('e-squat-s1', 4);
        await workouts.setWeight('e-squat-s1', 140);
      });

      await openTodaysWorkout(tester);
      await startWorkout(tester);

      await showOnWorkoutPage(tester, repsField(0, 0));
      // Set 1 was not logged last time, so nothing stands beside it.
      expect(find.byKey(const ValueKey<String>('fs-last-0-0')), findsNothing);
      expect(
        _text(tester, find.byKey(const ValueKey<String>('fs-last-0-1'))),
        '140×4',
      );
      expect(find.byKey(const ValueKey<String>('fs-last-0-2')), findsNothing);
      // The line above the sets still names the last set he logged.
      expect(
        find.text('140 lb × 4 reps on your last working set'),
        findsOneWidget,
      );
    });
  });

  group('the rest timer', () {
    testWidgets('counts down from the rest the prescription writes', (
      tester,
    ) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await showOnWorkoutPage(tester, _rest('go', 0));

      // "rest 2 min".
      expect(_restTime(tester, 0), '2:00');
      expect(tester.widget<FsButton>(_rest('go', 0)).label, 'Start');

      await tester.tap(_rest('go', 0));
      await tester.pumpAndSettle();
      expect(tester.widget<FsButton>(_rest('go', 0)).label, 'Pause');
      app.clock.time = liftingEvening.add(const Duration(seconds: 45));
      await tester.pump(const Duration(seconds: 1));
      expect(_restTime(tester, 0), '1:15');

      // It ends at an instant that is stored, not counted in memory.
      final stored = (await app.savedSession(tester, _monday))!.exercises.first;
      expect(
        stored.restEndsAtUtc,
        liftingEvening.toUtc().add(const Duration(seconds: 120)),
      );

      // At zero it says go.
      app.clock.time = liftingEvening.add(const Duration(seconds: 121));
      await tester.pump(const Duration(seconds: 1));
      expect(_restTime(tester, 0), 'GO');
      expect(tester.widget<FsButton>(_rest('go', 0)).label, 'Start');
    });

    testWidgets('pauses, resumes, resets and moves by 15 seconds', (
      tester,
    ) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await showOnWorkoutPage(tester, _rest('reset', 0));

      await tester.tap(_rest('go', 0));
      await tester.pumpAndSettle();
      app.clock.time = liftingEvening.add(const Duration(seconds: 30));
      await tester.tap(_rest('go', 0));
      await tester.pumpAndSettle();
      expect(_restTime(tester, 0), '1:30');
      expect(tester.widget<FsButton>(_rest('go', 0)).label, 'Resume');
      // Paused, it does not move with the clock.
      app.clock.time = liftingEvening.add(const Duration(minutes: 5));
      await tester.pump(const Duration(seconds: 1));
      expect(_restTime(tester, 0), '1:30');

      await tester.tap(_rest('go', 0));
      await tester.pumpAndSettle();
      expect(tester.widget<FsButton>(_rest('go', 0)).label, 'Pause');
      expect(_restTime(tester, 0), '1:30');

      // Running, +15 gives 15 more seconds now and next time.
      await tester.tap(_rest('more', 0));
      await tester.pumpAndSettle();
      expect(_restTime(tester, 0), '1:45');

      await tester.tap(_rest('reset', 0));
      await tester.pumpAndSettle();
      expect(_restTime(tester, 0), '2:15');
      expect(tester.widget<FsButton>(_rest('go', 0)).label, 'Start');

      await tester.tap(_rest('less', 0));
      await tester.pumpAndSettle();
      await tester.tap(_rest('less', 0));
      await tester.pumpAndSettle();
      expect(_restTime(tester, 0), '1:45');
      expect(
        (await app.savedSession(
          tester,
          _monday,
        ))!.exercises.first.restBaseSeconds,
        105,
      );
    });

    testWidgets('never goes under 15 seconds or over 10 minutes', (
      tester,
    ) async {
      await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await showOnWorkoutPage(tester, _rest('reset', 0));

      for (var i = 0; i < 12; i++) {
        await tester.tap(_rest('less', 0));
        await tester.pumpAndSettle();
      }
      expect(_restTime(tester, 0), '0:15');

      for (var i = 0; i < 45; i++) {
        await tester.tap(_rest('more', 0));
        await tester.pump();
      }
      await tester.pumpAndSettle();
      expect(_restTime(tester, 0), '10:00');
    });

    testWidgets('at ten minutes, +15 does not make a running rest longer; '
        'at fifteen seconds, −15 does not make it shorter', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await showOnWorkoutPage(tester, _rest('reset', 0));
      Future<DateTime?> endsAt() async => (await app.savedSession(
        tester,
        _monday,
      ))!.exercises.first.restEndsAtUtc;

      // Up to the longest rest, then start it.
      for (var i = 0; i < 40; i++) {
        await tester.tap(_rest('more', 0));
        await tester.pump();
      }
      await tester.pumpAndSettle();
      await tester.tap(_rest('go', 0));
      await tester.pumpAndSettle();
      expect(_restTime(tester, 0), '10:00');
      final longest = await endsAt();
      expect(longest, liftingEvening.toUtc().add(const Duration(minutes: 10)));

      for (var i = 0; i < 3; i++) {
        await tester.tap(_rest('more', 0));
        await tester.pumpAndSettle();
      }
      expect(_restTime(tester, 0), '10:00');
      expect(await endsAt(), longest);
      // One step down from the limit does move it, by that step.
      await tester.tap(_rest('less', 0));
      await tester.pumpAndSettle();
      expect(_restTime(tester, 0), '9:45');
      expect(await endsAt(), longest!.subtract(const Duration(seconds: 15)));

      // Down to the shortest rest, then start it.
      await tester.tap(_rest('reset', 0));
      await tester.pumpAndSettle();
      for (var i = 0; i < 45; i++) {
        await tester.tap(_rest('less', 0));
        await tester.pump();
      }
      await tester.pumpAndSettle();
      await tester.tap(_rest('go', 0));
      await tester.pumpAndSettle();
      expect(_restTime(tester, 0), '0:15');
      final shortest = await endsAt();
      expect(shortest, liftingEvening.toUtc().add(const Duration(seconds: 15)));

      for (var i = 0; i < 3; i++) {
        await tester.tap(_rest('less', 0));
        await tester.pumpAndSettle();
      }
      // Still running, and still fifteen seconds: it has not run out.
      expect(_restTime(tester, 0), '0:15');
      expect(await endsAt(), shortest);
      expect(tester.widget<FsButton>(_rest('go', 0)).label, 'Pause');
    });

    testWidgets('the first half of a superset has no timer; the second '
        'has a minute', (tester) async {
      await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);

      await showOnWorkoutPage(tester, _rest('go', 6));
      expect(_restTime(tester, 6), '1:00');
      expect(_rest('go', 5), findsNothing);
      expect(
        find.text('Superset: go straight to the next exercise, no rest.'),
        findsOneWidget,
      );
    });
  });

  group('the workout clock', () {
    testWidgets('shows the time since the session started', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);

      app.clock.time = liftingEvening.add(
        const Duration(minutes: 12, seconds: 34),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(_text(tester, workoutClock), '12:34');

      app.clock.time = liftingEvening.add(
        const Duration(hours: 1, minutes: 2, seconds: 3),
      );
      await tester.pump(const Duration(seconds: 1));
      expect(_text(tester, workoutClock), '1:02:03');
    });
  });

  group('finishing', () {
    testWidgets('locks the workout into a summary and checks the Workout '
        'box on Today', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await typeNumber(tester, repsField(0, 0), '5');
      await typeNumber(tester, weightField(0, 0), '135');
      await typeNumber(tester, repsField(0, 1), '5');
      await typeNumber(tester, weightField(0, 1), '140');
      app.clock.time = liftingEvening.add(const Duration(minutes: 42));

      await _tapOnPage(tester, finishWorkoutButton);
      // Sets are blank: he is asked, and may finish without them.
      expect(find.text('SOME SETS ARE BLANK'), findsOneWidget);
      expect(
        find.text('• Barbell Back Squat, Set 3: nothing entered'),
        findsOneWidget,
      );
      expect(find.text('• and 11 more'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey<String>('fs-finish-anyway')));
      await tester.pumpAndSettle();

      // A locked summary: no boxes, no buttons, the time it took.
      expect(lockedSummary, findsOneWidget);
      expect(find.byType(FsNumberField), findsNothing);
      expect(finishWorkoutButton, findsNothing);
      expect(startWorkoutButton, findsNothing);
      expect(find.text('FINISHED IN'), findsOneWidget);
      expect(_text(tester, workoutClock), '42:00');
      expect(find.text('Finished at 6:42 PM. Locked.'), findsOneWidget);
      expect(find.text('1,375'), findsOneWidget); // 5 x 135 + 5 x 140
      expect(find.text('LB VOLUME'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      // The count's label and the section's heading.
      expect(find.text('WORK SETS'), findsNWidgets(2));
      expect(find.text('5 reps × 135 lb'), findsOneWidget);
      expect(find.text('5 reps × 140 lb'), findsOneWidget);
      expect(find.text('Not logged'), findsWidgets);
      // The clock has stopped.
      app.clock.time = liftingEvening.add(const Duration(hours: 3));
      await tester.pump(const Duration(seconds: 2));
      expect(_text(tester, workoutClock), '42:00');

      final session = (await app.savedSession(tester, _monday))!;
      expect(session.finished, isTrue);
      expect(
        session.finishedAtUtc,
        liftingEvening.add(const Duration(minutes: 42)).toUtc(),
      );

      // Train says so.
      await tester.tap(find.text('‹ BACK'));
      await tester.pumpAndSettle();
      expect(_trainStatus(tester), 'WORKOUT COMPLETE');
      final today = tester.widget<FsChevronRow>(trainTodayRow);
      expect(today.mark, FsRowMark.check);
      expect(today.subtitle, 'Core · 45 min · Finished · Tap to view');
      expect(
        tester
            .widget<FsChevronRow>(
              find.byKey(const ValueKey<String>('fs-week-2026-11-09')),
            )
            .mark,
        FsRowMark.check,
      );

      // The Workout box on Today has checked itself.
      await openTab(tester, 'Today');
      await showBox(tester, 't_workout');
      final workoutBox = tester.widget<FsBoxRow>(box('t_workout'));
      expect(workoutBox.checked, isTrue);
      expect(workoutBox.subtitle, 'Finished in Train');
      await scrollTodayToTop(tester);
      expect(find.text('1/7'), findsOneWidget);
      expect(find.text('1 OF 4'), findsOneWidget);
      // Decision Q6: the streak counts devotional days, not workouts.
      expect(find.text('0 DAYS'), findsOneWidget);
      expect(await app.savedDoneDays(tester), {
        _monday: {DayItems.workout},
      });
    });

    testWidgets('twice records one completion (P07 acceptance 2)', (
      tester,
    ) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await showOnWorkoutPage(tester, finishWorkoutButton);

      // Two taps on Finish before the page has redrawn.
      await tester.tap(finishWorkoutButton);
      await tester.pumpAndSettle();
      final anyway = find.byKey(const ValueKey<String>('fs-finish-anyway'));
      await tester.tap(anyway);
      await tester.tap(anyway, warnIfMissed: false);
      await tester.pumpAndSettle();
      expect(lockedSummary, findsOneWidget);

      // And a finish replayed straight at the store, an hour later.
      final session = (await app.savedSession(tester, _monday))!;
      final again = await tester.runAsync(
        () => app.store.workouts.finishSession(
          session.id,
          liftingEvening.add(const Duration(hours: 1)),
        ),
      );

      expect(again, FinishOutcome.alreadyFinished);
      final events = await app.savedEvents(tester, _monday, DayItems.workout);
      expect(events, hasLength(1));
      expect(events.single.id, session.finishEventId);
      expect(
        (await app.savedSession(tester, _monday))!.finishedAtUtc,
        liftingEvening.toUtc(),
      );
      expect((app.store.days as TestDayRepository).saveAttempts, 1);
    });

    testWidgets('a set with reps and no weight has to be fixed first', (
      tester,
    ) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await typeNumber(tester, repsField(0, 0), '5');

      await _tapOnPage(tester, finishWorkoutButton);

      expect(find.text('FIX THIS SET FIRST'), findsOneWidget);
      expect(
        find.text('• Barbell Back Squat, Set 1: add the weight'),
        findsOneWidget,
      );
      // There is no way past it from here.
      expect(
        find.byKey(const ValueKey<String>('fs-finish-anyway')),
        findsNothing,
      );
      expect(
        tester.widget<FsDialog>(find.byType(FsDialog)).tone,
        FsDialogTone.warning,
      );
      await tester.tap(find.byKey(const ValueKey<String>('fs-finish-fix')));
      await tester.pumpAndSettle();

      expect((await app.savedSession(tester, _monday))!.finished, isFalse);
      // The box that is missing its number is outlined.
      await showOnWorkoutPage(tester, weightField(0, 0));
      expect(tester.widget<FsNumberField>(weightField(0, 0)).invalid, isTrue);
      expect(tester.widget<FsNumberField>(repsField(0, 0)).invalid, isFalse);

      // Fixed, the workout finishes.
      await typeNumber(tester, weightField(0, 0), '135');
      await _finish(tester);
      expect(lockedSummary, findsOneWidget);
    });

    testWidgets('a set with a weight and no reps does not hold Finish up, '
        'and the summary says it was not counted and why', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await typeNumber(tester, repsField(0, 0), '5');
      await typeNumber(tester, weightField(0, 0), '135');
      // Set 2: the weight, and no reps.
      await typeNumber(tester, weightField(0, 1), '140');

      await _tapOnPage(tester, finishWorkoutButton);

      // He is told which set and why, and may finish without it.
      expect(find.text('SOME SETS WILL NOT BE COUNTED'), findsOneWidget);
      expect(
        find.text('• Barbell Back Squat, Set 2: a weight but no reps'),
        findsOneWidget,
      );
      expect(
        find.text('• Barbell Back Squat, Set 3: nothing entered'),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey<String>('fs-finish-fix')), findsNothing);
      expect(
        tester.widget<FsDialog>(find.byType(FsDialog)).tone,
        FsDialogTone.notice,
      );
      await tester.tap(find.byKey(const ValueKey<String>('fs-finish-anyway')));
      await tester.pumpAndSettle();

      // Finished. The summary names the set that was not counted and says
      // what it is missing; the set left empty has no line.
      expect(lockedSummary, findsOneWidget);
      expect(find.text('5 reps × 135 lb'), findsOneWidget);
      expect(find.text('Not counted: 140 lb, no reps'), findsOneWidget);
      expect(find.textContaining('Not counted'), findsOneWidget);
      // It adds nothing to the totals: one set, 5 x 135.
      expect(find.text('675'), findsOneWidget);
      expect(find.text('WORK SET'), findsOneWidget);

      final session = (await app.savedSession(tester, _monday))!;
      expect(session.finished, isTrue);
      expect(session.totals.loggedSets, 1);
      // What he typed is still in the locked workout.
      expect(session.exercises.first.sets[1].weightLb, 140);
      expect(session.exercises.first.sets[1].reps, isNull);
      expect(await app.savedDoneDays(tester), {
        _monday: {DayItems.workout},
      });
    });

    testWidgets('Go back and Android back leave the workout open', (
      tester,
    ) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);

      await _tapOnPage(tester, finishWorkoutButton);
      await tester.tap(find.byKey(const ValueKey<String>('fs-finish-back')));
      await tester.pumpAndSettle();
      expect((await app.savedSession(tester, _monday))!.finished, isFalse);

      await _tapOnPage(tester, finishWorkoutButton);
      await systemBack(tester);
      expect(find.byType(FsDialog), findsNothing);
      expect(find.byType(WorkoutPage), findsOneWidget);
      expect((await app.savedSession(tester, _monday))!.finished, isFalse);
      expect(await app.savedDoneDays(tester), isEmpty);
    });

    testWidgets('if finishing cannot be saved, the workout stays open and '
        'the page says so', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      (app.store.days as TestDayRepository).failWrites = true;

      await _finish(tester);

      expect(lockedSummary, findsNothing);
      await tester.drag(workoutScrollable, const Offset(0, 3000));
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey<String>('fs-workout-save-failed')),
        findsOneWidget,
      );
      expect((await app.savedSession(tester, _monday))!.finished, isFalse);
      expect(await app.savedDoneDays(tester), isEmpty);

      // Trying again when the store works finishes it.
      (app.store.days as TestDayRepository).failWrites = false;
      await _finish(tester);
      expect(lockedSummary, findsOneWidget);
      expect(await app.savedDoneDays(tester), {
        _monday: {DayItems.workout},
      });
    });

    testWidgets('a set that did not save holds Finish up until it is '
        'stored: nothing he entered is locked out', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      final workouts = app.store.workouts as TestWorkoutRepository;
      await typeNumber(tester, weightField(0, 0), '135');

      // Two changes cannot be stored: the reps of set 2, then those of
      // set 1. He is still in set 1's box, which shows the 5 he typed.
      workouts.failWrites = true;
      await typeNumber(tester, repsField(0, 1), '4');
      await typeNumber(tester, repsField(0, 0), '5');
      workouts.failWrites = false;
      expect(_typed(tester, repsField(0, 0)), '5');

      await _finish(tester);

      // Nothing is locked, and he was not asked whether to finish without
      // the set: he is at the top of the page, where the notice is.
      expect(lockedSummary, findsNothing);
      expect(find.byType(FsDialog), findsNothing);
      expect(_saveFailedNotice, findsOneWidget);
      expect(
        tester.state<ScrollableState>(workoutScrollable).position.pixels,
        0,
      );
      // The box he was in shows what is stored, which is nothing.
      expect(_typed(tester, repsField(0, 0)), '');
      var session = (await app.savedSession(tester, _monday))!;
      expect(session.finished, isFalse);
      expect(session.exercises.first.sets[0].reps, isNull);
      expect(await app.savedDoneDays(tester), isEmpty);

      // Another tap does the same. So does one of the two being stored:
      // the other is still not.
      await _finish(tester);
      await typeNumber(tester, repsField(0, 1), '4');
      await typeNumber(tester, weightField(0, 1), '140');
      await _finish(tester);
      expect(lockedSummary, findsNothing);
      expect(find.byType(FsDialog), findsNothing);
      expect((await app.savedSession(tester, _monday))!.finished, isFalse);

      // The reps of set 1 typed again and stored: the notice goes, and the
      // workout finishes with both sets in it.
      await typeNumber(tester, repsField(0, 0), '5');
      await tester.drag(workoutScrollable, const Offset(0, 3000));
      await tester.pumpAndSettle();
      expect(_saveFailedNotice, findsNothing);
      await _finish(tester);
      expect(lockedSummary, findsOneWidget);
      expect(find.text('5 reps × 135 lb'), findsOneWidget);
      expect(find.text('4 reps × 140 lb'), findsOneWidget);
      session = (await app.savedSession(tester, _monday))!;
      expect(session.finished, isTrue);
      expect(session.exercises.first.sets[0].reps, 5);
      expect(session.exercises.first.sets[1].reps, 4);
      expect(await app.savedDoneDays(tester), {
        _monday: {DayItems.workout},
      });
    });

    testWidgets('a tick that did not save holds Finish up too', (tester) async {
      // Tuesday, November 10: a recovery day, whose first row is a tick.
      const tuesday = LocalDate(2026, 11, 10);
      final app = await pumpApp(tester);
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      final workouts = app.store.workouts as TestWorkoutRepository;
      final tick = find.byKey(const ValueKey<String>('fs-tick-0'));

      workouts.failWrites = true;
      await _tapOnPage(tester, tick);
      workouts.failWrites = false;
      await _finish(tester);
      expect(lockedSummary, findsNothing);
      expect(find.byType(FsDialog), findsNothing);
      expect((await app.savedSession(tester, tuesday))!.finished, isFalse);

      // Ticked again and stored, the workout finishes with the tick in it.
      await _tapOnPage(tester, tick);
      await _finish(tester);
      expect(lockedSummary, findsOneWidget);
      final session = (await app.savedSession(tester, tuesday))!;
      expect(session.finished, isTrue);
      expect(session.exercises.first.sets.single.ticked, isTrue);
    });

    testWidgets('a rest timer that did not save does not hold Finish up', (
      tester,
    ) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      final workouts = app.store.workouts as TestWorkoutRepository;

      workouts.failWrites = true;
      await _tapOnPage(tester, _rest('more', 0));
      workouts.failWrites = false;
      await _finish(tester);

      // Where a rest timer stood is no part of what a finished workout
      // keeps.
      expect(lockedSummary, findsOneWidget);
      expect((await app.savedSession(tester, _monday))!.finished, isTrue);
    });

    testWidgets('a set still being written when Finish is tapped is waited '
        'for: if it then fails, nothing is locked', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      final workouts = app.store.workouts as TestWorkoutRepository;

      // A slow disk holds the reps of set 1, and will then refuse them.
      workouts.hold();
      await typeNumber(tester, repsField(0, 0), '5');
      workouts.failWrites = true;
      await _tapOnPage(tester, finishWorkoutButton);

      // Finish waits for the answer: nothing is asked or locked yet, and a
      // second tap has nothing to press.
      expect(find.byType(FsDialog), findsNothing);
      expect(lockedSummary, findsNothing);
      expect(tester.widget<FsButton>(finishWorkoutButton).onPressed, isNull);

      workouts.release();
      await tester.pumpAndSettle();
      workouts.failWrites = false;

      expect(find.byType(FsDialog), findsNothing);
      expect(lockedSummary, findsNothing);
      expect(_saveFailedNotice, findsOneWidget);
      expect((await app.savedSession(tester, _monday))!.finished, isFalse);
      expect(await app.savedDoneDays(tester), isEmpty);
    });

    testWidgets('a set still being written when Finish is tapped is in the '
        'check, and in the locked workout, once it is stored', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      final workouts = app.store.workouts as TestWorkoutRepository;

      // Set 1's reps are held by a slow disk: its weight is never typed.
      workouts.hold();
      await typeNumber(tester, repsField(0, 0), '5');
      await _tapOnPage(tester, finishWorkoutButton);
      expect(find.byType(FsDialog), findsNothing);

      // Stored. The check sees the reps the page has not yet redrawn: a
      // set with reps and no weight has to be fixed, not finished without.
      workouts.release();
      await tester.pumpAndSettle();
      expect(find.text('FIX THIS SET FIRST'), findsOneWidget);
      expect(
        find.text('• Barbell Back Squat, Set 1: add the weight'),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey<String>('fs-finish-fix')));
      await tester.pumpAndSettle();
      expect((await app.savedSession(tester, _monday))!.finished, isFalse);

      await typeNumber(tester, weightField(0, 0), '135');
      await _finish(tester);
      expect(lockedSummary, findsOneWidget);
      expect(find.text('5 reps × 135 lb'), findsOneWidget);
    });

    testWidgets('if the workout cannot be read back before it is locked, '
        'nothing is finished and the page says so', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      final workouts = app.store.workouts as TestWorkoutRepository;

      workouts.failSessionReads = true;
      await _finish(tester);

      expect(find.byType(FsDialog), findsNothing);
      expect(lockedSummary, findsNothing);
      expect(_saveFailedNotice, findsOneWidget);
      workouts.failSessionReads = false;
      expect((await app.savedSession(tester, _monday))!.finished, isFalse);
      expect(await app.savedDoneDays(tester), isEmpty);

      // Trying again when the store can be read finishes it.
      await _finish(tester);
      expect(lockedSummary, findsOneWidget);
      expect(await app.savedDoneDays(tester), {
        _monday: {DayItems.workout},
      });
    });
  });

  group('the locked summary of a timed set', () {
    testWidgets('shows the weight he entered with it, in the form a set of '
        'reps has', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      // Today's workout, finished: a loaded carry, a hold with weight
      // added, and a hold with none.
      await tester.runAsync(() async {
        final workouts = app.store.workouts;
        await workouts.startSession(
          newSession(
            'timed',
            liftingEvening,
            owner: app.ownerId,
            exercises: <SessionExercise>[
              exercise(
                't-carry',
                position: 0,
                movementId: 'Suitcase Carry',
                prescription: '2 x 30 sec',
                measure: SetMeasure.seconds,
                weightMode: WeightMode.required,
                sets: 2,
              ),
              exercise(
                't-plank',
                position: 1,
                movementId: 'Plank',
                prescription: '2 x 25 sec',
                measure: SetMeasure.seconds,
                weightMode: WeightMode.optional,
                sets: 2,
              ),
            ],
          ),
        );
        await workouts.setReps('t-carry-s0', 30);
        await workouts.setWeight('t-carry-s0', 40);
        // The second carry: seconds, and no weight typed.
        await workouts.setReps('t-carry-s1', 28);
        await workouts.setReps('t-plank-s0', 25);
        await workouts.setWeight('t-plank-s0', 10);
        await workouts.setReps('t-plank-s1', 20);
        await workouts.finishSession(
          'timed',
          liftingEvening.add(const Duration(minutes: 30)),
        );
      });

      await openTodaysWorkout(tester);

      expect(lockedSummary, findsOneWidget);
      expect(find.text('30 sec × 40 lb'), findsOneWidget);
      expect(find.text('25 sec (bodyweight + 10 lb)'), findsOneWidget);
      // With no weight entered the line is as it was.
      expect(find.text('28 sec'), findsOneWidget);
      expect(find.text('20 sec'), findsOneWidget);
    });
  });

  group('an earlier day\'s unfinished workout', () {
    testWidgets('stays on Train after today\'s workout is started, also '
        'once its day has left the week shown', (tester) async {
      Future<void> backToTrain() async {
        await tester.drag(workoutScrollable, const Offset(0, 3000));
        await tester.pumpAndSettle();
        await tester.tap(find.text('‹ BACK'));
        await tester.pumpAndSettle();
      }

      final carried = find.byKey(
        const ValueKey<String>('fs-train-carried-over'),
      );

      // Friday of the plan's first week: started, one set, not finished.
      final clock = TestClock(DateTime(2026, 11, 13, 18));
      await pumpApp(tester, clock: clock);
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await typeNumber(tester, repsField(0, 0), '5');
      await typeNumber(tester, weightField(0, 0), '135');

      // Monday of the next week: Friday is no longer in the week shown.
      clock.time = DateTime(2026, 11, 16, 18);
      await backgroundAndResume(tester);
      await backToTrain();
      expect(find.text('MONDAY, NOVEMBER 16'), findsOneWidget);
      expect(
        find.byKey(const ValueKey<String>('fs-week-2026-11-13')),
        findsNothing,
      );
      expect(
        tester.widget<FsChevronRow>(carried).title,
        'Full Body C: Bench Press',
      );

      // He starts Monday's workout as well.
      await tester.ensureVisible(trainTodayRow);
      await tester.pumpAndSettle();
      await tester.tap(trainTodayRow);
      await tester.pumpAndSettle();
      await startWorkout(tester);
      await backToTrain();

      // Friday's is still on Train, and still opens Friday's workout.
      expect(find.text('WORKOUT IN PROGRESS'), findsOneWidget);
      expect(
        tester.widget<FsChevronRow>(carried).title,
        'Full Body C: Bench Press',
      );
      await tester.ensureVisible(carried);
      await tester.pumpAndSettle();
      await tester.tap(carried);
      await tester.pumpAndSettle();
      expect(find.text('FRIDAY, NOVEMBER 13'), findsOneWidget);
      expect(repsField(0, 0), findsOneWidget);
    });
  });

  group('a session started at 23:50 can be finished at 00:10 '
      '(P07 acceptance 3, review finding U2)', () {
    testWidgets('it stays open past midnight and checks the box of the day '
        'it started on', (tester) async {
      final clock = TestClock(DateTime(2026, 11, 9, 23, 50));
      final app = await pumpApp(tester, clock: clock);
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await typeNumber(tester, repsField(0, 0), '5');
      await typeNumber(tester, weightField(0, 0), '135');

      // Midnight passes with the page open.
      clock.time = DateTime(2026, 11, 10, 0, 10);
      await backgroundAndResume(tester);

      // The page is still Monday's workout, still open for logging.
      expect(find.text('MONDAY, NOVEMBER 9'), findsOneWidget);
      expect(_text(tester, workoutClock), '20:00');
      await typeNumber(tester, repsField(0, 1), '4');
      await typeNumber(tester, weightField(0, 1), '140');
      expect(
        (await app.savedSession(tester, _monday))!.exercises.first.sets[1].reps,
        4,
      );

      // Train, now on Tuesday, shows the way back into it.
      await tester.drag(workoutScrollable, const Offset(0, 3000));
      await tester.pumpAndSettle();
      await tester.tap(find.text('‹ BACK'));
      await tester.pumpAndSettle();
      expect(find.text('TUESDAY, NOVEMBER 10'), findsOneWidget);
      expect(find.text('WORKOUT IN PROGRESS'), findsOneWidget);
      final carried = find.byKey(
        const ValueKey<String>('fs-train-carried-over'),
      );
      expect(
        tester.widget<FsChevronRow>(carried).title,
        'Full Body A: Back Squat',
      );
      await tester.tap(carried);
      await tester.pumpAndSettle();
      expect(find.text('MONDAY, NOVEMBER 9'), findsOneWidget);

      await _finish(tester);

      expect(lockedSummary, findsOneWidget);
      expect(_text(tester, workoutClock), '20:00');
      expect(find.text('Finished at 12:10 AM. Locked.'), findsOneWidget);
      final session = (await app.savedSession(tester, _monday))!;
      expect(session.day, _monday);
      expect(session.finished, isTrue);
      // Monday's box, not Tuesday's.
      expect(await app.savedDoneDays(tester), {
        _monday: {DayItems.workout},
      });
      expect(
        await app.savedSession(tester, const LocalDate(2026, 11, 10)),
        isNull,
      );

      // Train: nothing in progress any more; Monday is checked in the
      // week; Tuesday's own session is still there to do.
      await tester.tap(find.text('‹ BACK'));
      await tester.pumpAndSettle();
      expect(find.text('WORKOUT IN PROGRESS'), findsNothing);
      expect(_trainStatus(tester), 'READY TO TRAIN');
      expect(
        tester
            .widget<FsChevronRow>(
              find.byKey(const ValueKey<String>('fs-week-2026-11-09')),
            )
            .mark,
        FsRowMark.check,
      );
      // Today (Tuesday) does not show a finished workout.
      await openTab(tester, 'Today');
      await showBox(tester, 't_workout');
      expect(tester.widget<FsBoxRow>(box('t_workout')).checked, isFalse);
    });

    testWidgets('a workout cannot be started for a day that has ended', (
      tester,
    ) async {
      final clock = TestClock(DateTime(2026, 11, 9, 23, 59));
      final app = await pumpApp(tester, clock: clock);
      await openTodaysWorkout(tester);
      await tester.tap(startWorkoutButton);
      await tester.pumpAndSettle();

      // He reads the prayer past midnight, then says Amen.
      clock.time = DateTime(2026, 11, 10, 0, 1);
      await tester.tap(prayerAmenButton);
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey<String>('fs-workout-new-day')),
        findsOneWidget,
      );
      expect(find.text(workoutNewDayNotice), findsOneWidget);
      expect(await app.savedSession(tester, _monday), isNull);
      expect(
        await app.savedSession(tester, const LocalDate(2026, 11, 10)),
        isNull,
      );
      // Monday's page no longer offers Start: Monday is over.
      expect(startWorkoutButton, findsNothing);
    });
  });

  group('changing the plan afterwards (P07 acceptance 4)', () {
    testWidgets('does not alter the finished session', (tester) async {
      final app = await pumpApp(tester, clock: TestClock(liftingEvening));
      await openTodaysWorkout(tester);
      await startWorkout(tester);
      await typeNumber(tester, repsField(0, 0), '5');
      await typeNumber(tester, weightField(0, 0), '135');
      await _finish(tester);
      final before = (await app.savedSession(tester, _monday))!;

      // The plan changes under it: dumbbells only, and a start that makes
      // this Monday a different plan day.
      await tester.runAsync(() async {
        final plan = (await app.store.workouts.watchPlan(app.ownerId).first)!;
        await app.store.workouts.savePlan(
          app.ownerId,
          plan.copyWith(
            equipment: 'Dumbbells Only',
            start: const LocalDate(2026, 11, 2),
            fourthDay: true,
          ),
        );
      });
      await tester.pumpAndSettle();

      // The finished workout reads as it did.
      expect(lockedSummary, findsOneWidget);
      expect(find.text('WEEK 1 · DAY 1 · 45 MIN'), findsOneWidget);
      expect(find.text('FULL BODY A: BACK SQUAT'), findsOneWidget);
      expect(find.text('Barbell Back Squat'), findsOneWidget);
      expect(find.text('Dumbbell Goblet Squat'), findsNothing);
      expect(find.text('5 reps × 135 lb'), findsOneWidget);
      final after = (await app.savedSession(tester, _monday))!;
      expect(after.title, before.title);
      expect(after.planDay, before.planDay);
      expect(
        after.exercises.map((e) => (e.movementId, e.name, e.prescription)),
        before.exercises.map((e) => (e.movementId, e.name, e.prescription)),
      );
      expect(after.finishedAtUtc, before.finishedAtUtc);
      expect(after.totals.volumeLb, 675);

      // Train does follow the new plan: this Monday is now week 2, and
      // the day still counts as done.
      await tester.tap(find.text('‹ BACK'));
      await tester.pumpAndSettle();
      expect(find.byType(TrainPage), findsOneWidget);
      expect(_trainStatus(tester), 'WORKOUT COMPLETE');
      final friday = tester.widget<FsChevronRow>(
        find.byKey(const ValueKey<String>('fs-week-2026-11-13')),
      );
      expect(friday.title, library.days[11].title);
      // And a later day of the new plan shows the new equipment's names.
      await tester.ensureVisible(
        find.byKey(const ValueKey<String>('fs-week-2026-11-11')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey<String>('fs-week-2026-11-11')),
      );
      await tester.pumpAndSettle();
      expect(find.text('WEEK 2 · DAY 10 · 45 MIN'), findsOneWidget);
      expect(find.text('Barbell Back Squat'), findsNothing);
    });
  });

  group('the page fits', () {
    for (final (name, size, scale) in <(String, Size, double)>[
      ('at 1.3 times the text size', phone, 1.3),
      ('at 2.0 times the text size', phone, 2.0),
      (
        'on a small phone at 1.3 times the text size',
        const Size(320, 568),
        1.3,
      ),
    ]) {
      testWidgets('nothing overflows $name', (tester) async {
        await pumpApp(
          tester,
          size: size,
          textScale: scale,
          clock: TestClock(liftingEvening),
        );
        await openTodaysWorkout(tester);
        expect(tester.takeException(), isNull);

        await tester.ensureVisible(startWorkoutButton);
        await tester.pumpAndSettle();
        await tester.tap(startWorkoutButton);
        await tester.pumpAndSettle();
        await tester.ensureVisible(prayerAmenButton);
        await tester.pumpAndSettle();
        await tester.tap(prayerAmenButton);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);

        // The live page from top to bottom.
        await typeNumber(tester, repsField(0, 0), '5');
        await typeNumber(tester, weightField(0, 0), '135');
        await showOnWorkoutPage(tester, finishWorkoutButton);
        expect(tester.takeException(), isNull);

        // The blank-sets dialog, then the locked summary.
        await tester.tap(finishWorkoutButton);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final anyway = find.byKey(const ValueKey<String>('fs-finish-anyway'));
        await tester.ensureVisible(anyway);
        await tester.pumpAndSettle();
        await tester.tap(anyway);
        await tester.pumpAndSettle();
        expect(lockedSummary, findsOneWidget);
        final position = tester
            .state<ScrollableState>(workoutScrollable)
            .position;
        position.jumpTo(position.maxScrollExtent);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      });
    }
  });
}
