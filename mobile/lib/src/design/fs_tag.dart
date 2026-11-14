import 'package:flutter/material.dart';

import 'fs_colors.dart';
import 'fs_icons.dart';
import 'fs_typography.dart';

/// The two colors a tag is drawn in. A tag sits on the reading's header,
/// which is dark in both themes.
enum FsTagTone {
  /// The dark theme's accent. In the light theme it is the ring's bright
  /// orange, like [gold]: the light theme's accent is a dark orange that is
  /// hard to read on the dark header. The prototype uses that dark orange;
  /// the maintainer chose the bright one on 2026-11-12.
  accent,

  /// The bright orange of the progress ring, the same in both themes
  /// (the prototype's `--gold-2`).
  gold,
}

/// A small outlined pill with an icon and a caps label: the prototype's
/// `.devo-tg`. It is a mark to read, not a control: it has no tap.
///
/// A screen reader hears the label as written; the icon is decoration.
class FsTag extends StatelessWidget {
  const FsTag({
    super.key,
    required this.label,
    required this.icon,
    this.tone = FsTagTone.accent,
  });

  final String label;
  final FsIconData icon;
  final FsTagTone tone;

  /// The pill is at least this tall; a label that wraps makes it taller.
  static const double minHeight = 26;

  @override
  Widget build(BuildContext context) {
    final color = switch (tone) {
      FsTagTone.accent =>
        Theme.of(context).brightness == Brightness.dark
            ? FsColors.of(context).accent
            : FsColors.ringValue,
      FsTagTone.gold => FsColors.ringValue,
    };
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: minHeight),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: color),
          borderRadius: const BorderRadius.all(Radius.circular(minHeight / 2)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ExcludeSemantics(child: FsIcon(icon, size: 14, color: color)),
              const SizedBox(width: 5),
              // Flexible, so a long label at a large text size wraps inside
              // the pill instead of running off the screen.
              Flexible(
                child: Text(
                  label.toUpperCase(),
                  semanticsLabel: label,
                  style: FsText.tag.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
