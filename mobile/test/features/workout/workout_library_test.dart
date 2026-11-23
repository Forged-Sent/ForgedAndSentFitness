import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/features/workout/domain/prescription.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/features/workout/data/workout_library.dart';
import 'package:forged_and_sent/src/features/workout/domain/workout_plan.dart';
import 'package:forged_and_sent/src/features/workout/domain/workout_session.dart';

import '../../support/fs_test_support.dart';

/// Parsed JSON of a file, relative to `mobile/`, where the tests run.
Object? _json(String path) => json.decode(File(path).readAsStringSync());

/// A session started on plan day 1 that holds [exercises] in that order
/// and the mark [superset], as a session copies both from the program
/// when it is started.
WorkoutSession _sessionOf(
  List<PlannedExercise> exercises, {
  List<int> superset = const <int>[],
}) => WorkoutSession(
  id: 's',
  ownerId: 'local-test',
  day: const LocalDate(2026, 11, 9),
  program: 'Forged',
  planDay: 1,
  planWeek: 1,
  title: 'Full Body A: Back Squat',
  sessionType: 'Core',
  minutes: 45,
  startedAtUtc: DateTime.utc(2026, 11, 10, 1),
  startUtcOffset: const Duration(hours: -7),
  finishEventId: 's-finish',
  superset: superset,
  exercises: <SessionExercise>[
    for (var i = 0; i < exercises.length; i++)
      SessionExercise(
        id: 'e$i',
        position: i,
        movementId: exercises[i].movementId,
        name: exercises[i].movementId,
        prescription: exercises[i].prescription,
        measure: SetMeasure.reps,
        weightMode: WeightMode.required,
        restBaseSeconds: 90,
        sets: const <SessionSet>[],
      ),
  ],
);

