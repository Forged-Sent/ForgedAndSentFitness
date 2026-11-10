# Current project state

Curated 2026-11-08 (Phoenix). This is orientation, not a live GitHub mirror. Read [WORK](WORK.md) next; use [HISTORY](HISTORY.md) only for a specific past decision or regression.

## Verified baseline

- [PR #30](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/30) merged the repository-backed Obsidian workspace and agent handoffs. The cross-origin Atlas preview finding was fixed and its review thread resolved. Open `docs/` as its own Obsidian vault; its visual rendering and a friend's first-use walkthrough remain **NOT VERIFIED**.
- [PR #43](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/43) merged the trusted Dependabot review route, and [PR #44](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/44) fixed a timestamp precision bug found during hosted validation. [PR #42](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/42) was the first real Dependabot PR to receive a clean exact-head Codex gate status; it merged after `ci-gate` passed.
- The separate `Functional Flutter AI review` ruleset remains **disabled**. [PR #46](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/46) merged after required `ci-gate` passed. The new two-phase publisher needs a hosted acceptance PR to prove that a failed handoff cannot leave a green review status. The test branch `codex/review-gate-hosted-acceptance` is local; the maintainer accepted three low review comments as follow-up and will make its first push. See the [gate handoff](handoffs/flutter-ai-review-gate.md) and live GitHub for status.
- The production mobile client is still a Flutter scaffold. CI builds temporary native hosts; reviewed Android/iOS hosts, a durable local workout store, a production Firebase project and user-facing feature slices have not been committed.

## Accepted direction and decisions still needed

The user chose a repository-backed Obsidian vault, current-first notes, history on demand, and task-dependent coordinators with separate implementers and reviewers. The [agent workspace](AGENT-WORKSPACE.md) and task-coordinator skill describe this process. Embedded agent dispatch from Obsidian is **NOT VERIFIED**.

The maintainer accepted [ADR-0005's client stack](../architecture/ADR-0005-flutter-client-stack.md): Riverpod, go_router and Drift/native SQLite. This ADR is on a local documentation branch, not yet merged. No package or feature code has been added. The first feature contract still needs scope and acceptance tests. The default Windows Flutter is 3.44.8 while CI pins 3.47.8; a separate pinned 3.47.8 SDK now passes the five scaffold tests without changing the lockfile. Use its explicit path, as described in the [CLI guide](../development/FLUTTER-CLAUDE-CLI.md). The first small feature candidate is owner-only devotional/workout completion with a fake repository, followed by locally durable events and idempotent sync. Firebase DEV and group authorization come after that boundary is tested.

## Next actions

1. Finish the [hosted review gate](handoffs/flutter-ai-review-gate.md): maintainer first-pushes its local test branch, then test the hosted handoff, failure/retry cases and remaining routes. Activate the disabled ruleset only after the acceptance checklist passes.
2. Run the Obsidian first-use pilot with the maintainer and nontechnical collaborator; record confusing navigation or missing handoff fields in the [workspace handoff](handoffs/obsidian-current-and-history.md).
3. Publish the client-stack ADR, align the local Flutter SDK to CI, define the first feature contract, then commit reviewed Android/iOS hosts and build one offline-first Flutter vertical slice. [WORK](WORK.md) tracks owners and blockers.

GitHub checks, PR threads and repository rules must be read live before any push or merge. This page does not grant approval or certify integrations that have not been exercised.
