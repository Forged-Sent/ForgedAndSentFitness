import 'package:flutter/widgets.dart';

/// A check mark drawn as the prototype draws it
/// (`M3.5 9.5l3.6 3.6L14.5 5.2` in an 18-unit box).
class FsCheckMark extends StatelessWidget {
  const FsCheckMark({super.key, required this.color, this.size = 16});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _CheckPainter(color: color),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 18;
    final path = Path()
      ..moveTo(3.5 * unit, 9.5 * unit)
      ..relativeLineTo(3.6 * unit, 3.6 * unit)
      ..lineTo(14.5 * unit, 5.2 * unit);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.6 * unit
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) => oldDelegate.color != color;
}

/// The closed padlock beside "Locked." on a finished workout: the
/// prototype's `.lockline` drawing, in a 24-unit box.
class FsLockMark extends StatelessWidget {
  const FsLockMark({super.key, required this.color, this.size = 16});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _LockPainter(color: color),
    );
  }
}

class _LockPainter extends CustomPainter {
  const _LockPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 24;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2 * unit
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = color;
    // The body: a 14 by 10 box from (5, 11).
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(5 * unit, 11 * unit, 14 * unit, 10 * unit),
        Radius.circular(unit),
      ),
      paint,
    );
    // The shackle: up from (8, 11) to 7, over to (16, 7), down to 11.
    final shackle = Path()
      ..moveTo(8 * unit, 11 * unit)
      ..lineTo(8 * unit, 7 * unit)
      ..arcToPoint(
        Offset(16 * unit, 7 * unit),
        radius: Radius.circular(4 * unit),
      )
      ..lineTo(16 * unit, 11 * unit);
    canvas.drawPath(shackle, paint);
  }

  @override
  bool shouldRepaint(_LockPainter oldDelegate) => oldDelegate.color != color;
}
