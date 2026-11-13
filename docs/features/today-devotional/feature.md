---
kind: feature-spec
feature_id: FNS-002
status: proposed
risk: medium
owner: maintainer
source_ref: claude/s1b-v254-readings
source_sha: 449b9473cc1ba4259f08fa241f4778482289490d
approved_by: none
test_plan: completion-event rules against the Drift and in-memory stores, close and reopen on a real SQLite file, streak rule, clock and midnight rollover, bundled content and ESV limit checks, Today and reading widget tests including screen-reader activation, golden images at 390x844 in dark and light, one emulator run of complete, kill, relaunch
verified_tests: mobile/test/features/today/drift_day_repository_test.dart, mobile/test/features/today/memory_day_repository_test.dart, mobile/test/features/today/streak_test.dart, mobile/test/features/today/today_page_test.dart, mobile/test/features/today/today_golden_test.dart, mobile/test/features/devotional/devotional_page_test.dart, mobile/test/features/devotional/bundled_content_test.dart, mobile/test/design/fs_components_test.dart, mobile/test/features/settings/settings_page_test.dart, mobile/test/features/no_firebase_import_test.dart, mobile/test/core/clock_test.dart, mobile/test/core/local_date_test.dart, mobile/test/storage/sqlite_available_test.dart, mobile/test/storage/corrupt_database_test.dart, mobile/integration_test/restart_1_complete_test.dart, mobile/integration_test/restart_2_verify_test.dart
implementation_paths: mobile/lib/src/features/today, mobile/lib/src/features/devotional, mobile/lib/src/features/settings, mobile/lib/src/core, mobile/lib/src/storage, mobile/lib/src/app/local_store.dart, mobile/lib/src/app/open_local_store.dart, mobile/assets/content
verification: see the pull request that adds this page for the commands and their output
---

# Today and the day's devotional, saved on the device