void main() {
  final library = loadBundledWorkoutLibrary();

  group('the superset mark (display only)', () {
    test('each plan day carries the mark seed/workouts.json gives it', () {
      final seed =
          (_json('../seed/workouts.json')! as Map<String, dynamic>)['Forged']
              as List<dynamic>;
      expect(library.days, hasLength(seed.length));
      var marked = 0;
      for (var i = 0; i < seed.length; i++) {
        final mark = (seed[i] as Map<String, dynamic>)['superset'];
        expect(
          library.days[i].superset,
          mark ?? const <int>[],
          reason: 'plan day ${library.days[i].day}',
        );
        if (mark != null) marked++;
      }
      // Day 1's superset is its sixth and seventh exercises.
      expect(library.days.first.superset, <int>[5, 6]);
      expect(marked, 209);
    });

    test('a mark is two or more neighbouring places inside the day\'s '
        'exercises; anything else is read as no superset', () {
      expect(readSupersetMark(<dynamic>[5, 6], 7), <int>[5, 6]);
      expect(readSupersetMark(<dynamic>[0, 1, 2], 3), <int>[0, 1, 2]);

      expect(readSupersetMark(null, 7), isEmpty);
      expect(readSupersetMark('5,6', 7), isEmpty);
      expect(readSupersetMark(<dynamic>[], 7), isEmpty);
      expect(readSupersetMark(<dynamic>[5], 7), isEmpty);
      // Not neighbours, or not in order.
      expect(readSupersetMark(<dynamic>[4, 6], 7), isEmpty);
      expect(readSupersetMark(<dynamic>[6, 5], 7), isEmpty);
      // Outside the list.
      expect(readSupersetMark(<dynamic>[6, 7], 7), isEmpty);
      expect(readSupersetMark(<dynamic>[-1, 0], 7), isEmpty);
      // Not whole numbers.
      expect(readSupersetMark(<dynamic>[5.5, 6.5], 7), isEmpty);
      expect(readSupersetMark(<dynamic>['5', '6'], 7), isEmpty);
    });

    test('the two exercises are labelled A1 and A2, the others not', () {
      expect(supersetLabels(const <int>[5, 6], 7), <String?>[
        null,
        null,
        null,
        null,
        null,
        'A1',
        'A2',
      ]);
      expect(supersetLabels(const <int>[], 3), <String?>[null, null, null]);
    });

    test('a session\'s labels come from the mark it holds', () {
      final day1 = library.days.first;

      expect(
        _sessionOf(day1.exercises, superset: day1.superset).supersetLabels,
        <String?>[null, null, null, null, null, 'A1', 'A2'],
      );
      // A session with no mark has no label, whatever the program says
      // for its day: this is every session started before the mark was
      // stored.
      final plain = _sessionOf(day1.exercises).supersetLabels;
      expect(plain, hasLength(7));
      expect(plain, everyElement(isNull));
    });

    test('a mark that does not fit the session\'s exercises gives no '
        'label at all', () {
      final day1 = library.days.first;
      for (final mark in <List<int>>[
        <int>[6, 7],
        <int>[5],
        <int>[4, 6],
        <int>[6, 5],
        <int>[-1, 0],
      ]) {
        expect(
          _sessionOf(day1.exercises, superset: mark).supersetLabels,
          everyElement(isNull),
          reason: '$mark',
        );
      }
      // The session's own list decides, not the program's: a session with
      // fewer exercises than the mark reaches has no label.
      expect(
        _sessionOf(
          day1.exercises.sublist(0, 6),
          superset: <int>[5, 6],
        ).supersetLabels,
        everyElement(isNull),
      );
    });

    test('in the bundle the mark and the prescriptions name the same '
        'places', () {
      // The page draws from the mark; the rest timer's rule reads the
      // prescription's words. In the bundle the two must not disagree.
      final words = RegExp(r'^\s*Superset\s+[A-Z]\d+:', caseSensitive: false);
      for (final day in library.days) {
        expect(
          <int>[
            for (var i = 0; i < day.exercises.length; i++)
              if (words.hasMatch(day.exercises[i].prescription)) i,
          ],
          day.superset,
          reason: 'plan day ${day.day}',
        );
      }
    });
  });

  group('the bundled workout files are the repository\'s own', () {
    test('the program is the Forged list of seed/workouts.json', () {
      final seed = _json('../seed/workouts.json')! as Map<String, dynamic>;

      expect(_json(WorkoutLibrary.workoutsAsset), seed['Forged']);
      expect(WorkoutLibrary.program, 'Forged');
    });

    test('the movements say what seed/movements.json says', () {
      // Compared as JSON, not as bytes: a Windows checkout may give the
      // two files different line endings.
      expect(
        _json(WorkoutLibrary.movementsAsset),
        _json('../seed/movements.json'),
      );
    });

    test('the workout prayer is the one inside the prototype', () {
      final html = File('../index.html').readAsStringSync();
      final match = RegExp(
        r'var WORKOUT_PRAYER\s*=\s*(\[.*?\]);',
        dotAll: true,
      ).firstMatch(html);
      expect(match, isNotNull, reason: 'WORKOUT_PRAYER not found');

      final bundled =
          (_json(WorkoutLibrary.prayerAsset)! as Map<String, dynamic>)['lines'];
      expect(bundled, json.decode(match!.group(1)!));
      expect(library.prayerLines, bundled);
      // Six paragraphs; the last is the one the Amen button answers.
      expect(library.prayerLines, hasLength(6));
      expect(library.prayerLines.last, 'Amen.');
    });

    test('the app bundle serves all three files', () async {
      TestWidgetsFlutterBinding.ensureInitialized();
      for (final asset in <String>[
        WorkoutLibrary.workoutsAsset,
        WorkoutLibrary.movementsAsset,
        WorkoutLibrary.prayerAsset,
      ]) {
        final bytes = await rootBundle.load(asset);
        expect(
          utf8.decode(bytes.buffer.asUint8List()),
          File(asset).readAsStringSync(),
          reason: asset,
        );
      }
    });
  });

  group('the Forged program', () {
    test('has 365 plan days, numbered in order, seven to a week', () {
      expect(library.days, hasLength(365));
      for (var i = 0; i < library.days.length; i++) {
        final day = library.days[i];
        expect(day.day, i + 1);
        expect(day.week, i ~/ 7 + 1, reason: 'day ${day.day}');
        expect(day.templateDay, i % 7 + 1, reason: 'day ${day.day}');
      }
    });

    test('follows the weekly template: three lifting days, two recovery '
        'days, an optional day and a rest day', () {
      expect(library.days.take(7).map((day) => day.sessionType), <String>[
        'Core',
        'Recovery',
        'Core',
        'Recovery',
        'Core',
        'Optional',
        'Rest',
      ]);
      expect(library.days.first.title, 'Full Body A: Back Squat');
      expect(library.days.first.minutes, 45);
    });

    test('every exercise names a movement the library knows', () {
      final known =
          (_json(WorkoutLibrary.movementsAsset)! as Map<String, dynamic>).keys
              .toSet();
      for (final day in library.days) {
        if (day.sessionType == 'Rest') continue;
        expect(day.exercises, isNotEmpty, reason: 'day ${day.day}');
        for (final exercise in day.exercises) {
          expect(
            known,
            contains(exercise.movementId),
            reason: 'day ${day.day}',
          );
          expect(exercise.prescription.trim(), isNotEmpty);
        }
      }
    });

    test('a movement is shown by its name for the member\'s equipment', () {
      expect(library.nameFor('Back Squat', 'Full Gym'), 'Barbell Back Squat');
      expect(
        library.nameFor('Back Squat', 'Dumbbells Only'),
        'Dumbbell Goblet Squat',
      );
      // A movement or a setup the library does not know keeps its own name.
      expect(library.nameFor('Back Squat', 'Moon Base'), 'Back Squat');
      expect(library.nameFor('Yak Carry', 'Full Gym'), 'Yak Carry');
    });

    test('prescriptions keep the RPE and RIR guidance of seed/ (L11)', () {
      final first = library.days.first.exercises.first;

      expect(first.movementId, 'Back Squat');
      expect(first.prescription, '3 x 5 (RPE 7, rest 2 min)');
    });
  });
}
