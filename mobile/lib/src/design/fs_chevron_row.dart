import 'package:flutter/material.dart';

import 'fs_colors.dart';
import 'fs_marks.dart';
import 'fs_tokens.dart';
import 'fs_typography.dart';
import 'fs_typography_workout.dart';

/// How a [FsChevronRow] is drawn.
enum FsRowEmphasis {
  /// A button of its own, outlined in the accent color: the prototype's
  /// `.wk-open`.
  outlined,

  /// A row of a list, with a hairline above it: the prototype's `.wrow`.
  plain,

  /// A row of a list that stands for today: raised, with an accent bar at
  /// its left (`.wrow.is-today`).
  current,
}

/// What stands at the right of a [FsChevronRow].
enum FsRowMark {
  none,

  /// "›": the row opens a page.
  chevron,

  /// A check: the thing the row stands for is done.
  check,
}

/// A title over a line of detail, with a mark at the right: the
/// prototype's `chevRow`.
///
/// A null [onTap] makes it plain text: it offers no tap, and a screen
/// reader does not call it a button.
class FsChevronRow extends StatelessWidget {
  const FsChevronRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.mark,
    required this.onTap,
    this.leading,
    this.emphasis = FsRowEmphasis.outlined,
    this.dim = false,
    this.semanticLabel,
  });

  final String title;

  /// Empty for no second line.
  final String subtitle;

  final FsRowMark mark;
  final VoidCallback? onTap;

  /// Set at the left, for example a weekday over a day of the month.
  final Widget? leading;

  final FsRowEmphasis emphasis;

  /// Draws the title muted: nothing to do on this row.
  final bool dim;

  /// What a screen reader says. Defaults to the title and the subtitle.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    final outlined = emphasis == FsRowEmphasis.outlined;
    final current = emphasis == FsRowEmphasis.current;

    final titleStyle = outlined
        ? FsWorkoutText.rowTitle.copyWith(color: colors.text)
        : FsWorkoutText.weekTitle.copyWith(
            color: dim ? colors.textMuted : colors.text,
            fontWeight: dim ? FontWeight.w500 : null,
          );
    final subtitleStyle =
        (outlined ? FsText.bodySmall : FsWorkoutText.weekSubtitle).copyWith(
          color: colors.textMuted,
        );
    final markColor = outlined || mark == FsRowMark.check
        ? colors.accent
        : colors.textMuted;

    final content = Row(
      children: <Widget>[
        if (leading != null) ...<Widget>[leading!, const SizedBox(width: 12)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(title, style: titleStyle),
              if (subtitle.isNotEmpty) Text(subtitle, style: subtitleStyle),
            ],
          ),
        ),
        if (mark != FsRowMark.none) ...<Widget>[
          const SizedBox(width: 12),
          SizedBox(
            width: 20,
            child: Center(
              child: mark == FsRowMark.check
                  ? FsCheckMark(color: markColor, size: 18)
                  : Text(
                      '›',
                      textScaler: TextScaler.noScaling,
                      style: FsWorkoutText.rowMark.copyWith(color: markColor),
                    ),
            ),
          ),
        ],
      ],
    );

    final ShapeBorder shape;
    final Color background;
    final EdgeInsets padding;
    final double minHeight;
    if (outlined) {
      shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FsRadius.base),
        side: BorderSide(color: colors.accent, width: 2),
      );
      background = colors.surface;
      padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 10);
      minHeight = 64;
    } else {
      shape = Border(
        top: BorderSide(color: colors.hairline),
        left: current
            ? BorderSide(color: colors.accent, width: 4)
            : BorderSide.none,
      );
      background = current ? colors.surfaceRaised : const Color(0x00000000);
      padding = EdgeInsets.fromLTRB(current ? 8 : 4, 8, 4, 8);
      minHeight = 60;
    }

    return Semantics(
      container: true,
      button: onTap != null,
      label:
          semanticLabel ??
          <String>[title, if (subtitle.isNotEmpty) subtitle].join('. '),
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: background,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: Padding(
              padding: padding,
              child: Align(
                alignment: Alignment.centerLeft,
                heightFactor: 1,
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
