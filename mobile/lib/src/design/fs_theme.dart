import 'package:flutter/material.dart';

import 'fs_colors.dart';
import 'fs_typography.dart';

/// The two Forged & Sent themes. Every color is written out; nothing is
/// derived from a seed color.
abstract final class FsTheme {
  static final ThemeData dark = _build(FsColors.dark, Brightness.dark);
  static final ThemeData light = _build(FsColors.light, Brightness.light);

  static ColorScheme _scheme(FsColors c, Brightness brightness) {
    return ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.highlight,
      onSecondary: c.onAccent,
      error: c.danger,
      onError: c.onAccent,
      surface: c.background,
      onSurface: c.text,
      onSurfaceVariant: c.textMuted,
      surfaceContainerLowest: c.background,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surface,
      surfaceContainerHigh: c.surfaceRaised,
      surfaceContainerHighest: c.surfaceRaised,
      outline: c.hairline,
      outlineVariant: c.hairline,
      // Material 3 tints raised surfaces with the primary color. The
      // prototype's surfaces are flat.
      surfaceTint: const Color(0x00000000),
    );
  }

  static ThemeData _build(FsColors c, Brightness brightness) {
    final scheme = _scheme(c, brightness);
    final body = FsText.body.copyWith(color: c.text);
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      fontFamily: FsFonts.body,
      textTheme: TextTheme(
        titleLarge: FsText.heroTitle.copyWith(color: c.text),
        titleMedium: FsText.sectionTitle.copyWith(color: c.text),
        bodyLarge: body,
        bodyMedium: body,
        bodySmall: FsText.bodySmall.copyWith(color: c.textMuted),
        labelLarge: FsText.button.copyWith(color: c.text),
        labelMedium: FsText.labelCaps.copyWith(color: c.text),
        labelSmall: FsText.buttonMini.copyWith(color: c.textMuted),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: c.background,
        foregroundColor: c.text,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: FsText.sectionTitle.copyWith(color: c.text),
      ),
      dividerColor: c.hairline,
      extensions: <ThemeExtension<dynamic>>[c],
    );
  }
}
