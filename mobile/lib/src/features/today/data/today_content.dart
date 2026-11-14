import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/local_date.dart';
import '../../devotional/data/devotional_library.dart';
import '../domain/completion_event.dart';
import '../domain/day_box.dart';

/// What Today shows that is not the member's own data: the list of boxes
/// and the mission lines. Bundled with the app.
///
/// - `tasks.json` is a copy of the repository's `seed/tasks.json`, kept
///   identical by a test.
/// - `missions.json` holds the prototype's 14 mission lines, which exist
///   nowhere else but inside `index.html` (identical on `main` at `dd35157`
///   and in v254). A test compares the two.
class TodayContent {
  const TodayContent({required this.boxes, required this.missionLines});

  static const String tasksAsset = 'assets/content/tasks.json';
  static const String missionsAsset = 'assets/content/missions.json';

  factory TodayContent.fromJson({
    required String tasks,
    required String missions,
  }) {
    final boxes = <DayBox>[];
    final file = json.decode(tasks) as Map<String, dynamic>;
    for (final entry in file.entries) {
      final task = entry.value as Map<String, dynamic>;
      final kind = task['kind'] as String;
      // The weigh-in and progress-photo boxes appear only on the weekly
      // rest day in the prototype. Neither feature exists yet, so they are
      // left out rather than carrying that rule over.
      if (kind == 'weigh' || kind == 'photos') continue;

      final spirit = kind == 'devo' || entry.key == 't_motto';
      final brotherhood = kind == 'checkin';
      boxes.add(
        DayBox(
          id: entry.key,
          // v254 calls this box "My Mission"; the seed still says "My Creed".
          title: entry.key == 't_motto'
              ? 'My Mission'
              : task['title'] as String,
          category: spirit
              ? BoxCategory.spirit
              : brotherhood
              ? BoxCategory.brotherhood
              : BoxCategory.body,
          command: spirit
              ? 'Stand firm'
              : brotherhood
              ? 'In love'
              : 'Be strong',
          previewPoints: (task['points'] as num).toInt(),
          item: kind == 'devo' ? DayItems.devotional : null,
        ),
      );
    }
    final lines = (json.decode(missions) as Map<String, dynamic>)['lines'];
    return TodayContent(
      boxes: List<DayBox>.unmodifiable(boxes),
      missionLines: List<String>.unmodifiable(
        (lines as List<dynamic>).cast<String>(),
      ),
    );
  }

  static Future<TodayContent> load(AssetBundle bundle) async {
    return TodayContent.fromJson(
      tasks: await bundle.loadString(tasksAsset),
      missions: await bundle.loadString(missionsAsset),
    );
  }

  /// The day's boxes, in the order they are listed.
  final List<DayBox> boxes;

  final List<String> missionLines;

  String missionFor(LocalDate date) => missionLineFor(date, missionLines);
}

final todayContentProvider = FutureProvider<TodayContent>(
  (ref) => TodayContent.load(ref.watch(assetBundleProvider)),
);
