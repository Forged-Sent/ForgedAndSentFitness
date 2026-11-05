---
name: task-coordinator
description: Coordinate a scoped repository task using task-based model selection, implementation agents, deterministic checks, separate review and a resumable Obsidian handoff.
---
# Task coordinator

Use for a delegated development task or a request to start/resume a task from the project vault. Follow root AGENTS.md; read docs/knowledge/INDEX.md, CURRENT.md and only the assigned handoff/contract. Model routing is defined in [AGENT-WORKSPACE](../../../docs/knowledge/AGENT-WORKSPACE.md#coordinator-routing).

## Start and route

1. Verify worktree, base/head SHA, dirty files, live task dependencies and relevant checks. Reuse one handoff per task; keep unrelated work intact. Identify acceptance conditions and decisions that block dependent work.
2. Classify the task using the routing table. Discover actual models/tools in the current host or provider; distinguish listed model, authenticated account and successful invocation. Select within available authorized options. Log profile, actual coordinator/model/provider, selection reason, workers and review plan before dispatch. Family labels are not executable model IDs.
3. Honor a specifically requested model; if unavailable, report that and ask only about the blocked substitution. For automatic routing use an available candidate without repeated permission questions. Do not change subscriptions, authenticate accounts or enable paid API routes merely to satisfy routing. "Open" stays ineligible until its exact model/provider is supplied and verified.
4. One active lead owns this task. Multiple leads may handle independent tasks with separate worktrees and explicit file/interface boundaries. A lead change requires a handoff and retirement of the prior lead's task ownership; no competing instructions to the same writer.

## Dispatch and integrate

5. Assign one implementation agent a bounded packet: outcome, contract, source/base SHA, owned files, interface constraints, applicable skills, acceptance commands, exclusions, output evidence and stop conditions. Parallelize only independent research or disjoint work; keep shared schemas/rules/ADRs under one writer. If delegation tools are absent, report a single-agent fallback rather than invent workers.
6. Research only material uncertainty: name the question, primary-source requirements, scope/budget and what result ends the investigation. Store the conclusion in the task, detailed evidence through HISTORY. Do not promote research into an accepted product decision.
7. Have the writer run deterministic checks before review. Track every author/provider, including a coordinator that edits code. Use the existing review runner and independent-code-review skill for exact-diff review; exclude all author providers when selecting runner reviewers. A second model from the same provider is not a runner-independent reviewer.
8. Require separate review for meaningful work under the requested team process and a second independent specialist for high-risk work. If unavailable, continue authorized local implementation/checks/handoff; record review coverage NOT VERIFIED and surface the exception to the maintainer without claiming review passed or waiving it yourself. Never invent review evidence or falsify `--author`; its single field cannot capture multiple authors. Resolve confirmed findings and rerun affected checks/reviews after edits. Review does not grant merge approval.
9. Keep the human informed with plain-language progress, concrete decisions, working demonstrations and limitations. Reuse repository push/release constraints; choosing a model or moving a card grants no external-action permission.

## Close or transfer

10. Update the handoff with actual models/providers, base/head and diff evidence, owned files, executed tests, review findings, remaining risks and one next action. Set lifecycle/stage honestly; a locally complete edit is not merged or released. Update WORK/CURRENT only for changed coordination facts. Preserve historical audit snapshots.
11. If handing to another lead, checkpoint first, stop old dispatch, list remaining workers and their ownership, and have the new lead verify the checkpoint against the real checkout before resuming. Record the actual new model; a role instruction cannot change a session's model.

Completion: the scoped outcome and evidence are inspectable, unresolved decisions/coverage are explicit, and a fresh agent can resume from the task note without chat history.
