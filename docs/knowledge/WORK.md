# Active work

Curated 2026-11-09 (Phoenix). This board is human navigation, not a lock or live GitHub mirror. See [Pull requests and next steps](PR-STATUS.md) for the PR overview. Evidence belongs in the linked handoff or PR. [Start an agent session](START-SESSION.md).

[Open the active-task table](ACTIVE-TASKS.base) in Obsidian Bases. Its Kanban view needs Obsidian 1.14+. Obsidian rendering and the collaborator walkthrough remain **NOT VERIFIED**; plain Markdown links are the fallback.

| State | Work | Owner | Blocker / next action |
|---|---|---|---|
| Active | [Hosted review gate](PR-STATUS.md) | Maintainer / gate implementor | PR #48's Claude handoff and exact-head success passed on `1fd91af`; verify the remaining activation cases and recheck each new head. PR stays held and the ruleset disabled |
| Ready | [Obsidian first-use pilot](handoffs/obsidian-current-and-history.md) | Maintainer + collaborator | Open `docs/` as a vault and try HOME → WORK → START-SESSION → handoff without reading Markdown source |
| Ready | Native Android/iOS hosts | Maintainer / Flutter builder | Local branch passed Android builds; maintainer first-pushes it, then opens a focused PR. iOS host compilation from this branch remains unverified |
| Ready | Synthetic Today completion | Maintainer / Flutter builder | Local fake-repository flow passed local checks; publish the feature contract and branch after the native-host PR is ready |
| Blocked | Durable devotional/workout completion | Flutter builder | Wait for the first synthetic slice and a local storage contract; Drift is accepted direction but not in `main` |
| Later | Firebase DEV and group authorization | Maintainer + Firebase reviewer | Design deny-by-default rules and emulator tests before cloud data or member rollout |

Use Ready / Active / Blocked / Decision needed / Review / Completed in handoffs. Recently merged PRs #46, #47, #49, #50 and #51 are recorded in GitHub; they do not stay on the active board. Refresh GitHub at task start and before publication.
