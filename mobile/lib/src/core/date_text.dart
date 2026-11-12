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
