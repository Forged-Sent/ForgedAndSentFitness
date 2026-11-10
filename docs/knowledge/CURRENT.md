# Current project state

Curated 2026-11-09 (Phoenix). This is orientation, not a live GitHub mirror. Start with [Pull requests and next steps](PR-STATUS.md), then [WORK](WORK.md); use [HISTORY](HISTORY.md) only for a specific past decision or regression.

## Verified baseline

- [PR #30](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/30) merged the repository-backed Obsidian workspace and agent handoffs. The cross-origin Atlas preview finding was fixed and its review thread resolved. Open `docs/` as its own Obsidian vault; its visual rendering and a friend's first-use walkthrough remain **NOT VERIFIED**.
- [PR #43](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/43) merged the trusted Dependabot review route, and [PR #44](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/44) fixed a timestamp precision bug found during hosted validation. [PR #42](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/42) was the first real Dependabot PR to receive a clean exact-head Codex gate status; it merged after `ci-gate` passed.
- The separate `Functional Flutter AI review` ruleset remains **disabled**. [PR #46](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/46) merged the two-phase publisher, and [PR #51](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/51) hardened its permissions and output checks. [PR #48](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/48) is open and held for hosted acceptance. On head `97acf7a`, the Claude route posted an implementor handoff before final exact-head success, and `ci-gate` passed. A stale-head dispatch was rejected before review. The current native Codex route and remaining failure/retry and identity cases are **NOT VERIFIED**; use the [PR status page](PR-STATUS.md) and live GitHub for details.
- The production mobile client is still a Flutter scaffold. CI builds temporary native hosts; reviewed Android/iOS hosts, a durable local workout store, a production Firebase project and user-facing feature slices have not been committed.

## Accepted direction and decisions still needed

The user chose a repository-backed Obsidian vault, current-first notes, history on demand, and task-dependent coordinators with separate implementers and reviewers. The [agent workspace](AGENT-WORKSPACE.md) and task-coordinator skill describe this process. Embedded agent dispatch from Obsidian is **NOT VERIFIED**.

The maintainer accepted [ADR-0005's client stack](../architecture/ADR-0005-flutter-client-stack.md): Riverpod, go_router and Drift/native SQLite. [PR #47](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/47) merged the ADR and [CLI guide](../development/FLUTTER-CLAUDE-CLI.md). No selected package or feature code is in `main` yet. Native hosts and a synthetic Today flow have been prepared on separate local branches, with no PRs; see [PR status](PR-STATUS.md). The first feature contract still needs publication and hosted checks. Firebase DEV and group authorization come after the local app boundary is tested.

## Next actions

1. Continue [PR #48's hosted acceptance](PR-STATUS.md): exercise the current native Codex/Dependabot route and the remaining hosted failure, retry, base-change, shared-head and status-producer cases. Keep #48 unmerged and the separate ruleset disabled until the checklist is verified. After gate code merges, run follow-up hosted acceptance against that `main` version before activation.
2. Run the Obsidian first-use pilot with the maintainer and nontechnical collaborator; record confusing navigation or missing handoff fields in the [workspace handoff](handoffs/obsidian-current-and-history.md).
3. Publish and review the native-host and first synthetic Today branches as separate PRs. The accepted client stack is a decision, not yet a merged package implementation. [WORK](WORK.md) tracks owners and blockers.

GitHub checks, PR threads and repository rules must be read live before any push or merge. This page does not grant approval or certify integrations that have not been exercised.
