---
title: "P05 Today and Devotional, real and saved"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](../00-START-HERE.md) · [All prompts](../03-AGENT-PROMPTS.md) · [Decisions](../01-DECISIONS.md) · [Build plan](../02-BUILD-PLAN.md)

# P05 · Today and Devotional, real and saved

> [!IMPORTANT] Before you paste
> - [ ] P04 merged
> - [ ] These answers are filled in on the [Decisions](../01-DECISIONS.md) page: ==Q5==, ==Q6==, ==Q7==, ==Q9==, ==Q10==

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
3. docs/architecture/ADR-0005-flutter-client-stack.md
4. docs/reviews/2026-11-10-prototype-to-flutter/07-ARCHITECTURE.md (5.4 boundaries, journey J1)
5. docs/reviews/2026-11-10-prototype-to-flutter/02-BUILD-PLAN.md, step S1

Use the flutter-vertical-slice skill, and flutter-platform-parity for the
prototype comparison. Name them in the PR description.

Goal a user can see: Today shows the date, mission line, progress ring and
box list. Tapping Devotional opens today's real reading. Scrolling to the
end enables Amen. Amen checks the box, and it is still checked after the
app is killed and reopened. Undo works.

Design constraints (not negotiable in this PR):
- Repository contract takes an owner id and a local date and returns a
  Stream.
- A completion is an append-only event with a client-generated id, written
  in the same Drift transaction as the derived day state.
- One LocalDate type and one injected clock. The date is stamped when the
  tap happens (my Q9 answer).
- Owner id follows my Q10 answer.
- Devotional content is bundled from seed/devotionals.json, with scripture
  text per my Q7 answer.
- Whether point values are displayed follows my Q5 answer. The streak
  follows my Q6 answer.
- Nothing is written to Firebase. Keep the test that feature code imports
  no Firebase SDK.

Acceptance (each needs a test):
1. Complete, close the database, reopen: still complete.
2. Replaying the same event id leaves exactly one completion.
3. With the clock moved past midnight, Today is a new unchecked day and
   yesterday counts toward the streak.
4. Amen is disabled until the end of the scroll, and reachable by a screen
   reader.
5. Other boxes render and are visibly not yet active.
6. One integration test on the Android emulator: complete, kill, relaunch.

Reuse the view model and test patterns from the Today demo branch (Run
settings). Replace its screen and its demo copy.

Out of scope: habits, first orders, mission-complete dialog, sync, journal,
sign-in, any server.

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
- Also report the resolved package versions from pubspec.lock.
```

## When it comes back, check

- [ ] You personally killed and relaunched the app and the box stayed checked
- [ ] Six acceptance tests exist and pass
- [ ] No Firebase import in feature code
- [ ] Resolved versions of Riverpod, go_router and Drift are listed
- [ ] WORK.md row and the PROTOTYPE-PARITY rows are updated to their after-merge state
