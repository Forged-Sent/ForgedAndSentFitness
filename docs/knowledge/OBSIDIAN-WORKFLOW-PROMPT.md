# Claude prompt for the Obsidian workspace

Copy this note from the next heading to the end into a Claude project session with access to ForgedAndSentFitness.

## Assignment

Build the ADHD-friendly project workspace in the ForgedAndSentFitness repository. A teammate opening Obsidian after a day away should be able to pick one concrete action, see who is working on what, and find the context for a task without opening several notes. Use the plugins already installed. Put the shared workspace in the repository so the maintainer sees it in Obsidian from an up-to-date `main` checkout.

## Start from the current project

1. Read [AGENTS.md](../../AGENTS.md), [CLAUDE.md](../../CLAUDE.md), [HOME](../HOME.md), [INDEX](INDEX.md), [CURRENT](CURRENT.md), [WORK](WORK.md), and [LIFECYCLE](LIFECYCLE.md). Check the latest `origin/main`, open PRs touching the dashboard or rules, and the checkout's status before changing files. The project may already have a dashboard refresh underway. Build on the merged layout and preserve parallel work.
2. Use a clean feature branch or worktree. Scope the change to shared notes, templates, and any small view generation or checks needed. Use a draft PR targeting `main` under the existing publication rules. Keep the maintainer's daily `main` checkout and the personal vault out of feature-branch testing.
3. Confirm the exact Obsidian version and plugin IDs in the project vault. Obsidian settings are per vault. Identify which plugins are available in the test vault and use the Markdown fallback for any you cannot exercise. Use version-matched Context7 where available and upstream documentation for the installed versions.

## Build the homepage

- Start at [HOME](../HOME.md). In the first screen, show one recommended next action when WORK identifies one, a short list of up to three ready or active items with concrete actions, and direct links to the board and notes. When there is no next action, point to the board for triage. Use labels, short headings, and whitespace so the page works without color cues.
- Let a teammate choose **Work board**, **Find a note**, or **Resume a task** from HOME. Use the existing knowledge index and task links. Surface current project material first, with decisions, architecture, feature contracts, and history available by link. Keep the existing GitHub or generated PR-attention path reachable.
- Document how to set Homepage to open `HOME.md` on startup in the project vault, plus the bookmark fallback. Make the essential navigation work in Reading view, default theme, and ordinary Markdown on GitHub.

## Make progress visible

- Use **Next**, **In progress**, **Waiting**, **Done**, and **Later** as the Kanban lanes. Map each actual WORK state and any separate WORK sections on the current base to exactly one lane. For example, Ready goes to Next, Active to In progress, Blocked or Paused to Waiting, Completed to Done, and deferred work to Later. Give waiting items the reason and what would unblock them. Keep recent completions visible and preserve older outcomes through the source board, Git history or the existing history index. Show an empty lane when there are no verified items for it.
- Keep WORK authoritative for project work status and next actions. Use the community Kanban plugin to display a generated Markdown board with one card per work item, linked back to its source row or task context. Put the task title and next action on the card. Label the board as a view and make the update path obvious from HOME and the setup guide. Change status in WORK and regenerate. Moving a card in the generated view does not update WORK, so the shared workflow uses the source edit to move it.
- Inspect the installed Kanban plugin's saved Markdown in a disposable vault before defining the generator's output. Make refresh deterministic, avoid a second editable status field, and keep the view current when WORK changes. If the generated board is checked in for immediate viewing from `main`, provide a stale-output check in the same change and keep the existing Markdown board as the fallback. Prove that repeating the refresh produces the same output and that a WORK transition moves exactly one card.
- Keep project phase separate from checklist completion. Use GitHub or the existing generated status for live PR and CI state. Update project docs in the same PR as the work they describe, or use a standalone docs-only PR targeting `main`. Give the maintainer a short desktop or Obsidian walkthrough for daily reading and explain when merged docs appear after updating the `main` checkout.

## Put the installed plugins to work

| Plugin or theme | Use in the project |
|---|---|
| [Homepage](https://github.com/mirnovov/obsidian-homepage) | Open HOME on launch and return to it from the command palette or ribbon. |
| [Kanban](https://github.com/community-archive/obsidian-kanban) | Show the five progress lanes from WORK. Keep links clickable in the board and its Markdown fallback. |
| [Advanced Tables](https://github.com/tgrosinger/advanced-tables-obsidian) | Make the canonical WORK table easier to navigate and edit in Obsidian. Keep it valid Markdown and test that formatting a row preserves its links and status. |
| [Templater](https://silentvoid13.github.io/Templater/) | Provide a small task or handoff template for outcome, owner, next action, blocker, and evidence links. Reuse the existing handoff fields when that template applies. Provide a lightweight reference-note template only if the existing notes lack one. Use explicit template insertion and simple date/title substitution. |
| [Dataview](https://blacksmithgu.github.io/obsidian-dataview/) | Use scoped DQL for a compact index of current notes or active handoffs. Limit results, use stable sorting, and exclude templates, history and generated board cards. Preserve direct links for the same entry points when Dataview is off or a query is empty. |
| [Tasks](https://publish.obsidian.md/tasks/Introduction) | Use standard Markdown checkboxes for concrete steps inside task notes. If a Tasks query adds value, scope it to incomplete checklist actions in task notes and exclude templates, archives and Kanban cards. Use due dates only when there is a real deadline. |
| [Minimal](https://github.com/kepano/obsidian-minimal) and [Style Settings](https://github.com/mgmeyers/obsidian-style-settings) | Document a readable local setup with clear contrast, modest line length, and subdued decoration. Keep lane and action labels legible with the default theme and without custom checkbox styles. |

Keep shared content in tracked Markdown and any reviewed view definitions. Keep `.obsidian/`, plugin binaries, device preferences, and personal notes local. Use native links and plain Markdown for essential actions. Use declarative queries and templates that require no shell hooks, account access, or agent launching.

## Verify and hand off

1. Run `python tooling/knowledge/check.py`, `git diff --check`, and the repo checks that cover changed paths. Validate all new links in the preview and Markdown fallback.
2. In a disposable project vault, reopen Obsidian and verify Homepage lands on HOME. Find the next action, open its card and context, and find a reference note from HOME. Create a temporary note with Templater and confirm the intended Dataview or Tasks view finds it exactly once. Check off a step and confirm the project's WORK status stays as written.
3. With a sample WORK row, exercise Next → In progress → Waiting → In progress → Done and regenerate after each change. Verify each card appears in the intended lane, the waiting reason is visible, and no card is duplicated or lost. Check deferred work, empty lanes, Markdown fallback, and the default theme. Remove test fixtures from shared docs.
4. Make one brief walkthrough for someone unfamiliar with the vault. Ask them to find their next action, open its context, locate a decision, and return home. Report the Obsidian and plugin versions actually tested, and mark any desktop, collaborator, or plugin checks you could not run **NOT VERIFIED**.
5. In the implementation PR, update the Obsidian workspace row in WORK and any navigation or rules changed by the rollout. Report what was built, tests run, open questions, and the merge target. Follow the repository's publication rules and leave the merge decision to the maintainer.
