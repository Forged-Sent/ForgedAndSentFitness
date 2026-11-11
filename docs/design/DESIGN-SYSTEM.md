# Design system

**Status: Planned.** Nothing on this page is implemented in Flutter yet. The values below were read from the prototype's stylesheet (`index.html` at `main` commit `94daa63`). Build step S0 implements them under `mobile/lib/src/design/` and must update this page in the same pull request: change the status, list the real file for each token group and component, and note any value that changed.

Reference screenshots: [review reference folder](../reviews/2026-11-10-prototype-to-flutter/06-SCREENS-AND-UI.md).

## Colors

| Token | Dark | Light |
|---|---|---|
| Background | `#151719` | `#f3f0eb` |
| Surface / raised surface | `#222528` / `#303337` | `#ffffff` / `#e4dfd8` |
| Text / muted text | `#f2f0eb` / `#b6b3ae` | `#292521` / `#68615b` |
| Hairline | `#414448` | `#d1c9c0` |
| Accent / text on accent | `#f17b32` / `#171411` | `#ae4514` / `#ffffff` |
| Highlight ("brass") | `#ff9a55` | `#9d3e13` |
| Danger | `#f08076` | `#a4281c` |
| Radius | 8 px base; 10 and 12 px on cards; full round for icon buttons | same |

## Type

| Role | Typeface |
|---|---|
| Brand wordmark | Saira Stencil One |
| Headings and labels (uppercase, tracked) | Saira Condensed 500–800 |
| Body | IBM Plex Sans 400–600 |
| Scripture | Merriweather italic |

All four families are bundled as assets. Nothing is fetched at runtime.

## Conventions

Other measurable conventions: tap targets mostly 44–52 px; body text mostly 12–15 px; `safe-area-inset` used 32 times; reduced-motion handled; breakpoints only below 430 px (phone-only layout); Dark, Light and Auto themes.

## Shared components

| Component | Used by | Status | File |
|---|---|---|---|
| `FsTheme` (two `ColorScheme`s, `TextTheme`, spacing and radius constants) | Everything | Planned | — |
| `FsShell`: brand bar plus a six-destination tab bar with a top indicator | All top-level pages | Planned | — |
| `FsHeroHeader`: mountain photograph, kicker, title, round action buttons | Today, Fuel, Train, Board, Campaign, Settings, Devotional | Planned | — |
| `FsCard`, `FsSectionHead`, `FsLabelCaps` | Everything | Planned | — |
| `FsButton` (primary, ghost, mini), `FsIconAction` | Everything | Planned | — |
| `FsBoxRow`: checkbox, title, sub-line, points, chevron | Today, first orders, habits | Planned | — |
| `FsProgressRing`, `FsMeter` | Today, Fuel | Planned | — |
| `FsSegmented` | Board, Settings, Profile | Planned | — |
| `FsDialog`, `FsSheet` | About 40 dialogs | Planned | — |
| `FsScripture` block | Devotional, workout prayer, footers | Planned | — |
| `FsEmptyState` (dashed outline) | Rally, journal, boards | Planned | — |

## Rules

- A feature widget never introduces its own color, font or spacing value. Add it here and in `mobile/lib/src/design/` first.
- CI fails a pull request that changes `mobile/lib/src/design/` without changing this page.
