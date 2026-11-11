import 'package:flutter/widgets.dart';

/// One line-drawn icon: the prototype's own SVG path data, translated
/// command by command, so the app needs no icon font or SVG package.
@immutable
class FsIconData {
  const FsIconData._(
    this._build, {
    this.viewBox = const Size(24, 24),
    this.strokeWidth = 2,
    this.cap = StrokeCap.square,
    this.join = StrokeJoin.miter,
  });

  final Path Function() _build;

  /// The coordinate space the path is written in.
  final Size viewBox;

  /// Stroke width in view-box units.
  final double strokeWidth;
  final StrokeCap cap;
  final StrokeJoin join;

  Path path() => _build();
}

/// The icons the shell uses. Source: `versions/app-v254.html` at `3ff4a6f`
/// (the tab bar at line 2665, the header buttons and the brand bar shield).
abstract final class FsIcons {
  // Tab bar: 24x24, stroke 2, square caps, mitred joins.

  static const FsIconData today = FsIconData._(_today);
  static const FsIconData fuel = FsIconData._(_fuel);
  static const FsIconData train = FsIconData._(_train);
  static const FsIconData walk = FsIconData._(_walk);
  static const FsIconData board = FsIconData._(_board);
  static const FsIconData rally = FsIconData._(_rally);

  // Round hero buttons.

  static const FsIconData search = FsIconData._(
    _search,
    strokeWidth: 2.2,
    cap: StrokeCap.round,
  );
  static const FsIconData journal = FsIconData._(
    _journal,
    strokeWidth: 2.2,
    cap: StrokeCap.round,
    join: StrokeJoin.round,
  );
  static const FsIconData bell = FsIconData._(
    _bell,
    cap: StrokeCap.butt,
    join: StrokeJoin.round,
  );

  /// Stands in for the member's initial until profiles exist. Not from the
  /// prototype, which shows the initial.
  static const FsIconData person = FsIconData._(
    _person,
    cap: StrokeCap.round,
    join: StrokeJoin.round,
  );

  /// The shield with a cross in the brand bar.
  static const FsIconData shield = FsIconData._(
    _shield,
    viewBox: Size(132, 150),
    strokeWidth: 9,
    cap: StrokeCap.butt,
  );

  // M4 4h16v16H4z  M8 12l3 3 5-6
  static Path _today() => Path()
    ..moveTo(4, 4)
    ..relativeLineTo(16, 0)
    ..relativeLineTo(0, 16)
    ..lineTo(4, 20)
    ..close()
    ..moveTo(8, 12)
    ..relativeLineTo(3, 3)
    ..relativeLineTo(5, -6);

  // M12 3c2.5 3.5 6 6.5 6 11a6 6 0 0 1-12 0c0-2.5 1.2-4.3 2.5-5.5
  //   .3 2 1.3 3 2.5 3.5C11 9 11 6 12 3z
  // M12 20.5a2.5 2.5 0 0 1-2.5-2.5c0-1.5 1.2-2.5 2.5-4
  //   1.3 1.5 2.5 2.5 2.5 4a2.5 2.5 0 0 1-2.5 2.5z
  static Path _fuel() => Path()
    ..moveTo(12, 3)
    ..relativeCubicTo(2.5, 3.5, 6, 6.5, 6, 11)
    ..relativeArcToPoint(const Offset(-12, 0), radius: const Radius.circular(6))
    ..relativeCubicTo(0, -2.5, 1.2, -4.3, 2.5, -5.5)
    ..relativeCubicTo(0.3, 2, 1.3, 3, 2.5, 3.5)
    ..cubicTo(11, 9, 11, 6, 12, 3)
    ..close()
    ..moveTo(12, 20.5)
    ..relativeArcToPoint(
      const Offset(-2.5, -2.5),
      radius: const Radius.circular(2.5),
    )
    ..relativeCubicTo(0, -1.5, 1.2, -2.5, 2.5, -4)
    ..relativeCubicTo(1.3, 1.5, 2.5, 2.5, 2.5, 4)
    ..relativeArcToPoint(
      const Offset(-2.5, 2.5),
      radius: const Radius.circular(2.5),
    )
    ..close();

  // M3 9v6M6 7v10M18 7v10M21 9v6M6 12h12
  static Path _train() => Path()
    ..moveTo(3, 9)
    ..relativeLineTo(0, 6)
    ..moveTo(6, 7)
    ..relativeLineTo(0, 10)
    ..moveTo(18, 7)
    ..relativeLineTo(0, 10)
    ..moveTo(21, 9)
    ..relativeLineTo(0, 6)
    ..moveTo(6, 12)
    ..relativeLineTo(12, 0);

