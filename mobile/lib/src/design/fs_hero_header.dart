import 'package:flutter/material.dart';

import 'fs_colors.dart';
import 'fs_icons.dart';
import 'fs_label_caps.dart';
import 'fs_tokens.dart';
import 'fs_typography.dart';

/// The round buttons a hero header can show, in the prototype's order.
enum FsHeroActionKind { search, help, journal, tags, profile }

/// One round button in a hero header.
///
/// With a null [onPressed] the button is drawn but does nothing and is hidden
/// from screen readers. That is every button in step S0: their behavior comes
/// with the features they open.
@immutable
class FsHeroAction {
  const FsHeroAction(this.kind, {required this.label, this.onPressed});

  final FsHeroActionKind kind;

  /// What a screen reader says, for example "New journal entry".
  final String label;

  final VoidCallback? onPressed;
}

/// The header of a top-level page: the mountain photograph under a dark
/// wash, a small caps line, the page title and round action buttons.
///
/// It looks the same in both themes, as it does in the prototype
/// (`header.hero`).
class FsHeroHeader extends StatelessWidget {
  const FsHeroHeader({
    super.key,
    required this.title,
    this.kicker,
    this.subtitle,
    this.actions = const <FsHeroAction>[],
    this.large = false,
  });

  /// The bundled photograph, with a 2.0x variant beside it.
  static const String photoAsset = 'assets/images/hero_mountain.jpg';

  final String title;

  /// The small caps line above the title.
  final String? kicker;

  /// The line under the title.
  final String? subtitle;

  final List<FsHeroAction> actions;

  /// Today's layout: a larger title, with the buttons on their own row
  /// under the small caps line.
  final bool large;

  @override
  Widget build(BuildContext context) {
    final kickerText = kicker == null
        ? null
        : FsLabelCaps(
            kicker!,
            style: FsText.kicker,
            color: FsColors.heroKicker,
          );
    final buttons = actions.isEmpty ? null : _HeroActions(actions: actions);

    final List<Widget> lines;
    if (large) {
      lines = <Widget>[
        if (kickerText != null) kickerText,
        if (kickerText != null && buttons != null) const SizedBox(height: 12),
        if (buttons != null)
          Align(alignment: Alignment.centerRight, child: buttons),
      ];
    } else {
      lines = <Widget>[
        if (kickerText != null || buttons != null)
          Row(
            children: <Widget>[
              Expanded(child: kickerText ?? const SizedBox.shrink()),
              if (buttons != null) ...<Widget>[
                const SizedBox(width: 12),
                buttons,
              ],
            ],
          ),
      ];
    }

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(
        FsSpacing.page,
        FsSpacing.heroTop,
        FsSpacing.page,
        FsSpacing.heroBottom,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ...lines,
          if (lines.isNotEmpty) const SizedBox(height: FsSpacing.heroGap),
          Semantics(
            header: true,
            child: Text(
              title.toUpperCase(),
              semanticsLabel: title,
              style: (large ? FsText.heroTitleLarge : FsText.heroTitle)
                  .copyWith(color: FsColors.heroInk),
            ),
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: FsSpacing.heroGap),
            Text(
              subtitle!.toUpperCase(),
              semanticsLabel: subtitle,
              style: FsText.heroSubtitle.copyWith(color: FsColors.heroSubtle),
            ),
          ],
        ],
      ),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        ClipRect(
          child: Stack(
            children: <Widget>[
              const Positioned.fill(child: _HeroBackdrop()),
              content,
            ],
          ),
        ),
        const ColoredBox(
          color: FsColors.gold,
          child: SizedBox(height: FsSizes.heroRule),
        ),
      ],
    );
  }
}

/// Photograph, dark wash, then the two drawn ridges along the bottom.
class _HeroBackdrop extends StatelessWidget {
  const _HeroBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.asset(
          FsHeroHeader.photoAsset,
          fit: BoxFit.cover,
          // The prototype positions the photo at "center 44%".
          alignment: const Alignment(0, -0.12),
          excludeFromSemantics: true,
          errorBuilder: (context, error, stackTrace) =>
              const ColoredBox(color: FsColors.night),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[FsColors.heroScrimStart, FsColors.heroScrimEnd],
            ),
          ),
        ),
        // The prototype's `.hero-mtn`: the bottom 62% of the header.
        const FractionallySizedBox(
          alignment: Alignment.bottomCenter,
          heightFactor: 0.62,
          child: CustomPaint(painter: _RidgePainter()),
        ),
      ],
    );
  }
}

