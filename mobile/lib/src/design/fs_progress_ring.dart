import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'fs_colors.dart';
import 'fs_typography.dart';

/// The prototype's `.rd-ring`: a ring that fills clockwise from the top,
/// with a count and a word in the middle.
///
/// Its colors are fixed. It sits on the dark panel under Today's header,
/// which does not change with the theme.
class FsProgressRing extends StatelessWidget {
  const FsProgressRing({
    super.key,
    required this.done,
    required this.total,
    required this.caption,
    required this.semanticLabel,
    this.size = 92,
  });

  final int done;
  final int total;

  /// The word under the count, for example "Boxes".
  final String caption;

  /// What a screen reader says for the whole ring, for example
  /// "1 of 7 boxes done today".
  final String semanticLabel;

  final double size;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : (done / total).clamp(0.0, 1.0);
    return Semantics(
      image: true,
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: size,
        child: CustomPaint(
          painter: _RingPainter(fraction: fraction),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '$done/$total',
                  textScaler: TextScaler.noScaling,
                  style: FsText.ringValue.copyWith(color: FsColors.heroInk),
                ),
                const SizedBox(height: 2),
                Text(
                  caption.toUpperCase(),
                  textScaler: TextScaler.noScaling,
                  style: FsText.ringLabel.copyWith(color: FsColors.ringValue),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Drawn as the prototype's SVG is: a circle of radius 15.5 in a 36-unit
/// box, stroke 3, the filled arc with round ends. An empty ring therefore
/// still shows a dot at the top, as it does in the prototype.
class _RingPainter extends CustomPainter {
  const _RingPainter({required this.fraction});

  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 36;
    final center = size.center(Offset.zero);
    final radius = 15.5 * unit;
    final stroke = 3 * unit;

    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..color = FsColors.ringTrack,
    );
    if (fraction == 0) {
      // A zero-length arc with round ends is a dot in SVG and nothing on a
      // canvas, so the dot is drawn.
      canvas.drawCircle(
        center - Offset(0, radius),
        stroke / 2,
        Paint()..color = FsColors.ringValue,
      );
      return;
    }
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * fraction,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round
        ..color = FsColors.ringValue,
    );
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction;
}
