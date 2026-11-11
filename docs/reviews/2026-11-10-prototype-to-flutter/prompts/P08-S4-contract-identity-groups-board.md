---
title: "P08 S4 contract: sign-in, groups, first shared board (design only)"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](../00-START-HERE.md) · [All prompts](../03-AGENT-PROMPTS.md) · [Decisions](../01-DECISIONS.md) · [Build plan](../02-BUILD-PLAN.md)

# P08 · S4 contract: sign-in, groups, first shared board (design only)

> [!IMPORTANT] Before you paste
> - [ ] P05 merged
> - [ ] Q2, Q3 and Q4 answered
> - [ ] These answers are filled in on the [Decisions](../01-DECISIONS.md) page: ==Q2==, ==Q3==, ==Q4==, ==Q9==, ==Q10==

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
3. docs/features/README.md and TEMPLATE-HIGH-RISK.md
4. docs/design/sign-in.md (approved sign-in design)
5. docs/reviews/2026-11-10-prototype-to-flutter/07-ARCHITECTURE.md (5.6, journeys J4 and J5)
6. docs/reviews/2026-11-10-prototype-to-flutter/04-FINDINGS.md (L1 to L5)
7. Branch arch/firebase-reconciliation, only the ADRs my Q4 answer names.

Task: write the high-risk feature contract for S4. NO implementation code
in this PR.

Deliver docs/features/identity-groups-board/ with requirements.md,
design.md and tasks.md covering:
- Sign-in per the approved design, and adoption of the local profile.
- Group membership documents and how rules read them.
- The event outbox: completion events sent once, document id equal to the
  event id, create-only.
- A Cloud Function that validates events and writes totals. Clients never
  write points.
- What the board shows, per my Q2 answer. How fasting appears or does not,
  per my Q3 answer.
- Firestore rules as a table: actor, resource, read, write, delete.
- Negative tests: another member, another group, a signed-out client, a
  client writing totals.
- Sign-out and account switching: what stays on the device.

Mark every item I have not decided as BLOCKED with the question. Status
stays "proposed" until I approve it.

Out of scope: any code under mobile/, firebase/ or functions/.

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

- [ ] No code, only the three contract files
- [ ] Every undecided item is marked BLOCKED, none guessed
- [ ] The rules table and the negative-test list are both present
