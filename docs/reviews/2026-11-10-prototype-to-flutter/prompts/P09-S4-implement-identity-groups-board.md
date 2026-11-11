---
title: "P09 S4 implementation"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](../00-START-HERE.md) · [All prompts](../03-AGENT-PROMPTS.md) · [Decisions](../01-DECISIONS.md) · [Build plan](../02-BUILD-PLAN.md)

# P09 · S4 implementation

> [!IMPORTANT] Before you paste
> - [ ] P08 merged and you changed its status to approved
> - [ ] These answers are filled in on the [Decisions](../01-DECISIONS.md) page: ==Q2==, ==Q3==, ==Q4==

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
3. docs/features/identity-groups-board/ (requirements, design, tasks). It
   must say status: approved. If it does not, stop.

Task: implement that contract and nothing beyond it. Use the
flutter-vertical-slice skill for client code.

Goal a user can see: I sign in. My local profile is adopted. My completion
events sync. A server-computed board for my group, as defined by my Q2 answer.

Acceptance:
1. Emulator rules tests pass, including every negative case in the
   contract.
2. Completions made in airplane mode appear on the board after reconnect,
   exactly once.
3. Signing out and into a second account shows none of the first account's
   data.
4. A modified client cannot change any total.
5. Everything runs against the Firebase emulators with a demo-* project.
   No cloud project, no flutterfire configure, no deploy.

Out of scope: Rally, campaigns, challenges, video proof, Fuel, health,
owner tools.

First give me a plan and the file list, and wait for my go-ahead. Ask for
a non-author review before I merge (prompt P10).

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

- [ ] Rules test output is pasted, negatives included
- [ ] Airplane-mode sync shown once, not twice
- [ ] Second-account isolation demonstrated
- [ ] A different AI provider reviewed it (P10)
