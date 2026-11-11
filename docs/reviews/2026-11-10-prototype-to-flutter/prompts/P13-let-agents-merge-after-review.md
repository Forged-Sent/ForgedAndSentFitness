---
title: "P13 Let agents merge after independent review"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](../00-START-HERE.md) · [All prompts](../03-AGENT-PROMPTS.md) · [Decisions](../01-DECISIONS.md) · [Build plan](../02-BUILD-PLAN.md)

# P13 · Let agents merge after independent review

> [!IMPORTANT] Before you paste
> - [ ] P01 merged: this edits the rule files P01 publishes
> - [ ] A3 answered on the [Decisions](../01-DECISIONS.md) page
> - [ ] You merge this pull request yourself: it changes the merge rule
> - [ ] These answers are filled in on the [Decisions](../01-DECISIONS.md) page: ==A3==

## What you fill in

**Nothing.** Paste it as is. The agent reads your answers from the Decisions page.

## Your answers right now

Live view of the Decisions page (Obsidian only; on GitHub open the [Decisions](../01-DECISIONS.md) page).

![[01-DECISIONS#Your answers]]

## The prompt

Copy everything in the box.

```text
Read AGENTS.md first. Then read my A3 answer in
  docs/reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md
If A3 still contains TODO, stop and ask me. Where my answer differs from
the default rule below, my answer wins; quote the difference back to me
before you write anything.

Task: change the repository rules so that an AI agent may merge a pull
request that passed independent review, inside the limits below. Today
every rule file says agents never merge, and .claude/settings.json denies
gh pr merge.

Default rule (my A3 answer overrides it where they differ):

  Agent merge rule. An AI agent may merge a pull request, using
  gh pr merge --squash, only when ALL of these are confirmed on GitHub
  immediately before merging:
  1. Scope. Every changed file is under mobile/ or docs/, or is a
     prototype path that already qualifies for the lighter prototype
     review. Excluded even there: docs/architecture/ADR-*,
     docs/development/REPOSITORY-SECURITY.md and any 01-DECISIONS.md.
     A pull request that touches anything else is merged by the
     maintainer: tooling/, .github/, AGENTS.md, CLAUDE.md, any nested
     AGENTS.md or CLAUDE.md, .agents/, .claude/, .codex/, .gemini/, MCP
     settings, firebase/, functions/, firebase.json, protected seed files.
  2. Risk. It does not add or change auth, Firebase rules, scoring, group
     privacy, offline sync or health-related data (the high-risk list
     under "Feature contracts"). Those are merged by the maintainer.
  3. Checks. ci-gate is green on the pull request's current head commit.
  4. Review. A tool other than the one that wrote the change reviewed
     that same head commit with the independent-code-review skill. The
     review is recorded as a comment on the pull request naming the
     reviewer tool, the model and the commit SHA. It has no open Blocker
     or High finding, and every review thread is resolved.
  5. State. Not a draft, no merge conflict, no "changes requested".
  6. Record. The pull request description names the tool that wrote the
     change and the tool that reviewed it.
  Never use --admin or any bypass. Never merge with a pending or failing
  check. Never approve, and never change a ruleset or branch protection.
  If the review after one round of fixes still has findings, stop and
  wait for the maintainer. After merging, run
  python3 tooling/knowledge/live_status.py --pull.

Deliver, on a branch from origin/main in its own worktree:
1. AGENTS.md, "Protected operations": add the Agent merge rule and reword
   the sentences that say agents never merge so that they point to it.
   Keep the Agent push rule exactly as it is. Keep "never push to main,
   force-push, approve, bypass".
2. Find every other statement of the old rule and make it agree:
     git grep -n -i -E "self-merge|never merge|must not merge|not merge automatically|merge decision"
   Expect at least CLAUDE.md, mobile/AGENTS.md, dev/AGENTS.md, README.md,
   docs/development/FIRST-CONTRIBUTION.md,
   docs/development/REPOSITORY-SECURITY.md, .github/pull_request_template.md
   and the task-coordinator skill (edit .agents/skills, then run
   python3 tooling/skills/sync.py --fix). Each should state the rule in
   one sentence and link to AGENTS.md, not restate the conditions.
3. .claude/settings.json: move "Bash(gh pr merge*)" from deny to ask, and
   add "Bash(gh pr merge*--admin*)" to deny. Do not add permissions.allow.
4. tooling/policy/agent_merge_check.py with unit tests. Given a pull
   request number it uses gh to check conditions 1, 3, 4 (a comment that
   contains the head SHA and the word "review"), 5, and prints
   ELIGIBLE or NOT ELIGIBLE with the failing condition. It never merges.
   Add to the rule: an agent runs it and pastes its output on the pull
   request before merging. Condition 2 stays a judgment the agent states
   in that same comment.
5. .github/pull_request_template.md: a short "Agent merge" checklist with
   the six conditions.
6. docs/architecture/ADR-0006-agent-merge-after-review.md, short: the
   decision, the limits, and this sentence in substance: "GitHub enforces
   only ci-gate. The scope, risk and review conditions are checked by the
   agent and by agent_merge_check.py, not by GitHub, until a review
   ruleset is enabled." Add the same enforcement note to
   docs/development/REPOSITORY-SECURITY.md.
7. Run every command in the policy job of ci-gate.yml and paste the
   output. If a policy test asserts the old wording, update that
   assertion only; do not weaken any other check.

Out of scope: GitHub rulesets and branch protection, the hosted review
gate, the Agent push rule, user-level Codex or Claude settings, mobile/.

Rules for this task:
- One focused branch and one PR. Never commit to main. Do not push; tell me
  when it is ready and I will authorize the push.
- This pull request is merged by me, not by an agent.
- Report: files changed, every command you ran with its real output, and
  anything you did not run labelled NOT VERIFIED.
```

## When it comes back, check

- [ ] The Agent push rule is unchanged, word for word
- [ ] No rule file still says agents never merge without pointing to the new rule
- [ ] `.claude/settings.json` has no `permissions.allow`; `gh pr merge` is under ask; `--admin` is denied
- [ ] `agent_merge_check.py` reports NOT ELIGIBLE for a pull request that touches `tooling/` or `.github/`, shown by a test
- [ ] Policy-job commands pass, output pasted
- [ ] You read this diff yourself and merged it yourself