Build step S1 of the [prototype-to-Flutter review](../../reviews/2026-11-10-prototype-to-flutter/02-BUILD-PLAN.md), built from prompt [P05](../../reviews/2026-11-10-prototype-to-flutter/prompts/P05-S1-today-and-devotional.md). Step S1b, on 2026-11-12, replaced the readings' words with v254's and added the headline, the tags and the "In Jesus" section; see [The readings are v254's](#the-readings-are-v254s-decided-by-the-maintainer-on-2026-11-12). This page is a **proposed** contract drafted by Claude. Only the maintainer can approve it.

The decisions it rests on are the maintainer's, on the [Decisions](../../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md) page: Q5 (points), Q6 (streak), Q7 (translations), Q9 (day boundary), Q10 (use before sign-in), and the completion event's key (option A, 2026-11-11, in [the architecture page](../../reviews/2026-11-10-prototype-to-flutter/07-ARCHITECTURE.md), journey J1).

## User outcome

A man opens the app and sees today: the date, a mission line, a ring that shows how many of the day's boxes are done, and the boxes. He taps Daily Devotional and gets today's reading. When he has scrolled to the end he can say Amen. That checks the box, and it is still checked after the app is killed and opened again. He can undo it. Nothing leaves his phone.

## Acceptance and failure cases

**What he sees**

- **Today:** the date, the streak line, the mission line, the ring with Spirit, Body and Brotherhood counts and the streak, and seven boxes. Only Daily Devotional can be opened and checked. The other six are drawn faded, say "Not active yet", offer no tap, and are announced to a screen reader as not available.
- **The reading:** the month and its theme, the date, the series line where the reading has one, the reading's headline, its tag where it has one, and the month's line; then Open in prayer, Reading, In Jesus, Reflect and Act. Amen is disabled, and says what it waits for, until he is within 12 points of the end. The page is always at least 220 points taller than the screen, so there is always an end to reach. Amen returns him to Today. Once the box is checked the button reads "Amen. Undo".
- **Tags:** a reading may carry one of two tags under its headline, "Sent: take it to someone" or "Spirit-led". They are words to read. They have no tap, nothing is saved or counted from them, and a screen reader hears them as text.
- **Translations (Q7):** the verse opens in the BSB every time. A BSB / ESV tab switches it. The Crossway notice is shown wherever ESV text is. A verse with no ESV text bundled shows "ESV limit reached until we have a licence" on its ESV tab, and no ESV notice.
- **Points (Q5):** no point values, and no totals, anywhere. A switch in Settings, off by default, shows the prototype's value on each box under the words "Points: preview, not official".
- **Streak (Q6):** consecutive days with the devotional done. It ends today if today is done, otherwise yesterday: a day that is not over does not break it.

**What is saved, and how**

- A completion is an event with a client-generated id, which is its only key. What a box shows is a separate row for (owner, local day, box). Both are written in one transaction.
- An event states its target (done or not done). Sending the same event again changes nothing. A second tap for the state the box already has stores nothing.
- The later of two events is the one with the higher counter in that database, never the one with the later time on the phone.
- **Day boundary (Q9):** a completion belongs to the local date at the moment of the tap. Past local midnight Today is a new, unchecked day and shows the new date, also when the app was left open or is resumed.
- **Amen just after midnight (decided by the maintainer on 2026-11-12):** if midnight passes while a reading is open and he taps Amen before the page has changed, the tap is refused and nothing is saved, for the old day or for the new one. The page shows the new day's reading from the top with Amen locked again, and one line says why: "It is a new day. This is today's reading." He is not credited for a reading he has not opened, and yesterday's box is not checked late. The same line appears when the page changes by itself at midnight.
- **Tap time:** stored as an instant in UTC and, beside it, the phone's offset from UTC at that moment. Neither is folded into the other, so the instant stays exact and the time on his clock can still be shown.
- **Undo after the clock has moved:** an undo clears the box on the day the completion was recorded, also when the clock has moved to another day since.
- **Owner (Q10):** before sign-in the owner is a local profile, made on first launch. Each owner has his own database file. Adopting the profile at sign-in is not built.

**Failure and edge states**

- **A save fails:** he stays on the reading and reads "That did not save. Try again." The box is not shown as checked.
- **The day cannot be loaded:** Today says so and offers "Try again". The header still shows the date.
- **Storage cannot be opened or read at start-up:** the database file is read once before the first screen. If that fails, for example because the file is corrupt, the app opens on the status page and says nothing is saved on this device; Today works and says the same. The file is closed and left as it was.
- **Nothing can be kept (the web preview):** Today and the reading say "Nothing you check here is saved."
- **No reading for the date:** the page says "No devotional today". The bundled file has all 366 dates, so this cannot happen today.

**Known gaps, on the [work board](../../knowledge/WORK.md)**

- The bundled BSB and ESV verse text has not been checked against a published source. (Before public release.)
- The readings' own text quotes scripture inline; those quotations have not been checked against a published text, inline ESV wording is not counted toward the 499-verse limit, and no ESV notice is shown beside it. The [full list](inline-scripture-in-v254.md). (Owner: the maintainer. Before public release.)

- For a moment after the day changes, the page still shows yesterday's reading while today's loads. Scrolling that to its end in that moment unlocks Amen for today's reading. (Review finding, medium.)
- If the preview points switch cannot be saved, nothing on screen says so. (Review finding, medium.)
- A corrupt database file is found at start-up, and the app says nothing is saved, but there is no way to recover from it inside the app.

**What must not change**

- Nothing is written to Firebase, and no feature code imports its SDK.
- The app computes no score and no total.

## The readings are v254's (decided by the maintainer on 2026-11-12)

**The decision, in the maintainer's words:** "the readings inside versions/app-v254.html on origin/app/v241-bold are the real readings for the pilot." That file is at commit `3ff4a6f`. `index.html` on `main` holds the same 366 readings.

**What step S1b took from v254, and what it left as it was**

| Part of a reading | Where it comes from now | Dates that changed |
|---|---|---|
| Headline | v254 (`headline`) | New on all 366 |
| "In Jesus" paragraph | v254 (`jesus`) | New on all 366 |
| Tags | v254 (`sent`, `spirit`) | New: 48 Sent, 55 Spirit-led, never both on one date |
| Open in prayer | v254 | 365 |
| Reflect | v254 | 318 |
| Act | v254 | 366 |
| Verse reference | Unchanged. v254 has the same reference on every date | 0 |
| Verse text, BSB | Unchanged: the text `seed/devotionals.json` already had | 0 |
| Verse text, ESV | Unchanged: `seed/esv-verses.json` | 0 |
| Series line, month names, themes and month lines | Unchanged. v254 has the same | 0 |

v254 has a reading for every one of the 366 dates and no empty field, so no date kept its earlier reading.

**Scripture text was not touched.** v254 quotes its verses in the ESV. Its wording differs from `seed/esv-verses.json` on 108 dates: on 56 only in the shape of quotation marks and apostrophes, on 46 in a capital first letter or a final full stop where the verse ends with a comma, and on 6 in an added closing quotation mark. Which wording is the published ESV was not checked, and none was typed or recalled, so the maintainer's direction was to leave all scripture text as `seed/` has it. Checking it against a published source is on the board.

**The tags are shown and nothing more.** In v254 they are drawn by `drawDevo` with no handler, and nothing else in the prototype reads them. The same in the app. One difference in color, decided by the maintainer on 2026-11-12: in the light theme the Sent tag is the same bright orange as the Spirit-led tag, where v254 uses a dark orange that is hard to read on the dark header.

**Inline scripture (decided by the maintainer on 2026-11-12).** The headline, prayer, "In Jesus" paragraph and action of some readings quote scripture themselves: 23 clear quotations on 23 dates, and 35 quoted spans the repository cannot identify. The [full list](inline-scripture-in-v254.md) is beside this page. The maintainer's decision: build with v254's text unchanged, keep the ESV limit test counting `seed/esv-verses.json` only, and put the checking on the board.

**The ESV limits (Q7), before and after S1b**

| Limit | Before | After |
|---|---|---|
| At most 499 distinct verses | 437 | 437 |
| No more than half of any one book | Philippians, 15.4% | Philippians, 15.4% |
| Under 25% of the bundled text | 22.8% | 16.2%, because the readings' own text is longer |

## Rules taken from the prototype, confirmed by the maintainer on 2026-11-12

These two rules are the prototype's, read from `index.html` (identical on `main` at `dd35157` and in v254). The project's rule is that product behavior is not inferred from the prototype, so they were put to the maintainer, who **confirmed both as they are on 2026-11-12**: the reading by month and day, repeating yearly, and the mission line by the day of the year modulo 14.

| Rule | How it works | What shows after the last entry |
|---|---|---|
| **Which reading is today's** (`devoToday`) | By the calendar month and day of the local date. There are 366 readings, one for every date including February 29 | After December 31 the year starts again at January 1. The same date shows the same reading every year. February 29 has its own reading and is skipped in other years |
| **Which mission line is today's** (`drawHeader`) | The day of the year (January 1 is 1) modulo the number of lines, which is 14 | After the 14th line the list starts again. The count restarts every January 1, so the position in the list jumps at New Year: December 31 and January 1 show the same line in an ordinary year |

One deliberate difference: the prototype works out the day of the year from elapsed milliseconds. During daylight-saving time that is an hour short, so for the first hour after midnight it shows the previous day's line. The app uses the calendar.

## Boundaries and evidence

- **Source:** `mobile/lib/src/features/today/`, `devotional/` and `settings/`; `mobile/lib/src/core/` (local date, clock, event ids); `mobile/lib/src/storage/` (Drift tables, the local profile, the database file); `mobile/assets/content/` (bundled readings, ESV text, boxes, mission lines).
- **Architecture:** [ADR-0005](../../architecture/ADR-0005-flutter-client-stack.md) (Riverpod, go_router, Drift) and [SYSTEM](../../architecture/SYSTEM.md).
- **Prototype:** layout, and since S1b the readings' words, from `versions/app-v254.html` at `3ff4a6f` (decision Q1, and the decision of 2026-11-12 above); reference pictures in `docs/design/reference/s1-today/`. What differs from it is listed on the [parity page](../../knowledge/PROTOTYPE-PARITY.md).
- **Tests:** the files in `verified_tests` above. The emulator test is two files run one after the other with the app's process killed in between; how to run it is in `mobile/README.md`.

**Not verified**

- iOS: built only by CI's simulator job; never run.
- The emulator test of complete, kill, relaunch passed on 2026-11-12 on one emulator only: an emulator made for this test, `FS_S1_Restart_API_36`, from the installed `system-images;android-36;google_apis_playstore;x86_64` image (Android 16, API 36), on the maintainer's Windows workstation. No CI lane has an emulator. Nothing has run on a physical phone, and no other Android version was tried.
- The golden images are compared on Windows only.
- S1b was not run on a phone or an emulator. It changes what the reading shows, not what is saved.
- Schema migration: the database is at version 1, so there is nothing to migrate yet.
- That Crossway's permission covers an app. That is the maintainer's to confirm before public release (Q7).

## Tasks

- [x] Storage: Drift tables, the local profile, one database file per owner.
- [x] Rules: event id as the only key, target not toggle, counter order, undo on the completion's day.
- [x] Content: readings, ESV text, boxes and mission lines bundled, each checked against its source.
- [x] Screens: Today, the reading, and Settings with the preview points switch.
- [x] Tests for each acceptance item, and golden images in dark and light.
- [x] Maintainer: confirmed the two rules taken from the prototype, on 2026-11-12.
- [x] S1b: v254's readings in `seed/devotionals.json` and the app's copy; the headline, the tags and "In Jesus" on the reading; tests and golden images.
- [ ] Maintainer: approve this contract, or say what to change.
