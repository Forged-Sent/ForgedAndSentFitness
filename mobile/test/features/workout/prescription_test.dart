import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/features/workout/domain/prescription.dart';
import 'package:forged_and_sent/src/features/workout/domain/workout_session.dart';

import '../../support/fs_test_support.dart';

SessionExercise _exercise({
  SetMeasure measure = SetMeasure.reps,
  WeightMode weightMode = WeightMode.required,
  List<SessionSet> sets = const <SessionSet>[],
  String name = 'Barbell Back Squat',
  DateTime? restEndsAtUtc,
  int? restPausedSeconds,
}) => SessionExercise(
  id: 'x',
  position: 0,
  movementId: 'Back Squat',
  name: name,
  prescription: '3 x 5 (RPE 7, rest 2 min)',
  measure: measure,
  weightMode: weightMode,
  restBaseSeconds: 120,
  restEndsAtUtc: restEndsAtUtc,
  restPausedSeconds: restPausedSeconds,
  sets: sets,
);

SessionSet _set(String id, {int? reps, double? weight, bool ticked = false}) =>
    SessionSet(
      id: id,
      position: 0,
      target: '5',
      reps: reps,
      weightLb: weight,
      ticked: ticked,
    );

WorkoutSession _session(List<SessionExercise> exercises) => WorkoutSession(
  id: 's',
  ownerId: 'local-a',
  day: const LocalDate(2026, 11, 12),
  program: 'Forged',
  planDay: 1,
  planWeek: 1,
  title: 'Full Body A: Back Squat',
  sessionType: 'Core',
  minutes: 45,
  startedAtUtc: DateTime.utc(2026, 11, 12, 23),
  startUtcOffset: const Duration(hours: -5),
  finishEventId: 'f',
  exercises: exercises,
);

