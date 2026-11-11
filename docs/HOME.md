# Forged & Sent — project dashboard

Open this page first, in Obsidian, from the `main` checkout.

## Needs your attention

![[LIVE]]

> [!NOTE]
> The block above is generated from GitHub: open pull requests, failing checks, local branches that are not on GitHub yet, and decisions still open. If it is empty or old, run `python tooling/knowledge/live_status.py --pull` in the repository. Agents run it at the end of every session. On GitHub this block shows as plain text.

## What is next

![[WORK#Now]]

Full board: [Work board](knowledge/WORK.md).

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
| Set up a workstation | [Start here](development/START_HERE.md) |
| Start Flutter work with Claude CLI | [Flutter CLI guide](development/FLUTTER-CLAUDE-CLI.md) |
| Open the prototype or Architecture Atlas | [Workspace guide](development/KNOWLEDGE-WORKSPACE.md) |
| Agent entrypoint | [Index](knowledge/INDEX.md) |

## How these pages stay current

- **Lasting pages** (board, parity, features, design, architecture) are updated by each pull request in the same pull request as the work. `AGENTS.md` lists which page goes with which kind of change, and CI checks the ones a machine can check.
- **Pull request and CI state** is never typed by hand. It comes from the generated block at the top.
- A checkbox does not approve product behavior. Decisions are recorded on the Decisions page and merged.

## Dedicated repository vault

Open this worktree's **docs folder** as an Obsidian vault and open `HOME.md`. For this workstation, the stable `main` checkout is `C:\ws_c\ForgedAndSent\ForgedAndSentFitness-main\docs`. After a pull request merges, `live_status.py --pull` fast-forwards that checkout so its notes are current. Local `.obsidian` state stays ignored. Avoid editing the same note in multiple worktrees. This public vault must contain no credentials, personal journals, real member records, prayers or health data.
