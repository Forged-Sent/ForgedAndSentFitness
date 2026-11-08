---
status: archived
updated: 2026-11-05
owner: Codex research team
source_ref: codex/obsidian-current-and-history
source_sha: 1ef8ce67ae15f78801e234f71aaad20511a9c913
superseded_by: docs/knowledge/AGENT-WORKSPACE.md
---

# Obsidian task workspace: plugin research

Research date: 2026-11-05. **Proposal, not approved configuration. All software behavior locally NOT VERIFIED.** No plugins installed, settings changed, or agents launched. Repository baseline: `codex/obsidian-current-and-history`, HEAD `1ef8ce67ae15f78801e234f71aaad20511a9c913`, with existing uncommitted knowledge edits. This report owns only this file.

Read INDEX, CURRENT, WORK, AGENT-OPERATIONS and root AGENTS before research. Repository Markdown remains authoritative; Obsidian is the optional interface. The existing WORK ledger is orientation, not a lock or live CI mirror.

## Recommendation

Start with **zero community plugins**: Properties + Bases + Templates + Bookmarks, with Workspaces optional. Use a task note for each substantial software task and display the same notes in a filtered table or board. This minimizes setup and avoids a separate board whose status disagrees with the handoff. Core Bases stores data in Markdown properties and views in `.base` definitions. [Bases documentation](https://obsidian.md/help/bases)

Current official documentation includes a **native Bases Kanban view requiring Obsidian 1.14+**. Group by the note's status property; moving a card updates that property. Check both developers' installed versions before promising this interface. On older installations use a table/Markdown WORK page until an app update is deliberately evaluated. Do not group by folder: dragging could move the underlying note. [Kanban documentation](https://obsidian.md/help/bases/views/kanban)

The least complicated friend-facing flow is: bookmark HOME, open My work, open a task, read its next action, then copy its prepared prompt into the chosen agent app. Do not make card movement launch an agent or imply product approval, green tests, push permission, or merge authorization. A later explicit launcher is a separate implementation/security decision.

## Capability and evidence comparison

| Component | Useful job | Recommendation and evidence |
|---|---|---|
| Properties | Edit owner, state, next action and links through fields | Core foundation. Types apply across the vault by property name; use a small flat schema and avoid nested YAML. [Official docs](https://obsidian.md/help/properties) |
| Bases | Editable, filtered views over task notes | Default dashboard; do not add Dataview just to recreate this table. Core maintenance reduces dependency count, but is not proof of compatibility on the installed app. [Official docs](https://obsidian.md/help/bases) |
| Templates | Consistent task body and initial fields | Default capture; inserts text into the active note. Date/title variables are supported. Edit template YAML in Source mode to avoid variable damage. [Official docs](https://obsidian.md/help/plugins/templates) |
| Bookmarks | One-click HOME, current work and saved searches | Default navigation; no additional homepage plugin needed. [Official docs](https://obsidian.md/help/plugins/bookmarks) |
| Workspaces | Restore a convenient tab/sidebar arrangement | Optional personal convenience, not task ownership or Git worktree management. [Official docs](https://obsidian.md/help/plugins/workspaces) |
| Tasks | Collect checkbox actions across notes; due dates and recurrence | Add only if cross-note checkbox scheduling becomes a real need. Task-note state remains separate from checklist completion. [User guide](https://publish.obsidian.md/tasks/Introduction) |
| Community Kanban | Markdown-backed boards | Do not adopt for a new setup. Original URL redirects to `community-archive/obsidian-kanban`; README explicitly seeks maintainers. Native Bases covers this proposal's board need. This is a maintenance concern, not a claim of malware or proof the repository is technically archived. [Repository](https://github.com/community-archive/obsidian-kanban) |
| QuickAdd | Prompted note creation and capture | First optional addition if basic Templates prove awkward. Configure one New task capture, not arbitrary scripts or agent execution. It supports templates, capture and macros. [Official project docs](https://quickadd.obsidian.guide/) |
| Dataview | More expressive queries over metadata/tasks | Defer until a concrete query exceeds Bases. DQL/JavaScript introduce another authoring surface for a nontechnical friend. [Project docs](https://blacksmithgu.github.io/obsidian-dataview/) |

Maintenance snapshot: Tasks release page listed 8.6.0, with compatibility changes and preceding fixes; QuickAdd listed 2.33.1 with a settings-save fix; Dataview listed 0.5.70, whose notes still call it beta. These are evidence of published changes, not local validation or a support guarantee. Verify actual release manifests/minimum app versions before installation. Tasks' release prose includes potentially confusing compatibility wording, so do not infer the minimum solely from its changelog. [Tasks releases](https://github.com/obsidian-tasks-group/obsidian-tasks/releases), [QuickAdd releases](https://github.com/chhoumann/quickadd/releases), [Dataview releases](https://github.com/blacksmithgu/obsidian-dataview/releases)

Popularity is not the decision criterion: stars/downloads do not establish active maintenance, security review, recoverability or Windows/Mac behavior. Prefer direct evidence: maintainer status, recent relevant fixes, release compatibility, documented data format, security advisories and an actual acceptance run. No plugin source/security audit was performed here.

## Proposed data and agent boundary

Use one existing handoff/task note as the state-bearing record: stable ID, title, owner, state, next action, contract/issue link, branch and exact source SHA. Keep test commands/results and review findings in its body. Avoid copying the same mutable fields into multiple ledgers; WORK should link to these records or eventually derive its view from them. Migration is not implemented by this research.

For a friend, expose only title, state, owner and next action prominently. Put agent instructions and detailed evidence lower in the task. A prepared launch prompt should identify the repository/worktree, task note and intended role, require baseline verification, and say which operations are authorized. The orchestrator may coordinate author and non-author reviewer; a review is advisory and must never become a merge approval. A Markdown owner field cannot prevent two agents from editing simultaneously.

Community plugins inherit Obsidian's access and cannot reliably be restricted to individual permissions. They can access computer files, network services and install programs. Restricted mode disables third-party execution. Therefore a dedicated vault is useful organization, **not a security sandbox**. Keep credentials and private member data outside this workflow; do not treat plugin directory review as proof of safety. [Obsidian plugin security](https://obsidian.md/help/Extending%2BObsidian/Plugin%2Bsecurity)

## Acceptance gates before adopting

1. Record Obsidian versions on Windows and Mac; confirm the selected view exists. Test in a disposable copy of project notes, not the personal vault reached by the current MCP connection.
2. Create a task from the template, find it in My work, change status, reopen Obsidian, and inspect the Markdown/Git diff. Confirm no duplicate state or unexpected file movement.
3. Disable optional plugins and confirm task text, next action and evidence remain readable. Verify backup/restore and the intended Git conflict workflow; do not claim synchronization proven from one-machine editing.
4. Have the friend perform creation, next-action discovery and prompt copying without terminal knowledge. If creation is the only friction, trial QuickAdd alone and repeat these checks.
5. Before any agent launcher, test cancellation, duplicate clicks, wrong repository, dirty worktree and stale SHA. Task text must not become executable shell text. Preserve explicit authorization and the project's push/CI/review-thread rules. None of these launcher checks has run.

Documentation method: Context7 resolve selected `/websites/obsidian_md_help` (official help, high source reputation); query confirmed Bases Kanban's 1.14 requirement and property update behavior. Direct official help and upstream repositories supplied the remaining evidence. Sources were fetched on the research date; recheck before configuration. No claim of tested, proven, approved or production-ready integration is made.
