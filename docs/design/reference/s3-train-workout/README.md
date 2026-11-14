# Prototype captures for step S3 (Train and workout logging)

These twelve pictures show the HTML prototype at 390×844, the size of the Flutter golden images in `mobile/test/features/workout/goldens/`. They are for comparing Train and the workout page with the prototype by eye.

**The Flutter golden images they are compared with are not approved.** They were drawn on 2026-11-13, after S1b was merged, for the maintainer to look at. The side-by-side sheets made from these pictures and the goldens are linked from the pull request; they are not in the repository, so no picture is stored twice.

**They are not part of the 2026-11-10 review.** They were captured by Claude on 2026-11-13.

| File | What it shows | Flutter golden |
|---|---|---|
| `v254-train-dark.png`, `v254-train-light.png` | Train's day card, scrolled to it | `train_dark.png`, `train_light.png` |
| `v254-week-dark.png`, `v254-week-light.png` | Train scrolled to "Your week" | `train_week_dark.png`, `train_week_light.png` |
| `v254-before-dark.png`, `v254-before-light.png` | The workout page before it is started | `workout_before_dark.png`, `workout_before_light.png` |
| `v254-prayer-dark.png`, `v254-prayer-light.png` | The workout prayer | `workout_prayer_dark.png`, `workout_prayer_light.png` |
| `v254-live-dark.png`, `v254-live-light.png` | Logging sets, scrolled to the first lift | `workout_live_dark.png`, `workout_live_light.png` |
| `v254-locked-dark.png`, `v254-locked-light.png` | The finished workout, locked | `workout_locked_dark.png`, `workout_locked_light.png` |

## What they are a picture of

- **Prototype file:** `versions/app-v254.html` on branch `app/v241-bold` at commit `3ff4a6f`. That is the layout and navigation baseline of decision Q1.
- **Runtime:** the repository's local stand-in, `dev/mock-claude.js`, with no saved data: a first-run member called "Dev User".
- **Browser:** headless Google Chrome on Windows 11, one device pixel per point.
- **Date:** the page's clock was set to **Monday, November 9, 2026, 6:00 PM**, the moment the Flutter goldens are drawn for. The prototype starts a new plan on the first day after the next rest day, so on a Monday the default plan starts that day and both show "Full Body A: Back Squat".
- **Plan:** the prototype's defaults, started by pressing "Start plan": Forged, Full Gym, Sabbath on Sunday, lifting Monday, Wednesday and Friday.
- **Sets:** the same numbers as in the goldens were typed into the same boxes: 5 × 135 and 5 reps for the live picture; 5 × 135, 5 × 140, 5 × 145 and 8 × 50 for the locked one.

## Where the two differ, and why

The layout is what is being compared. These differ on purpose:

- **Left out of S3 (prompt P07):** on Train, the weekly challenge buttons, "New to the gym", "Ready to protect", the calendar strip, "Move day", "Add your own workout", the week's collapse button, the charts and the plan form. On the workout page, the search and help buttons, Coach Gideon's guidance, the warm-up, "Add exercise", the "Alt" swap button, the muscle picture and video link, the cue line, "Add a note for next time", "Warm-up set" and "Add set", the superset group, the cool-down, the PR count and "Share".
- **Nothing about the body.** The prototype's "Before you lift" (sleep and stress), "On your last set, how many more could you have done?" and "After your workout" are not in the app: it stores and asks for nothing about the body.
- **The prayer has "Not now"** (decision Q11). The prototype has Amen only.
- **RPE and RIR.** The app shows "3 x 5 (RPE 7, rest 2 min)", as `seed/workouts.json` has it; the prototype strips the guidance and shows "3 x 5 (rest 2 min)". The maintainer decided on 2026-11-13 that the app shows it.
- **Pause.** The prototype's clock has a Pause button; the app's clock has none.
- **The clock's time.** The prototype's pictures show the seconds its script took; the goldens set the clock to 12:34 and 42:00.
- **Lines between exercises** are solid in the app and dashed in the prototype.
- **Today's row in the week** is tinted in the app; in the prototype it has the card's own color and the accent bar only.
- **Letter spacing.** The app's small caps lines are tracked a little wider than the prototype's. The goldens were drawn after S1b was merged, so they carry its change to letter spacing; S3 names no letter spacing of its own.

## How to make them again

The repository's `dev/capture_prototype_reference.py` opens a tab and takes a picture. These pictures need more than that: the page's clock set to a Monday, the default plan started, the workout opened, the prayer answered, numbers typed and the workout finished. Prompt P07 allows no new tooling, so the script that did it is not in the repository. It reuses `dev/capture_prototype_reference.py` for finding the browser, reading the prototype out of git and framing it, and adds a script that runs inside the page and only presses buttons a person would press. Adding that to `dev/capture_prototype_reference.py` belongs with the next change to that file.

## What they do not show

The mock runtime is not a backend. These pictures are evidence of layout, type and color only, never of data access, sharing, identity or saving.
