import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/design/fs_box_row.dart';
import 'package:forged_and_sent/src/design/fs_chevron_row.dart';
import 'package:forged_and_sent/src/features/today/presentation/today_page.dart';
import 'package:forged_and_sent/src/features/workout/presentation/train_page.dart';
import 'package:forged_and_sent/src/features/workout/presentation/workout_page.dart';

import '../../support/fs_test_support.dart';

FsChevronRow _weekRow(WidgetTester tester, LocalDate day) => tester
    .widget<FsChevronRow>(find.byKey(ValueKey<String>('fs-week-${day.iso}')));

String _status(WidgetTester tester) => tester
    .widget<Text>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('fs-train-status')),
        matching: find.byType(Text),
      ),
    )
    .data!;

void main() {
  setUpAll(loadAppFonts);

  const monday = LocalDate(2026, 11, 9);

  testWidgets('Train shows today and this week, Monday to Sunday', (
    tester,
  ) async {
    // Tuesday, November 10: a recovery day of the plan's first week.
    await pumpApp(tester);
    await openTab(tester, 'Train');

    expect(find.byType(TrainPage), findsOneWidget);
    expect(find.text('TRAIN'), findsWidgets);
    expect(find.text('STRENGTH IS FOR SERVING'), findsOneWidget);
    expect(find.text('Tuesday, November 10'), findsOneWidget);
    expect(_status(tester), 'READY TO TRAIN');

    final today = tester.widget<FsChevronRow>(trainTodayRow);
    expect(today.title, 'Active Recovery: Zone 2 Cardio');
    expect(today.subtitle, 'Recovery · 30 min · Tap to open');
    expect(today.mark, FsRowMark.chevron);

    expect(find.text('Your week'), findsOneWidget);
    final rows = <FsChevronRow>[
      for (var i = 0; i < 7; i++) _weekRow(tester, monday.addDays(i)),
    ];
    expect(rows.map((row) => row.title), <String>[
      'Full Body A: Back Squat',
      'Active Recovery: Zone 2 Cardio',
      'Full Body B: Deadlift',
      'Active Recovery: Zone 2 Cardio',
      'Full Body C: Bench Press',
      'Rest day',
      'Sabbath',
    ]);
    expect(rows.map((row) => row.subtitle), <String>[
      'Core · 45 min',
      'Today · Recovery · 30 min',
      'Core · 45 min',
      'Recovery · 30 min',
      'Core · 45 min',
      'Optional day is off',
      'Rest, worship, family',
    ]);
    // Today's row stands out; days with a session open it; the others
    // are plain text.
    expect(rows[1].emphasis, FsRowEmphasis.current);
    expect(rows[0].emphasis, FsRowEmphasis.plain);
    expect(rows.take(5).every((row) => row.onTap != null), isTrue);
    expect(rows.take(5).every((row) => row.mark == FsRowMark.chevron), isTrue);
    expect(rows[5].onTap, isNull);
    expect(rows[6].onTap, isNull);
    expect(rows[5].dim, isTrue);
    expect(rows[6].mark, FsRowMark.none);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a new member gets a session on his next lifting day, not '
      'next week (review finding U1)', (tester) async {
    // He first opens the app on a Thursday.
    final clock = TestClock(DateTime(2026, 11, 12, 7, 30));
    await pumpApp(tester, clock: clock);
    await openTab(tester, 'Train');

    // Friday, tomorrow, is a lifting day of week 1, not "Plan starts".
    final friday = _weekRow(tester, monday.addDays(4));
    expect(friday.title, 'Full Body C: Bench Press');
    expect(friday.onTap, isNotNull);
    expect(find.textContaining('Plan starts'), findsNothing);
    // Today has its recovery session too.
    expect(_status(tester), 'READY TO TRAIN');
    expect(
      tester.widget<FsChevronRow>(trainTodayRow).title,
      'Active Recovery: Zone 2 Cardio',
    );

    // On Friday the session is there to start.
    clock.time = DateTime(2026, 11, 13, 17);
    await backgroundAndResume(tester);
    expect(find.text('Friday, November 13'), findsOneWidget);
    await tester.tap(trainTodayRow);
    await tester.pumpAndSettle();
    expect(find.byType(WorkoutPage), findsOneWidget);
    expect(find.text('WEEK 1 · DAY 5 · 45 MIN'), findsOneWidget);
    expect(startWorkoutButton, findsOneWidget);
  });

  testWidgets('first opened on a Saturday, the plan starts on Monday, his '
      'next lifting day', (tester) async {
    final clock = TestClock(DateTime(2026, 11, 14, 9));
    await pumpApp(tester, clock: clock);
    await openTab(tester, 'Train');

    expect(_status(tester), 'NOTHING FINISHED YET TODAY');
    expect(trainTodayRow, findsNothing);
    expect(find.text('Your plan starts Monday, November 16.'), findsOneWidget);
    expect(_weekRow(tester, monday.addDays(5)).title, 'Plan starts Monday');
    expect(_weekRow(tester, monday.addDays(5)).onTap, isNull);

    clock.time = DateTime(2026, 11, 16, 6);
    await backgroundAndResume(tester);
    expect(_status(tester), 'READY TO TRAIN');
    expect(
      tester.widget<FsChevronRow>(trainTodayRow).title,
      'Full Body A: Back Squat',
    );
    expect(
      _weekRow(tester, const LocalDate(2026, 11, 16)).subtitle,
      'Today · Core · 45 min',
    );
  });

  testWidgets('a rest day says so and offers no session', (tester) async {
    // Sunday of the plan's first week.
    final clock = TestClock(DateTime(2026, 11, 10, 7));
    await pumpApp(tester, clock: clock);
    await openTab(tester, 'Train');
    clock.time = DateTime(2026, 11, 15, 9);
    await backgroundAndResume(tester);

    expect(_status(tester), 'REST DAY');
    expect(trainTodayRow, findsNothing);
    expect(
      find.text('Sabbath. Full rest. An easy walk or stretch is optional.'),
      findsOneWidget,
    );

    // Saturday: the optional fourth day is off.
    clock.time = DateTime(2026, 11, 21, 9);
    await backgroundAndResume(tester);
    expect(_status(tester), 'REST DAY');
    expect(
      find.text('Rest day. The optional 4th training day is off.'),
      findsOneWidget,
    );
  });

  testWidgets('a day\'s row opens its workout, and back returns to Train', (
    tester,
  ) async {
    await pumpApp(tester, clock: TestClock(liftingEvening));
    await openTodaysWorkout(tester);

    expect(find.byType(WorkoutPage), findsOneWidget);
    expect(find.text('MONDAY, NOVEMBER 9'), findsOneWidget);
    // The page sits inside the shell: the bars are still there.
    expect(find.text('FORGED & SENT'), findsOneWidget);

    await systemBack(tester);
    expect(find.byType(WorkoutPage), findsNothing);
    expect(find.byType(TrainPage), findsOneWidget);

    // Another day of the week, from its row; the page's own Back button.
    final friday = find.byKey(const ValueKey<String>('fs-week-2026-11-13'));
    await tester.ensureVisible(friday);
    await tester.pumpAndSettle();
    await tester.tap(friday);
    await tester.pumpAndSettle();
    expect(find.text('FRIDAY, NOVEMBER 13'), findsOneWidget);
    expect(find.text('FULL BODY C: BENCH PRESS'), findsOneWidget);
    // Only today's session can be started.
    expect(startWorkoutButton, findsNothing);
    expect(find.text('You can start this workout on its day.'), findsOneWidget);

    await tester.tap(find.text('‹ BACK'));
    await tester.pumpAndSettle();
    expect(find.byType(TrainPage), findsOneWidget);

    // A rest day's row is not a button.
    final sunday = find.byKey(const ValueKey<String>('fs-week-2026-11-15'));
    await tester.ensureVisible(sunday);
    await tester.pumpAndSettle();
    await tester.tap(sunday, warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.byType(TrainPage), findsOneWidget);
    expect(find.byType(WorkoutPage), findsNothing);
  });

  testWidgets('the Workout box on Today opens Train and cannot be checked '
      'by tapping it', (tester) async {
    final handle = tester.ensureSemantics();
    final app = await pumpApp(tester, clock: TestClock(liftingEvening));
    await showBox(tester, 't_workout');

    final row = tester.widget<FsBoxRow>(box('t_workout'));
    expect(row.title, 'Workout');
    expect(row.subtitle, 'Checks itself when you finish a workout');
    expect(row.checked, isFalse);
    expect(row.showChevron, isTrue);
    expect(
      tester.getSemantics(box('t_workout')),
      isSemantics(
        label: 'Workout. Checks itself when you finish a workout',
        isButton: true,
        hasEnabledState: true,
        isEnabled: true,
        hasTapAction: true,
        hasCheckedState: true,
        isChecked: false,
      ),
    );

    await tester.tap(box('t_workout'));
    await tester.pumpAndSettle();

    expect(find.byType(TrainPage), findsOneWidget);
    expect(find.byType(TodayPage), findsNothing);
    // Nothing was recorded: only finishing a workout checks the box.
    expect(await app.savedDoneDays(tester), isEmpty);
    expect((app.store.days as TestDayRepository).saveAttempts, 0);
    handle.dispose();
  });

  testWidgets('week rows tell a screen reader the day and what it holds', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpApp(tester);
    await openTab(tester, 'Train');
    final wednesday = find.byKey(const ValueKey<String>('fs-week-2026-11-11'));
    await tester.ensureVisible(wednesday);
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(wednesday),
      isSemantics(
        label: 'Wednesday, November 11: Full Body B: Deadlift. Core · 45 min',
        isButton: true,
        hasTapAction: true,
      ),
    );
    final sunday = find.byKey(const ValueKey<String>('fs-week-2026-11-15'));
    await tester.ensureVisible(sunday);
    await tester.pumpAndSettle();
    expect(
      tester.getSemantics(sunday),
      isSemantics(
        label: 'Sunday, November 15: Sabbath. Rest, worship, family',
        isButton: false,
        hasTapAction: false,
      ),
    );
    handle.dispose();
  });

  for (final (name, size, scale) in <(String, Size, double)>[
    ('at 1.3 times the text size', phone, 1.3),
    ('at 2.0 times the text size', phone, 2.0),
    ('on a small phone at 1.3 times the text size', const Size(320, 568), 1.3),
  ]) {
    testWidgets('nothing on Train overflows $name', (tester) async {
      await pumpApp(
        tester,
        size: size,
        textScale: scale,
        clock: TestClock(liftingEvening),
      );
      await openTab(tester, 'Train');
      final scrollable = find
          .descendant(
            of: find.byType(TrainPage),
            matching: find.byType(Scrollable),
          )
          .first;
      final position = tester.state<ScrollableState>(scrollable).position;
      position.jumpTo(position.maxScrollExtent);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  }
}
