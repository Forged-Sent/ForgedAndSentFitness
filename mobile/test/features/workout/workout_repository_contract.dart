import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/features/today/data/day_repository.dart';
import 'package:forged_and_sent/src/features/today/domain/completion_event.dart';
import 'package:forged_and_sent/src/features/workout/data/workout_repository.dart';
import 'package:forged_and_sent/src/features/workout/domain/prescription.dart';
import 'package:forged_and_sent/src/features/workout/domain/workout_plan.dart';
import 'package:forged_and_sent/src/features/workout/domain/workout_session.dart';

const String ownerA = 'local-a';
const String ownerB = 'local-b';

const LocalDate nov9 = LocalDate(2026, 11, 9);
const LocalDate nov11 = LocalDate(2026, 11, 11);
const LocalDate nov12 = LocalDate(2026, 11, 12);
const LocalDate nov13 = LocalDate(2026, 11, 13);

/// The two stores a workout touches: its own, and the day's boxes.
typedef WorkoutStores = ({WorkoutRepository workouts, DayRepository days});

/// One exercise for a session a test starts. Ids are made from [tag], so a
/// test can name its sets: `<tag>-s0`, `<tag>-s1`, ...
SessionExercise exercise(
  String tag, {
  required int position,
  required String movementId,
  String? name,
  String prescription = '3 x 5 (RPE 7, rest 2 min)',
  SetMeasure measure = SetMeasure.reps,
  WeightMode weightMode = WeightMode.required,
  int sets = 3,
}) => SessionExercise(
  id: tag,
  position: position,
  movementId: movementId,
  name: name ?? movementId,
  prescription: prescription,
  measure: measure,
  weightMode: weightMode,
  restBaseSeconds: restBaseFor(prescription),
  sets: <SessionSet>[
    for (var i = 0; i < sets; i++)
      SessionSet(id: '$tag-s$i', position: i, target: '5'),
  ],
);

/// A session about to be started at [at]. Its id is [id] and its finish
/// event is `<id>-finish`.
NewSession newSession(
  String id,
  DateTime at, {
  String owner = ownerA,
  List<SessionExercise>? exercises,
}) => NewSession(
  id: id,
  ownerId: owner,
  program: 'Forged',
  planDay: 1,
  planWeek: 1,
  title: 'Full Body A: Back Squat',
  sessionType: 'Core',
  minutes: 45,
  startedAt: at,
  finishEventId: '$id-finish',
  exercises:
      exercises ??
      <SessionExercise>[
        exercise('$id-squat', position: 0, movementId: 'Back Squat'),
        exercise(
          '$id-plank',
          position: 1,
          movementId: 'Plank',
          prescription: '2 x 25 sec',
          measure: SetMeasure.seconds,
          weightMode: WeightMode.none,
          sets: 2,
        ),
      ],
);

