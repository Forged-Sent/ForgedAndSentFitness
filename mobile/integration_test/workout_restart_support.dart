import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/main.dart' as app;
import 'package:forged_and_sent/src/app/local_store.dart';
import 'package:forged_and_sent/src/core/clock.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/design/fs_box_row.dart';
import 'package:forged_and_sent/src/design/fs_chevron_row.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';
import 'package:forged_and_sent/src/features/workout/domain/workout_session.dart';
import 'package:forged_and_sent/src/features/workout/presentation/train_page.dart';
import 'package:forged_and_sent/src/features/workout/presentation/workout_page.dart';

/// Shared by the two halves of the workout restart test (P07 acceptance 5:
/// start, two sets, kill, relaunch, finish, on the Android emulator).
///
/// A test cannot outlive the app it runs in, so the test is two files, run
/// one after the other with the app's process stopped in between. Each
/// starts the real app: `startApp()`, the real SQLite file in the app's own
/// folder.
///
///     flutter test integration_test/workout_restart_1_start_test.dart -d <device> --no-uninstall
///     flutter test integration_test/workout_restart_2_finish_test.dart -d <device>
///
/// `--no-uninstall` on the first keeps the app and its data on the device;
/// the test runner stops the app's process when the run ends, with the
/// workout in progress. The second installs over it, starts a new process,
/// and checks what that process finds. It uninstalls the app afterwards.
///
/// The app is new on the device when the first half starts: the half
/// uninstalls nothing itself, so run it on an emulator without the app, or
/// after the second half of an earlier run.
///
/// **The clock.** A workout can be started only on a day that has one, and
/// logging weights needs a lifting day. The test must pass whatever day it
/// is run on, so both halves start the app on the phone's clock moved
/// forward by whole days to the next lifting day: Monday, Wednesday or
/// Friday. Nothing else about the clock changes: it still runs, so the
/// time between the two halves is real time. Both halves must run on the
/// same real day, or they would not agree on the day they moved to.
/// A release build refuses to start on any clock but the phone's
/// (`clockForStart` in `main.dart`); these tests run in debug mode.
class NextLiftingDayClock implements Clock {
  NextLiftingDayClock() : _shift = Duration(days: _daysToLiftingDay());

  final Duration _shift;

  static const Set<int> _liftingDays = <int>{
    DateTime.monday,
    DateTime.wednesday,
    DateTime.friday,
  };

  static int _daysToLiftingDay() {
    final today = LocalDate.of(DateTime.now());
    for (var days = 0; days < 7; days++) {
      if (_liftingDays.contains(today.addDays(days).weekday)) return days;
    }
    throw StateError('No lifting day in the next week.');
  }

  @override
  DateTime now() {
    final real = DateTime.now();
    // Calendar days, not 24-hour steps: the hour on the clock stays the
    // same across a daylight-saving change.
    return DateTime(
      real.year,
      real.month,
      real.day + _shift.inDays,
      real.hour,
      real.minute,
      real.second,
      real.millisecond,
    );
  }
}

final Finder trainTab = find.byKey(const ValueKey<String>('fs-tab-train'));
final Finder todayTab = find.byKey(const ValueKey<String>('fs-tab-today'));
final Finder trainTodayRow = find.byKey(
  const ValueKey<String>('fs-train-today'),
);
final Finder startWorkoutButton = find.byKey(
  const ValueKey<String>('fs-start-workout'),
);
final Finder finishWorkoutButton = find.byKey(
  const ValueKey<String>('fs-finish-workout'),
);
final Finder prayerAmenButton = find.byKey(
  const ValueKey<String>('fs-prayer-amen'),
);
final Finder workoutClock = find.byKey(
  const ValueKey<String>('fs-workout-clock'),
);
final Finder lockedSummary = find.byKey(
  const ValueKey<String>('fs-workout-locked'),
);
final Finder workoutBox = find.byKey(
  const ValueKey<String>('fs-box-t_workout'),
);

Finder repsField(int exercise, int set) =>
    find.byKey(ValueKey<String>('fs-reps-$exercise-$set'));
Finder weightField(int exercise, int set) =>
    find.byKey(ValueKey<String>('fs-weight-$exercise-$set'));

/// The two exercises of a superset, drawn as one group.
final Finder supersetGroup = find.byKey(
  const ValueKey<String>('fs-superset-group'),
);