/// The prototype's two mountain silhouettes, drawn in a 300x120 box that is
/// stretched to the space it is given.
class _RidgePainter extends CustomPainter {
  const _RidgePainter();

  // M0 120V70l30-22 22 14 40-38 30 26 26-18 44 40 30-20 34 24 44-30v74z
  static const List<Offset> _far = <Offset>[
    Offset(30, -22),
    Offset(22, 14),
    Offset(40, -38),
    Offset(30, 26),
    Offset(26, -18),
    Offset(44, 40),
    Offset(30, -20),
    Offset(34, 24),
    Offset(44, -30),
  ];

  // M0 120V92l40-14 34 10 46-24 40 22 38-12 52 18 50-16v44z
  static const List<Offset> _near = <Offset>[
    Offset(40, -14),
    Offset(34, 10),
    Offset(46, -24),
    Offset(40, 22),
    Offset(38, -12),
    Offset(52, 18),
    Offset(50, -16),
  ];

  static Path _ridge(double startY, List<Offset> steps) {
    final path = Path()
      ..moveTo(0, 120)
      ..lineTo(0, startY);
    for (final step in steps) {
      path.relativeLineTo(step.dx, step.dy);
    }
    return path
      ..lineTo(300, 120)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 300, size.height / 120);
    canvas.drawPath(_ridge(70, _far), Paint()..color = FsColors.heroRidgeFar);
    canvas.drawPath(_ridge(92, _near), Paint()..color = FsColors.heroRidgeNear);
  }

  @override
  bool shouldRepaint(_RidgePainter oldDelegate) => false;
}

class _HeroActions extends StatelessWidget {
  const _HeroActions({required this.actions});

  final List<FsHeroAction> actions;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < actions.length; i++) {
      final action = actions[i];
      if (i > 0) {
        // The journal button stands a little apart from what follows it.
        final previous = actions[i - 1].kind;
        children.add(
          SizedBox(width: previous == FsHeroActionKind.journal ? 16 : 10),
        );
      }
      children.add(_HeroRoundButton(action: action));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: children);
  }
}

class _HeroRoundButton extends StatelessWidget {
  const _HeroRoundButton({required this.action});

  final FsHeroAction action;

  @override
  Widget build(BuildContext context) {
    final colors = FsColors.of(context);

    final double size;
    final Color ring;
    final Color fill;
    final Widget glyph;
    switch (action.kind) {
      case FsHeroActionKind.search:
        size = 30;
        ring = FsColors.heroButtonRing;
        fill = const Color(0x00000000);
        glyph = const FsIcon(
          FsIcons.search,
          size: 16,
          color: FsColors.heroButtonInk,
        );
      case FsHeroActionKind.help:
        size = 30;
        ring = FsColors.heroButtonRing;
        fill = const Color(0x00000000);
        glyph = Text(
          'i',
          textScaler: TextScaler.noScaling,
          style: FsText.scripture.copyWith(
            fontSize: 16,
            height: 1,
            color: FsColors.heroButtonInk,
          ),
        );
      case FsHeroActionKind.journal:
        size = 34;
        ring = colors.highlight;
        fill = const Color(0x00000000);
        glyph = FsIcon(FsIcons.journal, size: 20, color: colors.accent);
      case FsHeroActionKind.tags:
        size = 34;
        ring = FsColors.heroButtonRing;
        fill = const Color(0x00000000);
        glyph = const FsIcon(
          FsIcons.bell,
          size: 17,
          color: FsColors.heroButtonInk,
        );
      case FsHeroActionKind.profile:
        size = 40;
        ring = FsColors.gold;
        fill = colors.surfaceRaised;
        glyph = FsIcon(FsIcons.person, size: 20, color: colors.text);
    }

    final circle = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fill,
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 1.5),
      ),
      child: glyph,
    );

    final onPressed = action.onPressed;
    if (onPressed == null) {
      return ExcludeSemantics(child: circle);
    }
    return Semantics(
      button: true,
      label: action.label,
      excludeSemantics: true,
      child: InkResponse(onTap: onPressed, radius: size / 2 + 6, child: circle),
    );
  }
}