void main() {
  group(
    'reading the sets out of a prescription (the prototype\'s parseSets)',
    () {
      test('sets of reps', () {
        final plan = parseSets('3 x 5 (RPE 7, rest 2 min)')!;

        expect(plan.count, 3);
        expect(plan.targets, <String>['5', '5', '5']);
        expect(plan.measure, SetMeasure.reps);
        expect(parseSets('3 x 6-8 (RPE 7, rest 90 sec)')!.targets.first, '6-8');
        expect(parseSets('3 x 5')!.count, 3);
      });

      test('timed sets', () {
        final plan = parseSets('2 x 25 sec')!;

        expect(plan.count, 2);
        expect(plan.targets, <String>['25 sec', '25 sec']);
        expect(plan.measure, SetMeasure.seconds);
      });

      test('ramp sets get one row each with its own target', () {
        final plan = parseSets(
          '1 x 5, 1 x 3, 1 x 1 (RPE 9, heaviest set last, rest 3 min)',
        )!;

        expect(plan.targets, <String>['5', '3', '1']);
        expect(plan.measure, SetMeasure.reps);
        expect(parseSets('2 x 5, 1 x 3')!.targets, <String>['5', '5', '3']);
      });

      test('a superset line counts only its sets part', () {
        final first = parseSets(
          'Superset A1: 3 x 12 (RIR 3). Go straight to A2, then rest 45 to 60 sec',
        )!;
        final second = parseSets(
          'Superset A2: 3 x 12 (RIR 2-3). Rest 45 to 60 sec, then back to A1',
        )!;

        expect(first.targets, <String>['12', '12', '12']);
        expect(second.targets, <String>['12', '12', '12']);
      });

      test('a line that describes no sets has none: it gets a tick', () {
        for (final line in <String>[
          '12 min easy, conversational pace',
          '2 rounds: 30 sec hold or 6 slow reps per side',
          'Full rest. An easy walk or stretch is optional.',
          '0 x 5',
          '13 x 5',
          '',
        ]) {
          expect(parseSets(line), isNull, reason: line);
        }
      });

      test('never more than twelve rows', () {
        expect(parseSets('12 x 3')!.count, 12);
        expect(parseSets('6 x 1, 6 x 1, 6 x 1')!.count, maxSets);
      });

      test('every prescription of the bundled Forged program is read as the '
          'prototype reads it', () {
        // Counted with the prototype's own parseSets rules over
        // seed/workouts.json: 1,684 with sets, 39 ramps, 468 ticks.
        var sets = 0;
        var ramps = 0;
        var ticks = 0;
        final targets = <String>{};
        for (final day in loadBundledWorkoutLibrary().days) {
          for (final exercise in day.exercises) {
            final plan = parseSets(exercise.prescription);
            if (plan == null) {
              ticks++;
            } else if (plan.targets.toSet().length > 1) {
              ramps++;
            } else {
              sets++;
              targets.add(plan.targets.first);
            }
          }
        }

        expect(sets, 1684);
        expect(ramps, 39);
        expect(ticks, 468);
        expect(targets, <String>{
          '10',
          '10-12',
          '12',
          '20 sec',
          '25 sec',
          '3',
          '30 sec',
          '35 sec',
          '40 sec',
          '45 sec',
          '5',
          '6',
          '6-8',
          '8',
          '8-10',
        });
      });
    },
  );

  group('the rest a prescription writes (the prototype\'s restOf)', () {
    test('minutes and seconds', () {
      expect(restSecondsIn('3 x 5 (RPE 7, rest 2 min)'), 120);
      expect(restSecondsIn('3 x 6-8 (RPE 7, rest 90 sec)'), 90);
      expect(restSecondsIn('3 x 5 (rest 2.5 min)'), 150);
    });

    test('the top of a range', () {
      expect(
        restSecondsIn(
          'Superset A2: 3 x 12 (RIR 3). Rest 45 to 60 sec, then back',
        ),
        60,
      );
      expect(restSecondsIn('3 x 8 (rest 60-90 sec)'), 90);
    });

    test('none written, or one outside ten seconds to ten minutes', () {
      expect(restSecondsIn('2 x 25 sec'), 0);
      expect(restSecondsIn('3 x 5 (rest 5 sec)'), 0);
      expect(restSecondsIn('3 x 5 (rest 11 min)'), 0);
      expect(restSecondsIn(''), 0);
    });

    test('the timer starts at the written rest, else a minute after the '
        'second half of a superset, else ninety seconds', () {
      expect(restBaseFor('3 x 5 (RPE 7, rest 2 min)'), 120);
      expect(restBaseFor('Superset A2: 3 x 12 (RIR 3). Then back to A1'), 60);
      expect(restBaseFor('2 x 25 sec'), defaultRestSeconds);
      expect(defaultRestSeconds, 90);
    });

    test('the first half of a superset has no rest timer', () {
      expect(
        isSupersetFirst('Superset A1: 3 x 12 (RIR 3). Go straight to A2'),
        isTrue,
      );
      expect(isSupersetFirst('Superset A2: 3 x 12 (RIR 3). Rest 45'), isFalse);
      expect(isSupersetFirst('3 x 5 (RPE 7, rest 2 min)'), isFalse);
    });
  });

  group('whether a set needs a weight (the prototype\'s needsWeight)', () {
    final library = loadBundledWorkoutLibrary();
    WeightMode mode(String movement) =>
        library.weightModeOf(movement, 'Full Gym');

    test('a loaded lift does', () {
      for (final movement in <String>[
        'Back Squat',
        'Bench Press',
        'Deadlift',
        'Barbell Row',
        'Cable Curl',
      ]) {
        expect(mode(movement), WeightMode.required, reason: movement);
      }
    });

    test('a bodyweight move does not', () {
      for (final movement in <String>['Plank', 'Bird Dog', 'Deep Squat Hold']) {
        expect(mode(movement), WeightMode.none, reason: movement);
      }
    });

    test('a pull-up may take added weight, and never needs it', () {
      expect(library.nameFor('Pull-Up', 'Full Gym'), contains('Pull-Up'));
      expect(mode('Pull-Up'), WeightMode.optional);
    });

    test('a name with no clue is decided by what a man with no equipment '
        'would do instead', () {
      expect(
        weightModeFor(shownName: 'Zercher Carry', bodyweightName: 'Bear Hug'),
        WeightMode.required,
      );
      expect(
        weightModeFor(
          shownName: 'Cossack Squat',
          bodyweightName: 'Cossack Squat',
        ),
        WeightMode.none,
      );
    });

    test('every movement of the Forged program resolves to a name', () {
      for (final day in library.days) {
        for (final exercise in day.exercises) {
          expect(
            library.nameFor(exercise.movementId, 'Full Gym').trim(),
            isNotEmpty,
            reason: exercise.movementId,
          );
        }
      }
    });
  });

  group('whether a set is logged (the prototype\'s paintDone)', () {
    test('a loaded lift needs reps and a weight', () {
      final exercise = _exercise();

      expect(exercise.isLogged(_set('a', reps: 5, weight: 135)), isTrue);
      expect(exercise.isLogged(_set('a', reps: 5)), isFalse);
      expect(exercise.isLogged(_set('a', weight: 135)), isFalse);
      expect(exercise.isLogged(_set('a', reps: 0, weight: 135)), isFalse);
      expect(exercise.isLogged(_set('a')), isFalse);
    });

    test('a bodyweight lift needs reps only', () {
      final none = _exercise(weightMode: WeightMode.none);
      final optional = _exercise(weightMode: WeightMode.optional);

      expect(none.isLogged(_set('a', reps: 8)), isTrue);
      expect(optional.isLogged(_set('a', reps: 8)), isTrue);
      expect(optional.isLogged(_set('a', reps: 8, weight: 25)), isTrue);
      expect(optional.isLogged(_set('a', weight: 25)), isFalse);
    });

    test('a timed set needs its seconds, whatever it is loaded with', () {
      final carry = _exercise(measure: SetMeasure.seconds);

      expect(carry.isLogged(_set('a', reps: 30)), isTrue);
      expect(carry.isLogged(_set('a')), isFalse);
    });

    test('a tick row is logged when it is ticked', () {
      final walk = _exercise(
        measure: SetMeasure.tick,
        weightMode: WeightMode.none,
      );

      expect(walk.isLogged(_set('a', ticked: true)), isTrue);
      expect(walk.isLogged(_set('a')), isFalse);
    });
  });

  group('the check before finishing (the prototype\'s workoutFixes)', () {
    test('a fully logged session is clear', () {
      final check = checkBeforeFinish(
        _session(<SessionExercise>[
          _exercise(sets: <SessionSet>[_set('a', reps: 5, weight: 135)]),
          _exercise(
            measure: SetMeasure.tick,
            weightMode: WeightMode.none,
            sets: <SessionSet>[_set('t')],
          ),
        ]),
      );

      expect(check.clear, isTrue);
    });

    test('reps without the weight, or the weight without reps, must be '
        'fixed', () {
      final check = checkBeforeFinish(
        _session(<SessionExercise>[
          _exercise(
            sets: <SessionSet>[
              _set('a', reps: 5, weight: 135),
              _set('b', reps: 5),
              _set('c', weight: 135),
            ],
          ),
        ]),
      );

      expect(check.blanks, isEmpty);
      expect(check.fixes.map((f) => f.setId), <String>['b', 'c']);
      expect(check.fixes.map((f) => f.text), <String>[
        'Barbell Back Squat, Set 2: add the weight',
        'Barbell Back Squat, Set 3: add the reps',
      ]);
    });

    test('a set with nothing entered is blank, not wrong', () {
      final check = checkBeforeFinish(
        _session(<SessionExercise>[
          _exercise(
            sets: <SessionSet>[_set('a', reps: 5, weight: 135), _set('b')],
          ),
          _exercise(
            name: 'Plank',
            measure: SetMeasure.seconds,
            weightMode: WeightMode.none,
            sets: <SessionSet>[_set('p')],
          ),
        ]),
      );

      expect(check.fixes, isEmpty);
      expect(check.blanks.map((b) => b.text), <String>[
        'Barbell Back Squat, Set 2: nothing entered',
        'Plank, Set 1: nothing entered',
      ]);
    });

    test('a tick row left unticked holds nothing up', () {
      final check = checkBeforeFinish(
        _session(<SessionExercise>[
          _exercise(
            measure: SetMeasure.tick,
            weightMode: WeightMode.none,
            sets: <SessionSet>[_set('t')],
          ),
        ]),
      );

      expect(check.clear, isTrue);
    });
  });

  group('a session\'s totals', () {
    test('count logged sets, and volume as weight times reps', () {
      final totals = _session(<SessionExercise>[
        _exercise(
          sets: <SessionSet>[
            _set('a', reps: 5, weight: 135),
            _set('b', reps: 5, weight: 137.5),
            _set('c', reps: 4), // not logged: no weight
          ],
        ),
        _exercise(
          weightMode: WeightMode.optional,
          sets: <SessionSet>[
            _set('d', reps: 8), // bodyweight only: counts, adds no pounds
            _set('e', reps: 6, weight: 25), // added load only
          ],
        ),
        _exercise(
          measure: SetMeasure.seconds,
          sets: <SessionSet>[_set('f', reps: 30, weight: 50)], // timed
        ),
        _exercise(
          measure: SetMeasure.tick,
          weightMode: WeightMode.none,
          sets: <SessionSet>[_set('g', ticked: true)],
        ),
      ]).totals;

      expect(totals.loggedSets, 6);
      // 5 x 135 + 5 x 137.5 + 6 x 25. No body weight is added anywhere:
      // the app stores none.
      expect(totals.volumeLb, 1513);
    });
  });

  group('the workout clock and the rest timer', () {
    final session = _session(const <SessionExercise>[]);

    test('the clock is the time since the stored start', () {
      expect(
        session.elapsedAt(DateTime.utc(2026, 11, 12, 23, 17, 5)),
        const Duration(minutes: 17, seconds: 5),
      );
      // A phone whose clock was set back never shows a negative time.
      expect(session.elapsedAt(DateTime.utc(2026, 11, 12, 22)), Duration.zero);
      // The start as the phone showed it: 6 PM, five hours behind UTC.
      expect(session.startedAtWallClock.hour, 18);
    });

    test('the rest timer counts down to a stored instant', () {
      final endsAt = DateTime.utc(2026, 11, 12, 23, 10);
      final running = _exercise(restEndsAtUtc: endsAt);

      final early = running.restAt(
        endsAt.subtract(const Duration(seconds: 75)),
      );
      expect(early.left, 75);
      expect(early.running, isTrue);
      expect(early.over, isFalse);
      // Part of a second left still shows as one second.
      expect(
        running.restAt(endsAt.subtract(const Duration(milliseconds: 300))).left,
        1,
      );
      final late = running.restAt(endsAt.add(const Duration(minutes: 3)));
      expect(late.left, 0);
      expect(late.running, isFalse);
      expect(late.over, isTrue);
    });

    test('a paused timer keeps its remainder, a waiting one its full '
        'length', () {
      final now = DateTime.utc(2026, 11, 12, 23, 10);

      final paused = _exercise(restPausedSeconds: 40).restAt(now);
      expect(paused.left, 40);
      expect(paused.paused, isTrue);
      expect(paused.running, isFalse);

      final waiting = _exercise().restAt(now);
      expect(waiting.left, 120);
      expect(waiting.paused, isFalse);
      expect(waiting.running, isFalse);
      expect(waiting.over, isFalse);
    });
  });
}
