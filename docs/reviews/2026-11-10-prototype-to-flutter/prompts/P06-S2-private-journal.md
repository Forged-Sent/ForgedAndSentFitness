---
title: "P06 Private journal"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](../00-START-HERE.md) · [All prompts](../03-AGENT-PROMPTS.md) · [Decisions](../01-DECISIONS.md) · [Build plan](../02-BUILD-PLAN.md)

# P06 · Private journal

> [!IMPORTANT] Before you paste
> - [ ] P05 merged
> - [ ] Q8 answered
> - [ ] These answers are filled in on the [Decisions](../01-DECISIONS.md) page: ==Q8==

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
3. docs/reviews/2026-11-10-prototype-to-flutter/07-ARCHITECTURE.md (journey J3)
4. The prototype's journal save logic in index.html: jrDraftId, jrWrite,
   jrSave, jrAction. It is the behavior to match.

Use the flutter-vertical-slice skill, and flutter-platform-parity for the
prototype comparison. Name them in the PR description.

Goal a user can see: "Write it down" under the devotional saves to a
private journal. A Journal page lists entries; I can edit and delete them.

Constraints:
- Storage, encryption and sign-out behavior follow my Q8 answer exactly.
- A new entry gets a stable id once, so a retry can never create a second
  entry.
- "Saved" is shown only after the local transaction commits. A failed save
  keeps my text on screen and offers retry.
- Journal text never appears in any scoring input, shared document, log
  line or analytics event.

Acceptance (each needs a test):
1. Save, close the database, reopen: the entry is there.
2. Force a save failure: text is kept, retry works, exactly one entry.
3. Edit and delete work and survive restart.
4. A test proves no journal field is passed to any Firebase call.
5. Completing the devotional does not depend on writing anything.

Out of scope: prayer tabs, tags, search, export, sync, sharing.

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

- [ ] The failed-save path was demonstrated, not just asserted
- [ ] No journal text in logs or Firebase calls
- [ ] Devotional still completes with an empty journal box
- [ ] WORK.md row and the PROTOTYPE-PARITY rows are updated to their after-merge state