/// "Add set", under the rows of one exercise.
Finder addSetButton(int exercise) =>
    find.byKey(ValueKey<String>('fs-add-set-$exercise'));

/// "Remove", under a row he added while it is empty.
Finder removeSetButton(int exercise, int set) =>
    find.byKey(ValueKey<String>('fs-remove-set-$exercise-$set'));

Finder scrollableOf(Type page) =>
    find.descendant(of: find.byType(page), matching: find.byType(Scrollable));

/// What the two sets hold after the first half.
const List<(String reps, String weight)> enteredSets = <(String, String)>[
  ('5', '135'),
  ('4', '137.5'),
];

/// What the set he adds holds, in the device test for adding a set.
const (String reps, String weight) addedSet = ('6', '100');

/// Starts the app as the launcher does, on the next lifting day, and waits
/// for Today's boxes.
Future<NextLiftingDayClock> startAppOnLiftingDay(WidgetTester tester) async {
  final clock = NextLiftingDayClock();
  await app.startApp(testClock: clock);
  await tester.pumpAndSettle();
  for (var i = 0; i < 100 && find.byType(FsBoxRow).evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.byType(TodayPage), findsOneWidget);
  return clock;
}

/// Pumps until [finder] finds something, for up to ten seconds.
///
/// On a device a save is real work on another thread: the screen changes
/// a moment after the tap, and `pumpAndSettle` does not wait for it.
Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 100 && finder.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
  expect(finder, findsWidgets);
}

/// Pumps until [finder] finds nothing, for up to ten seconds.
Future<void> pumpUntilGone(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 100 && finder.evaluate().isNotEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  await tester.pumpAndSettle();
  expect(finder, findsNothing);
}

/// Opens the Train tab and waits for today's row.
Future<void> openTrain(WidgetTester tester) async {
  await tester.tap(trainTab);
  await tester.pumpAndSettle();
  for (var i = 0; i < 100 && trainTodayRow.evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.byType(TrainPage), findsOneWidget);
  expect(trainTodayRow, findsOneWidget);
}

/// Opens today's workout page from Train.
Future<void> openTodaysWorkout(WidgetTester tester) async {
  await openTrain(tester);
  await tester.tap(trainTodayRow);
  await tester.pumpAndSettle();
  for (var i = 0; i < 100 && find.byType(WorkoutPage).evaluate().isEmpty; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  expect(find.byType(WorkoutPage), findsOneWidget);
}

String trainTodaySubtitle(WidgetTester tester) =>
    tester.widget<FsChevronRow>(trainTodayRow).subtitle;

/// Brings a widget of the workout page onto the screen with a finger.
Future<void> showOnWorkoutPage(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    200,
    scrollable: scrollableOf(WorkoutPage).first,
  );
  await tester.pumpAndSettle();
}

/// Types into one number box, as the keyboard does.
Future<void> typeNumber(WidgetTester tester, Finder field, String text) async {
  await showOnWorkoutPage(tester, field);
  await tester.tap(field);
  await tester.pumpAndSettle();
  await tester.enterText(field, text);
  await tester.pumpAndSettle();
}

/// What a number box shows.
String shownIn(WidgetTester tester, Finder field) => tester
    .widget<EditableText>(
      find.descendant(of: field, matching: find.byType(EditableText)),
    )
    .controller
    .text;

/// The session the app's own store holds for the day the clock shows,
/// read from the real database file.
Future<WorkoutSession?> storedSession(WidgetTester tester, Clock clock) async {
  final store = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  ).read(localStoreProvider);
  return store.workouts
      .watchSession(store.ownerId, LocalDate.of(clock.now()))
      .first;
}

/// Whether the day's Workout box is checked in the real database file.
Future<bool> workoutBoxStored(WidgetTester tester, LocalDate day) async {
  final store = ProviderScope.containerOf(
    tester.element(find.byType(MaterialApp)),
  ).read(localStoreProvider);
  final record = await store.days.watchDay(store.ownerId, day).first;
  return record.isDone('workout');
}

/// "12:34" or "1:02:03" as seconds.
int clockSeconds(String text) => text
    .split(':')
    .map(int.parse)
    .fold<int>(0, (total, part) => total * 60 + part);