  // circle(8, 7, 2.6)  circle(16.5, 8, 2.2)
  // M3.5 20c.4-4 2.2-6.5 4.5-6.5s4 2.5 4.5 6.5
  // M12.5 20c.3-3 1.8-5 4-5s3.6 2 4 5
  // Each "s" repeats the previous curve's second control point, mirrored.
  static Path _walk() => Path()
    ..addOval(Rect.fromCircle(center: const Offset(8, 7), radius: 2.6))
    ..addOval(Rect.fromCircle(center: const Offset(16.5, 8), radius: 2.2))
    ..moveTo(3.5, 20)
    ..relativeCubicTo(0.4, -4, 2.2, -6.5, 4.5, -6.5)
    ..relativeCubicTo(2.3, 0, 4, 2.5, 4.5, 6.5)
    ..moveTo(12.5, 20)
    ..relativeCubicTo(0.3, -3, 1.8, -5, 4, -5)
    ..relativeCubicTo(2.2, 0, 3.6, 2, 4, 5);

  // M5 20V10M12 20V4M19 20v-7
  static Path _board() => Path()
    ..moveTo(5, 20)
    ..lineTo(5, 10)
    ..moveTo(12, 20)
    ..lineTo(12, 4)
    ..moveTo(19, 20)
    ..relativeLineTo(0, -7);

  // M4 5h16v11H9l-5 4z
  static Path _rally() => Path()
    ..moveTo(4, 5)
    ..relativeLineTo(16, 0)
    ..relativeLineTo(0, 11)
    ..lineTo(9, 16)
    ..relativeLineTo(-5, 4)
    ..close();

  // circle(10.5, 10.5, 6)  M15 15l5 5
  static Path _search() => Path()
    ..addOval(Rect.fromCircle(center: const Offset(10.5, 10.5), radius: 6))
    ..moveTo(15, 15)
    ..relativeLineTo(5, 5);

  // M4 20h4L19 9l-4-4L4 16v4z  M13.5 6.5l4 4
  static Path _journal() => Path()
    ..moveTo(4, 20)
    ..relativeLineTo(4, 0)
    ..lineTo(19, 9)
    ..relativeLineTo(-4, -4)
    ..lineTo(4, 16)
    ..relativeLineTo(0, 4)
    ..close()
    ..moveTo(13.5, 6.5)
    ..relativeLineTo(4, 4);

  // M6 16V11a6 6 0 0 1 12 0v5l2 2H4z  M10 20a2 2 0 0 0 4 0
  static Path _bell() => Path()
    ..moveTo(6, 16)
    ..lineTo(6, 11)
    ..relativeArcToPoint(const Offset(12, 0), radius: const Radius.circular(6))
    ..relativeLineTo(0, 5)
    ..relativeLineTo(2, 2)
    ..lineTo(4, 18)
    ..close()
    ..moveTo(10, 20)
    ..relativeArcToPoint(
      const Offset(4, 0),
      radius: const Radius.circular(2),
      clockwise: false,
    );

  static Path _person() => Path()
    ..addOval(Rect.fromCircle(center: const Offset(12, 8.5), radius: 3.5))
    ..moveTo(5, 20)
    ..relativeCubicTo(0.6, -4, 3.4, -6, 7, -6)
    ..relativeCubicTo(3.6, 0, 6.4, 2, 7, 6);

  // M66 6 122 24v44c0 38-26 64-56 76C36 132 10 106 10 68V24z
  // line (66,34)-(66,118)  line (40,62)-(92,62)
  static Path _shield() => Path()
    ..moveTo(66, 6)
    ..lineTo(122, 24)
    ..relativeLineTo(0, 44)
    ..relativeCubicTo(0, 38, -26, 64, -56, 76)
    ..cubicTo(36, 132, 10, 106, 10, 68)
    ..lineTo(10, 24)
    ..close()
    ..moveTo(66, 34)
    ..lineTo(66, 118)
    ..moveTo(40, 62)
    ..lineTo(92, 62);
}

/// Draws an [FsIconData] at [size] logical pixels wide, in [color].
class FsIcon extends StatelessWidget {
  const FsIcon(this.icon, {super.key, required this.color, this.size = 24});

  final FsIconData icon;
  final Color color;

  /// Width in logical pixels. The height follows the icon's proportions.
  final double size;

  @override
  Widget build(BuildContext context) {
    final height = size * icon.viewBox.height / icon.viewBox.width;
    return SizedBox(
      width: size,
      height: height,
      child: CustomPaint(painter: _FsIconPainter(icon, color)),
    );
  }
}

class _FsIconPainter extends CustomPainter {
  const _FsIconPainter(this.icon, this.color);

  final FsIconData icon;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / icon.viewBox.width;
    canvas.scale(scale, size.height / icon.viewBox.height);
    canvas.drawPath(
      icon.path(),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = color
        ..strokeWidth = icon.strokeWidth
        ..strokeCap = icon.cap
        ..strokeJoin = icon.join,
    );
  }

  @override
  bool shouldRepaint(_FsIconPainter oldDelegate) =>
      oldDelegate.icon != icon || oldDelegate.color != color;
}
