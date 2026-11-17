# Resume a task

Pick a task, open its prompt or note, do its next action. Status lives on the [work board](WORK.md); this page only helps you find the context.

## Start here (works everywhere)

1. Open the [board view](WORK-BOARD-VIEW.md) or the [work board](WORK.md) and choose a card in **In progress** or **Next**.
2. Do the **next action** written on the card. It usually names an [agent prompt](../reviews/2026-11-10-prototype-to-flutter/03-AGENT-PROMPTS.md) to run; the card also shows the branch or pull request.
3. The pull request description is the handoff for work that already has a pull request. Open it from the card or from GitHub.
4. Stuck? Read [Start or resume an agent session](START-SESSION.md), or ask the maintainer.

A task note under `handoffs/` exists only for work that paused across sessions before it had a pull request. The two lists below show those notes. To write one, see Create a task note in the [Obsidian setup guide](OBSIDIAN-SETUP.md).

## Paused task notes (Obsidian with Dataview)

Task notes marked `status: active`, newest first, at most ten. If you see code instead of a table, Dataview is off: use the steps above.

```dataview
TABLE WITHOUT ID file.link AS "Task note", owner AS "Owner", next_action AS "Next action", updated AS "Updated"
WHERE contains(file.path, "knowledge/handoffs/") AND status = "active" AND file.name != "TEMPLATE"
SORT updated DESC, file.name ASC
LIMIT 10
```

An empty table means no task note is marked active. The board still lists every task.

## Open steps in task notes (Obsidian with Tasks)

Unchecked steps inside task notes only. Templates, archives and board cards are left out. Ticking a step here ticks it in the note; it never changes a task's state on the work board.

```tasks
not done
path includes knowledge/handoffs/
path does not include TEMPLATE
group by filename
sort by path
limit 15
```

"0 tasks" means no task note has an open step. Add a due date to a step only when there is a real deadline.
