# Task handoff template (copy to a new task-specific file)

Reuse one file for the task across sessions. Put current outcome, blocker and next action in their sections; append only concise dated evidence when history is useful. The coordinator links it from WORK while active, then HISTORY at completion. Avoid a new note per chat turn.

Do not commit a note with placeholder SHA or claim tests were run. Required YAML metadata in active notes:

```yaml
---
status: active
updated: YYYY-MM-DD
owner: unassigned
stage: Inbox
next_action: one concrete next action
source_ref: feature/task-branch
source_sha: full-40-character-git-commit
profile: auto
coordinator_model: unassigned
coordinator_provider: unassigned
author_providers: []
---
```

Use `profile: auto`, `routine`, `deep` or `research` according to the [routing policy](../AGENT-WORKSPACE.md). Replace the date, branch and full SHA with verified values before using this as an active handoff. `unassigned` and empty lists mean no assignment or verified record yet, not proof of access or independence. Record all providers that actually author changes, including a coordinator that edits files.

## Coordination and bounded assignments

- Active lead: unassigned; actual model/provider: unassigned; routing reason: not recorded.
- Availability evidence: UNVERIFIED (plugin installation, authenticated account and exact model entitlement must each be checked when relevant). The Open alias is unresolved until its exact configured model/provider is verified.
- Implementation writer: unassigned; branch/worktree and owned paths: unassigned.
- Author providers: not recorded yet; reconcile with metadata before selecting reviewers.
- Task budget/stop condition: unassigned. A budget is a limit, not authorization for new spending, subscriptions, installations or accounts.

For each delegated assignment, record the owner and actual model/provider, specific question or outcome, allowed files/interfaces, excluded scope, input SHA/evidence, acceptance checks, output location, time/token/cost bounds and stop condition. Keep one implementation writer and one active lead for this task. A research assignment must answer a bounded question and return sources and a recommendation; it must not silently expand implementation scope.

For a lead handoff, record outgoing/incoming model and provider, transfer time, exact source SHA and uncommitted diff evidence, completed checks, pending decisions, owned files and the next executable action. End outgoing ownership before incoming ownership starts. Markdown is an evidence record, not an atomic lock. Do not silently substitute an unavailable explicitly requested exact model.

## Goal and acceptance conditions
What the user requested, relevant issue/PR, and specific measurable behavior.

## Verified observations
Exact paths/lines or test outputs at source_sha. Separate facts from proposed design.

## Work performed
Diff/commit/PR links, design choices, rejected alternatives.

## Test and platform matrix
Commands executed and results, plus every check NOT VERIFIED and why.

## Separate review and evidence

- Reviewer(s), actual model/provider and scope: unassigned.
- Independent eligibility: NOT VERIFIED. Exclude every author provider under the current review runner; a different model or session from the same provider does not qualify.
- Reviewed source SHA and exact diff/artifact identity: not recorded.
- Deterministic checks run before review: not recorded.
- Findings, evidence locations and resolution/recheck results: not recorded.
- Missing coverage and reason: NOT VERIFIED until review evidence is recorded; add a second independent specialist for high-risk changes under this session workflow.

Record changed code after review and any required rerun; an older reviewed SHA does not cover a newer diff. Review is advisory and never satisfies human approval or authorizes pushing/merging. Do not invent reviewer access when no eligible provider is available.

## Risks, blockers and decisions
Credentials/data safety, platform gaps, unapproved product decisions.

## Next action
One precise executable next step; include ownership and links.

After merge set status: completed and include merged PR. When replaced set status: superseded with successor link.
