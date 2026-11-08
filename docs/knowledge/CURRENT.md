# Current project state

Curated 2026-11-08 (Phoenix). This is orientation, not a live GitHub mirror. Read [WORK](WORK.md) next; use [HISTORY](HISTORY.md) only for a specific past decision or regression.

## Verified baseline

- [PR #30](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/30) merged the repository-backed Obsidian workspace and agent handoffs. The cross-origin Atlas preview finding was fixed and its review thread resolved. Open `docs/` as its own Obsidian vault; its visual rendering and a friend's first-use walkthrough remain **NOT VERIFIED**.
- [PR #43](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/43) merged the trusted Dependabot review route, and [PR #44](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/44) fixed a timestamp precision bug found during hosted validation. [PR #42](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/42) was the first real Dependabot PR to receive a clean exact-head Codex gate status; it merged after `ci-gate` passed.
- [PR #46](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/46) merged the two-phase hosted review gate on November 8 as `61e1b7d`. Its required `ci-gate` passed. Hosted Claude returned an exact-head advisory PASS, but the publisher's PR comment still failed with HTTP 403, so the review workflow was red. The old trusted policy wrote a green review status before that failure; the merged code now requires the handoff before final success. The separate `Functional Flutter AI review` ruleset remains **disabled**. No open PR currently exercises the merged path. See the [gate handoff](handoffs/flutter-ai-review-gate.md) for the current acceptance plan.
- The production mobile client is still a Flutter scaffold. CI builds temporary native hosts; reviewed Android/iOS hosts, a durable local workout store, a production Firebase project and user-facing feature slices have not been committed.

## Accepted direction and decisions still needed

The user chose a repository-backed Obsidian vault, current-first notes, history on demand, and task-dependent coordinators with separate implementers and reviewers. The [agent workspace](AGENT-WORKSPACE.md) and task-coordinator skill describe this process. Embedded agent dispatch from Obsidian is **NOT VERIFIED**.

Before app runtime work, the maintainer still needs to choose the state management, navigation and durable local persistence dependencies, then record the choice in an ADR. Riverpod, go_router and Drift are proposals, not approvals. The first small feature candidate is owner-only devotional/workout completion with a fake repository, followed by locally durable events and idempotent sync. Firebase DEV and group authorization come after that boundary is tested.

## Next actions

1. Finish the [hosted review gate](handoffs/flutter-ai-review-gate.md): the maintainer makes the first push of the focused functional test PR because an agent cannot satisfy the PR-head/green-`ci-gate` push rule before the PR exists. Then inspect the trusted publisher's HTTP 403 diagnostics and pending status, and exercise the remaining routes and failure cases. Activate the disabled ruleset only after the acceptance checklist passes.
2. Run the Obsidian first-use pilot with the maintainer and nontechnical collaborator; record confusing navigation or missing handoff fields in the [workspace handoff](handoffs/obsidian-current-and-history.md).
3. Decide the client stack and first feature contract; then commit reviewed Android/iOS hosts and build one offline-first Flutter vertical slice. [WORK](WORK.md) tracks owners and blockers.

GitHub checks, PR threads and repository rules must be read live before any push or merge. This page does not grant approval or certify integrations that have not been exercised.
