/// Spacing and corner radii, read from the prototype's computed layout at
/// 390x844. Recorded in `docs/design/DESIGN-SYSTEM.md`.
abstract final class FsSpacing {
  /// Left and right page margin, and the hero's side padding.
  static const double page = 16;

  /// Space between blocks on a page (hero to first card, card to card).
  static const double block = 22;

  /// Space below the last block on a page.
  static const double pageBottom = 28;

  /// Padding inside a card.
  static const double card = 14;

  /// Space between lines inside the hero header.
  static const double heroGap = 10;

  static const double heroTop = 18;
  static const double heroBottom = 20;
}

abstract final class FsRadius {
  /// Buttons and inputs.
  static const double base = 8;

  /// Cards.
  static const double card = 10;

  /// Large cards and dialogs.
  static const double cardLarge = 12;
}

abstract final class FsSizes {
  /// Brand bar height, before the status-bar inset.
  static const double brandBar = 34;

  /// Tab bar height, before the home-indicator inset.
  static const double tabBar = 60;

  /// The orange bar above the current tab.
  static const double tabIndicator = 3;

  static const double buttonHeight = 48;
  static const double miniButtonHeight = 40;

  /// The orange rule under the hero header.
  static const double heroRule = 1.5;
}
