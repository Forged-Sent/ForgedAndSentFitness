---
title: "P14 Archive the Copilot and Gemini rule files"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](../00-START-HERE.md) · [All prompts](../03-AGENT-PROMPTS.md) · [Decisions](../01-DECISIONS.md) · [Build plan](../02-BUILD-PLAN.md)

# P14 · Archive the Copilot and Gemini rule files

> [!IMPORTANT] Before you paste
> - [ ] P01 merged
> - [ ] A1 answered on the [Decisions](../01-DECISIONS.md) page
> - [ ] You merge this pull request yourself: it changes `.github/` and `tooling/`
> - [ ] These answers are filled in on the [Decisions](../01-DECISIONS.md) page: ==A1==

## What you fill in

**Nothing.** Paste it as is. The agent reads your answers from the Decisions page.

## Your answers right now

Live view of the Decisions page (Obsidian only; on GitHub open the [Decisions](../01-DECISIONS.md) page).

![[01-DECISIONS#Your answers]]

## The prompt

Copy everything in the box.

```text
Read AGENTS.md first. Then read my A1 answer in
  docs/reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md
If A1 still contains TODO, stop and ask me.

Task: archive the GitHub Copilot and Gemini CLI rule files. I am not using
those tools now and plan to later, so the files must be recoverable, and
nothing may keep pointing at files that are gone.

Files to archive:
  GEMINI.md
  .gemini/settings.json
  .github/copilot-instructions.md
  .github/agents/*.agent.md
  .github/instructions/*.instructions.md
  .github/prompts/*.prompt.md

Deliver, on a branch from origin/main in its own worktree:
1. Move them with git mv into
   docs/knowledge/archive/2026-11-10-copilot-gemini-rules/
   keeping each file's original relative path underneath, with the leading
   dot dropped from folder names (.github -> github, .gemini -> gemini) so
   nothing there is picked up as live configuration.
2. Make the archived copies pass python3 tooling/knowledge/check.py
   (archived notes need status: archived and superseded_by). Do not weaken
   that check.
3. README.md in that folder: why and when they were archived; a table of
   archived path -> original path; how to restore one tool (git mv back,
   remove the archive front matter); and what to bring up to date before
   using it again: compare it with the current AGENTS.md, CLAUDE.md and
   .agents/skills, and put its checks back into tooling/policy/check.py.
4. Find everything that still refers to the moved files and update it:
     git grep -n -i -E "GEMINI\.md|\.gemini|copilot-instructions|\.github/(agents|instructions|prompts)"
   Expect tooling/policy/, tooling/knowledge/, tooling/review/,
   tooling/ci/, tooling/onboarding/, tooling/architecture/, the Windows
   and macOS setup scripts, .github/CODEOWNERS and docs. Remove or adjust
   a check only where it exists for the archived files. Keep every other
   check as strict as it is. List each change and its reason in the pull
   request description.
5. Run every command in the policy job of ci-gate.yml and paste the
   output.

Out of scope: Codex and Claude rule files, skills, mobile/, any new
tooling.

Rules for this task:
- One focused branch and one PR. Never commit to main. Do not push; tell me
  when it is ready and I will authorize the push.
- This pull request is merged by me, not by an agent.
- Update your row in docs/knowledge/WORK.md in this same PR.
- Report: files changed, every command you ran with its real output, and
  anything you did not run labelled NOT VERIFIED.
```

## When it comes back, check

- [ ] Every archived file is listed in the README with its original path
- [ ] The README says how to restore a tool and what to update first
- [ ] `git grep` for the old paths finds only the archive folder and history pages
- [ ] No check was weakened except the ones that existed for these files
- [ ] Policy-job commands pass, output pasted
