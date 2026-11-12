# Prototype captures for step S1 (Today and the day's reading)

These eight pictures show the HTML prototype at 390×844, the size of the Flutter golden images in `mobile/test/features/today/goldens/`. They are for comparing Today and the devotional reading with the prototype by eye.

**They are not part of the 2026-11-10 review.** The review's own reference screenshots are in `docs/reviews/2026-11-10-prototype-to-flutter/reference/` and are dark only. These were captured by Claude on 2026-11-12, so both themes can be compared at the same size and scroll position.

| File | What it shows | Flutter golden |
|---|---|---|
| `v254-today-dark.png`, `v254-today-light.png` | Today as it opens | `today_dark.png`, `today_light.png` |
| `v254-today-tasks-dark.png`, `v254-today-tasks-light.png` | Today scrolled to the day's boxes | `today_boxes_dark.png`, `today_boxes_light.png` |
| `v254-today-devo-dark.png`, `v254-today-devo-light.png` | The reading as it opens | `reading_dark.png`, `reading_light.png` |
| `v254-today-devo-end-dark.png`, `v254-today-devo-end-light.png` | The end of the reading, Amen unlocked | `reading_end_dark.png`, `reading_end_light.png` |

## What they are a picture of

- **Prototype file:** `versions/app-v254.html` on branch `app/v241-bold` at commit `3ff4a6f`. That is the layout and navigation baseline of decision Q1.
- **Runtime:** the repository's local stand-in, `dev/mock-claude.js`, with no saved data: a first-run member called "Dev User".
- **Browser:** headless Google Chrome 157 on Windows 11, one device pixel per point.
- **Date:** the day the capture ran, Thursday, November 12, with that day's mission line and reading. The Flutter goldens are drawn for the same date.

## Where the content differs, and why

The layout is what is being compared. Some of the words differ on purpose:

- **Box titles.** The mock runtime has its own older task list ("Daily Check-In", "Drink 3 Liters of Water"). The app bundles `seed/tasks.json` ("Rally Call", "Hydrate").
- **The reading.** v254 carries a newer set of readings inside its HTML, with a headline, an "In Jesus" section and reworded prayers. The app bundles `seed/devotionals.json` from `main`, as prompt P05 says, which has neither.
- **The translation.** The prototype shows the verse in the ESV. The app opens it in the BSB, with an ESV tab (decision Q7).
- **Points.** The prototype shows "+2 pts" on each box and a "Week pts" line. The app hides point values unless the preview switch in Settings is on (decision Q5), and shows no total.
- **Left out of S1.** First orders, "Your two" habits, the campaign card, the Stand Firm creed card and "Write it down".

## How to make them again

```
python3 dev/capture_prototype_reference.py --out docs/design/reference/s1-today --pages "today,today@#tasks,today+devo,today+devo@end"
```

The script reads the prototype file out of git, so the branch does not need to be checked out. It needs Chrome or Edge, and a network connection for the prototype's web fonts. The date in the pictures is the day it runs.

## What they do not show

The mock runtime is not a backend. These pictures are evidence of layout, type and color only, never of data access, sharing, identity or saving.
