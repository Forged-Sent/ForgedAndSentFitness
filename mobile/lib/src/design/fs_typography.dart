import 'package:flutter/painting.dart';

/// The four bundled typefaces. Nothing is fetched at runtime.
abstract final class FsFonts {
  /// Headings and labels: uppercase, tracked.
  static const String display = 'Saira Condensed';

  /// The splash wordmark in the prototype. Bundled; not used by the shell.
  static const String stencil = 'Saira Stencil One';

  /// Body text.
  static const String body = 'IBM Plex Sans';

  /// Scripture. Only the italic is bundled.
  static const String scripture = 'Merriweather';
}

/// Text styles by role. Sizes, weights, tracking and line heights are the
/// prototype's computed values at 390x844. Colors are applied where a style
/// is used, because most of them change with the theme.
///
/// CSS `text-transform: uppercase` has no Flutter equivalent, so the widgets
/// that use the caps styles uppercase their own text.
abstract final class FsText {
  /// "FORGED & SENT" in the brand bar.
  static const TextStyle brandBar = TextStyle(
    fontFamily: FsFonts.display,
    fontWeight: FontWeight.w700,
    fontSize: 12.5,
    letterSpacing: 2.25,
    height: 1.4,
  );

  /// The splash wordmark. Defined for later use.
  static const TextStyle wordmark = TextStyle(
    fontFamily: FsFonts.stencil,
    fontWeight: FontWeight.w400,
    fontSize: 28,
    letterSpacing: 1.4,
    height: 1.1,
  );

  /// The small caps line above a hero title.
  static const TextStyle kicker = TextStyle(
    fontFamily: FsFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 12.5,
    letterSpacing: 1.5,
    height: 1.4,
  );

  /// Today's hero title.
  static const TextStyle heroTitleLarge = TextStyle(
    fontFamily: FsFonts.display,
    fontWeight: FontWeight.w800,
    fontSize: 38,
    letterSpacing: 0.76,
    height: 0.95,
  );

  /// Every other page's hero title.
  static const TextStyle heroTitle = TextStyle(
    fontFamily: FsFonts.display,
    fontWeight: FontWeight.w800,
    fontSize: 32,
    letterSpacing: 0.64,
    height: 0.95,
  );

  /// The line under the hero title.
  static const TextStyle heroSubtitle = TextStyle(
    fontFamily: FsFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 16.5,
    letterSpacing: 0.495,
    height: 1.2,
  );

  /// Uppercase tracked label ([FsLabelCaps]).
  static const TextStyle labelCaps = TextStyle(
    fontFamily: FsFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: 1.68,
    height: 1.4,
  );

  /// Primary and ghost buttons.
  static const TextStyle button = TextStyle(
    fontFamily: FsFonts.display,
    fontWeight: FontWeight.w700,
    fontSize: 14,
    letterSpacing: 1.4,
    height: 1.4,
  );

  /// Mini buttons.
  static const TextStyle buttonMini = TextStyle(
    fontFamily: FsFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 12.5,
    letterSpacing: 1.25,
    height: 1.4,
  );

  /// Tab bar labels.
  static const TextStyle tabLabel = TextStyle(
    fontFamily: FsFonts.display,
    fontWeight: FontWeight.w600,
    fontSize: 10.5,
    letterSpacing: 0.21,
    height: 1.4,
  );

  /// The initial or glyph in the round profile button.
  static const TextStyle avatar = TextStyle(
    fontFamily: FsFonts.display,
    fontWeight: FontWeight.w700,
    fontSize: 14,
    height: 1.4,
  );

  /// A card's title.
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: FsFonts.body,
    fontWeight: FontWeight.w600,
    fontSize: 15,
    height: 1.4,
  );

  static const TextStyle body = TextStyle(
    fontFamily: FsFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.4,
  );

  /// Notes under a card's content.
  static const TextStyle bodySmall = TextStyle(
    fontFamily: FsFonts.body,
    fontWeight: FontWeight.w400,
    fontSize: 12.5,
    height: 1.4,
  );

  /// Scripture and the "i" of the help button.
  static const TextStyle scripture = TextStyle(
    fontFamily: FsFonts.scripture,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w400,
    fontSize: 15,
    height: 1.45,
  );
}
