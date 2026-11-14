import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/local_date.dart';
import 'package:forged_and_sent/src/features/today/domain/completion_event.dart';
import 'package:forged_and_sent/src/features/today/domain/streak.dart';

const String _devotional = DayItems.devotional;
const LocalDate _today = LocalDate(2026, 11, 12);

/// The days, counted back from today, on which the devotional was done.
/// `0` is today, `1` yesterday.
Map<LocalDate, Set<String>> _done(List<int> daysAgo) => {
  for (final ago in daysAgo) _today.addDays(-ago): {_devotional},
};

int _streak(Map<LocalDate, Set<String>> doneByDay) =>
    StreakRule.devotional.length(doneByDay: doneByDay, today: _today);

void main() {
  group('the devotional streak (decision Q6)', () {
    test('is zero when nothing has been done', () {
      expect(_streak(const {}), 0);
    });

    test('counts today once today is done', () {
      expect(_streak(_done([0])), 1);
      expect(_streak(_done([0, 1, 2])), 3);
    });

    test('still counts yesterday while today is not done yet', () {
      // The day is not over, so an unchecked today does not break it.
      expect(_streak(_done([1])), 1);
      expect(_streak(_done([1, 2, 3, 4])), 4);
    });

    test('is broken by a missed day', () {
      expect(_streak(_done([0, 1, 3, 4])), 2);
      expect(_streak(_done([2, 3])), 0);
    });

    test('crosses a month and a year', () {
      final byDay = <LocalDate, Set<String>>{
        for (var ago = 0; ago < 400; ago++)
          const LocalDate(2027, 1, 2).addDays(-ago): {_devotional},
      };

      expect(
        StreakRule.devotional.length(
          doneByDay: byDay,
          today: const LocalDate(2027, 1, 2),
        ),
        400,
      );
    });

    test('ignores other boxes done on a day', () {
      expect(
        _streak({
          _today: {'workout'},
          _today.previous: {'workout', _devotional},
        }),
        1,
      );
    });
  });

  test('another streak is another rule: every listed item, every day', () {
    const both = StreakRule(
      name: 'devotional and workout',
      items: {_devotional, 'workout'},
    );
    final byDay = <LocalDate, Set<String>>{
      _today: {_devotional, 'workout'},
      _today.addDays(-1): {_devotional, 'workout', 'water'},
      _today.addDays(-2): {_devotional},
    };

    expect(both.length(doneByDay: byDay, today: _today), 2);
    expect(StreakRule.devotional.length(doneByDay: byDay, today: _today), 3);
  });
}
