# Prototype captures for step S0 (the app shell)

These four pictures show the HTML prototype at 390×844, the size of the Flutter golden images. They are for comparing the Flutter shell with the prototype by eye.

**They are not part of the 2026-11-10 review.** The review's own reference screenshots are in `docs/reviews/2026-11-10-prototype-to-flutter/reference/` and are dark only. These were captured by Claude on 2026-11-11 so that the light theme has something to be compared with, and so the dark theme can be compared at the same size and scroll position.

| File | Page | Theme |
|---|---|---|
| `v254-today-dark.png` | Today | Dark |
| `v254-today-light.png` | Today | Light |
| `v254-walk-dark.png` | Walk | Dark |
| `v254-walk-light.png` | Walk | Light |

## What they are a picture of

- **Prototype file:** `versions/app-v254.html` on branch `app/v241-bold` at commit `3ff4a6f`. That is the layout and navigation baseline of decision Q1.
- **Runtime:** the repository's local stand-in, `dev/mock-claude.js`, with no saved data: a first-run member called "Dev User".
- **Browser:** headless Google Chrome 157 on Windows 11, one device pixel per point.
- **Date:** Today shows the day the capture ran (Wednesday, November 11) and that day's mission line. Both change daily.

## How to make them again

```
python3 dev/capture_prototype_reference.py
```

The script reads the prototype file out of git, so the branch does not need to be checked out. It needs Chrome or Edge, and a network connection for the prototype's web fonts. Run it with `--help` for other pages, another prototype file or another output folder.

## What they do not show

The mock runtime is not a backend. These pictures are evidence of layout, type and color only, never of data access, sharing, identity or saving.
