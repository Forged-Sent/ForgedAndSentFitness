/// A calendar day as the member sees it on his phone: a year, a month and a
/// day, with no time and no time zone.
///
/// Decision Q9: a day is the device's local date at the moment of the action.
/// Everything that is "per day" (the day's boxes, the streak, which reading
/// is today's) is keyed by this type, never by a `DateTime`, so a time zone
/// or a clock change cannot shift a record into another day after the fact.
class LocalDate implements Comparable<LocalDate> {
  const LocalDate(this.year, this.month, this.day);

  /// The calendar day of [local], which must be a local-time `DateTime`.
  LocalDate.of(DateTime local)
    : year = local.year,
      month = local.month,
      day = local.day;

  /// Reads `2026-11-12`. Throws a [FormatException] for anything else.
  factory LocalDate.parse(String iso) {
    final match = _pattern.firstMatch(iso);
    if (match == null) {
      throw FormatException('Not a date in YYYY-MM-DD form', iso);
    }
    final date = LocalDate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
    // Rejects 2026-02-31 and the like, which the pattern alone lets through.
    if (date._asUtc.month != date.month || date._asUtc.day != date.day) {
      throw FormatException('Not a real calendar date', iso);
    }
    return date;
  }

  static final RegExp _pattern = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$');

  final int year;
  final int month;
  final int day;

  /// Calendar arithmetic is done on a UTC date, which has no daylight-saving
  /// jumps, so adding a day never lands on the same day or skips one.
  DateTime get _asUtc => DateTime.utc(year, month, day);

  /// `2026-11-12`. The form stored in the database.
  String get iso =>
      '${year.toString().padLeft(4, '0')}-${_two(month)}-${_two(day)}';

  /// `11-12`. The key of a reading in the bundled devotional file.
  String get monthDayKey => '${_two(month)}-${_two(day)}';

  /// Monday is 1 and Sunday is 7, as in `DateTime.weekday`.
  int get weekday => _asUtc.weekday;

  /// January 1 is 1.
  int get dayOfYear => _asUtc.difference(DateTime.utc(year, 1, 1)).inDays + 1;

  LocalDate addDays(int days) {
    final moved = DateTime.utc(year, month, day + days);
    return LocalDate(moved.year, moved.month, moved.day);
  }

  LocalDate get previous => addDays(-1);

  static String _two(int value) => value.toString().padLeft(2, '0');

  @override
  int compareTo(LocalDate other) => _asUtc.compareTo(other._asUtc);

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => iso;
}
