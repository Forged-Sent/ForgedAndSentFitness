import 'local_date.dart';

const List<String> _shortWeekdays = <String>[
  'Mon',
  'Tue',
  'Wed',
  'Thu',
  'Fri',
  'Sat',
  'Sun',
];

const List<String> _shortMonths = <String>[
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "Thu".
String shortWeekdayName(LocalDate date) => _shortWeekdays[date.weekday - 1];

/// "Nov 12".
String shortMonthAndDay(LocalDate date) =>
    '${_shortMonths[date.month - 1]} ${date.day}';

/// "6:10 PM": the time of day of [wallClock], whose fields are read as
/// they stand. Pass the time the phone's clock showed.
String clockTime(DateTime wallClock) {
  final hour = wallClock.hour % 12 == 0 ? 12 : wallClock.hour % 12;
  final minute = wallClock.minute.toString().padLeft(2, '0');
  return '$hour:$minute ${wallClock.hour < 12 ? 'AM' : 'PM'}';
}

/// "1:30" for 90 seconds. Never negative.
String minutesAndSeconds(int seconds) {
  final whole = seconds < 0 ? 0 : seconds;
  return '${whole ~/ 60}:${(whole % 60).toString().padLeft(2, '0')}';
}

/// How long something ran: "12:34", or "1:02:03" from an hour up.
String elapsedText(Duration elapsed) {
  final total = elapsed.isNegative ? 0 : elapsed.inSeconds;
  final hours = total ~/ 3600;
  final minutes = (total ~/ 60) % 60;
  final seconds = (total % 60).toString().padLeft(2, '0');
  return hours > 0
      ? '$hours:${minutes.toString().padLeft(2, '0')}:$seconds'
      : '$minutes:$seconds';
}
