# Forged & Sent — project dashboard

Open this page first, in Obsidian, from the `main` checkout. Pick the one action below, or choose where to go.

<!-- work-focus:start (generated from knowledge/WORK.md; edit that table, then run: python tooling/knowledge/work_board.py --write) -->
## Do this next

> **Run prompt [P13](reviews/2026-11-10-prototype-to-flutter/prompts/P13-let-agents-merge-after-review.md) after its merge check is fixed (see Later)**
>
> Task: Agents may merge after review · Lane: Next

Board now: Next 1 · In progress 0 · Waiting 4 · Done 8 · Later 29.
<!-- work-focus:end -->

## Where to go

- **Work board** → [Board view](knowledge/WORK-BOARD-VIEW.md) (Kanban lanes in Obsidian, headings elsewhere) · [Source table](knowledge/WORK.md) (change status here)
- **Resume a task** → [Agent prompts for each step](reviews/2026-11-10-prototype-to-flutter/03-AGENT-PROMPTS.md) · [Paused task notes and open steps](knowledge/RESUME.md)
- **Find a note** → [Decisions](reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md) · [Plan and why](reviews/2026-11-10-prototype-to-flutter/00-START-HERE.md) · [System and ADRs](architecture/SYSTEM.md) · more under **Find things** below
- **Pull requests** → **Needs your attention**, the next section · [Live list on GitHub](https://github.com/Forged-Sent/ForgedAndSentFitness/pulls)

## Needs your attention

![[LIVE]]

> [!NOTE]
> The block above is generated from GitHub: open pull requests, failing checks, local branches that are not on GitHub yet, and decisions still open. If it is empty or old, run `python tooling/knowledge/live_status.py --pull` in the repository. Agents run it at the end of every session. On GitHub this block shows as plain text.

## Find things

| I want to… | Open |
|---|---|
| Make the open product decisions | [Decisions](reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md) |
| Hand a step to Codex or Claude | [Agent prompts](reviews/2026-11-10-prototype-to-flutter/03-AGENT-PROMPTS.md) |
| Understand the plan and why | [Prototype-to-Flutter review](reviews/2026-11-10-prototype-to-flutter/00-START-HERE.md) |
| See which prototype screens are built | [Prototype parity](knowledge/PROTOTYPE-PARITY.md) |
| See colors, type and shared components | [Design system](design/DESIGN-SYSTEM.md) |
| See what exists in code and what is planned | [System and ADRs](architecture/SYSTEM.md) |
| Specify or review a feature | [Feature contracts](features/README.md) |
| See live pull requests and checks on GitHub | [Pull requests](https://github.com/Forged-Sent/ForgedAndSentFitness/pulls) |
| Find historical evidence or rationale | [History index](knowledge/HISTORY.md), on demand |
| Set up Obsidian for this vault | [Obsidian setup and walkthrough](knowledge/OBSIDIAN-SETUP.md) |
| Set up a workstation | [Start here](development/START_HERE.md) |
| Start Flutter work with Claude CLI | [Flutter CLI guide](development/FLUTTER-CLAUDE-CLI.md) |
| Open the prototype or Architecture Atlas | [Workspace guide](development/KNOWLEDGE-WORKSPACE.md) |
| Agent entrypoint | [Index](knowledge/INDEX.md) |

## How these pages stay current

- **The block under the title is generated** from the [work board](knowledge/WORK.md): the first In progress row, or the first Next row when nothing is in progress, then up to two more. To change it, edit the row and run `python tooling/knowledge/work_board.py --write`. CI fails when the block or the [board view](knowledge/WORK-BOARD-VIEW.md) is out of date.
- **Moving a card in the board view changes nothing.** The board view is a view. Edit the row on the work board.
- **Edit a row yourself and leave it.** The dashboard lists the edit under Needs your attention, and the next agent session publishes it as a pull request for your merge.
- **Lasting pages** (board, parity, features, design, architecture) are updated by each pull request in the same pull request as the work. `AGENTS.md` lists which page goes with which kind of change, and CI checks the ones a machine can check.
- **Pull request and CI state** is never typed by hand. It comes from the generated **Needs your attention** block.
- A checkbox does not approve product behavior. Decisions are recorded on the Decisions page and merged.

## Dedicated repository vault

Open one clean, current `main` checkout as an Obsidian vault, either the checkout folder or its `docs` folder, and open `HOME.md`. Obsidian settings and plugins are per vault, so use the same folder each time; the [setup guide](knowledge/OBSIDIAN-SETUP.md) says what each plugin adds, and nothing essential needs one. For this workstation, the stable `main` checkout is `C:\ws_c\ForgedAndSent\ForgedAndSentFitness-main`. After a pull request merges, `live_status.py --pull` fast-forwards that checkout so its notes are current. Local `.obsidian` state stays ignored. Avoid editing the same note in multiple worktrees. This public vault must contain no credentials, personal journals, real member records, prayers or health data.
