import '../../../core/local_date.dart';

/// The two translations a verse can be read in (decision Q7).
enum Translation {
  /// Berean Standard Bible. Public domain, the default, and every verse has
  /// it.
  bsb('BSB'),

  /// English Standard Version. Bundled for at most 499 distinct verses
  /// until there is a licence.
  esv('ESV');

  const Translation(this.label);

  /// The short name on the tab and after the reference.
  final String label;
}

/// The credit lines shown with scripture, word for word as the prototype
/// gives them: the ESV line from Settings › Scripture in `index.html` on
/// `main`; the BSB line from the same place in v175 (`52ae0d5`), the last
/// version that quoted the BSB.
abstract final class ScriptureNotices {
  static const String bsb =
      'Scripture quotations are from the Berean Standard Bible (BSB), which '
      'is in the public domain.';

  static const String esv =
      'Scripture quotations are from the ESV® Bible (The Holy Bible, English '
      'Standard Version®), © 2001 by Crossway, a publishing ministry of Good '
      'News Publishers. Used by permission. All rights reserved.';

  /// What the ESV tab says for a verse whose ESV text is not bundled.
  static const String esvLimitReached =
      'ESV limit reached until we have a licence';

  static String of(Translation translation) => switch (translation) {
    Translation.bsb => bsb,
    Translation.esv => esv,
  };
}

/// A mark some readings carry under their headline. It is shown and
/// nothing more: it has no action, and nothing is counted or scored from
/// it. The words are the prototype's (`drawDevo` in v254).
enum ReadingTag {
  sent('Sent: take it to someone'),
  spiritLed('Spirit-led');

  const ReadingTag(this.label);

  final String label;
}

/// One day's reading.
class Devotional {
  const Devotional({
    required this.monthDayKey,
    required this.monthName,
    required this.monthTheme,
    required this.monthTag,
    required this.prayer,
    required this.reference,
    required this.bsbText,
    required this.esvText,
    required this.reflect,
    required this.act,
    this.series,
    this.headline,
    this.inJesus,
    this.tags = const <ReadingTag>[],
  });

  /// `11-12`: the calendar date this reading belongs to, in every year.
  final String monthDayKey;

  /// The month's name, theme and one-line tag, from the bundled file.
  final String monthName;
  final String monthTheme;
  final String monthTag;

  /// The series a reading belongs to, where it has one.
  final String? series;

  /// The line under the date. Every bundled reading has one; a reading
  /// without it shows none, as in the prototype.
  final String? headline;

  /// The reading's marks, in the order they are shown. The library hands
  /// out a list that cannot be changed.
  final List<ReadingTag> tags;

  final String prayer;

  /// For example `James 1:17`.
  final String reference;

  final String bsbText;

  /// Null when this verse's ESV text is not bundled. The ESV tab then shows
  /// [ScriptureNotices.esvLimitReached].
  final String? esvText;

  /// The "In Jesus" paragraph, shown between the verse and the reflection.
  /// Every bundled reading has one; a reading without it shows no such
  /// section, as in the prototype.
  final String? inJesus;

  final String reflect;
  final String act;

  /// The verse in [translation], or null where it is not bundled.
  String? textIn(Translation translation) => switch (translation) {
    Translation.bsb => bsbText,
    Translation.esv => esvText,
  };
}

/// Which reading belongs to a date.
///
/// The prototype's rule (`devoToday` in `index.html`), which the maintainer
/// confirmed on 2026-11-12 (recorded in the feature contract): the reading
/// is looked up by the calendar month and day alone. There are 366,
/// one for every date including February 29, so the year after December 31
/// starts again at January 1 with the same readings.
String readingKeyFor(LocalDate date) => date.monthDayKey;
