# Design system

**Status: the foundation is implemented; most shared components are still planned.** Build step S0 put the colors, type, spacing, the shell and four components under `mobile/lib/src/design/`. Every row below says which it is. Each later step that builds a planned component changes its row here in the same pull request.

The values were read from the prototype as it renders, not from its stylesheet by eye: `versions/app-v254.html` on branch `app/v241-bold` at `3ff4a6f` (decision Q1), rendered at 390×844 and inspected in both themes. The theme rules, the font list and the hero photograph are identical in `index.html` on `main`. Where this page and the prototype disagreed, the prototype won.

Reference pictures: the [review's screenshots](../reviews/2026-11-10-prototype-to-flutter/06-SCREENS-AND-UI.md) (dark only) and the [S0 captures](reference/s0-shell/README.md) of v254 in dark and light.

## Colors that change with the theme

Implemented in `mobile/lib/src/design/fs_colors.dart` (`FsColors.dark`, `FsColors.light`) and written out as two explicit color schemes in `fs_theme.dart`. Nothing is derived from a seed color.

| Token | In code | Dark | Light |
|---|---|---|---|
| Background | `background` | `#151719` | `#f3f0eb` |
| Surface / raised surface | `surface` / `surfaceRaised` | `#222528` / `#303337` | `#ffffff` / `#e4dfd8` |
| Text / muted text | `text` / `textMuted` | `#f2f0eb` / `#b6b3ae` | `#292521` / `#68615b` |
| Hairline | `hairline` | `#414448` | `#d1c9c0` |
| Accent / text on accent | `accent` / `onAccent` | `#f17b32` / `#171411` | `#ae4514` / `#ffffff` |
| Highlight ("brass") | `highlight` | `#ff9a55` | `#9d3e13` |
| Danger | `danger` | `#f08076` | `#a4281c` |

## Colors that are the same in both themes

The brand bar, the hero header and the tab bar are dark on a light page too, and the primary button keeps one orange. These were missing from this page before S0. Implemented as constants on `FsColors`.

| Token | In code | Value | Used for |
|---|---|---|---|
| Night | `night` | `#101214` | Brand bar and tab bar background |
| Brand bar rule | `brandBarRule` | `#333333` | Line under the brand bar |
| Tab bar rule | `tabBarRule` | `#383a3c` | Line above the tab bar |
| Brand mark | `brandMark` | `#f17b32` | The shield in the brand bar |
| Gold | `gold` | `#e87328` | Primary button, the rule under the hero, the profile button's ring |
| Text on gold | `onGold` | `#151719` | Primary button label |
| Hero ink | `heroInk` | `#f5f1eb` | Hero title; "Forged & Sent" in the brand bar |
| Hero subtle | `heroSubtle` | `#e3ddd4` | The line under the hero title |
| Hero kicker | `heroKicker` | `#f4aa76` | The small caps line above the hero title |
| Hero button ring / ink | `heroButtonRing` / `heroButtonInk` | `#d0c2a0` / `#efe4c8` | The round hero buttons |
| Hero scrim | `heroScrimStart` → `heroScrimEnd` | `#0c0d0e` at 92% → 48% | Dark wash over the photograph, left to right |
| Hero ridges | `heroRidgeFar` / `heroRidgeNear` | `#2a241b` / `#14120e` | The two drawn ridges along the bottom of the hero |
| Tab inactive / active | `tabInactive` / `tabActive` | `#aaa9a5` / `#ff8840` | Tab icons, labels and the bar above the current tab |

**Changed in S0, because the prototype differs from what this page said:**

- **Primary button:** `#e87328` with `#151719` text in both themes. This page implied the accent and text-on-accent pair, which would have made it `#ae4514` with white text in light.
- **Journal button ring:** the highlight color of the theme (`#ff9a55` dark, `#9d3e13` light), with the glyph in the accent color.
- **Profile button:** raised surface of the theme with a gold ring.

## Spacing, radius and sizes

Implemented in `mobile/lib/src/design/fs_tokens.dart`.

| Token | Value |
|---|---|
| Page margin (`FsSpacing.page`) | 16 |
| Space between blocks (`FsSpacing.block`) | 22 |
| Space under the last block (`FsSpacing.pageBottom`) | 28 |
| Card padding (`FsSpacing.card`) | 14 |
| Hero padding (`heroTop`, `heroBottom`) and line gap (`heroGap`) | 18, 20 and 10 |
| Radius (`FsRadius`) | 8 base (buttons); 10 cards; 12 large cards and dialogs; full round for icon buttons |
| Brand bar / tab bar height (`FsSizes`) | 34 / 60, before the status-bar and home-indicator insets |
| Bar above the current tab | 3 |
| Button height | 48; mini 40 |

## Type

Implemented in `mobile/lib/src/design/fs_typography.dart` (`FsFonts`, `FsText`).

| Role | Typeface | Style in code |
|---|---|---|
| Headings and labels (uppercase, tracked) | Saira Condensed 500–800 | `heroTitleLarge` 38/800, `heroTitle` 32/800, `heroSubtitle` 16.5/600, `kicker` 12.5/600, `labelCaps` 14/600, `button` 14/700, `buttonMini` 12.5/600, `tabLabel` 10.5/600, `brandBar` 12.5/700 |
| Body | IBM Plex Sans 400–600 | `body` 14, `bodySmall` 12.5, `sectionTitle` 15/600 |
| Scripture | Merriweather italic | `scripture` 15 |
| Wordmark on the opening screen | Saira Stencil One | `wordmark`; bundled, not used by any screen yet |

**Changed in S0:** the brand bar's "Forged & Sent" is Saira Condensed 700, as in the prototype. This page gave Saira Stencil One as the brand wordmark; the prototype uses the stencil face only on its opening screen.

All four families are bundled as assets under `mobile/assets/fonts/`. Nothing is fetched at runtime. Every family is under the SIL Open Font License 1.1, and its `OFL.txt` is bundled beside it. Source commits and SHA-256 values: `mobile/assets/SOURCES.md`. Merriweather and IBM Plex Sans are the last static releases, not the current variable ones; Merriweather's current file is over the repository's 2 MB limit for a binary asset.

CSS `text-transform: uppercase` has no Flutter equivalent. Widgets that use a caps style uppercase their own text and give screen readers the text as written.

## Hero photograph

`mobile/assets/images/hero_mountain.jpg`, with a 2.0x variant. It is the prototype's `--mtn-photo`, 750×1333, unchanged at 2.0x and scaled down for 1x. There is no 3.0x: the source is too small. **Its origin and licence are not recorded anywhere in this repository**; that has to be settled before the app is distributed (see the board).

## Conventions

Other measurable conventions: tap targets mostly 44–52 px; body text mostly 12–15 px; `safe-area-inset` used 32 times; reduced-motion handled; breakpoints only below 430 px (phone-only layout); Dark, Light and Auto themes.

In Flutter so far: the app follows the phone's dark or light setting (there is no Dark / Light / Auto switch yet); text follows the phone's text size, and the shell is tested without overflow at 1.3× and 2×; the brand bar and tab bar cover the status-bar and home-indicator insets.

## Shared components

| Component | Used by | Status | File |
|---|---|---|---|
| `FsTheme` (two `ColorScheme`s, `TextTheme`, spacing and radius constants) | Everything | Implemented | `mobile/lib/src/design/fs_theme.dart`, `fs_colors.dart`, `fs_typography.dart`, `fs_tokens.dart` |
| `FsShell`: brand bar plus a six-destination tab bar with a top indicator | All top-level pages | Implemented | `mobile/lib/src/design/fs_shell.dart` |
| `FsHeroHeader`: mountain photograph, kicker, title, round action buttons | Today, Fuel, Train, Board, Campaign, Settings, Devotional | Implemented. The round buttons are drawn but do nothing yet | `mobile/lib/src/design/fs_hero_header.dart` |
| `FsCard` | Everything | Implemented | `mobile/lib/src/design/fs_card.dart` |
| `FsLabelCaps` | Everything | Implemented | `mobile/lib/src/design/fs_label_caps.dart` |
| `FsSectionHead` | Everything | Planned | — |
| `FsButton` (primary, ghost, mini) | Everything | Implemented | `mobile/lib/src/design/fs_button.dart` |
| `FsIconAction` | Everything | Planned. The hero's round buttons are private to `FsHeroHeader` for now | — |
| `FsIcon` and `FsIcons`: the prototype's line icons, drawn from its own SVG paths | Tab bar, hero buttons, brand bar | Implemented (added in S0; no icon package is used) | `mobile/lib/src/design/fs_icons.dart` |
| `FsBoxRow`: checkbox, title, sub-line, points, chevron | Today, first orders, habits | Planned | — |
| `FsProgressRing`, `FsMeter` | Today, Fuel | Planned | — |
| `FsSegmented` | Board, Settings, Profile | Planned | — |
| `FsDialog`, `FsSheet` | About 40 dialogs | Planned | — |
| `FsScripture` block | Devotional, workout prayer, footers | Planned | — |
| `FsEmptyState` (dashed outline) | Rally, journal, boards | Planned | — |

## Golden images

`mobile/test/app/goldens/` holds the shell at 390×844: Today and Walk, dark and light. The maintainer approved them beside the prototype on 2026-11-11, and they are the baseline. They are compared on Windows only, because text is drawn slightly differently on each operating system. No CI lane checks them yet.

## Rules

- A feature widget never introduces its own color, font or spacing value. Add it here and in `mobile/lib/src/design/` first.
- CI fails a pull request that changes `mobile/lib/src/design/` without changing this page.
