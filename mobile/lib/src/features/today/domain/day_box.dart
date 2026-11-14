import '../../../core/local_date.dart';

/// The three groups the progress ring counts boxes in.
enum BoxCategory {
  spirit('Spirit'),
  body('Body'),
  brotherhood('Brotherhood');

  const BoxCategory(this.label);

  final String label;
}

/// One of the day's boxes, as content: what it is called and which group it
/// counts in. Whether it is checked is not here; that is the day's record.
class DayBox {
  const DayBox({
    required this.id,
    required this.title,
    required this.category,
    required this.command,
    required this.previewPoints,
    this.item,
  });

  /// The id in the bundled task list, for example `t_devo`.
  final String id;

  final String title;

  final BoxCategory category;

  /// The small caps line above the title: a phrase of the Stand Firm creed.
  final String command;

  /// The prototype's point value. Not a score: decision Q5 hides it unless
  /// the member turns on the preview switch, and then it is labelled
  /// "preview, not official".
  final int previewPoints;

  /// The item this box records under, or null if the box cannot be checked
  /// yet. In build step S1 only the devotional can.
  final String? item;

  bool get active => item != null;
}

/// Which mission line a date shows.
///
/// The prototype's rule (`drawHeader` in `index.html`), which the maintainer
/// confirmed on 2026-11-12 (recorded in the feature contract): the day of
/// the year (January 1 is 1) modulo the number of lines. After the last
/// line the list starts again, and the count restarts every January 1.
///
/// One correction: the prototype derives the day of the year from elapsed
/// milliseconds, which is an hour short during daylight-saving time and so
/// shows yesterday's line for the first hour of the day. This uses the
/// calendar.
String missionLineFor(LocalDate date, List<String> lines) {
  if (lines.isEmpty) return '';
  return lines[date.dayOfYear % lines.length];
}
