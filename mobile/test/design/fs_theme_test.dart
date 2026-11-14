import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forged_and_sent/src/design/fs_colors.dart';
import 'package:forged_and_sent/src/design/fs_theme.dart';
import 'package:forged_and_sent/src/design/fs_typography.dart';

/// The values here are the design system page's tables, written out again
/// on purpose: a changed token has to be changed in both places.
void main() {
  test('dark theme holds the prototype tokens', () {
    const c = FsColors.dark;
    expect(c.background, const Color(0xFF151719));
    expect(c.surface, const Color(0xFF222528));
    expect(c.surfaceRaised, const Color(0xFF303337));
    expect(c.text, const Color(0xFFF2F0EB));
    expect(c.textMuted, const Color(0xFFB6B3AE));
    expect(c.hairline, const Color(0xFF414448));
    expect(c.accent, const Color(0xFFF17B32));
    expect(c.onAccent, const Color(0xFF171411));
    expect(c.highlight, const Color(0xFFFF9A55));
    expect(c.danger, const Color(0xFFF08076));
  });

  test('light theme holds the prototype tokens', () {
    const c = FsColors.light;
    expect(c.background, const Color(0xFFF3F0EB));
    expect(c.surface, const Color(0xFFFFFFFF));
    expect(c.surfaceRaised, const Color(0xFFE4DFD8));
    expect(c.text, const Color(0xFF292521));
    expect(c.textMuted, const Color(0xFF68615B));
    expect(c.hairline, const Color(0xFFD1C9C0));
    expect(c.accent, const Color(0xFFAE4514));
    expect(c.onAccent, const Color(0xFFFFFFFF));
    expect(c.highlight, const Color(0xFF9D3E13));
    expect(c.danger, const Color(0xFFA4281C));
  });

  test('the bars, hero and primary button are one set for both themes', () {
    expect(FsColors.night, const Color(0xFF101214));
    expect(FsColors.gold, const Color(0xFFE87328));
    expect(FsColors.onGold, const Color(0xFF151719));
    expect(FsColors.heroInk, const Color(0xFFF5F1EB));
    expect(FsColors.heroKicker, const Color(0xFFF4AA76));
    expect(FsColors.tabInactive, const Color(0xFFAAA9A5));
    expect(FsColors.tabActive, const Color(0xFFFF8840));
  });

  for (final (name, theme, colors, brightness)
      in <(String, ThemeData, FsColors, Brightness)>[
        ('dark', FsTheme.dark, FsColors.dark, Brightness.dark),
        ('light', FsTheme.light, FsColors.light, Brightness.light),
      ]) {
    test('$name color scheme is written out from the tokens', () {
      final scheme = theme.colorScheme;
      expect(theme.brightness, brightness);
      expect(scheme.brightness, brightness);
      expect(scheme.primary, colors.accent);
      expect(scheme.onPrimary, colors.onAccent);
      expect(scheme.secondary, colors.highlight);
      expect(scheme.error, colors.danger);
      expect(scheme.surface, colors.background);
      expect(scheme.onSurface, colors.text);
      expect(scheme.onSurfaceVariant, colors.textMuted);
      expect(scheme.surfaceContainer, colors.surface);
      expect(scheme.surfaceContainerHigh, colors.surfaceRaised);
      expect(scheme.outline, colors.hairline);
      expect(theme.scaffoldBackgroundColor, colors.background);
      // The olive of the old seeded theme is gone.
      expect(scheme.primary, isNot(const Color(0xFF6B7C43)));
      // The tokens travel with the theme for widgets to read.
      expect(theme.extension<FsColors>(), same(colors));
    });

    test('$name text uses the bundled typefaces', () {
      final text = theme.textTheme;
      expect(text.bodyMedium?.fontFamily, FsFonts.body);
      expect(text.bodyMedium?.color, colors.text);
      expect(text.bodySmall?.color, colors.textMuted);
      expect(text.titleMedium?.fontFamily, FsFonts.body);
      expect(text.labelMedium?.fontFamily, FsFonts.display);
    });
  }

  test('text styles carry the prototype sizes', () {
    expect(FsFonts.display, 'Saira Condensed');
    expect(FsFonts.stencil, 'Saira Stencil One');
    expect(FsFonts.body, 'IBM Plex Sans');
    expect(FsFonts.scripture, 'Merriweather');

    expect(FsText.heroTitleLarge.fontSize, 38);
    expect(FsText.heroTitleLarge.fontWeight, FontWeight.w800);
    expect(FsText.heroTitle.fontSize, 32);
    expect(FsText.kicker.fontSize, 12.5);
    expect(FsText.kicker.letterSpacing, 1.5);
    expect(FsText.labelCaps.fontSize, 14);
    expect(FsText.labelCaps.fontWeight, FontWeight.w600);
    expect(FsText.button.fontWeight, FontWeight.w700);
    expect(FsText.tabLabel.fontSize, 10.5);
    expect(FsText.body.fontSize, 14);
    expect(FsText.scripture.fontStyle, FontStyle.italic);
    // The brand bar is set in the condensed face, as in the prototype.
    expect(FsText.brandBar.fontFamily, FsFonts.display);
    expect(FsText.wordmark.fontFamily, FsFonts.stencil);
  });

  test('moving between themes blends every token', () {
    final half = FsColors.dark.lerp(FsColors.light, 0.5);
    expect(half.background, isNot(FsColors.dark.background));
    expect(half.background, isNot(FsColors.light.background));
    expect(FsColors.dark.lerp(FsColors.light, 0).accent, FsColors.dark.accent);
    expect(FsColors.dark.lerp(FsColors.light, 1).accent, FsColors.light.accent);
    expect(
      FsColors.dark.copyWith(accent: const Color(0xFF000000)).accent,
      const Color(0xFF000000),
    );
    expect(FsColors.dark.copyWith().surface, FsColors.dark.surface);
  });
}
