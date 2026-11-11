---
title: "P12 Let CI accept reviewed images and fonts"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](../00-START-HERE.md) · [All prompts](../03-AGENT-PROMPTS.md) · [Decisions](../01-DECISIONS.md) · [Build plan](../02-BUILD-PLAN.md)

# P12 · Let CI accept reviewed images and fonts

> [!IMPORTANT] Before you paste
> - [ ] A2 answered on the [Decisions](../01-DECISIONS.md) page
> - [ ] Run this FIRST: P01, P03 and P04 all add images or fonts and fail `ci-gate` without it
> - [ ] These answers are filled in on the [Decisions](../01-DECISIONS.md) page: ==A2==

## What you fill in

**Nothing.** Paste it as is. The agent reads your answers from the Decisions page.

## Your answers right now

Live view of the Decisions page (Obsidian only; on GitHub open the [Decisions](../01-DECISIONS.md) page).

![[01-DECISIONS#Your answers]]

## The prompt

Copy everything in the box.

```text
Read AGENTS.md first. My decisions are not on main yet; read my A2 answer in
  C:\ws_c\ForgedAndSent\ForgedAndSentFitness-main\docs\reviews\2026-11-10-prototype-to-flutter\01-DECISIONS.md
If A2 still contains TODO, stop and ask me.

Problem: the required ci-gate fails any pull request that adds or changes
a binary file. tooling/review/review.py raises "Binary changes are outside
this text-only AI review" in patch_context(), and the policy job in
.github/workflows/ci-gate.yml runs it with --dry-run on every pull request.
The Android and iOS hosts (launcher icons), the design foundation (fonts,
hero image, golden images) and the review's reference screenshots all
contain binaries.

Task: let reviewed binary assets through without weakening the text
review. Follow my A2 answer for which folders and file types are allowed.

Deliver, on a branch from origin/main in its own worktree:
1. In tooling/review/review.py, treat an allowed binary file the way lock
   files are treated today: leave it out of the text patch and record it in
   the excluded manifest with its path and blob SHA, so the report still
   pins exactly what was not read.
2. Allow only the folders and extensions in my A2 answer. A binary
   anywhere else, or of any other type, must still fail with the current
   message. Keep a size cap per file and fail above it.
3. Tests in tooling/review/: an allowed image passes and appears in the
   manifest; a binary outside the allow-list fails; an oversized file
   fails; the existing secret scan still runs.
4. One paragraph in docs/development/AI-REVIEW-WORKFLOW.md saying what is
   allowed and that these files are pinned by hash, not read.
5. Run every command in the policy job of ci-gate.yml and paste the output.

Out of scope: the hosted review gate workflow, any other policy, mobile/.

Rules for this task:
- One focused branch and one PR. Never commit to main. Do not push; tell me
  when it is ready and I will authorize the push.
- Report: files changed, every command you ran with its real output, and
  anything you did not run labelled NOT VERIFIED.
```

## When it comes back, check

- [ ] A binary outside the allow-list still fails, shown by a test
- [ ] Allowed files appear in the manifest with their hash
- [ ] Policy-job commands pass, output pasted
- [ ] This is a review-policy change: read the diff yourself before merging
