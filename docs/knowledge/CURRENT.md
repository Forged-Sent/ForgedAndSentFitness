# Current project state

Curated 2026-11-07 (Phoenix; GitHub merge timestamps are November 8 UTC). This is orientation, not a live GitHub mirror. Read [WORK](WORK.md) next; use [HISTORY](HISTORY.md) only for a specific past decision or regression.

## Verified baseline

- [PR #30](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/30) merged the repository-backed Obsidian workspace and agent handoffs. The cross-origin Atlas preview finding was fixed and its review thread resolved. Open `docs/` as its own Obsidian vault; its visual rendering and a friend's first-use walkthrough remain **NOT VERIFIED**.
- [PR #43](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/43) merged the trusted Dependabot review route, and [PR #44](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/44) fixed a timestamp precision bug found during hosted validation. [PR #42](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/42) was the first real Dependabot PR to receive a clean exact-head Codex gate status; it merged after `ci-gate` passed.
- The separate `Functional Flutter AI review` ruleset remains **disabled**. Its status producer has passed a real Codex route, but hosted acceptance is incomplete. PR handoff comments failed with GitHub HTTP 403 on `POST issues/{PR}/comments` despite the publish job declaring `issues: write`. A failed first Dependabot dispatch can still require a maintainer retry. See the [gate handoff](handoffs/flutter-ai-review-gate.md).
- The production mobile client is still a Flutter scaffold. CI builds temporary native hosts; reviewed Android/iOS hosts, a durable local workout store, a production Firebase project and user-facing feature slices have not been committed.

## Accepted direction and decisions still needed

The user chose a repository-backed Obsidian vault, current-first notes, history on demand, and task-dependent coordinators with separate implementers and reviewers. The [agent workspace](AGENT-WORKSPACE.md) and task-coordinator skill describe this process. Embedded agent dispatch from Obsidian is **NOT VERIFIED**.

Before app runtime work, the maintainer still needs to choose the state management, navigation and durable local persistence dependencies, then record the choice in an ADR. Riverpod, go_router and Drift are proposals, not approvals. The first small feature candidate is owner-only devotional/workout completion with a fake repository, followed by locally durable events and idempotent sync. Firebase DEV and group authorization come after that boundary is tested.

## Next actions

1. Finish the [hosted review gate](handoffs/flutter-ai-review-gate.md): diagnose the handoff-comment 403, test failure/retry cases, and activate the disabled ruleset only after the acceptance checklist passes.
2. Run the Obsidian first-use pilot with the maintainer and nontechnical collaborator; record confusing navigation or missing handoff fields in the [workspace handoff](handoffs/obsidian-current-and-history.md).
3. Decide the client stack and first feature contract; then commit reviewed Android/iOS hosts and build one offline-first Flutter vertical slice. [WORK](WORK.md) tracks owners and blockers.

GitHub checks, PR threads and repository rules must be read live before any push or merge. This page does not grant approval or certify integrations that have not been exercised.
