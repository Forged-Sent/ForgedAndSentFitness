import 'package:flutter/widgets.dart';

import 'fs_button.dart';
import 'fs_colors.dart';
import 'fs_label_caps.dart';
import 'fs_typography.dart';

/// The bar at the top of a page that was opened from another: a small
/// "‹ Back" button on the left and a small caps line on the right. The
/// prototype's `.pbar`.
class FsPageBar extends StatelessWidget {
  const FsPageBar({super.key, required this.onBack, this.trailing});

  final VoidCallback onBack;

  /// The small caps line on the right, for example the weekday.
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    return Row(
      children: <Widget>[
        FsButton.mini(
          label: '‹ Back',
          semanticLabel: 'Back',
          onPressed: onBack,
        ),
        const Spacer(),
        if (trailing != null)
          FsLabelCaps(trailing!, style: FsText.kicker, color: colors.textMuted),
      ],
    );
  }
}
