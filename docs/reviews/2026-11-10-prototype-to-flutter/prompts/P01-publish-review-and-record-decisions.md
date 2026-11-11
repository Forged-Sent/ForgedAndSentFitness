---
title: "P01 Publish the review, my decisions and the rules cleanup"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](../00-START-HERE.md) · [All prompts](../03-AGENT-PROMPTS.md) · [Decisions](../01-DECISIONS.md) · [Build plan](../02-BUILD-PLAN.md)

# P01 · Publish the review, my decisions and the rules cleanup

> [!IMPORTANT] Before you paste
> - [ ] You filled in the five TODO answers on the [Decisions](../01-DECISIONS.md) page
> - [ ] Run it in the main checkout, where the changes are waiting uncommitted
> - [ ] P12 merged, or leave the `reference/` images out: this pull request contains PNG files
> - [ ] These answers are filled in on the [Decisions](../01-DECISIONS.md) page: ==Q1==, ==Q2==, ==Q5==, ==Q6==, ==Q7==

## What you fill in

**Nothing.** Paste it as is. The agent reads your answers from the Decisions page.

## Your answers right now

Live view of the Decisions page (Obsidian only; on GitHub open the [Decisions](../01-DECISIONS.md) page).

![[01-DECISIONS#Your answers]]

## The prompt

Copy everything in the box.

```text
Work in this checkout: C:\ws_c\ForgedAndSent\ForgedAndSentFitness-main
It is on main with changes that are NOT committed yet. git diff --stat
should show exactly these 17 tracked files:
- AGENTS.md, CLAUDE.md, .gitignore, docs/HOME.md
- .agents/skills/<name>/SKILL.md for flutter-architecture-review,
  flutter-platform-parity, flutter-vertical-slice, knowledge-steward and
  task-coordinator
- docs/knowledge/ AGENT-OPERATIONS.md, CURRENT.md, INDEX.md, PR-STATUS.md,
  PROTOTYPE-PARITY.md and WORK.md
- tooling/knowledge/check.py and test_check.py
and git status should show these as untracked:
- docs/reviews/2026-11-10-prototype-to-flutter/   (the review folder)
- mobile/CLAUDE.md, dev/CLAUDE.md, docs/design/DESIGN-SYSTEM.md,
  tooling/knowledge/live_status.py and test_live_status.py
One more file may show as changed: docs/knowledge/ACTIVE-TASKS.base.
Obsidian reformatted it; it is not part of this work. Do not stage it and
do not restore it; mention it in your report.
Eight more files (the .claude/ skill mirrors, one subagent, the PR
template and one workflow) are saved in the review folder's apply/
subfolder. They may already have been copied into .claude/ and .github/;
if so, those eight also show as modified and step 3 only re-checks them.
Two more things are expected and are not part of this work:
- an untracked logs/ folder (MCP server logs). Never stage it.
- up to 19 files under docs/ that show as modified with an EMPTY diff
  (line endings only). Run git update-index --refresh. If any still
  show, confirm git diff is empty for each one and run git restore on
  exactly those files. If any of them has a real diff, stop and show me.
The list and the reason for each change are in
docs/reviews/2026-11-10-prototype-to-flutter/09-AGENT-RULES-AUDIT.md.

Task: publish these as one pull request. Do not rewrite them. Do not decide
anything yourself. If any of Q1, Q2, Q5, Q6 or Q7 in 01-DECISIONS.md still
contains TODO, stop and ask me.

Steps:
1. Run git status. If it shows changes outside the list above, stop and
   show me.
2. git switch -c chore/review-rules-and-dashboard   (this carries the
   uncommitted changes onto the branch; nothing is lost)
3. Put the eight files that could not be written remotely into place
   (.claude/ and .github/ are protected locations). They are saved in
   docs/reviews/2026-11-10-prototype-to-flutter/apply/ in two folders that
   mirror the repository without the leading dot:
   - copy everything under apply/claude/ to the same relative path under
     .claude/   (5 skill files and agents/flutter-builder.md)
   - copy everything under apply/github/ to the same relative path under
     .github/   (pull_request_template.md and
     workflows/claude-code-review.yml)
   The exact file list and copy commands are in
   apply/APPLY-THESE-FILES.md. Overwrite the existing files; do not
   create any file that is not in that list.
   - run python3 tooling/skills/sync.py --check   (must pass; if it does
     not, stop and show me, do not run --fix)
   - show me git diff --stat for .claude/ and .github/, then delete the
     apply/ folder so it is not committed
4. docs/knowledge/PROTOTYPE-PARITY.md: replace the "Prototype baseline: not
   yet recorded" paragraph with the baseline from my Q1 answer and its
   commit.
5. docs/architecture/SYSTEM.md: add one short paragraph saying the
   ADR-0001..0019 set on branch arch/firebase-reconciliation is not on
   main, that its numbers collide with main's ADR-0001..0005, and that
   01-DECISIONS.md records which of those decisions I carry forward.
6. Run every command in the "policy" job of .github/workflows/ci-gate.yml
   and paste the output. Fix only failures caused by steps 3 to 5.
7. Commit as two commits: (a) the review folder, (b) everything else.
8. Run python3 tooling/knowledge/live_status.py and show me the page.

Do not push. Tell me when it is ready and I will authorize the push.

After it merges, in this checkout: git switch main, then
python3 tooling/knowledge/live_status.py --pull

Out of scope: index.html, versions/, mobile/lib, new ADR files, any change
to the wording of the pending edits beyond steps 4 and 5.

Report: files changed, check output, and anything in the review that
contradicts my answers.
```

## When it comes back, check

- [ ] `git status` matched the expected list before branching
- [ ] All eight `apply/` files were copied into `.claude/` and `.github/`, `sync.py --check` passes, and the `apply/` folder is gone
- [ ] Your answers appear word for word, nothing invented
- [ ] All policy-job commands pass, output pasted
- [ ] The live status page generated and lists your open pull requests
- [ ] After merge: the checkout is back on `main` and pulled
