import 'package:flutter/widgets.dart';

import 'fs_colors.dart';
import 'fs_label_caps.dart';
import 'fs_typography.dart';

/// A verse set as scripture: italic Merriweather behind a brass rule, with
/// its reference underneath. The prototype's `.d-read` and `.d-ref`.
class FsScripture extends StatelessWidget {
  const FsScripture({
    super.key,
    required this.text,
    required this.reference,
    required this.translation,
  });

  final String text;

  /// For example `James 1:17`.
  final String reference;

  /// The translation's short name, for example `BSB`.
  final String translation;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(color: colors.highlight, width: 3.6),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(left: 14),
            child: Text(
              text,
              style: FsText.scriptureLarge.copyWith(color: colors.text),
            ),
          ),
        ),
        const SizedBox(height: 8),
        FsLabelCaps(
          '— $reference ($translation)',
          style: FsText.sectionLabel,
          color: colors.textMuted,
        ),
      ],
    );
  }
}
