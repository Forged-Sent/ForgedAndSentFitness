# Pull requests and next steps

Updated 2026-11-09 (Phoenix). This is the human-readable snapshot for the Obsidian vault. Click a PR to see its live checks and discussion before deciding to merge. Keep this one page current when a PR opens, changes state, or merges; put detailed evidence in the PR or its task handoff.

## On GitHub

| PR | State | What it adds | What happens next |
|---|---|---|---|
| [#48 — Hosted AI review acceptance](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/48) | **Open · hold** | Head `97acf7a` passed `ci-gate`. Its hosted Claude PASS posted the implementor handoff before final exact-head success; a stale-head dispatch was rejected. | Verify the current native Codex/Dependabot route plus hosted failure, retry, base-change, shared-head and producer-identity cases. The [activation checklist](../development/FLUTTER-AI-REVIEW-GATE.md#activation-checklist) remains open. Do not merge #48 or enable the separate ruleset yet. |
| [#47 — Flutter client stack and CLI plan](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/47) | **Merged** | Records the accepted Riverpod, go_router and Drift direction in [ADR-0005](../architecture/ADR-0005-flutter-client-stack.md), plus the [CLI guide](../development/FLUTTER-CLAUDE-CLI.md). | Implement the packages in a focused Flutter PR after the first feature contract and native hosts are ready. |
| [#46 — Two-phase review publisher](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/46) | **Merged** | Makes a functional PASS wait for the implementor handoff before final review success. | #48 supplies hosted acceptance; #46's merge alone did not prove handoff delivery. |

Only #48 was open when this page was updated. [PR #51](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/51) has merged its publisher hardening into `main`. The live [pull request list](https://github.com/Forged-Sent/ForgedAndSentFitness/pulls) takes precedence over this snapshot.

## Prepared locally, not yet PRs

| Work | Where it stands | Next step |
|---|---|---|
| Android/iOS native hosts | Local `codex/native-host-skeleton` branch. Android debug, profile and release builds passed locally; iOS compilation has not been verified from these tracked hosts. | Maintainer first-pushes the branch, then open and review its focused PR. |
| Synthetic Today completion | Local `codex/today-demo-contract` branch. The small fake-repository flow passed local analysis, tests and an Android walkthrough; it is not in `main`. | Publish the feature contract and branch after the host work is ready; verify hosted CI and review before merge. |

The [active work board](WORK.md) shows owners and blockers. The [system map](../architecture/SYSTEM.md) distinguishes implemented boundaries from planned ones. Local branches and this page do not make unmerged app behavior available on `main`.
