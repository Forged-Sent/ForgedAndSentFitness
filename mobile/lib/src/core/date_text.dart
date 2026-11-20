import 'local_date.dart';

const List<String> _weekdays = <String>[
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const List<String> _months = <String>[
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// "Thursday".
String weekdayName(LocalDate date) => _weekdays[date.weekday - 1];

/// "November 12": the title of a reading.
String monthAndDay(LocalDate date) => '${_months[date.month - 1]} ${date.day}';

/// "Thursday, November 12": the line above Today's title.
String heroDateLine(LocalDate date) =>
    '${weekdayName(date)}, ${monthAndDay(date)}';

/// "Tue, Nov 10": a short date for a list.
String shortDate(LocalDate date) =>
    '${_weekdays[date.weekday - 1].substring(0, 3)}, '
    '${_months[date.month - 1].substring(0, 3)} ${date.day}';

/// "7:30 AM": a time on a twelve-hour clock, from a local `DateTime`.
String clockTime(DateTime local) {
  final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final minute = local.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${local.hour < 12 ? 'AM' : 'PM'}';
}
