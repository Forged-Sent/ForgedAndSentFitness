---
title: "P00 Orchestrator kickoff: Claude builds, Codex reviews"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](../00-START-HERE.md) · [All prompts](../03-AGENT-PROMPTS.md) · [Decisions](../01-DECISIONS.md) · [Build plan](../02-BUILD-PLAN.md)

# P00 · Orchestrator kickoff: Claude builds, Codex reviews

> [!IMPORTANT] Before you paste
> - [ ] Every answer on the [Decisions](../01-DECISIONS.md) page is filled in
> - [ ] Claude Code is open in the main checkout; the Codex CLI is installed and signed in
> - [ ] You stay available: it stops for every push, and for the merges that are yours

## What you fill in

**Nothing.** Paste it as is. The agent reads your answers from the Decisions page.

## The prompt

Copy everything in the box.

```text
You are the orchestrator for this repository. Work in
C:\ws_c\ForgedAndSent\ForgedAndSentFitness-main and follow AGENTS.md.

Read docs/reviews/2026-11-10-prototype-to-flutter/03-AGENT-PROMPTS.md and
01-DECISIONS.md. If an answer a prompt needs still says TODO, stop and ask.

Run these prompts one at a time, in this order:
  P12, P01, P13, P14, P02, P03, P04, P05
Each one is a page under docs/reviews/2026-11-10-prototype-to-flutter/prompts/.
Skip one that is already merged. For each prompt:

1. Build. Follow the prompt exactly. Claude Code writes the change; you
   may hand the building to one subagent. One writer per pull request.
2. Check. Run the checks the prompt lists and show the real output.
   Label anything you did not run NOT VERIFIED.
3. Review with Codex. Stage any new files, then run
     py -3 tooling/review/review.py --reviewers codex --author claude --minimum 1
   and read .review/summary.md. Fix Blocker and High findings once on the
   same branch, rerun the checks, then rerun the review on the new HEAD.
   If that second review still has findings, stop and show me.
   On a large change you may also run the review at natural checkpoints;
   only the review of the final HEAD counts.
4. Push. Stop and ask me before every push. After I authorize it, push
   the branch, open the pull request, and post the review summary as a
   pull request comment naming the reviewer, the model and the commit SHA.
5. Refresh. Run python tooling/knowledge/live_status.py --pull.
6. Merge. P12, P01, P13 and P14 are mine to merge: stop and wait. Once
   P13 has merged, follow the Agent merge rule in AGENTS.md for the rest;
   where it does not allow you to merge, stop and wait for me.
7. Do not start the next prompt until the previous pull request has
   merged.

Never force-push, push to main, approve, or bypass a check. If the Codex
CLI is missing or not signed in, stop and tell me; do not review your own
change. If anything in the checkout is not what the prompt expects, stop
and show me instead of working around it.
```

## When it comes back, check

- [ ] It stopped before each push and waited for you
- [ ] Each pull request has a Codex review comment naming the commit SHA
- [ ] It did not merge P12, P01, P13 or P14 itself
- [ ] The dashboard shows each pull request after it was opened
