import 'package:flutter/material.dart';

import 'fs_colors.dart';
import 'fs_tokens.dart';
import 'fs_typography.dart';

/// One of the day's boxes: a checkbox, a small caps line, a title and a
/// line under it. The prototype's `.item` row.
///
/// A null [onTap] makes the row inactive: it is drawn faded, offers no tap,
/// and a screen reader hears that it is not available.
class FsBoxRow extends StatelessWidget {
  const FsBoxRow({
    super.key,
    required this.command,
    required this.title,
    required this.subtitle,
    required this.checked,
    required this.onTap,
    this.points,
    this.showChevron = false,
  });

  /// The small caps line above the title, for example "Stand firm".
  final String command;

  final String title;
  final String subtitle;
  final bool checked;

  /// Opens or checks the box. Null when the box cannot be used yet.
  final VoidCallback? onTap;

  /// A point value to show at the right, for example "+2 pts". Null hides
  /// it, which is the default until the server scores (decision Q5).
  final String? points;

  /// The "›" that says the row opens a page.
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    final active = onTap != null;

    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: <Widget>[
          _Box(checked: checked),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  command.toUpperCase(),
                  style: FsText.boxCommand.copyWith(color: colors.highlight),
                ),
                const SizedBox(height: 1),
                Text(
                  title,
                  style: FsText.boxTitle.copyWith(
                    color: checked ? colors.textMuted : colors.text,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: FsText.bodySmall.copyWith(color: colors.textMuted),
                ),
              ],
            ),
          ),
          if (points != null) ...<Widget>[
            const SizedBox(width: 16),
            Text(
              points!.toUpperCase(),
              style: FsText.boxPoints.copyWith(
                color: checked ? colors.accent : colors.textMuted,
              ),
            ),
          ],
          if (showChevron) ...<Widget>[
            const SizedBox(width: 16),
            Text(
              '›',
              textScaler: TextScaler.noScaling,
              style: FsText.body.copyWith(
                fontSize: 19,
                height: 1,
                color: colors.accent,
              ),
            ),
          ],
        ],
      ),
    );

    return Semantics(
      container: true,
      button: active,
      enabled: active,
      checked: checked,
      label: <String>[title, subtitle, if (points != null) points!].join('. '),
      // One node for the whole row, carrying the tap for assistive
      // technology. An inactive row offers none.
      excludeSemantics: true,
      onTap: onTap,
      child: Opacity(
        opacity: active ? 1 : 0.5,
        child: Material(
          color: colors.surfaceRaised,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(FsRadius.base),
            side: BorderSide(color: colors.hairline),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 74),
              child: Align(
                alignment: Alignment.centerLeft,
                heightFactor: 1,
                child: row,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The 27-point checkbox. Checked, it fills with the accent color and
/// shows the prototype's check mark.
class _Box extends StatelessWidget {
  const _Box({required this.checked});

  final bool checked;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);
    return Container(
      width: 27,
      height: 27,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: checked ? colors.accent : const Color(0x00000000),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: checked ? colors.accent : colors.textMuted,
          width: 1.5,
        ),
      ),
      child: checked
          ? CustomPaint(
              size: const Size.square(18),
              painter: _CheckPainter(color: colors.onAccent),
            )
          : null,
    );
  }
}

/// The prototype's check mark: `M3.5 9.5l3.6 3.6L14.5 5.2` in an 18-unit
/// box, stroke 3.2.
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
        ..strokeWidth = 3.2 * unit
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) => oldDelegate.color != color;
}
