# Active work

Curated 2026-11-09 (Phoenix). This board is human navigation, not a lock or live GitHub mirror. Evidence belongs in the linked handoff or PR. [Start an agent session](START-SESSION.md).

[Open the active-task table](ACTIVE-TASKS.base) in Obsidian Bases. Its Kanban view needs Obsidian 1.14+. Obsidian rendering and the collaborator walkthrough remain **NOT VERIFIED**; plain Markdown links are the fallback.

| State | Work | Owner | Blocker / next action |
|---|---|---|---|
| Blocked | [Hosted review gate](handoffs/flutter-ai-review-gate.md) | Maintainer / gate implementor | PR #48 is open; `ci-gate` passed, but hosted handoff POST returns HTTP 403 and exact-head review status remains pending. Diagnose and retest; ruleset remains disabled |
| Ready | [Obsidian first-use pilot](handoffs/obsidian-current-and-history.md) | Maintainer + collaborator | Open `docs/` as a vault and try HOME → WORK → START-SESSION → handoff without reading Markdown source |
| Active | First Flutter feature contract and native hosts | Maintainer / Flutter builder | PR #47 merged the stack ADR and CLI guide; Android licenses accepted. Define the first feature contract and publish reviewed hosts in separate PRs |
| Blocked | Durable devotional/workout completion | Flutter builder | Wait for first feature contract and aligned toolchain; start with a fake repository and tests |
| Later | Firebase DEV and group authorization | Maintainer + Firebase reviewer | Design deny-by-default rules and emulator tests before cloud data or member rollout |

Use Ready / Active / Blocked / Decision needed / Review / Completed in handoffs. Completed PRs #30, #42, #43, #44, #46 and #47 are recorded in [CURRENT](CURRENT.md) and the linked gate/workspace handoffs; they do not stay on the active board. Refresh GitHub at task start and before publication.
