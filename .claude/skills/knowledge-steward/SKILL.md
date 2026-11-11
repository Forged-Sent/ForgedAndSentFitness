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
