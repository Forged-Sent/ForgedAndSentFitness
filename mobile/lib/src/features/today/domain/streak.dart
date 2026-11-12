import '../../../core/local_date.dart';
import 'completion_event.dart';

/// What makes a day count toward a streak: every item in [items] done on
/// that day.
///
/// Decision Q6: the streak is consecutive days with the devotional done,
/// and other streaks (workout, nutrition, combinations) must be possible
/// later. Each of those is another rule with another set of items; nothing
/// else changes.
class StreakRule {
  const StreakRule({required this.name, required this.items});

  /// The streak shown in build step S1.
  static const StreakRule devotional = StreakRule(
    name: 'devotional',
    items: <String>{DayItems.devotional},
  );

  final String name;
  final Set<String> items;

  bool _counts(Set<String>? doneOnDay) =>
      doneOnDay != null && doneOnDay.containsAll(items);

  /// The number of consecutive days that count, ending today if today
  /// counts, otherwise ending yesterday. Today not being done yet does not
  /// break a streak: the day is not over.
  ///
  /// [doneByDay] holds, for each day, the items that are done on it.
  int length({
    required Map<LocalDate, Set<String>> doneByDay,
    required LocalDate today,
  }) {
    var day = _counts(doneByDay[today]) ? today : today.previous;
    var days = 0;
    while (_counts(doneByDay[day])) {
      days++;
      day = day.previous;
    }
    return days;
  }
}
