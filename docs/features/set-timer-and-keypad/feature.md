---
kind: feature-spec
feature_id: FNS-009
status: proposed
risk: low
owner: maintainer
source_ref: claude/review-contracts-setup-and-check-in
source_sha: 49104c9d801b853d0dfc14e0c4d26c4ab2101ed3
approved_by: none
test_plan: timer phases with a controlled clock (count, hold, switch, hold), stop early logs the seconds held, a timed round is ticked when its timer ends, the keypad writes reps and weight and Log set carries the weight to the next set, a hardware keyboard still types into the boxes
verified_tests: none
implementation_paths: none
verification: none
---

# Set timer, timed rounds and the in-app keypad (proposed)

**For the Flutter build: not approved here.** The maintainer approved three mockups in his session of 2026-11-24 and had them built in the HTML prototype as v257 (branch `app/v241-bold`, `versions/app-v257.html`). This page records what he approved so the Flutter track can plan it. Take the rules from this page, **not from the prototype's code**.

## User outcome

A man logging a workout does not watch a clock or fight the phone keyboard.

1. **Timer on each timed set.** An exercise written in seconds ("2 x 25 sec") has a Start on every set. Start gives a 3-second count with a tick on each second, then counts the set down, and chimes at zero. The seconds are logged, the set is ticked, and the rest timer starts.
2. **Timed rounds.** A move written as "2 rounds: 30 sec hold or 6 slow reps per side" shows a row for each round, in place of one Done box. One Start runs both sides: count, left side, chime, switch count, right side, chime. He can tick a round without the timer when he did the slow reps. There is no rest bar between these moves.
3. **Keypad.** Tapping a reps or weight box opens the app's own keypad, not the phone's. It shows the set and what he did last time, shortcuts ("Same as last"; minus 1 and plus 1 for reps; minus 5, plus 5 and plus 10 for weight), and one main button: "Next: weight", then "Log set". Log set ticks the set, starts the rest timer, and opens the next set with the weight carried over.

## Acceptance and failure cases

- **Stop early** during a hold logs the seconds he held. **Cancel** during the first count logs nothing.
- **Sound.** The chime may not play when the phone is silenced; the screen shows the change as well, so sound is never the only signal.
- **Screen.** The screen is asked to stay awake while a timer runs; a refusal changes nothing else.
- **Keyboards and screen readers.** The boxes stay real fields: a hardware keyboard types into them, and every keypad key is a labeled button.
- **Bodyweight lifts** show reps only, with the optional added weight. **Timed sets** can still be typed by hand.
- **Must not change:** what a set stores, PR and volume rules, and the rest timer's own buttons.

**Open, not decided:** whether warm-up holds get the same count and chime; whether interval circuits ("30 sec on / 30 sec off") get a timer; smaller weight jumps (2.5 lb); the keypad on other number boxes (weigh-in, steps, water).

## Boundaries and evidence

- Related work-board rows under Later: "Rest timer alerts at zero" (needs the notification-permission decision; this page does not answer it) and "Whether a lift needs a weight comes from `seed/`".
- Flutter contract to amend when built: [FNS-004](../workout-logging/feature.md).
- Prototype check of 2026-11-24: run in a local preview with the stand-in runtime and a simulated clock. NOT VERIFIED: sound, a phone, the claude.ai runtime, anything in Flutter.

## Tasks

1. Maintainer: approve or change this page for the Flutter build, and answer the open items.
2. Timer state machine with tests on a controlled clock.
3. Timed-set and timed-round rows.
4. Keypad, with a hardware-keyboard test.
