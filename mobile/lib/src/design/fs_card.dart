import 'package:flutter/widgets.dart';

import 'fs_colors.dart';
import 'fs_tokens.dart';

/// A surface with a hairline border: the prototype's card.
class FsCard extends StatelessWidget {
  const FsCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(FsSpacing.card),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border.all(color: colors.hairline),
        borderRadius: BorderRadius.circular(FsRadius.card),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}
