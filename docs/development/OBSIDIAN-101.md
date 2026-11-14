# Obsidian 101: home, board, next action

> [!TIP] Three things to remember
> **WORK owns the plan. GitHub owns live PR/check status. Your task worktree owns your edits.**
> Obsidian shows ordinary files. It does not run Flutter, merge code or start an AI by itself.

## Open the right folder

For the daily dashboard, open the stable **main checkout** or its **docs folder** as a vault. Pick one and stay consistent. For a branch-specific lesson or edit, open that branch's folder deliberately; its files are not on main until merged.

| Vault root | Home page | Plugin settings |
|---|---|---|
| Repository folder | `docs/HOME.md` | `<repo>/.obsidian/` |
| `docs` folder | `HOME.md` | `<repo>/docs/.obsidian/` |

The maintainer's registered project vault was the **repository folder** when inspected on 2026-11-13. Its local settings listed Kanban, Homepage and Bases. Those settings do not automatically apply to a separate docs-only vault, another worktree or your friend's machine. This docs update installs or enables no plugins.

**Do:** open HOME and bookmark its tab. If Homepage is already enabled, use its command to set the current page as home. Plain Markdown and links work without plugins.

## Which board am I looking at?

| View | What it actually contains | What you edit |
|---|---|---|
| [WORK](../knowledge/WORK.md) | The canonical project rows, branches and next actions | Your assigned row, with the task change |
| [Generated work board](../knowledge/WORK-BOARD-VIEW.md) | One card per WORK row, in five lanes | Edit WORK, then regenerate; do not drag cards |
| [Teaching board](../knowledge/TEACHING-BOARD.md) | Navigation cards for this lesson; no live product status | Normally just follow the links |
| [Active handoffs Base](../knowledge/ACTIVE-TASKS.base) | Notes in `knowledge/handoffs` with `status: active` | The note's properties, only when accurate |
| [Live status](../knowledge/LIVE.md) | Generated PR/check information and local unpublished commits | Refresh it; never type status into it |

The lesson board uses the **community Kanban plugin** if already enabled. Without it, the same file is headings and links. It deliberately avoids copying work rows into a second status board.

The Base's Kanban is a **different feature**: core Bases in Obsidian 1.14+. It groups handoff notes by `stage`. Dragging a card changes that note's stage; it does **not** change WORK, run a check, merge a PR or prove completion. A table view is the fallback. The Base supports both vault-root choices above.

**An almost empty handoff board can be correct.** Most tasks are work rows or PRs. Only paused work needing a pre-PR handoff gets a handoff note. Completed notes are filtered out. Do not create duplicate task notes just to fill the screen.

## Refresh the project board

The [generated work board](../knowledge/WORK-BOARD-VIEW.md), [setup guide](../knowledge/OBSIDIAN-SETUP.md), and `tooling/knowledge/work_board.py` are included with this course. WORK is the source; the board and HOME's **Do this next** block are derived views.

After changing your assigned row, run these from the repository root:

```sh
python tooling/knowledge/work_board.py --write
python tooling/knowledge/check.py
```

Commit WORK and both generated views with the task. **Expect:** the board's lanes and HOME match WORK, and the check passes. Dragging a generated card only edits the view; the next refresh restores it from WORK. The teaching board holds lesson links and is separate from these generated task statuses.

If these files are absent in an older checkout, update that checkout through the project's normal branch workflow first. Follow the [setup guide](../knowledge/OBSIDIAN-SETUP.md) for plugin settings and prior UI test evidence; do not copy an old generated board into another checkout.

## Follow one task

1. Open WORK. Choose the row the maintainer assigned you.
2. Read its **next action**, branch/PR and linked prompt. A decision answer is design intent, not proof the feature exists.
3. Open that task's code worktree in VS Code and the agent app. Keep one writer per task.
4. Use the [101 prompt](PROJECT-101.md#copy-a-prompt). You can also [run/check it yourself](RUN-COMMANDS.md).
5. In the task branch, update the work row and relevant documentation, regenerate the board views, and run the check above. Inspect `git diff` before sharing.
6. Use the PR for the handoff once it exists. After merge, refresh the main checkout.

If you accidentally edit notes in the main vault, preserve the edit and show the maintainer `git status`. Do not reset it away or start an automatic sync to make the warning disappear.

## Refresh without copying status by hand

From **repo root** (not `docs/`):

```sh
python tooling/knowledge/live_status.py
```

This reads GitHub through the configured `gh` CLI and writes ignored `docs/knowledge/LIVE.md` in the checkout containing branch main. It does **not** list uncommitted work as published commits. `git status` still matters. If GitHub cannot be read, the page says unavailable; that is not “no open work”.

After a merge, to also fast-forward main:

```sh
python tooling/knowledge/live_status.py --pull
```

Mac may use `python3`. This command can update the main checkout even when invoked from another worktree. If local edits conflict, preserve them and resolve deliberately. The refresh can clear an unstaged edit only when it exactly matches the upstream file, then retry the fast-forward; if the retry fails, it restores that edit. Other local edits are reported for the maintainer. Do not hand-edit the generated page or commit it.

**Expect:** a fresh timestamp on LIVE, valid GitHub links, and the correct vault folder. A new uncommitted course in a feature worktree will not appear in the main vault yet.

## A readable lesson layout

- Left: HOME or the teaching board.
- Middle: the 101 page in Reading view, one section at a time.
- Right: VS Code terminal and the running app.
- Bookmark **101**, **Run commands**, **WORK** and **Decisions**.
- Use the numbered course route. Optional detail stays behind links.

No Dataview, Tasks, embedded agent plugin or Obsidian Sync is required for this route. Those may be useful later; a plugin being listed does not verify its behavior in this vault.

## Five-minute acceptance check

- [ ] I can find HOME and return to it.
- [ ] I can follow a teaching card to the command I need.
- [ ] I can find a work row, explain its next action, regenerate the views and pass the freshness check.
- [ ] I know whether I am in main or a task worktree.
- [ ] I can refresh LIVE and distinguish unavailable data from an empty list.
- [ ] I understand that moving a card does not run tests or merge code.

**Sources:** local vault configuration and branch comparison on 2026-11-13; [official Bases Kanban help](https://obsidian.md/help/bases/views/kanban); [community Kanban](https://github.com/community-archive/obsidian-kanban). Actual rendering and drag behavior in your chosen vault still need the short acceptance check above.
