---
title: "P02 Reconcile the two prototype forks"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](../00-START-HERE.md) · [All prompts](../03-AGENT-PROMPTS.md) · [Decisions](../01-DECISIONS.md) · [Build plan](../02-BUILD-PLAN.md)

# P02 · Reconcile the two prototype forks

> [!IMPORTANT] Before you paste
> - [ ] P01 merged
> - [ ] Only run this if your Q1 answer says to combine v254 with main
> - [ ] These answers are filled in on the [Decisions](../01-DECISIONS.md) page: ==Q1==

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

Task: one prototype-only PR that produces a single reference prototype, as
my Q1 answer describes.

Inputs:
- main:index.html (v238 plus the 2026-11-05 hardening: awaited journal
  saves with retry, mentoring deferred, superset permissions, bodyweight
  volume refresh).
- versions/app-v254.html on remote branch app/v241-bold (the live app).

Deliver:
1. A branch prototype/reconcile-v255 from origin/main.
2. index.html that follows my Q1 answer. Where the two versions disagree,
   do NOT choose silently: list every disagreement in the PR description
   as a table (area, main behavior, v254 behavior, what you kept, why).
3. Bring versions/app-v239..v254.html across unchanged, and add
   versions/app-v255.html as the reconciled snapshot. Never rewrite an
   older version file.
4. All four dev/test_*.cjs regression tests pass. If a v254 feature breaks
   one, stop and show me the conflict.
5. Run python3 dev/make_preview.py and describe what you checked by eye.

Out of scope: mobile/, tooling/, seed/, any new scoring rule. Flag, do not
adopt, v254 point sources that 01-DECISIONS.md does not approve (Bold Step,
Instagram share).

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

- [ ] The disagreement table exists and nothing was merged silently
- [ ] Four regression tests pass, output pasted
- [ ] No file under `versions/` older than v255 changed
- [ ] New point sources are flagged, not adopted
