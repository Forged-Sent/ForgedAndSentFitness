import 'package:flutter/material.dart';

import 'fs_colors.dart';
import 'fs_tokens.dart';
import 'fs_typography.dart';

enum FsButtonVariant {
  /// Filled orange. One per screen at most.
  primary,

  /// Outlined, for secondary actions.
  ghost,

  /// Small and outlined, for chips and inline choices.
  mini,
}

/// The prototype's `.btn`, `.btn.ghost` and `.mini`.
///
/// A null [onPressed] disables the button. [selected] applies to
/// [FsButtonVariant.mini] only and draws it in the accent color.
class FsButton extends StatelessWidget {
  const FsButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = FsButtonVariant.primary,
    this.selected = false,
  });

  const FsButton.ghost({
    super.key,
    required this.label,
    required this.onPressed,
  }) : variant = FsButtonVariant.ghost,
       selected = false;

  const FsButton.mini({
    super.key,
    required this.label,
    required this.onPressed,
    this.selected = false,
  }) : variant = FsButtonVariant.mini;

  final String label;
  final VoidCallback? onPressed;
  final FsButtonVariant variant;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    final enabled = onPressed != null;
    final mini = variant == FsButtonVariant.mini;

    final Color background;
    final Color foreground;
    final Color border;
    final double borderWidth;
    switch (variant) {
      case FsButtonVariant.primary:
        background = FsColors.gold;
        foreground = FsColors.onGold;
        border = FsColors.gold;
        borderWidth = 1.5;
      case FsButtonVariant.ghost:
        background = const Color(0x00000000);
        foreground = colors.text;
        border = colors.hairline;
        borderWidth = 1.5;
      case FsButtonVariant.mini:
        background = const Color(0x00000000);
        foreground = selected ? colors.accent : colors.textMuted;
        border = selected ? colors.accent : colors.hairline;
        borderWidth = 1;
    }

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(FsRadius.base),
      side: BorderSide(color: border, width: borderWidth),
    );
    final style = (mini ? FsText.buttonMini : FsText.button).copyWith(
      color: foreground,
    );

    return Semantics(
      button: true,
      enabled: enabled,
      selected: mini ? selected : null,
      label: label,
      excludeSemantics: true,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Material(
          color: background,
          shape: shape,
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onPressed,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: mini
                    ? FsSizes.miniButtonHeight
                    : FsSizes.buttonHeight,
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: mini ? 12 : 18,
                  vertical: 6,
                ),
                child: Center(
                  widthFactor: 1,
                  heightFactor: 1,
                  child: Text(
                    label.toUpperCase(),
                    textAlign: TextAlign.center,
                    style: style,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
