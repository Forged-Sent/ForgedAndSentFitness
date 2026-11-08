# Active work

Curated 2026-11-08 (Phoenix). This board is human navigation, not a lock or live GitHub mirror. Evidence belongs in the linked handoff or PR. [Start an agent session](START-SESSION.md).

[Open the active-task table](ACTIVE-TASKS.base) in Obsidian Bases. Its Kanban view needs Obsidian 1.14+. Obsidian rendering and the collaborator walkthrough remain **NOT VERIFIED**; plain Markdown links are the fallback.

| State | Work | Owner | Blocker / next action |
|---|---|---|---|
| Active | [Hosted review gate](handoffs/flutter-ai-review-gate.md) | Maintainer / gate implementor | PR #46 merged; prepare a small functional test PR to exercise the trusted two-phase publisher and diagnose the comment HTTP 403. First branch push needs the maintainer under the agent push rule. Ruleset is disabled |
| Ready | [Obsidian first-use pilot](handoffs/obsidian-current-and-history.md) | Maintainer + collaborator | Open `docs/` as a vault and try HOME → WORK → START-SESSION → handoff without reading Markdown source |
| Decision needed | Client dependencies and first feature contract | Maintainer | Select state management, navigation and local persistence; record ADR and scope an owner-only offline completion slice |
| Blocked | Durable devotional/workout completion | Flutter builder | Wait for accepted contract and local persistence choice; start with a fake repository and tests |
| Later | Firebase DEV and group authorization | Maintainer + Firebase reviewer | Design deny-by-default rules and emulator tests before cloud data or member rollout |

Use Ready / Active / Blocked / Decision needed / Review / Completed in handoffs. Completed PRs #30, #42, #43, #44 and #46 are recorded in [CURRENT](CURRENT.md) and the linked gate/workspace handoffs; they do not stay on the active board. Refresh GitHub at task start and before publication.
