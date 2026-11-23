import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/local_date.dart';
import '../../devotional/data/devotional_library.dart' show assetBundleProvider;
import '../domain/prescription.dart';
import '../domain/workout_plan.dart';

/// The workout content bundled with the app. Nothing is fetched at runtime.
///
/// Three files, each kept identical to its source by a test:
/// - `workouts_forged.json`: the Forged program's 365 plan days, a copy of
///   the `Forged` list in the repository's `seed/workouts.json`;
/// - `movements.json`: a copy of `seed/movements.json`, read here only for
///   each movement's name per equipment setup;
/// - `workout_prayer.json`: the lines of `WORKOUT_PRAYER` inside
///   `index.html`, which exist nowhere else.
///
/// Build step S3 bundles the Forged program only.
class WorkoutLibrary {
  WorkoutLibrary._({
    required this.days,
    required Map<String, Map<String, String>> names,
    required this.prayerLines,
  }) : _names = names;

  static const String workoutsAsset = 'assets/content/workouts_forged.json';
  static const String movementsAsset = 'assets/content/movements.json';
  static const String prayerAsset = 'assets/content/workout_prayer.json';

  /// The only program in the bundle.
  static const String program = WorkoutPlan.defaultProgram;

  /// The equipment setup whose name tells a bodyweight move from a loaded
  /// one.
  static const String bodyweightOnly = 'Bodyweight Only';

  factory WorkoutLibrary.fromJson({
    required String workouts,
    required String movements,
    required String prayer,
  }) {
    final days = <PlannedWorkout>[
      for (final entry
          in (json.decode(workouts) as List<dynamic>)
              .cast<Map<String, dynamic>>())
        PlannedWorkout(
          day: (entry['day'] as num).toInt(),
          week: (entry['week'] as num).toInt(),
          templateDay: (entry['templateDay'] as num).toInt(),
          sessionType: entry['sessionType'] as String,
          title: entry['title'] as String,
          minutes: (entry['minutes'] as num).toInt(),
          exercises: List<PlannedExercise>.unmodifiable(<PlannedExercise>[
            for (final exercise
                in (entry['exercises'] as List<dynamic>).cast<List<dynamic>>())
              PlannedExercise(
                movementId: exercise[0] as String,
                prescription: exercise[1] as String,
              ),
          ]),
        ),
    ];
    final names = <String, Map<String, String>>{
      for (final entry
          in (json.decode(movements) as Map<String, dynamic>).entries)
        entry.key:
            ((entry.value as Map<String, dynamic>)['byEquipment']
                        as Map<String, dynamic>? ??
                    const <String, dynamic>{})
                .cast<String, String>(),
    };
    final lines = (json.decode(prayer) as Map<String, dynamic>)['lines'];
    return WorkoutLibrary._(
      days: List<PlannedWorkout>.unmodifiable(days),
      names: names,
      prayerLines: List<String>.unmodifiable(
        (lines as List<dynamic>).cast<String>(),
      ),
    );
  }

  static Future<WorkoutLibrary> load(AssetBundle bundle) async {
    return WorkoutLibrary.fromJson(
      workouts: await bundle.loadString(workoutsAsset),
      movements: await bundle.loadString(movementsAsset),
      prayer: await bundle.loadString(prayerAsset),
    );
  }

  /// The program's plan days, in order.
  final List<PlannedWorkout> days;

  final Map<String, Map<String, String>> _names;

  /// The workout prayer, one paragraph per entry. The last is "Amen."
  final List<String> prayerLines;

  /// The name a movement is shown by for [equipment]: the prototype's
  /// `moveName`. A movement the library does not know keeps its own name.
  String nameFor(String movementId, String equipment) =>
      _names[movementId]?[equipment] ?? movementId;

  /// Whether a set of [movementId] needs a weight for [equipment].
  WeightMode weightModeOf(String movementId, String equipment) => weightModeFor(
    shownName: nameFor(movementId, equipment),
    bodyweightName: nameFor(movementId, bodyweightOnly),
  );

  /// What [plan] holds for [date].
  PlanDay dayFor(WorkoutPlan plan, LocalDate date) =>
      planDayFor(plan, days, date);
}

final workoutLibraryProvider = FutureProvider<WorkoutLibrary>(
  (ref) => WorkoutLibrary.load(ref.watch(assetBundleProvider)),
);
