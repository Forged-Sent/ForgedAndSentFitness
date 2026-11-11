---
title: "P11 Fix review findings (one round)"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](../00-START-HERE.md) · [All prompts](../03-AGENT-PROMPTS.md) · [Decisions](../01-DECISIONS.md) · [Build plan](../02-BUILD-PLAN.md)

# P11 · Fix review findings (one round)

> [!IMPORTANT] Before you paste
> - [ ] A review from P10 exists on the PR

## What you fill in

Replace these in the prompt text before you paste. Everything else comes from the Decisions page.

| Find this | Put in |
|---|---|
| ==`<<FILL: PR number>>`== | The pull request that was reviewed |

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

PR #<<FILL: PR number>> has review findings. Address them once, on the same
branch.

1. List every finding and say for each: fix, or disagree with a reason.
   Wait for my go-ahead on that list.
2. Fix the confirmed defects with the smallest change. Add or correct the
   test that would have caught each one.
3. Do not widen the scope and do not refactor unrelated code.
4. Re-run the checks and paste the output.

If the next review still has findings, stop and wait for me. Do not start
a second round on your own.

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

- [ ] Each finding has a disposition
- [ ] No scope growth in the diff
- [ ] Checks re-run with output
