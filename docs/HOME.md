# Forged & Sent — project dashboard

Open this page first. Git versions this shared project memory; Obsidian provides navigation. Curated November 5, 2026. This workspace extends PR #30; check its live merge status before assuming it is on main.

| I want to… | Open |
|---|---|
| See verified progress and decisions needed | [Current state](knowledge/CURRENT.md) |
| Track owners, blockers and next actions | [Active work](knowledge/WORK.md) |
| Resume an agent task quickly | [Agent entrypoint](knowledge/INDEX.md) |
| Run a guided agent session | [Start or resume](knowledge/START-SESSION.md) |
| Understand the proposed agent/plugin workflow | [Agent workspace rollout](knowledge/AGENT-WORKSPACE.md) |
| Understand architecture | [System and ADRs](architecture/SYSTEM.md) |
| Specify/review a feature | [Feature contracts](features/README.md) |
| Find historical evidence or rationale | [History index](knowledge/HISTORY.md), on demand |
| Set up a workstation | [Start here](development/START_HERE.md) |
| Open prototype/Architecture Atlas | [Workspace guide](development/KNOWLEDGE-WORKSPACE.md) |

## Human routine

Read CURRENT, then WORK. Follow a task's handoff for details. Open the linked PR before trusting CI/merge status; notes are snapshots. Record decisions in their ADR or contract, then update the task pointer. A checkbox does not approve product behavior.

## Dedicated repository vault

Open this worktree's **docs folder** as an Obsidian vault and open `HOME.md`, following #30's existing convention. The notes stay versioned with code while build outputs and archived HTML stay outside the note browser. No personal vault, new database, community plugin or automatic sync is required. Local `.obsidian` state stays ignored; share notes through normal Git workflow.

The prepared branch lives in `ForgedAndSentFitness-knowledge`; after integration use `docs/HOME.md` in your normal checkout. Avoid editing the same note in multiple worktrees. This public vault must contain no credentials, personal journals, real member records, prayers or health data.
