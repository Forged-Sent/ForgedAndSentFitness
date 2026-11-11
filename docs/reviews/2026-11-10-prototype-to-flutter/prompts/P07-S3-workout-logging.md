---
title: "P07 Workout logging, one program"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](../00-START-HERE.md) · [All prompts](../03-AGENT-PROMPTS.md) · [Decisions](../01-DECISIONS.md) · [Build plan](../02-BUILD-PLAN.md)

# P07 · Workout logging, one program

> [!IMPORTANT] Before you paste
> - [ ] P05 merged
> - [ ] Q11 and L11 answered
> - [ ] These answers are filled in on the [Decisions](../01-DECISIONS.md) page: ==Q11==, ==L11==

## What you fill in

**Nothing.** Paste it as is. The agent reads your answers from the Decisions page.

## Your answers right now

Live view of the Decisions page (Obsidian only; on GitHub open the [Decisions](../01-DECISIONS.md) page).

![[01-DECISIONS#Your answers]]

## The prompt

Copy everything in the box.

```text
Read first, in this order:
1. AGENTS.md (and mobile/AGENTS.md for any Flutter work).
2. docs/reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md
   - The "Your answers" table holds my decisions. Use them exactly as written.
   - Any answer that still contains TODO is unanswered. If this task needs
     it, stop and ask me. Do not choose for me.
   - The "Run settings" table holds the SDK version, branches and paths.
3. docs/reviews/2026-11-10-prototype-to-flutter/07-ARCHITECTURE.md (journey J2)
4. docs/reviews/2026-11-10-prototype-to-flutter/05-PROTOTYPE.md (U1, U2, U3)

Use the flutter-vertical-slice skill, and flutter-platform-parity for the
prototype comparison. Name them in the PR description.

Goal a user can see: Train shows this week. Today's session opens. After
the workout prayer I log sets with last time's values beside them, use a
rest timer, finish, and see a locked summary. The Workout box on Today
checks itself.

Scope: the Forged program only. Content source follows my L11 answer.

Constraints:
- A session stores, for every exercise, the movement id and the
  prescription text. Never key history by position in the plan.
- Every field change is written to Drift, and flushed when the app is
  paused.
- The clock and rest timer are computed from stored timestamps.
- A session belongs to the date it started on and can be finished after
  midnight.
- The prayer gate follows my Q11 answer, including what Android back does.
- A new user gets a session on his next lifting day, not next week.

Acceptance (each needs a test):
1. Kill the app mid-set and relaunch: every entered set is present and the
   clock is correct.
2. Finish twice: one completion.
3. A session started at 23:50 can be finished at 00:10.
4. Changing the plan afterwards does not alter the finished session.
5. One integration test on the Android emulator covering start, two sets,
   kill, relaunch, finish.

Out of scope: swaps, add exercise, supersets, PR points, share to Rally,
workout image, charts, plan editor, the other three programs.

First give me a plan and the file list, and wait for my go-ahead.

Rules for this task:
- One focused branch and one PR. Never commit to main. Do not push; tell me
  when it is ready and I will authorize the push.
- No new tooling, checkers, templates, ADRs or status pages unless listed
  under Deliver.
- Docs are part of done. In this same PR, update your row in
  docs/knowledge/WORK.md and every page AGENTS.md lists under "Docs are
  part of done" for what you changed, each written as it will be true once
  the PR merges. Never hand-write PR or CI state.
- When the PR is open or updated, run
  python3 tooling/knowledge/live_status.py --pull
  so my Obsidian dashboard is current.
- Report: files changed, every command you ran with its real output, and
  anything you did not run labelled NOT VERIFIED.
```

## When it comes back, check

- [ ] Mid-set kill and relaunch demonstrated on the emulator
- [ ] Sets store a movement id, not a list position
- [ ] Midnight test exists and passes
- [ ] WORK.md row and the PROTOTYPE-PARITY rows are updated to their after-merge state
