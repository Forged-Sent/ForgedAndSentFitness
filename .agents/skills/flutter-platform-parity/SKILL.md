---
name: flutter-platform-parity
description: Port or compare one HTML prototype screen against its Flutter version, covering behavior, layout, design tokens and reference screenshots. Use with flutter-vertical-slice when a task names a prototype view.
---
# Prototype parity
1. Read docs/knowledge/PROTOTYPE-PARITY.md for the prototype baseline commit, and the screen's row in docs/reviews/2026-11-10-prototype-to-flutter/06-SCREENS-AND-UI.md.
2. Inspect `index.html` at that baseline and name the real functions and states. Never invent prototype functions or treat an archived `versions/` file as current.
3. Record what the screen shows, what each control does, and its loading, empty, error and saved states. The `B` / `window.claude` adapter is not a backend model; do not port its storage paths, client scoring or owner checks.
4. Use the design tokens, typefaces and shared components listed in 06-SCREENS-AND-UI.md. Do not add a one-off color, font or spacing value in a feature widget.
5. Produce golden images at 390x844 in dark and light, and show each beside the matching prototype screenshot in the review's reference/ folder. A Flutter render cannot pixel-match a browser render; the maintainer approves the match by eye, and the approved golden becomes the baseline.
6. Check text scaling at 1.3x, Android system back, safe areas and the keyboard. Classify every difference as unintended drift, a platform or accessibility adaptation, or a design change that needs a decision.
7. Android and iOS are the targets. Record which were actually run; mark the rest NOT VERIFIED.
