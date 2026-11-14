---
name: knowledge-steward
description: Keep the work board current inside the pull request that changes it, and retire stale notes without losing history. Use when a task starts, finishes or changes status, or when a note is out of date.
---
# Work board and notes
1. `docs/knowledge/WORK.md` is the one board. Find the row for your task before changing anything.
2. In the same pull request as the work, edit that row so it reads as it will be true once the pull request merges: state, branch or pull request link, next action. Then run `python3 tooling/knowledge/work_board.py --write` and commit the regenerated `docs/knowledge/WORK-BOARD-VIEW.md` and `docs/HOME.md` with it; never edit those two views by hand or move a card to change status. Do not open a separate "refresh" pull request.
3. Edit only your own row. Do not write CI results or open/merged state into the repository; link to GitHub for that.
4. The pull request description is the handoff: what changed, checks actually run, what is NOT VERIFIED, the next action. Create `docs/knowledge/handoffs/<task>.md` only for work that pauses across sessions before a pull request exists, and set its status to completed when the pull request opens.
5. Verify any claim in a note against code and tests at a named commit before repeating it.
6. To retire a note, find its inbound links, mark it superseded with a successor link and date, and update those links in the same pull request. Never rewrite `versions/` snapshots, accepted ADR history, generated CODE-MAP, or another agent's row.
7. Update every other page that describes what the pull request changed, using the table under "Docs are part of done" in AGENTS.md. Say what is planned and what is implemented.
8. Never hand-write pull request or CI state. After opening or updating a pull request, and at the end of a session, run `python3 tooling/knowledge/live_status.py --pull` to refresh the dashboard's generated block.
9. Run `python3 tooling/knowledge/check.py` and report NOT VERIFIED for anything you could not run.

## The maintainer's own edits
The maintainer edits `docs/knowledge/WORK.md` in Obsidian, in the `main` checkout, and does not commit. `python3 tooling/knowledge/live_status.py --pull` prints an `ACTION:` line when it sees that. Publish the edit for him before you finish.
1. Leave the `main` checkout as it is: no commit, stash, checkout or reset there.
2. Save his edit as a patch outside the repository: `git -C <main checkout> diff --output=<temp folder>/board.patch -- docs/knowledge/WORK.md`.
3. In your own worktree, on a new branch from `origin/main`, run `git apply --3way <temp folder>/board.patch`. If it does not apply cleanly, stop and show him the conflict.
4. Run `python3 tooling/knowledge/work_board.py --write`. If it reports a problem with a row, do not guess a fix: tell him which row and why.
5. Commit `docs/knowledge/WORK.md`, `docs/knowledge/WORK-BOARD-VIEW.md` and `docs/HOME.md` with a message that says the edit is his. Ask him for the push, then open the pull request.
6. After it merges, run `python3 tooling/knowledge/live_status.py --pull` again. It puts back an uncommitted edit that is already on `main`, then fast-forwards the `main` checkout.
For any other file the `ACTION:` line lists, tell him and ask whether to publish it the same way.
