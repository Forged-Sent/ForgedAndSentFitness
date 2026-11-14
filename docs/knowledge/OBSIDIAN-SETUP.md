# Obsidian setup and walkthrough

Obsidian is optional. Every essential link works as plain Markdown on GitHub. The plugins below add a start page, a lane view and two live lists. Settings are per vault and stay on your computer; nothing under `.obsidian/` is shared.

## What each plugin does here

| Plugin (ID) | Use in this project | Without it |
|---|---|---|
| Homepage (`homepage`) | Opens [HOME](../HOME.md) on launch; house icon and command return to it | Bookmark HOME |
| Kanban (`obsidian-kanban`) | Shows [the board view](WORK-BOARD-VIEW.md) as five lanes | The same file reads as five headings with task lists; the [work board](WORK.md) is the source either way |
| Advanced Tables (`table-editor-obsidian`) | In Source mode, **Advanced Tables: Format table at the cursor** lines up a work board table's columns; Tab and Enter move between cells | Edit the table as text, or in Obsidian's own table editor |
| Templater (`templater-obsidian`) | Inserts the [task note template](../templates/task-handoff.md) with title and date | Copy the template file |
| Dataview (`dataview`) | Lists paused task notes on [Resume a task](RESUME.md) | Use the board and the agent prompts |
| Tasks (`obsidian-tasks-plugin`) | Lists unchecked steps in task notes on [Resume a task](RESUME.md) | Read the Steps section of the note |
| Minimal theme, Minimal Theme Settings (`obsidian-minimal-settings`), Style Settings (`obsidian-style-settings`) | Optional reading comfort | Default theme; nothing depends on color or theme |

## Set up once per vault

The vault is one clean `main` checkout: either the checkout folder or its `docs` folder. Paths below show both as **checkout** / **docs**.

1. **Homepage.** Open HOME, then run **Homepage: Set to active file** from the command palette (Ctrl/Cmd+P). The plugin's defaults already open it on startup and replace the tabs left open, so HOME is the first thing you see. Optional: in Settings → Homepage set **Homepage view** to *Reading view*; in an editing view two `work-focus` marker comments are visible around the generated block.
2. **Return home any time.** Click the house icon in the left ribbon, or run **Homepage: Open homepage** from the command palette.
3. **Bookmark fallback.** Open HOME, right-click its tab, choose **Bookmark**. It then sits in the Bookmarks panel whether or not Homepage is enabled.
4. **Templater.** Settings → Templater. Set **Template folder location** to `docs/templates` / `templates`. Leave **Trigger Templater on new file creation** off. Add no startup templates, user scripts or system commands. The templates use only the note title and today's date.
5. **Kanban, Dataview, Tasks, Advanced Tables.** Leave the defaults. Dataview JavaScript queries stay off. Tasks needs no global filter.

## Read it daily

1. Open Obsidian. HOME appears.
2. Read **Do this next**. That is the one action.
3. Want a different task? Open **Work board** and pick a card in **In progress** or **Next**. Each card shows the task, its next action and its branch or pull request.
4. Follow the link in the next action for context. It is usually the agent prompt for that step.
5. Check **Needs your attention** on HOME for pull requests waiting on you.
6. Click the house icon to come back.

Pull request and CI state is not typed into these notes. It comes from the **Needs your attention** block and from GitHub.

## How the board stays current

- **Source:** the tables in [WORK](WORK.md). State, branch or pull request and next action are edited only there.
- **Views:** [the board](WORK-BOARD-VIEW.md) and the block at the top of HOME. Both are generated and both say so.
- **Update path:** change the row in WORK, run `python tooling/knowledge/work_board.py --write`, commit WORK, the board and HOME together.
- **Check:** `python tooling/knowledge/check.py` (run by CI) fails when a view does not match WORK.
- **Your own edit to a row** in Obsidian needs nothing else from you. `live_status.py` lists it under **Needs your attention** and tells the agent that ran it to publish the edit: the agent copies it to a branch, regenerates the views and opens a pull request for your merge. After the merge, `live_status.py --pull` clears the now-duplicate local edit so the `main` checkout keeps updating. To see the board move before then, run `python tooling/knowledge/work_board.py --write` in the checkout.
- **A forgotten row** is caught three ways: CI fails app and backend changes that leave WORK untouched, CI fails any pull request whose branch is named on the board and leaves WORK untouched, and the **Open pull requests** table on the dashboard has a **Work board** column saying whether each pull request changes it.
- **An older branch** that edits WORK without the generator fails CI with the command to run, after merging `origin/main`.
- **Dragging a card** in Obsidian edits only the view file. WORK does not change, the check reports the board as out of date, and the next refresh puts the card back. Undo an accidental drag with the same command.

The board file uses the exact Markdown that Kanban 2.0.51 saves: the `kanban-plugin: board` frontmatter, one `##` heading per lane, `**Complete**` under Done, one list item per card with tab-indented continuation lines, and the `%% kanban:settings` footer with no final newline. The format was read from the installed plugin's serializer and then confirmed in a disposable vault: after the plugin saved the generated board, the only lines that differed were the card that had been dragged. An empty lane keeps its heading.

## When merged notes appear

Notes on a feature branch are visible only in that branch's checkout. After a pull request merges, update the `main` checkout: `python tooling/knowledge/live_status.py --pull` fast-forwards it and refreshes the **Needs your attention** block, and agents run it at the end of every session. Obsidian shows the new files as soon as they are on disk; no restart is needed. If HOME looks old, check that the vault is the `main` checkout and that it has been updated.

