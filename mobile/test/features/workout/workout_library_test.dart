import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/features/workout/data/workout_library.dart';

import '../../support/fs_test_support.dart';

/// Parsed JSON of a file, relative to `mobile/`, where the tests run.
Object? _json(String path) => json.decode(File(path).readAsStringSync());

void main() {
  final library = loadBundledWorkoutLibrary();

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
