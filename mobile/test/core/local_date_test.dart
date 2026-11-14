import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/core/date_text.dart';
import 'package:forged_and_sent/src/core/local_date.dart';

void main() {
  group('LocalDate', () {
    test('is the calendar day of a local time, whatever the hour', () {
      expect(
        LocalDate.of(DateTime(2026, 11, 12, 0, 0, 1)),
        const LocalDate(2026, 11, 12),
      );
      expect(
        LocalDate.of(DateTime(2026, 11, 12, 23, 59, 59)),
        const LocalDate(2026, 11, 12),
      );
    });

    test('writes and reads the stored form', () {
      const date = LocalDate(2026, 3, 7);

      expect(date.iso, '2026-03-07');
      expect(date.toString(), '2026-03-07');
      expect(LocalDate.parse('2026-03-07'), date);
      expect(date.monthDayKey, '03-07');
    });

    test('refuses text that is not a real date', () {
      for (final bad in <String>['', '2026-3-7', '2026-02-31', '11-12', 'x']) {
        expect(() => LocalDate.parse(bad), throwsFormatException, reason: bad);
      }
    });

    test('adds days across months, years and leap days', () {
      expect(
        const LocalDate(2026, 12, 31).addDays(1),
        const LocalDate(2027, 1, 1),
      );
      expect(
        const LocalDate(2027, 1, 1).previous,
        const LocalDate(2026, 12, 31),
      );
      expect(
        const LocalDate(2028, 2, 28).addDays(1),
        const LocalDate(2028, 2, 29),
      );
      expect(
        const LocalDate(2027, 2, 28).addDays(1),
        const LocalDate(2027, 3, 1),
      );
      // Across a daylight-saving change, where a local day is 23 or 25 hours.
      expect(
        const LocalDate(2026, 3, 7).addDays(2),
        const LocalDate(2026, 3, 9),
      );
      expect(
        const LocalDate(2026, 10, 31).addDays(2),
        const LocalDate(2026, 11, 2),
      );
    });

    test('knows the weekday and the day of the year', () {
      expect(const LocalDate(2026, 11, 10).weekday, DateTime.tuesday);
      expect(const LocalDate(2026, 1, 1).dayOfYear, 1);
      expect(const LocalDate(2026, 11, 12).dayOfYear, 316);
      expect(const LocalDate(2026, 12, 31).dayOfYear, 365);
      expect(const LocalDate(2028, 12, 31).dayOfYear, 366);
    });

    test('compares and hashes by value', () {
      const a = LocalDate(2026, 11, 12);

      expect(a, const LocalDate(2026, 11, 12));
      expect(a.hashCode, const LocalDate(2026, 11, 12).hashCode);
      expect(a.compareTo(const LocalDate(2026, 11, 13)), isNegative);
      expect(a.compareTo(const LocalDate(2025, 12, 31)), isPositive);
      expect(<LocalDate>{a, LocalDate.parse('2026-11-12')}, hasLength(1));
    });
  });

  test('dates read as the prototype writes them', () {
    const date = LocalDate(2026, 11, 12);

    expect(weekdayName(date), 'Thursday');
    expect(monthAndDay(date), 'November 12');
    expect(heroDateLine(date), 'Thursday, November 12');
  });
}
