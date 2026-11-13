import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/features/workout/domain/workout_plan.dart';

import '../../support/fs_test_support.dart';

void main() {
  final library = loadBundledWorkoutLibrary();

  // November 9, 2026 is a Monday.
  const monday = LocalDate(2026, 11, 9);

  group('a new member\'s plan', () {
    test('has the prototype\'s default settings', () {
      final plan = WorkoutPlan.startingFor(monday);

      expect(plan.program, 'Forged');
      expect(plan.equipment, 'Full Gym');
      expect(plan.restWeekday, DateTime.sunday);
      expect(plan.liftWeekdays, <int>[
        DateTime.monday,
        DateTime.wednesday,
        DateTime.friday,
      ]);
      expect(plan.fourthDay, isFalse);
    });

    test('starts on the first day of the plan week that holds his next '
        'lifting day (review finding U1)', () {
      // Day he first opens Train -> the plan's first day.
      final expected = <LocalDate, LocalDate>{
        monday: monday, // a lifting day: week 1 starts today
        monday.addDays(1): monday, // Tuesday: Wednesday is next
        monday.addDays(2): monday, // Wednesday
        monday.addDays(3): monday, // Thursday: Friday is next
        monday.addDays(4): monday, // Friday
        monday.addDays(5): monday.addDays(7), // Saturday: Monday is next
        monday.addDays(6): monday.addDays(7), // Sunday
      };

      for (final entry in expected.entries) {
        expect(
          WorkoutPlan.startingFor(entry.key).start,
          entry.value,
          reason: 'first opened on ${entry.key}',
        );
      }
    });

    test('gives him a session on his next lifting day, never a week '
        'later', () {
      // Every day of four weeks, so every weekday and a month end.
      for (var i = 0; i < 28; i++) {
        final firstOpened = const LocalDate(2026, 11, 20).addDays(i);
        final plan = WorkoutPlan.startingFor(firstOpened);

        var nextLift = firstOpened;
        while (!plan.liftWeekdays.contains(nextLift.weekday)) {
          nextLift = nextLift.addDays(1);
        }
        final day = library.dayFor(plan, nextLift);

        expect(
          nextLift.compareTo(firstOpened.addDays(2)),
          lessThanOrEqualTo(0),
          reason: 'first opened on $firstOpened',
        );
        expect(day.kind, PlanDayKind.train, reason: '$firstOpened');
        expect(day.workout!.sessionType, 'Core', reason: '$firstOpened');
        expect(day.workout!.week, 1, reason: '$firstOpened');
        // The plan never starts after his next lifting day, and always on
        // the day after a rest day.
        expect(plan.start.compareTo(nextLift), lessThanOrEqualTo(0));
        expect(plan.start.weekday, DateTime.monday);
      }
    });

    test('opened on a Thursday: Friday is week 1\'s third lifting day, and '
        'the lifting days already past are simply not logged', () {
      final plan = WorkoutPlan.startingFor(monday.addDays(3));

      final friday = library.dayFor(plan, monday.addDays(4));
      expect(friday.kind, PlanDayKind.train);
      expect(friday.workout!.day, 5);
      expect(friday.workout!.title, 'Full Body C: Bench Press');
      // Monday and Wednesday of that week are in the plan, and past.
      expect(library.dayFor(plan, monday).workout!.day, 1);
      expect(library.dayFor(plan, monday.addDays(2)).workout!.day, 3);
    });

    test('opened on a Saturday: the days before Monday are before the '
        'plan', () {
      final plan = WorkoutPlan.startingFor(monday.addDays(5));

      expect(library.dayFor(plan, monday.addDays(5)).kind, PlanDayKind.before);
      expect(library.dayFor(plan, monday.addDays(6)).kind, PlanDayKind.before);
      final first = library.dayFor(plan, monday.addDays(7));
      expect(first.kind, PlanDayKind.train);
      expect(first.workout!.day, 1);
    });
  });

  group('which plan day a date shows (the prototype\'s planIndex)', () {
    final plan = WorkoutPlan.startingFor(monday);

    test('a week runs from the day after the rest day to the rest day', () {
      expect(
        <int>[for (var i = 0; i < 7; i++) plan.indexFor(monday.addDays(i))],
        <int>[0, 1, 2, 3, 4, 5, 6],
      );
      expect(plan.indexFor(monday.addDays(7)), 7);
      expect(plan.indexFor(monday.addDays(13)), 13);
      expect(plan.indexFor(monday.addDays(364)), 364);
    });

    test('a date before the start is before the plan', () {
      expect(plan.indexFor(monday.previous), isNegative);
      expect(library.dayFor(plan, monday.previous).kind, PlanDayKind.before);
    });

    test('a date past the last plan day is after the plan', () {
      expect(library.days, hasLength(365));
      expect(library.dayFor(plan, monday.addDays(364)).kind, PlanDayKind.train);
      expect(library.dayFor(plan, monday.addDays(365)).kind, PlanDayKind.over);
    });

    test('lifting days take the week\'s first, third and fifth sessions, '
        'whichever weekdays they are', () {
      // Lifting on Tuesday, Thursday and Saturday instead.
      final moved = plan.copyWith(
        liftWeekdays: const <int>[
          DateTime.tuesday,
          DateTime.thursday,
          DateTime.saturday,
        ],
      );

      // Mon Tue Wed Thu Fri Sat Sun
      expect(
        <int>[for (var i = 0; i < 7; i++) moved.indexFor(monday.addDays(i))],
        <int>[1, 0, 3, 2, 5, 4, 6],
      );
    });

    test('with another rest day the week starts the day after it', () {
      // Rest on Saturday: the week runs Sunday to Saturday.
      final plan = WorkoutPlan.startingFor(
        monday,
        restWeekday: DateTime.saturday,
      );

      expect(plan.liftWeekdays, <int>[
        DateTime.sunday,
        DateTime.tuesday,
        DateTime.thursday,
      ]);
      // Monday's next lifting day is Tuesday; its week began on Sunday.
      expect(plan.start, monday.previous);
      expect(plan.indexFor(monday.previous), 0);
      expect(plan.indexFor(monday.addDays(5)), 6); // Saturday: rest
      expect(library.dayFor(plan, monday.addDays(5)).kind, PlanDayKind.rest);
    });
  });

  group('what a day holds (the prototype\'s workoutFor)', () {
    final plan = WorkoutPlan.startingFor(monday);

    test('lifting and recovery days have a session', () {
      final kinds = <String>[
        for (var i = 0; i < 5; i++)
          library.dayFor(plan, monday.addDays(i)).workout!.sessionType,
      ];

      expect(kinds, <String>['Core', 'Recovery', 'Core', 'Recovery', 'Core']);
      for (var i = 0; i < 5; i++) {
        expect(library.dayFor(plan, monday.addDays(i)).isTrain, isTrue);
      }
    });

    test('the optional fourth day is off unless the plan turns it on', () {
      final saturday = monday.addDays(5);

      expect(library.dayFor(plan, saturday).kind, PlanDayKind.off);
      expect(library.dayFor(plan, saturday).isTrain, isFalse);

      final withFourth = plan.copyWith(fourthDay: true);
      expect(library.dayFor(withFourth, saturday).kind, PlanDayKind.train);
      expect(
        library.dayFor(withFourth, saturday).workout!.sessionType,
        'Optional',
      );
    });

    test('the rest day is a rest day', () {
      final sunday = library.dayFor(plan, monday.addDays(6));

      expect(sunday.kind, PlanDayKind.rest);
      expect(sunday.workout!.sessionType, 'Rest');
    });
  });

  test('two plans with the same settings are equal', () {
    expect(WorkoutPlan.startingFor(monday), WorkoutPlan.startingFor(monday));
    expect(
      WorkoutPlan.startingFor(monday).hashCode,
      WorkoutPlan.startingFor(monday).hashCode,
    );
    expect(
      WorkoutPlan.startingFor(monday),
      isNot(WorkoutPlan.startingFor(monday).copyWith(fourthDay: true)),
    );
  });
}