## Create a task note

The pull request description is the handoff. Write a task note only for work that pauses across sessions before it has a pull request.

1. Create a note (Ctrl/Cmd+N) and name it after the task, for example `native-hosts`.
2. Run **Move current file to another folder** and pick `knowledge/handoffs`. (Or right-click that folder and choose **New note**.)
3. Run **Templater: Open insert template modal** and pick `task-handoff`. The title and today's date are filled in. `reference-note` is the short template for a reference page.
4. Write the outcome, owner, one next action, any blocker, and the first steps as checkboxes.
5. Before committing, replace `source_ref` and `source_sha` with the real branch and full commit SHA. The knowledge check rejects the placeholders.
6. Set its status to completed when the pull request opens.

The template has the same metadata fields as the [full handoff template](handoffs/TEMPLATE.md), which adds the coordination and review sections for agent work. Without Templater, copy `templates/task-handoff.md` and replace the two `<% … %>` markers by hand.

Checking off a step never changes the task's state. State changes only in WORK. Tasks adds a done date (`✅ 2026-11-10`) to a step you tick from its list.

## Five-minute walkthrough

For someone who has not used this vault. Do not explain anything first; note where they hesitate.

1. Open Obsidian. **Ask:** what is the next action? (Expected: they read **Do this next** on HOME.)
2. **Ask:** where is its context, and which branch or pull request is it on? (Expected: the prompt link in the action; the branch or pull request on the line under it.)
3. **Ask:** what else is ready? (Expected: **Work board**, lanes **Next** and **In progress**.)
4. **Ask:** find a decision the project has made. (Expected: HOME → **Find a note** → **Decisions**.)
5. **Ask:** go back home. (Expected: house icon, or **Homepage: Open homepage**.)

Write down where they hesitated and what was missing. Fixes go in a pull request that edits the page that confused them.

## Reading comfort with Minimal (optional, local)

These are suggestions for one person's vault, not shared settings. Setting names are from Minimal Theme Settings 9.0; they were not exercised in testing.

- **Minimal Theme Settings:** keep **Readable line length** on with a normal line width near 40; line height about 1.5; turn off **Colorful headings**, **Colorful window frame** and **Colorful active states** for less decoration; keep **Text labels for primary navigation** on. Pick a light and a dark scheme with strong text contrast.
- **Style Settings:** leave checkbox icons and heading colors at their defaults. The board and HOME label every lane and action with words, so nothing is lost with the default theme, in grayscale or with custom checkbox styles off.

## Troubleshooting

- **A code block shows instead of a table or list.** Dataview or Tasks is off in this vault. Use the plain links above it.
- **The board shows headings and checkboxes, not lanes.** Kanban is off, or the file was opened as Markdown. It is still readable; use **Open as kanban board** in the note's menu when the plugin is on.
- **HOME did not open on launch.** Check the Homepage path for this vault (step 1), or use the bookmark.
- **Formatting the source table made a large diff.** Advanced Tables pads every cell. Links, states and the generated views are unchanged; commit it or undo it, either is fine.
- **The check says a view is out of date.** Run `python tooling/knowledge/work_board.py --write` and commit the result.

## What was tested

Tested 2026-11-10 on the maintainer's Windows workstation in a disposable vault: a copy of the feature branch's `docs/` plus copies of the installed plugins. The daily `main` vault was not used. Obsidian 1.15.0 (installer 1.9.12). Homepage 4.6.0, Kanban 2.0.51, Advanced Tables 0.23.2, Templater 2.27.0, Dataview 0.5.68, Tasks 8.6.0, Minimal Theme Settings 9.0.0, Style Settings 1.0.9, Minimal theme 9.1.4.

| Check | Result |
|---|---|
| Plugins off (Restricted Mode), default theme: HOME, board view and links in Reading view and Live Preview | Passed |
| Kanban shows five lanes with task, next action and links; an empty lane keeps its heading | Passed, default theme and Minimal |
| Kanban's own save of the generated board differs only by the dragged card | Passed |
| Dragging a card leaves WORK unchanged; the check reports the board view; refresh restores it | Passed |
| Homepage **Set to active file**, then Obsidian reopened | Passed: HOME opened alone, in Reading view |
| House icon and **Homepage: Open homepage** return to HOME | Passed |
| HOME → next action link → context; HOME → Find a note → Decisions | Passed |
| Templater `task-handoff` inserted into a temporary note | Passed: title and date filled in |
| Dataview table lists the temporary note exactly once; Tasks list shows its steps once, with no board cards or template steps | Passed |
| Ticking a step in the Tasks list | Passed: note updated; WORK, board view and HOME unchanged |
| Advanced Tables **Format table at the cursor** on a WORK table in Source mode | Passed on the single-table board that preceded this layout: links, states and generated views unchanged. Not re-run on today's tables; a unit test covers padded tables |
| Bookmark fallback for HOME | NOT VERIFIED |
| Minimal Theme Settings and Style Settings options | NOT VERIFIED (plugins loaded, settings not exercised) |
| Right-click folder → New note for a task note | NOT VERIFIED (Ctrl+N then move was used) |
| The **Needs your attention** block in the test vault | NOT VERIFIED (`LIVE.md` is generated on the workstation and was not present) |
| Rendering on github.com | NOT VERIFIED until the branch is pushed |
| The maintainer's daily `main` vault after merge | NOT VERIFIED |
| Walkthrough with someone new to the vault | NOT VERIFIED |
| macOS and mobile Obsidian | NOT VERIFIED |
