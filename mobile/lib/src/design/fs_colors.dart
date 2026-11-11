import 'package:flutter/material.dart';

/// The Forged & Sent colors, read from the prototype's stylesheet
/// (`versions/app-v254.html` at `3ff4a6f`; the theme rules are identical in
/// `index.html` on `main`). Recorded in `docs/design/DESIGN-SYSTEM.md`.
///
/// Two groups:
/// - colors that change with the theme (page, cards, text, accent);
/// - colors of the brand bar, hero header and tab bar, which stay dark in
///   both themes.
@immutable
class FsColors extends ThemeExtension<FsColors> {
  const FsColors({
    required this.background,
    required this.surface,
    required this.surfaceRaised,
    required this.text,
    required this.textMuted,
    required this.hairline,
    required this.accent,
    required this.onAccent,
    required this.highlight,
    required this.danger,
  });

  /// Page background.
  final Color background;

  /// Card background.
  final Color surface;

  /// Raised surface: the profile button, pressed and selected areas.
  final Color surfaceRaised;

  final Color text;
  final Color textMuted;

  /// One-pixel borders and dividers.
  final Color hairline;

  final Color accent;
  final Color onAccent;

  /// The prototype's "brass": small caps labels and the journal button ring.
  final Color highlight;

  final Color danger;

  static const FsColors dark = FsColors(
    background: Color(0xFF151719),
    surface: Color(0xFF222528),
    surfaceRaised: Color(0xFF303337),
    text: Color(0xFFF2F0EB),
    textMuted: Color(0xFFB6B3AE),
    hairline: Color(0xFF414448),
    accent: Color(0xFFF17B32),
    onAccent: Color(0xFF171411),
    highlight: Color(0xFFFF9A55),
    danger: Color(0xFFF08076),
  );

  static const FsColors light = FsColors(
    background: Color(0xFFF3F0EB),
    surface: Color(0xFFFFFFFF),
    surfaceRaised: Color(0xFFE4DFD8),
    text: Color(0xFF292521),
    textMuted: Color(0xFF68615B),
    hairline: Color(0xFFD1C9C0),
    accent: Color(0xFFAE4514),
    onAccent: Color(0xFFFFFFFF),
    highlight: Color(0xFF9D3E13),
    danger: Color(0xFFA4281C),
  );

  // The same in both themes: the brand bar, hero header and tab bar are dark
  // on a light page too, and the primary button keeps one orange.

  /// Brand bar and tab bar background.
  static const Color night = Color(0xFF101214);

  /// Rule under the brand bar.
  static const Color brandBarRule = Color(0xFF333333);

  /// Rule above the tab bar.
  static const Color tabBarRule = Color(0xFF383A3C);

  /// The orange of the hero's bottom rule, the profile ring and the primary button.
  static const Color gold = Color(0xFFE87328);

  /// Text on the primary button.
  static const Color onGold = Color(0xFF151719);

  /// Title and wordmark on the dark chrome.
  static const Color heroInk = Color(0xFFF5F1EB);

  /// The line under the hero title.
  static const Color heroSubtle = Color(0xFFE3DDD4);

  /// The small caps line above the hero title.
  static const Color heroKicker = Color(0xFFF4AA76);

  /// Ring and glyph of the round hero buttons.
  static const Color heroButtonRing = Color(0xFFD0C2A0);
  static const Color heroButtonInk = Color(0xFFEFE4C8);

  /// The dark wash over the hero photograph, strongest on the left.
  static const Color heroScrimStart = Color(0xEB0C0D0E); // 92%
  static const Color heroScrimEnd = Color(0x7A0C0D0E); // 48%

  /// The two drawn ridges along the bottom of the hero.
  static const Color heroRidgeFar = Color(0xFF2A241B);
  static const Color heroRidgeNear = Color(0xFF14120E);

  static const Color tabInactive = Color(0xFFAAA9A5);
  static const Color tabActive = Color(0xFFFF8840);

  /// The shield in the brand bar.
  static const Color brandMark = Color(0xFFF17B32);

  static FsColors of(BuildContext context) =>
      Theme.of(context).extension<FsColors>() ?? dark;

  @override
  FsColors copyWith({
    Color? background,
    Color? surface,
    Color? surfaceRaised,
    Color? text,
    Color? textMuted,
    Color? hairline,
    Color? accent,
    Color? onAccent,
    Color? highlight,
    Color? danger,
  }) {
    return FsColors(
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceRaised: surfaceRaised ?? this.surfaceRaised,
      text: text ?? this.text,
      textMuted: textMuted ?? this.textMuted,
      hairline: hairline ?? this.hairline,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      highlight: highlight ?? this.highlight,
      danger: danger ?? this.danger,
    );
  }

  @override
  FsColors lerp(ThemeExtension<FsColors>? other, double t) {
    if (other is! FsColors) return this;
    return FsColors(
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceRaised: Color.lerp(surfaceRaised, other.surfaceRaised, t)!,
      text: Color.lerp(text, other.text, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      hairline: Color.lerp(hairline, other.hairline, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      highlight: Color.lerp(highlight, other.highlight, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}
