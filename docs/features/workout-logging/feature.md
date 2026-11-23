---
kind: feature-spec
feature_id: FNS-004
status: approved
risk: medium
owner: maintainer
source_ref: claude/s3-workout-logging
source_sha: fa4f0d767b967f2091e77ea3e8613e0ce14c2b84
approved_by: Chad (GitHub Chadillac12), 2026-11-22, https://github.com/Forged-Sent/ForgedAndSentFitness/pull/85#issuecomment-7077562958
test_plan: plan schedule and prescription rules, workout repository rules against the Drift and in-memory stores, kill and reopen on a real SQLite file, schema migration from versions 1 and 2 to version 3, Train and workout page widget tests including the prayer gate and screen-reader labels, Finish held while a set he entered is not stored, the pause flush, the release-build clock guard, golden images at 390x844 in dark and light, one emulator run of start, two sets, kill, relaunch, finish
verified_tests: mobile/test/features/workout/workout_plan_test.dart, mobile/test/features/workout/prescription_test.dart, mobile/test/features/workout/workout_library_test.dart, mobile/test/features/workout/drift_workout_repository_test.dart, mobile/test/features/workout/memory_workout_repository_test.dart, mobile/test/features/workout/train_page_test.dart, mobile/test/features/workout/workout_page_test.dart, mobile/test/features/workout/workout_flush_test.dart, mobile/test/features/workout/workout_golden_test.dart, mobile/test/storage/migration_test.dart, mobile/test/app/start_clock_test.dart, mobile/integration_test/workout_restart_1_start_test.dart, mobile/integration_test/workout_restart_2_finish_test.dart
implementation_paths: mobile/lib/src/features/workout, mobile/lib/src/storage/app_database.dart, mobile/lib/src/storage/app_database.steps.dart, mobile/drift_schemas, mobile/lib/src/design/fs_dialog.dart, mobile/lib/src/design/fs_number_field.dart, mobile/lib/src/design/fs_chevron_row.dart, mobile/lib/src/design/fs_marks.dart, mobile/lib/src/design/fs_typography_workout.dart, mobile/lib/src/core/time_text.dart, mobile/lib/main.dart, mobile/assets/content
verification: see the pull request that adds this page for the commands and their output
---

# Workout logging, one program

