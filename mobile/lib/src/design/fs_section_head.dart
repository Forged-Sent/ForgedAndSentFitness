import 'package:flutter/widgets.dart';

import 'fs_colors.dart';
import 'fs_tokens.dart';
import 'fs_typography.dart';

/// The top of a card: its title on the left and, optionally, a tally on
/// the right. The prototype's `.section-head`.
class FsSectionHead extends StatelessWidget {
  const FsSectionHead({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Semantics(
            header: true,
            child: Text(
              title,
              style: FsText.sectionTitle.copyWith(color: colors.text),
            ),
          ),
        ),
        if (trailing != null) ...<Widget>[const SizedBox(width: 12), trailing!],
      ],
    );
  }
}

/// "1 / 7": the count in the text color, the total muted.
class FsTally extends StatelessWidget {
  const FsTally({
    super.key,
    required this.done,
    required this.total,
    required this.semanticLabel,
  });

  final int done;
  final int total;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    return Text.rich(
      TextSpan(
        text: '$done',
        style: FsText.tally.copyWith(color: colors.text),
        children: <InlineSpan>[
          TextSpan(
            text: ' / $total',
            style: FsText.tally.copyWith(
              fontWeight: FontWeight.w500,
              color: colors.textMuted,
            ),
          ),
        ],
      ),
      semanticsLabel: semanticLabel,
    );
  }
}

/// A thin bar that fills from the left. The prototype's `.meter`.
class FsMeter extends StatelessWidget {
  const FsMeter({super.key, required this.fraction});

  /// From 0 to 1.
  final double fraction;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    return ExcludeSemantics(
      child: Container(
        height: 8,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: colors.surfaceRaised,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: colors.hairline),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: fraction.clamp(0.0, 1.0),
          child: ColoredBox(color: colors.accent),
        ),
      ),
    );
  }
}

/// The space between a card's head, its meter and what follows.
abstract final class FsSectionSpacing {
  static const double headToMeter = 8;
  static const double meterToContent = 6;
  static const double rows = 6;
  static const double card = FsSpacing.card;
}