/// The rules every store of workout plans and sessions must follow. Run
/// against the Drift store and the in-memory one, so the two cannot drift
/// apart.
void workoutRepositoryContract(Future<WorkoutStores> Function() create) {
  late WorkoutRepository workouts;
  late DayRepository days;

  setUp(() async {
    final stores = await create();
    workouts = stores.workouts;
    days = stores.days;
  });

  Future<WorkoutSession?> session(LocalDate day, {String owner = ownerA}) =>
      workouts.watchSession(owner, day).first;

  Future<bool> workoutBox(LocalDate day, {String owner = ownerA}) async =>
      (await days.watchDay(owner, day).first).isDone(DayItems.workout);

  group('the plan', () {
    test('a new member has none', () async {
      expect(await workouts.watchPlan(ownerA).first, isNull);
    });

    test('is made once and never replaced by asking again', () async {
      final first = await workouts.ensurePlan(
        ownerA,
        () => WorkoutPlan.startingFor(nov12),
      );
      final again = await workouts.ensurePlan(
        ownerA,
        () => WorkoutPlan.startingFor(const LocalDate(2027, 1, 1)),
      );

      expect(first.start, nov9);
      expect(again, first);
      expect(await workouts.watchPlan(ownerA).first, first);
    });

    test('comes back as it was saved', () async {
      final plan = WorkoutPlan(
        program: 'Forged',
        equipment: 'Dumbbells Only',
        restWeekday: DateTime.saturday,
        liftWeekdays: const <int>[7, 2, 4],
        fourthDay: true,
        start: const LocalDate(2026, 11, 8),
      );
      await workouts.savePlan(ownerA, plan);

      expect(await workouts.watchPlan(ownerA).first, plan);
    });

    test('belongs to one owner', () async {
      await workouts.ensurePlan(ownerA, () => WorkoutPlan.startingFor(nov12));

      expect(await workouts.watchPlan(ownerB).first, isNull);
    });
  });

  group('starting a session', () {
    test('a day with no session has none', () async {
      expect(await session(nov12), isNull);
      expect(await workouts.watchOpenSession(ownerA).first, isNull);
    });

    test('stores every exercise with its movement id and prescription '
        '(review finding U3)', () async {
      await workouts.startSession(
        newSession('s1', DateTime(2026, 11, 12, 18, 10)),
      );

      final stored = (await session(nov12))!;
      expect(stored.id, 's1');
      expect(stored.day, nov12);
      expect(stored.title, 'Full Body A: Back Squat');
      expect(stored.finished, isFalse);
      expect(stored.finishEventId, 's1-finish');
      expect(stored.startedAtUtc, DateTime(2026, 11, 12, 18, 10).toUtc());
      expect(
        stored.startUtcOffset,
        DateTime(2026, 11, 12, 18, 10).timeZoneOffset,
      );
      expect(stored.exercises.map((e) => e.movementId), <String>[
        'Back Squat',
        'Plank',
      ]);
      expect(stored.exercises.map((e) => e.prescription), <String>[
        '3 x 5 (RPE 7, rest 2 min)',
        '2 x 25 sec',
      ]);
      expect(stored.exercises.first.measure, SetMeasure.reps);
      expect(stored.exercises.first.weightMode, WeightMode.required);
      expect(stored.exercises.first.restBaseSeconds, 120);
      expect(stored.exercises.last.measure, SetMeasure.seconds);
      expect(stored.exercises.first.sets.map((s) => s.id), <String>[
        's1-squat-s0',
        's1-squat-s1',
        's1-squat-s2',
      ]);
      expect(stored.exercises.first.sets.every((s) => s.reps == null), isTrue);
    });

    test('a second start on the same day starts nothing new', () async {
      final first = await workouts.startSession(
        newSession('s1', DateTime(2026, 11, 12, 18, 10)),
      );
      final second = await workouts.startSession(
        newSession('s2', DateTime(2026, 11, 12, 18, 11)),
      );

      expect(first.id, 's1');
      expect(second.id, 's1');
      expect((await session(nov12))!.id, 's1');
      expect(
        (await session(nov12))!.startedAtUtc,
        DateTime(2026, 11, 12, 18, 10).toUtc(),
      );
    });

    test('one owner never sees another owner\'s session', () async {
      await workouts.startSession(
        newSession('s1', DateTime(2026, 11, 12, 18, 10)),
      );

      expect(await session(nov12, owner: ownerB), isNull);
      expect(await workouts.watchOpenSession(ownerB).first, isNull);
    });
  });

  group('logging', () {
    setUp(
      () => workouts.startSession(
        newSession('s1', DateTime(2026, 11, 12, 18, 10)),
      ),
    );

    test('what is entered for a set is stored, and can be cleared', () async {
      await workouts.setReps('s1-squat-s0', 5);
      await workouts.setWeight('s1-squat-s0', 132.5);
      await workouts.setReps('s1-squat-s1', 4);

      var squat = (await session(nov12))!.exercises.first;
      expect(squat.sets[0].reps, 5);
      expect(squat.sets[0].weightLb, 132.5);
      expect(squat.sets[1].reps, 4);
      expect(squat.sets[1].weightLb, isNull);
      expect(squat.isLogged(squat.sets[0]), isTrue);
      expect(squat.isLogged(squat.sets[1]), isFalse);

      await workouts.setReps('s1-squat-s0', null);
      await workouts.setWeight('s1-squat-s0', null);
      squat = (await session(nov12))!.exercises.first;
      expect(squat.sets[0].reps, isNull);
      expect(squat.sets[0].weightLb, isNull);
    });

    test('a tick is stored and can be taken back', () async {
      await workouts.setTicked('s1-plank-s0', ticked: true);
      expect((await session(nov12))!.exercises.last.sets[0].ticked, isTrue);

      await workouts.setTicked('s1-plank-s0', ticked: false);
      expect((await session(nov12))!.exercises.last.sets[0].ticked, isFalse);
    });

    test('one read gives the session as it is stored at that moment', () async {
      expect(await workouts.readSession(ownerA, nov9), isNull);
      expect(await workouts.readSession(ownerB, nov12), isNull);
      final before = (await workouts.readSession(ownerA, nov12))!;
      expect(before.id, 's1');
      expect(before.exercises.map((e) => e.movementId), <String>[
        'Back Squat',
        'Plank',
      ]);
      expect(before.exercises.first.sets[0].reps, isNull);
      expect(before.finished, isFalse);

      // Straight after each change is stored, with nobody watching.
      await workouts.setReps('s1-squat-s0', 5);
      await workouts.setWeight('s1-squat-s0', 135);
      await workouts.setTicked('s1-plank-s0', ticked: true);
      var stored = (await workouts.readSession(ownerA, nov12))!;
      expect(stored.exercises.first.sets[0].reps, 5);
      expect(stored.exercises.first.sets[0].weightLb, 135);
      expect(stored.exercises.last.sets[0].ticked, isTrue);

      await workouts.finishSession('s1', DateTime(2026, 11, 12, 19));
      stored = (await workouts.readSession(ownerA, nov12))!;
      expect(stored.finished, isTrue);
      expect(stored.finishedAtUtc, DateTime(2026, 11, 12, 19).toUtc());
    });

    test('every change reaches whoever is watching the session', () async {
      final seen = <int?>[];
      final watching = workouts
          .watchSession(ownerA, nov12)
          .listen((s) => seen.add(s?.exercises.first.sets[0].reps));
      addTearDown(watching.cancel);
      await pumpEventQueue();

      await workouts.setReps('s1-squat-s0', 5);
      await pumpEventQueue();
      await workouts.setReps('s1-squat-s0', 6);
      await pumpEventQueue();

      expect(seen.first, isNull);
      expect(seen.last, 6);
      expect(seen, contains(5));
    });

    test(
      'the rest timer is stored as an instant, a remainder, or neither',
      () async {
        final endsAt = DateTime.utc(2026, 11, 13, 0, 12, 30);

        await workouts.setRest('s1-squat', baseSeconds: 135, endsAtUtc: endsAt);
        var squat = (await session(nov12))!.exercises.first;
        expect(squat.restBaseSeconds, 135);
        expect(squat.restEndsAtUtc, endsAt);
        expect(squat.restPausedSeconds, isNull);
        expect(
          squat.restAt(endsAt.subtract(const Duration(seconds: 40))).left,
          40,
        );

        await workouts.setRest('s1-squat', baseSeconds: 135, pausedSeconds: 40);
        squat = (await session(nov12))!.exercises.first;
        expect(squat.restEndsAtUtc, isNull);
        expect(squat.restPausedSeconds, 40);
        expect(squat.restAt(endsAt).paused, isTrue);

        await workouts.setRest('s1-squat', baseSeconds: 135);
        squat = (await session(nov12))!.exercises.first;
        expect(squat.restEndsAtUtc, isNull);
        expect(squat.restPausedSeconds, isNull);
        expect(squat.restAt(endsAt).left, 135);
      },
    );
  });

  group('finishing', () {
    test('finishes the session and checks the day\'s Workout box', () async {
      await workouts.startSession(
        newSession('s1', DateTime(2026, 11, 12, 18, 10)),
      );
      expect(await workoutBox(nov12), isFalse);

      final outcome = await workouts.finishSession(
        's1',
        DateTime(2026, 11, 12, 18, 52),
      );

      expect(outcome, FinishOutcome.finished);
      final stored = (await session(nov12))!;
      expect(stored.finished, isTrue);
      expect(stored.finishedAtUtc, DateTime(2026, 11, 12, 18, 52).toUtc());
      expect(
        stored.elapsedAt(DateTime(2030, 1, 1)),
        const Duration(minutes: 42),
      );
      expect(await workoutBox(nov12), isTrue);
      expect(await workouts.watchOpenSession(ownerA).first, isNull);
    });

    test('twice records one completion (P07 acceptance 2)', () async {
      await workouts.startSession(
        newSession('s1', DateTime(2026, 11, 12, 18, 10)),
      );

      final first = await workouts.finishSession(
        's1',
        DateTime(2026, 11, 12, 18, 52),
      );
      final second = await workouts.finishSession(
        's1',
        DateTime(2026, 11, 12, 19, 30),
      );

      expect(first, FinishOutcome.finished);
      expect(second, FinishOutcome.alreadyFinished);
      final events = await days.eventsFor(ownerA, nov12, DayItems.workout);
      expect(events, hasLength(1));
      expect(events.single.id, 's1-finish');
      expect(events.single.done, isTrue);
      // The first finish stands.
      expect(
        (await session(nov12))!.finishedAtUtc,
        DateTime(2026, 11, 12, 18, 52).toUtc(),
      );
      expect(await workoutBox(nov12), isTrue);
    });

    test('two finishes asked for at the same moment record one '
        'completion, and one finish time stands', () async {
      await workouts.startSession(
        newSession('s1', DateTime(2026, 11, 12, 18, 10)),
      );
      final times = <DateTime>[
        DateTime(2026, 11, 12, 18, 52),
        DateTime(2026, 11, 12, 18, 53),
      ];

      // Neither waits for the other, as two quick taps would not.
      final outcomes = await Future.wait(<Future<FinishOutcome>>[
        workouts.finishSession('s1', times[0]),
        workouts.finishSession('s1', times[1]),
      ]);

      expect(
        outcomes,
        unorderedEquals(<FinishOutcome>[
          FinishOutcome.finished,
          FinishOutcome.alreadyFinished,
        ]),
      );
      expect(
        await days.eventsFor(ownerA, nov12, DayItems.workout),
        hasLength(1),
      );
      // The time that stands is the time of the finish that finished it.
      final winner = times[outcomes.indexOf(FinishOutcome.finished)];
      expect((await session(nov12))!.finishedAtUtc, winner.toUtc());
      expect(await workoutBox(nov12), isTrue);
    });

    test('a session started at 23:50 can be finished at 00:10, and it '
        'belongs to the day it started on (P07 acceptance 3)', () async {
      await workouts.startSession(
        newSession('s1', DateTime(2026, 11, 12, 23, 50)),
      );
      await workouts.setReps('s1-squat-s0', 5);

      // Past midnight it is still open, and still logs.
      expect((await workouts.watchOpenSession(ownerA).first)!.id, 's1');
      await workouts.setWeight('s1-squat-s0', 135);

      final outcome = await workouts.finishSession(
        's1',
        DateTime(2026, 11, 13, 0, 10),
      );

      expect(outcome, FinishOutcome.finished);
      final stored = (await session(nov12))!;
      expect(stored.day, nov12);
      expect(stored.finished, isTrue);
      expect(
        stored.elapsedAt(DateTime(2026, 11, 13, 9)),
        const Duration(minutes: 20),
      );
      expect(stored.exercises.first.sets[0].weightLb, 135);
      // The box of the day it started on, not of the day it ended on.
      expect(await workoutBox(nov12), isTrue);
      expect(await workoutBox(nov13), isFalse);
      expect(await session(nov13), isNull);
      final event = (await days.eventsFor(
        ownerA,
        nov12,
        DayItems.workout,
      )).single;
      expect(event.day, nov12);
      expect(event.tapLocalDate, nov13);
    });

    test('a finished session is locked: nothing in it can change', () async {
      await workouts.startSession(
        newSession('s1', DateTime(2026, 11, 12, 18, 10)),
      );
      await workouts.setReps('s1-squat-s0', 5);
      await workouts.setWeight('s1-squat-s0', 135);
      await workouts.finishSession('s1', DateTime(2026, 11, 12, 18, 52));

      await workouts.setReps('s1-squat-s0', 99);
      await workouts.setWeight('s1-squat-s0', 999);
      await workouts.setTicked('s1-plank-s0', ticked: true);
      await workouts.setRest(
        's1-squat',
        baseSeconds: 15,
        endsAtUtc: DateTime.utc(2030),
      );

      final stored = (await session(nov12))!;
      expect(stored.exercises.first.sets[0].reps, 5);
      expect(stored.exercises.first.sets[0].weightLb, 135);
      expect(stored.exercises.last.sets[0].ticked, isFalse);
      expect(stored.exercises.first.restBaseSeconds, 120);
      expect(stored.exercises.first.restEndsAtUtc, isNull);
    });

    test('stops a rest timer that was left running', () async {
      await workouts.startSession(
        newSession('s1', DateTime(2026, 11, 12, 18, 10)),
      );
      await workouts.setRest(
        's1-squat',
        baseSeconds: 120,
        endsAtUtc: DateTime.utc(2026, 11, 13, 3),
      );

      await workouts.finishSession('s1', DateTime(2026, 11, 12, 18, 52));

      expect((await session(nov12))!.exercises.first.restEndsAtUtc, isNull);
    });

    test('changing the plan afterwards does not alter the finished session '
        '(P07 acceptance 4)', () async {
      final plan = await workouts.ensurePlan(
        ownerA,
        () => WorkoutPlan.startingFor(nov12),
      );
      await workouts.startSession(
        newSession(
          's1',
          DateTime(2026, 11, 12, 18, 10),
          exercises: <SessionExercise>[
            exercise(
              's1-squat',
              position: 0,
              movementId: 'Back Squat',
              name: 'Barbell Back Squat',
            ),
          ],
        ),
      );
      await workouts.setReps('s1-squat-s0', 5);
      await workouts.setWeight('s1-squat-s0', 135);
      await workouts.finishSession('s1', DateTime(2026, 11, 12, 18, 52));
      final before = (await session(nov12))!;

      // Other equipment, another rest day, other lifting days, a later
      // start: everything a plan holds.
      await workouts.savePlan(
        ownerA,
        plan.copyWith(
          equipment: 'Bodyweight Only',
          restWeekday: DateTime.saturday,
          liftWeekdays: const <int>[7, 2, 4],
          fourthDay: true,
          start: const LocalDate(2026, 12, 6),
        ),
      );

      final after = (await session(nov12))!;
      expect(after.day, before.day);
      expect(after.title, before.title);
      expect(after.planDay, before.planDay);
      expect(after.planWeek, before.planWeek);
      expect(after.finishedAtUtc, before.finishedAtUtc);
      expect(after.exercises.single.movementId, 'Back Squat');
      expect(after.exercises.single.name, 'Barbell Back Squat');
      expect(after.exercises.single.prescription, '3 x 5 (RPE 7, rest 2 min)');
      expect(after.exercises.single.weightMode, WeightMode.required);
      expect(after.exercises.single.sets[0].reps, 5);
      expect(after.exercises.single.sets[0].weightLb, 135);
      expect(after.totals.volumeLb, 675);
      expect(await workoutBox(nov12), isTrue);
    });

    test('a session that does not exist cannot be finished', () async {
      await expectLater(
        workouts.finishSession('nothing', DateTime(2026, 11, 12, 18, 52)),
        throwsStateError,
      );
    });
  });

  group('the open session', () {
    test('is the one most recently started and not finished', () async {
      await workouts.startSession(
        newSession('s1', DateTime(2026, 11, 11, 18, 10)),
      );
      await workouts.startSession(
        newSession('s2', DateTime(2026, 11, 12, 18, 10)),
      );
      expect((await workouts.watchOpenSession(ownerA).first)!.id, 's2');

      await workouts.finishSession('s2', DateTime(2026, 11, 12, 19));
      expect((await workouts.watchOpenSession(ownerA).first)!.id, 's1');

      await workouts.finishSession('s1', DateTime(2026, 11, 12, 19, 5));
      expect(await workouts.watchOpenSession(ownerA).first, isNull);
    });
  });

  group('last time (review finding U3)', () {
    test('is found by movement id, wherever the exercise stood', () async {
      // Monday: squat first, row second.
      await workouts.startSession(
        newSession(
          'mon',
          DateTime(2026, 11, 9, 18),
          exercises: <SessionExercise>[
            exercise('mon-squat', position: 0, movementId: 'Back Squat'),
            exercise('mon-row', position: 1, movementId: 'Barbell Row'),
          ],
        ),
      );
      await workouts.setReps('mon-squat-s0', 5);
      await workouts.setWeight('mon-squat-s0', 135);
      await workouts.setReps('mon-squat-s1', 4);
      await workouts.setWeight('mon-squat-s1', 140);
      await workouts.setReps('mon-row-s0', 8);
      await workouts.setWeight('mon-row-s0', 95);

      // Friday's plan has the row first and the squat second.
      final last = await workouts.lastTimes(
        ownerA,
        before: nov13,
        movementIds: <String>['Barbell Row', 'Back Squat', 'Deadlift'],
      );

      expect(last.keys.toSet(), <String>{'Barbell Row', 'Back Squat'});
      expect(last['Back Squat']!.day, nov9);
      expect(
        last['Back Squat']!.sets.map((s) => (s.reps, s.weightLb)),
        <(int, double?)>[(5, 135), (4, 140)],
      );
      expect(last['Barbell Row']!.sets.single.reps, 8);
      expect(last['Barbell Row']!.sets.single.weightLb, 95);
    });

    test('is the most recent earlier day, never today or later', () async {
      for (final (id, at, reps) in <(String, DateTime, int)>[
        ('mon', DateTime(2026, 11, 9, 18), 5),
        ('wed', DateTime(2026, 11, 11, 18), 6),
        ('fri', DateTime(2026, 11, 13, 18), 7),
      ]) {
        await workouts.startSession(
          newSession(
            id,
            at,
            exercises: <SessionExercise>[
              exercise('$id-squat', position: 0, movementId: 'Back Squat'),
            ],
          ),
        );
        await workouts.setReps('$id-squat-s0', reps);
        await workouts.setWeight('$id-squat-s0', 135);
      }

      final forFriday = await workouts.lastTimes(
        ownerA,
        before: nov13,
        movementIds: <String>['Back Squat'],
      );
      final forWednesday = await workouts.lastTimes(
        ownerA,
        before: nov11,
        movementIds: <String>['Back Squat'],
      );
      final forMonday = await workouts.lastTimes(
        ownerA,
        before: nov9,
        movementIds: <String>['Back Squat'],
      );

      expect(forFriday['Back Squat']!.day, nov11);
      expect(forFriday['Back Squat']!.sets.single.reps, 6);
      expect(forWednesday['Back Squat']!.day, nov9);
      expect(forMonday, isEmpty);
    });

    test('leaves out sets with no reps, timed sets and other owners', () async {
      await workouts.startSession(newSession('mon', DateTime(2026, 11, 9, 18)));
      await workouts.setWeight('mon-squat-s0', 135); // a weight, no reps
      await workouts.setReps('mon-plank-s0', 25); // seconds, not reps
      await workouts.startSession(
        newSession('other', DateTime(2026, 11, 9, 18), owner: ownerB),
      );
      await workouts.setReps('other-squat-s0', 5);

      final last = await workouts.lastTimes(
        ownerA,
        before: nov13,
        movementIds: <String>['Back Squat', 'Plank'],
      );

      expect(last, isEmpty);
    });
  });
}