Build step S3 of the [prototype-to-Flutter review](../../reviews/2026-11-10-prototype-to-flutter/02-BUILD-PLAN.md), built from prompt [P07](../../reviews/2026-11-10-prototype-to-flutter/prompts/P07-S3-workout-logging.md). This page was drafted by Claude. **Approved by the maintainer, Chad (GitHub `Chadillac12`), on 2026-11-22**, in [his comment on pull request #85](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/85#issuecomment-7077562958): "I approve FNS-004." The head of the branch at that moment was `681587d`. In his review of the same day he confirmed the rules taken from the prototype as built, approved the golden images, and let the workout prayer stand with no reference; each is recorded in its section below. What is listed below as not verified stays not verified; his approval is of this page as it is written.

It rests on the maintainer's decisions on the [Decisions](../../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md) page: Q9 (day boundary), Q10 (use before sign-in), Q11 (the workout prayer), L11 (content source), Q5 (points) and Q6 (streak); and on the design in [the architecture page](../../reviews/2026-11-10-prototype-to-flutter/07-ARCHITECTURE.md), journey J2.

## The maintainer's decisions of 2026-11-13

The maintainer decided these six points for S3 on 2026-11-13, in the session that built it. They are recorded here because the [Decisions](../../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md) page is the maintainer's to edit. The app is built to each of them.

| # | Point | The maintainer's decision | How it is built |
|---|---|---|---|
| 1 | **A new member's first week** (review finding U1) | The calendar week, as built | Week 1 is the plan week that holds his next lifting day, today included. Lifting days of that week that are already past stay unlogged |
| 2 | **Android back on the workout prayer** | The same as "Not now" | The prayer closes and nothing starts |
| 3 | **Recovery days** | They are sessions, and finishing one checks the box | A recovery day is started through the prayer like a lifting day, and finishing it checks the Workout box |
| 4 | **RPE and RIR in prescriptions** | Show the guidance | Shown as `seed/workouts.json` has them: "3 x 5 (RPE 7, rest 2 min)". The prototype strips them from its own copy and shows "3 x 5 (rest 2 min)" |
| 5 | **The start button's words** | Keep "Pray, then train" | v254's words. The prototype on `main` says "Start workout" |
| 6 | **A set with a weight and no reps** | It does not block Finish. The summary says which sets were not counted and why | True on every lift, loaded or not, and for a timed set with no seconds. He is told before he finishes; the summary has a line "Not counted: 140 lb, no reps". On a loaded lift this differs from the prototype, which holds Finish up there: see the differences below |

## User outcome

A man opens Train and sees today and this week from the Forged program. He opens today's session and taps Start. The workout prayer comes first; Amen starts the clock, and "Not now" starts nothing. He logs each set with last time's values beside it, uses the rest timer, and finishes. The workout locks into a summary, and the Workout box on Today checks itself. If the phone kills the app in the middle, what he logged is there when he opens it again, and the clock is right; the one limit, a change still on its way to the file at the instant of the kill, is stated under "What is saved, and how". Nothing leaves his phone.

## Acceptance and failure cases

**Train**

- Today's card: the date, where the day stands ("Ready to train", "Workout complete", "Rest day", "Nothing finished yet today"), and the session to open, or one line that says why there is none.
- "Your week": Monday to Sunday, each with its session or "Rest day" / "Sabbath" / "Plan starts Monday". A day with a session opens its workout page. A finished day shows a check.
- **A new member (U1, decision 1 above):** he has a session on his next lifting day at the latest, which is never more than two days away. He never waits for "next week".
- A workout begun on an earlier day and not finished has its own card at the top of Train, with the way back into it. The card stays when today's workout is started too, and when that earlier day is no longer in the week shown; with more than one such workout it is the most recent.

**The workout page**

- Before it is started: the plan's exercises and prescriptions, and the start button, "Pray, then train" (decision 5 above). Only today's session can be started. Another day's page shows its plan and says so.
- **The prayer (Q11):** the start button shows the workout prayer with **Amen** and **Not now**. Amen starts the session. Not now, and Android back (decision 2 above), close it and start nothing. A tap outside the box does nothing.
- In progress: one row per set with a box for reps (or seconds) and, where the lift takes one, a box for the weight in pounds. Last time's value for the same set stands under the set's number. A mark fills once the set is logged. An exercise with nothing to count has one "Done?" tick.
- **Last time (U3):** found by the movement, on the most recent earlier day he logged reps for it. Never by where the exercise stood in the plan. Each set keeps the position it was logged in: a set he left empty that day has nothing beside it today, and the sets after it are not moved up.
- **Rest timer:** per exercise, starting at the rest its prescription writes. Start, Pause, Resume, Reset, and 15 seconds less or more. At zero it reads "GO". It makes no sound.
- **Clock:** the time since Amen, in a bar that stays at the top.
- **Finish:** nothing is finished while a set he entered is not stored (see the failure states below). The workout is then checked as the store holds it, not as the page last drew it: a set with reps and no weight, where the lift needs one, must be fixed first; the page outlines it. Sets that will not be counted are listed, and he may finish without them: a set with nothing entered, and a set with a weight and no reps or seconds (decision 6 above). Finishing locks the workout into a summary: when it was finished, pounds moved, sets logged, and each logged set as text. A set entered halfway has a line too, which says it was not counted and what it is missing: "Not counted: 140 lb, no reps". A set left empty has no line. Nothing in a finished workout can be changed, on the screen or in the store.
- **The Workout box on Today** is checked by finishing a workout and by nothing else. A tap on it opens Train.
- **On a rest day the Workout box is not a to-do** (the maintainer, 2026-11-21). A rest day is a day his stored plan gives to rest: the weekly rest day, or the optional fourth day while it is off, the two days Train calls "Rest day". The box then reads "Rest day", is drawn faded like a box that is not active, offers no tap, shows no point value, and is announced to a screen reader as not available. It is left out of the ring, the tally and meter of "Today's boxes" and the Body line, so those count six boxes and it does not keep the day from being complete. The streak never counted it (Q6). **The days before his plan starts and after it ends follow the same rule** (the maintainer, 2026-11-21), in the words Train has for the day: the box reads "Plan starts Monday" (the weekday the plan starts on) or "Plan complete". A member who has not opened Train has no plan yet, so the box is the ordinary one for him. If the plan or the program cannot be read, the box is unchanged and Today still opens.

**What is saved, and how**

- **The session is its own record.** When Amen is tapped the session is stored with a copy of what the plan prescribed: for every exercise the movement id, the name shown and the prescription text, and one row per set. From then on it never reads the plan again, so changing the plan cannot change a session (P07 acceptance 4).
- **Every change is written at once.** Each keystroke in a set's box, each tick and each rest timer button is its own write to the database, in the order they were made. When the app is paused the page waits for the last of them. A change still waiting its turn is written also when he leaves the page first. The order is kept for the session, not for one opening of the page: if he leaves the page and opens it again while storage is slow and changes are still waiting, what he changes on the reopened page is stored after them, and Finish and the pause wait for them too (`WorkoutWrites` in `workout_view_model.dart`; four tests in `workout_flush_test.dart` that failed before it). One limit of this, accepted by the maintainer on 2026-11-22: the rest timer's last value is remembered by the page that set it, so a "+15" tapped on a reopened page while an earlier timer change is still waiting starts from what the store holds at that moment, and that one tap can be lost. There is no save button, and nothing is kept only in memory for longer than its turn takes (P07 acceptance 1). One limit, stated plainly: a change that is still waiting its turn at the instant the process is killed outright is not in the file. The device test kills the app only after it has read both sets back from the file, so it proves that what was written survives, not that nothing can be caught in that instant.
- **Time comes from stored instants.** The clock is the time since the stored start; the rest timer counts down to a stored instant. Both are right after the app was closed and opened again.
- **The day (Q9, U2):** a session belongs to the local date it was started on and keeps it. It can be logged and finished after midnight, with no time limit, and finishing checks the Workout box of the day it started on (P07 acceptance 3). One session per day.
- **Finishing is one transaction** with the day's completion event, whose id is made when the session starts. Finishing twice records one completion (P07 acceptance 2). If the box cannot be checked the session is not finished either. A session is read in one transaction as well, so a read that overlaps a finish gives the session wholly before it or wholly after it.
- **Schema version 3** adds four tables: plans, sessions, exercises, sets. Version 2 is the journal's (build step S2). A database file of version 1 or version 2 opens in this build with every row it had.
- **Owner (Q10):** the local profile, as in S1. Each owner has his own database file.

**Nothing about the body**

The app stores and asks for nothing about his body: no body weight, measurements, injuries or readiness. The only weight it stores is the weight on the bar, or the load added to a bodyweight lift, and the box for that says not to enter body weight. So the prototype's sleep and stress questions, its after-workout questions, its injury notice, and the body weight it adds to volume for bodyweight lifts are all left out.

**The clock a test can set**

The emulator test has to run on a lifting day whatever day it really is, so `startApp` can be given a clock. **A release build cannot:** `clockForStart` throws when it is given one in release mode, the app's own `main()` passes none, and no build flag, setting, link or stored value reaches it. `mobile/test/app/start_clock_test.dart` tests all of that.

**Failure and edge states**

- **A change cannot be stored:** the page says "That did not save. Try again." The line stays until that change is stored: the same box typed in again, the same tick, a button of the same rest timer, the start or the finish. Another change being stored does not clear it. The box itself goes back to what is stored when he leaves it.
- **A set he entered is not stored when he taps Finish:** nothing is finished, and he is not asked about blank sets. Finish first waits for the changes still being written. If a set's reps or seconds, its weight or its tick could not be stored, the page goes to the top, where "That did not save. Try again." stands, and the box he was in goes back to what is stored. Finish works once each of those is stored: the same box typed in again, or the same tick. A rest timer that did not save does not hold Finish up, because where a timer stood is no part of a finished workout. Leaving the page forgets what did not save: the boxes then show what is stored, and that is what he finishes.
- **The session cannot be stored:** nothing starts; the page says the same and Start stays.
- **Finishing cannot be saved:** the workout stays open and the page says so. The same when the workout cannot be read back from the store for the check before it is locked.
- **Midnight passes between opening the page and Amen:** nothing is started; the page says "It is a new day. Open today's workout from Train."
- **The plan, or today's session, cannot be loaded:** Train says so and offers "Try again", which reads all of it again.
- **Nothing can be kept (the web preview):** Train and the workout page say "Nothing you check here is saved."
- **Storage cannot be opened at start-up,** including a migration that fails: as in S1, the app opens on the status page and says nothing is saved.

**Known gaps, on the [work board](../../knowledge/WORK.md)**

- A workout that is never finished stays "in progress" on Train for good.
- The rest timer makes no sound.
- When "That did not save" appears above the set rows, the box he is typing in loses the keyboard and shows what is stored.

**What must not change**

- Nothing is written to Firebase, and no feature code imports its SDK.
- The app computes no score and awards no points. The streak still counts devotional days (Q6).

## The workout prayer and scripture

The prayer's six lines are the prototype's `WORKOUT_PRAYER`, copied by a script into `mobile/assets/content/workout_prayer.json` and compared with `index.html` by a test. They were never typed or recalled.

The prayer carries no reference and is not set as a quotation, but it **echoes scripture closely**, which the maintainer should know before release:

- its fourth line follows **1 Corinthians 16:13-14** nearly word for word;
- its first line alludes to **1 Corinthians 6:19-20**;
- its second line alludes to **Ephesians 6:11**.

It is not counted among the bundled ESV verses (decision Q7), because it is not marked as a quotation of any translation. **The maintainer's review of 2026-11-22:** the prayer shows no reference, as built. Whether its wording follows a translation closely enough to matter for a licence is part of his "Scripture licence" row on the [work board](../../knowledge/WORK.md).

## Rules taken from the prototype

The project's rule is that product behavior is not inferred from the prototype. Every rule below is the prototype's, read from `index.html` on `main` (identical in v254 unless noted), built as it stands, and listed here for the maintainer to confirm. Six points were decided on 2026-11-13, in the table at the top. **The maintainer confirmed the rest of this table as built on 2026-11-22**, in his review of pull request #85. Two rules he wants changed before any pilot are rows on the [work board](../../knowledge/WORK.md) and are not built: whether a lift needs a weight is to come from a field in `seed/`, not from the movement's name; and the rest timer is to alert at zero, also when the phone is locked.

| Rule | Prototype function | How it works |
|---|---|---|
| The plan with no setup | `planDraft`, `defaultLiftDays` | Forged, Full Gym, rest on Sunday, lifting on Monday, Wednesday and Friday, no fourth day. Approved as a default for S3, which has no plan editor |
| Which plan day a date shows | `planIndex` | A plan week runs from the day after the rest day to the rest day. Its three lifting days show the week's first, third and fifth entries, the other three days the second, fourth and sixth, the rest day the seventh |
| What a day holds | `workoutFor` | Before the plan, after it, the rest day, the optional fourth day (off), or a session. Recovery days are sessions |
| Day and week labels | `rowLabel`, `drawTrain`, `drawDayWorkout` | "Plan starts Monday", "Plan complete", "Sabbath / Rest, worship, family", "Rest day / Optional day is off", else the title with "Core · 45 min" |
| Only today can be started | `drawWorkoutPageNow` | "Start workout" shows for today's session only |
| Names by equipment | `moveName` | A movement is shown by its name for the member's equipment setup |
| Sets in a prescription | `parseSets` | "3 x 5 (…)" is three rows aiming for 5; "2 x 25 sec" is timed; "1 x 5, 1 x 3, 1 x 1" is one row each; a superset line counts only its sets; anything else is one "Done?" tick. At most 12 rows |
| Rest in a prescription | `restOf`, `restBar` | "rest 2 min" is 120 seconds; a range takes its top; outside 10 seconds to 10 minutes is ignored. With none written: 60 seconds after the second exercise of a superset, else 90. The first exercise of a superset has no timer |
| Rest timer buttons | `timerStart`, `timerAdj` | 15 seconds less or more, within 15 seconds to 10 minutes; a running timer moves by as much as its full length did; "GO" at zero. One difference at the limits is listed below |
| Whether a set needs a weight | `needsWeight`, `canAddWeight` | Decided from the words in the movement's name: a loaded implement needs a weight, a known bodyweight move does not, a pull-up or dip may take added weight |
| When a set is logged | `paintDone` | Reps (or seconds) over zero, and a weight where the lift needs one |
| Number limits | `numField` | Reps to 999, weight to 2,000 lb, added weight to 400 lb, one decimal place for weight |
| Last time | `liftSessions`, `lastWorking` | The most recent earlier day with reps logged for that movement; each set's value beside the same set; the last working set in one line |
| The check before finishing | `workoutFixes`, `openFixes` | Reps with no weight on a loaded lift must be fixed; sets he may finish without are listed, eight at most. What the app does with a weight and no reps is the maintainer's decision 6, and differs from the prototype as listed below |
| The Workout box | `previewWorkout`, the "auto" box | Checked by finishing; "Checks itself when you finish a workout", then "Finished in Train". What it says on a day with no workout ("Rest day", "Plan starts Monday", "Plan complete") is not from the prototype: it is the maintainer's decision of 2026-11-21 |
| The clock | `wkElapsed`, `fmtElapsed` | The time since the start: "12:34", or "1:02:03" from an hour up; "Workout time", then "Finished in" |
| The locked summary | `drawLockedSummary`, `volOf` | "Finished at 6:42 PM. Locked."; volume is weight times reps; each logged set as "5 reps × 135 lb", "8 reps (bodyweight)", "25 sec" or "Done"; a timed set with a weight typed shows it in the same form, "30 sec × 40 lb" or "25 sec (bodyweight + 10 lb)" |
| The prayer's box | `openWorkoutPrayer` | "Before you train", "Workout prayer", the six lines, Amen |

**Where the app deliberately differs from the prototype**

- **U1:** the plan starts with the week of his next lifting day, not on the first day after the next rest day.
- **U2:** a session stays open past midnight and keeps its start day. The prototype stops offering it once the day changes.
- **U3:** a session stores each exercise's movement id and prescription. The prototype stores sets by position and reads the names from whatever the plan says later.
- **Q11:** the prayer has "Not now".
- At ten minutes "+15" does nothing, and at fifteen seconds "−15" does nothing. In the prototype the full length stays at the limit too, but a running timer still moves by the 15 seconds, so a rest can run longer than ten minutes or be cut to nothing.
- **Decision 6:** a weight typed with no reps, or no seconds, does not hold Finish up on any lift. He is told before he finishes ("Some sets will not be counted", with "a weight but no reps" beside the set), and the summary says "Not counted: 140 lb, no reps". The prototype treats the two kinds of lift differently: on a loaded lift it holds Finish up ("add the reps"); on a bodyweight or timed lift it calls the set blank and lets him finish, and the weight is then shown nowhere.
- Because of that, the box that holds Finish up says "A set with reps needs its weight before you finish." The prototype's "Every set needs reps and weight before you finish" would no longer be true.
- **Decision 5:** the start button says "Pray, then train", as v254 does. The prototype on `main` says "Start workout".
- Reps are whole numbers. The prototype accepts one decimal place.
- Volume leaves out body weight, because the app stores none.
- The summary counts "sets logged" and has no PR count; PRs are a later step.
- The rest timer makes no sound, and nothing tells him it ended while the phone is locked. An alert at zero is a board row, required before any pilot.
- Two lines are reworded because the prototype's point at a plan form that S3 does not have: "Rest day. The optional 4th training day is off." and, once the calendar has run past the plan, "You have reached the end of this plan." The second is the maintainer's wording of 2026-11-20: the line is shown whether or not he logged anything, so it does not say he finished.
- Train's row says "In progress · Tap to continue" for a started session, and "Finished · Tap to view" for a finished one.
- Lines between exercises are solid, not dashed.

## Content (decision L11)

The app bundles the Forged program and the movement names as copies of `seed/` files, kept identical by a test. For the workout library, comparing `seed/` with the copy inside `index.html` gave:

| Content | Difference | What was done |
|---|---|---|
| Workouts | Only RPE and RIR: `seed/` has them, the copy in `index.html` has none | `seed/` kept, and the app shows them (decision 4 above) |
| Movements | The same 218 movements and videos, in a different field layout | No change |
| Themes | The copy in `index.html` has a `brief` on all 28 themes; `seed/` had none | `brief` added to `seed/workout-themes.json` by script: a field only one side has is kept |
| Program descriptions | Two lines differ. `seed/` was last changed on 2026-10-25, `index.html` on 2026-10-29 | The newer wording copied into `seed/workout-programs.json` by script |
| Meta, alternates, standards | Identical | No change |

Not done in this step: the challenge point values, which differed and are scoring content in a review-protected file that S3 does not read; and generating the prototype's embedded copy from `seed/`, which needed a tool and P07 allows none. Both were done afterwards, in [#76](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/76) (decision L11): the copy inside `index.html` is now generated from `seed/` and checked in CI.

## Proposed addition, written after the approval: add or remove a set

**This section is not part of what the maintainer approved on 2026-11-22.** It was added afterwards, with the change that builds it, at his request of 2026-11-21 and to his rules of 2026-11-22. It is **proposed** until he approves it; the rest of this page stands as approved.

**What he can do**

- **Add a set.** Under the rows of an exercise whose sets are counted there is "Add set". A tap adds one row at the end with the same target as the set before it. An exercise takes twelve rows at most, the limit a prescription already has; at twelve the button is gone. An exercise that is only marked done ("Done?") has no button.
- **Remove a set he added, while it is empty.** A row he added shows "Remove" under it for as long as nothing is entered in it. Once anything is typed in the row, reps or a weight, also a zero, the button is gone: he clears the row first. The rows after a removed row move up by one.
- **A row from the plan is never removed.** Leaving it empty already means it is not counted.
- **Nothing changes in a finished workout.** The summary has no buttons, and the store refuses both changes for a finished session. An empty row he added and left is kept as it stood, and is not counted.
- **"Last time" still lines up by position.** An added set is found the next time beside the set in the same place, once he adds a row there.

**How it is built**

- **No change to the database.** A set he adds is one more row in the session's existing set table; removing one deletes that row and renumbers the rows after it, in one transaction. The schema is still version 3.
- **Which rows are his.** A session keeps each exercise's prescription as it was when the session was started, and its rows are numbered from 0 with no gaps. The rows the prescription asks for are the plan's; a row after them is one he added (`plannedSetCount` in `prescription.dart`). Nothing new is stored to tell them apart.
- **The store decides, not the screen.** The store adds nothing past twelve rows and removes a row only if, as it holds it at that moment, the row is one he added, nothing is entered in it and the session is not finished. Both changes take their turn in the session's write queue behind what he typed before. So "Remove" tapped a moment after typing in that row removes nothing: the typing is stored first.
- **What the store cannot know, the page holds back** (added after the Codex review of this change). From the tap on "Remove" until the row is gone, the row is drawn faded and takes no tap, no keyboard and no screen-reader action: what he typed into it then would go to a set that no longer exists and be lost without a word. And "Remove" is not offered for a row with something he typed that could not be stored, nor is the removal sent if such a failure arrives after the tap: the store would see an empty row and take away the place for it. The row stays for him to type in again.
- **An id is used once.** Asking twice to add a set with the same id adds one row, in both stores.
- **If it cannot be stored** the page says "That did not save. Try again." That does not hold Finish up, because nothing he entered is missing.

**Limits, stated plainly**

- Which rows are the plan's is read from the stored prescription text each time. If the way a prescription is read ever changes, a workout still in progress from before could be read differently. A finished workout is not affected: nothing in it can be added or removed.
- An added set does not change the prescription line shown above the rows ("3 x 5" stays "3 x 5"), the rest timer, or the summary's layout. The summary lists an added set he logged like any other.
- Nothing marks an added row as added on the screen, other than its "Remove" while it is empty.

**Tests** (each failed before the change it belongs to): twelve rules run against both stores in `workout_repository_contract.dart`; add, remove, close and reopen on a real SQLite file in `drift_workout_repository_test.dart`; thirteen widget tests in `workout_page_test.dart`, among them "Remove" tapped while typing is still on its way to the store, typing after the tap, and typing that failed to be stored; `plannedSetCount` in `prescription_test.dart`. On the Android emulator, 2026-11-22: `integration_test/workout_sets_restart_1_add_test.dart` and `_2_verify_test.dart` (add two sets, log one, remove the empty one, kill, relaunch, find them as left, clear and remove), and the workout restart pair again on this build. Two golden images redrawn and **not approved**: `workout_live_dark.png` and `workout_live_light.png` now show a fourth, added row with its "Remove", and "Add set".

**Not verified:** a phone; iOS beyond CI's simulator build; the two new buttons with a screen reader on a device. One Codex review was run on this change (two High, one Medium), followed by one fix round; the fix round itself has not been reviewed.

## Proposed addition, written after the approval: supersets drawn as one group

**This section is not part of what the maintainer approved on 2026-11-22.** It was added afterwards, with the change that builds it, at his request of 2026-11-21 and to his rules of 2026-11-22. It is **proposed** until he approves it.

**What he sees.** On a day with a superset, its two exercises stand in one group on the workout page: a bar down the left, the word "Superset" above them, and "A1" and "A2" before their names. It is so before the workout is started and while it is logged. The finished workout's summary is as it was.

**Display only.**

- **Where the pair comes from.** From the day's `superset` mark in `seed/workouts.json` (for example `[5, 6]`: the sixth and seventh exercises), which the bundled copy keeps. Not from the words "Superset A1" in the prescription. A mark is accepted only if it is two or more neighbouring places inside the day's exercises; anything else is read as no superset. 209 of the Forged program's 365 days carry one, always a pair.
- **Nothing is stored and no rule changes.** The session, the database, the rest timer rules (the first of the two has no timer, the second has one) and the summary are as before. The prescription line is shown as it is written, with its own "Superset A1:".
- **A session already started** stores no mark. The page asks the program what it holds today for the plan day the session was started on, and draws the group only if the session is still a copy of that day: the same number of exercises, and at every place the program's movement and prescription text. If anything in the day has changed since, no group is drawn: nothing rather than the wrong pair. This is the one place a started session looks at the program again, and only to draw.
- **One thing that check cannot see by itself:** a program whose mark alone moved while every prescription stayed word for word. A test on the bundle rules it out: there the mark and the prescriptions' own "Superset A1" and "A2" name the same places on all 365 days, so the mark cannot move without a prescription changing. Storing the mark with the session when it is started would make this certain without that test; it needs a new column, which this change was told not to add.

**Tests** (each failed before the change, except those that expect no group): the mark of every plan day against `seed/workouts.json`, what counts as a mark, the labels, and a session's labels with and without the program's movements, in `workout_library_test.dart`; six widget tests in `workout_page_test.dart` (before the start, during the workout, a screen reader, a day with none, the summary, a session that does not match). After the Codex review of this change: a session differing from the program's day in any movement, prescription or count gets no group (failed before the fix); and the bundle's mark agrees with its prescriptions on every day (a guard: it passed before and after). Golden images, all **not approved**: two new, `workout_superset_dark.png` and `workout_superset_light.png`; four redrawn because the group is in view, `workout_before_` and `workout_prayer_`, dark and light. On the Android emulator, 2026-11-22: `integration_test/workout_superset_test.dart`, which expects the pair by name on the plan day a new plan opens on, and the workout restart pair again on this build.

**Not verified:** a phone; iOS beyond CI's simulator build; the group with a screen reader on a device. The other three programs are not bundled; their marks are the same shape in `seed/` (always a pair), but no test here reads them. One Codex review was run on this change (two Medium, one Low), followed by one fix round; the fix round itself has not been reviewed.

## Boundaries and evidence

- **Source:** `mobile/lib/src/features/workout/` (domain, data, presentation); `mobile/lib/src/storage/` (tables, migration steps); `mobile/drift_schemas/` (the frozen schema of each version); five shared widgets and text roles under `mobile/lib/src/design/`; `mobile/assets/content/` (the program, the movement names, the prayer).
- **Architecture:** [ADR-0005](../../architecture/ADR-0005-flutter-client-stack.md) and [SYSTEM](../../architecture/SYSTEM.md).
- **Prototype:** layout from `versions/app-v254.html` at `3ff4a6f` (decision Q1); behavior from `index.html` on `main`. Reference pictures and comparison sheets in `docs/design/reference/s3-train-workout/`. What differs is listed above and on the [parity page](../../knowledge/PROTOTYPE-PARITY.md).
- **P07's acceptance items and their tests:** listed in `mobile/README.md` and in the pull request.

**Not verified**

- iOS: built only by CI's simulator job; never run.
- A physical phone. The emulator test of start, two sets, kill, relaunch, finish passed on 2026-11-13 on one emulator only: `FS_S1_Restart_API_36`, from the installed `system-images;android-36;google_apis_playstore;x86_64` image (Android 16, API 36), on the maintainer's Windows workstation. No CI lane has an emulator, and no other Android version was tried.
- The migration on a member's phone. It was seen once on that emulator, which still held an S1 build and its version 1 database with three completion events: the S3 build was installed over it, the file read version 2 afterwards, and the three events and both day states were still there. That is one observation, not a test that is repeated. It was made on 2026-11-13, when the workout tables were schema version 2; since the journal (S2) merged first they are version 3. That upgrade was run on the same emulator on 2026-11-20 with a test in three parts (`mobile/integration_test/upgrade_*`): a build of `main` wrote two journal entries and completed a day, this build was installed over it without uninstalling, the file read version 3 afterwards with both entries and the completed day, a workout was started, and all of it was still there after a kill and relaunch. Not on a phone.
- The golden images are compared on Windows only. (The maintainer approved them on 2026-11-22.)
- A release build was not made, so the clock guard is proven by its unit test, not by running a release build.
- The keyboard on a real device: that the box being typed in stays in view above it.
- A rest timer across a daylight-saving change, and a phone whose clock is set back during a workout: the clock then shows 0:00 until it catches up.

## Tasks

- [x] Storage: schema version 3 (the journal's tables are version 2), the migrations from versions 1 and 2 and their tests.
- [x] Rules: the plan schedule, prescription parsing, one session per day, finish once, locked when finished.
- [x] Content: the Forged program, movement names and the prayer bundled, each checked against its source; L11 applied to the workout library.
- [x] Screens: Train, the workout page, the prayer, the Workout box on Today.
- [x] Tests for each of P07's five acceptance items.
- [x] Maintainer: the six points at the top, decided on 2026-11-13.
- [x] Maintainer: confirm the rules taken from the prototype. Confirmed as built on 2026-11-22.
- [x] Maintainer: look at the golden images beside the prototype and approve them. Approved on 2026-11-22.
- [x] Maintainer: approve this contract, or say what to change. Approved on 2026-11-22: ["I approve FNS-004."](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/85#issuecomment-7077562958)
