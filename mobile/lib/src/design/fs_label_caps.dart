import 'package:flutter/widgets.dart';

import 'fs_colors.dart';
import 'fs_typography.dart';

/// An uppercase, tracked label in the heading typeface: the prototype's
/// `.label-caps`.
///
/// Screen readers get the text as written, not the uppercased form, so they
/// do not spell it out letter by letter.
class FsLabelCaps extends StatelessWidget {
  const FsLabelCaps(this.text, {super.key, this.color, this.style});

  final String text;

  /// Defaults to the theme's text color.
  final Color? color;

  /// Defaults to [FsText.labelCaps]. Pass [FsText.kicker] for the smaller
  /// size used above hero titles.
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final resolved = (style ?? FsText.labelCaps).copyWith(
      color: color ?? FsColors.of(context).text,
    );
    return Text(text.toUpperCase(), semanticsLabel: text, style: resolved);
  }
}
