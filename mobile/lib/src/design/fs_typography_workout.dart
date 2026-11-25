import 'package:flutter/painting.dart';

import 'fs_typography.dart';

/// Text roles of the Train tab, the workout page and dialogs, read from the
/// prototype's stylesheet (`versions/app-v254.html` at `3ff4a6f`).
///
/// Each is one of the [FsText] roles with another size or weight. None
/// names a letter spacing of its own: tracking is inherited from the role
/// it starts from, so the one rule about tracking stays in
/// `fs_typography.dart`.
abstract final class FsWorkoutText {
  /// A dialog's title (`.cdlg-box h2`).
  static final TextStyle dialogTitle = FsText.labelCaps.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  /// A dialog's paragraphs (`.cdlg-box p`).
  static final TextStyle dialogBody = FsText.body.copyWith(
    fontSize: 14.5,
    height: 1.45,
  );

  /// The workout prayer (`.wp-text p`).
  static final TextStyle prayer = FsText.body.copyWith(
    fontSize: 15.5,
    height: 1.55,
  );

  /// The prayer's last line, "Amen." (`.wp-amen`).
  static final TextStyle prayerAmen = FsText.labelCaps.copyWith(
    fontSize: 15.5,
    fontWeight: FontWeight.w700,
  );

  /// The date at the top of Train's day card (`.day-panel h3`).
  static final TextStyle dayTitle = FsText.labelCaps.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    height: 1.25,
  );

  /// A day's status on Train: "READY TO TRAIN" (`.status`).
  static final TextStyle status = FsText.labelCaps.copyWith(fontSize: 14.5);

  /// The line above a workout's title: "WEEK 1 · DAY 5 · 45 MIN"
  /// (`.wk-meta`).
  static final TextStyle meta = FsText.labelCaps.copyWith(fontSize: 13);

  /// A workout's title on its own page (`h1.pg`).
  static final TextStyle pageTitle = FsText.heroTitle.copyWith(
    fontSize: 26,
    height: 1.05,
  );

  /// The title of a row that opens a workout (`.wk-open .wo-t`).
  static final TextStyle rowTitle = FsText.readingSeries.copyWith(
    fontSize: 15.5,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  /// The title of a row of the week list (`.wrow .wo-t`).
  static final TextStyle weekTitle = FsText.body.copyWith(
    fontWeight: FontWeight.w600,
  );

  /// The line under it (`.wrow .wo-s`).
  static final TextStyle weekSubtitle = FsText.body.copyWith(fontSize: 13);

  /// "MON" at the left of a week row (`.wrow .wd small`).
  static final TextStyle weekday = FsText.stat.copyWith(
    fontWeight: FontWeight.w500,
  );

  /// The day of the month under it (`.wrow .wd b`).
  static final TextStyle weekdayNumber = FsText.labelCaps.copyWith(
    fontSize: 16.5,
    height: 1.15,
  );

  /// The "›" or check at the right of a row.
  static final TextStyle rowMark = FsText.body.copyWith(
    fontSize: 19,
    height: 1,
  );

  /// An exercise's name (`.wx .wn`).
  static final TextStyle exerciseName = FsText.readingSeries.copyWith(
    fontSize: 14.5,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  /// An exercise's prescription (`.wx .wr`).
  static final TextStyle prescription = FsText.body.copyWith(
    fontWeight: FontWeight.w600,
  );

  /// "SET 1" at the left of a set row (`.setrow .sn`).
  static final TextStyle setLabel = FsText.buttonMini.copyWith(height: 1.15);

  /// Last time's value under it (`.sn-prev`).
  static final TextStyle setPrevious = FsText.bodySmall.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.15,
  );

  /// What is typed into a number field.
  static final TextStyle fieldValue = FsText.body.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );

  /// "Bodyweight" where a set asks for no weight (`.bw-tag`).
  static final TextStyle fieldTag = FsText.bodySmall.copyWith(fontSize: 12);

  /// The workout clock's time (`.wk-clock b`).
  static final TextStyle clock = FsText.tally.copyWith(
    fontSize: 26,
    height: 1.1,
    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
  );

  /// The rest timer's time (`.rest .rt-time`).
  static final TextStyle restTime = FsText.tally.copyWith(
    fontSize: 19,
    height: 1.1,
    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
  );

  /// A number in the finished workout's summary (`.lk-stats b`).
  static final TextStyle statValue = FsText.tally.copyWith(
    fontSize: 19,
    height: 1.2,
    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
  );

  /// The word under it (`.lk-stats span`).
  static final TextStyle statLabel = FsText.stat.copyWith(fontSize: 11);

  /// A section label of the summary: "WORK SETS" (`.lk-h`).
  static final TextStyle summaryHead = FsText.sectionLabel.copyWith(
    fontWeight: FontWeight.w700,
  );

  /// An exercise's name in the summary (`.lk-name`).
  static final TextStyle summaryName = FsText.readingSeries.copyWith(
    fontSize: 15,
    height: 1.25,
  );

  /// "SET 1" at the left of a summary line (`.lk-row > span`).
  static final TextStyle summaryLabel = FsText.stat;

  /// What was logged, at its right (`.lk-row b`).
  static final TextStyle summaryValue = FsText.body.copyWith(
    fontWeight: FontWeight.w500,
    fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
  );
}
