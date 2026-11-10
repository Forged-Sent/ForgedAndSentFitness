# Forged & Sent — project dashboard

Open this page first. Git versions this shared project memory; Obsidian provides navigation. The workspace was merged into `main` in [PR #30](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/30). Check [Current state](knowledge/CURRENT.md) and live GitHub before relying on a task's status. These notes are curated snapshots: PR activity does not update them automatically.

| I want to… | Open |
|---|---|
| Follow my PRs and see what needs my attention | [Pull requests and next steps](knowledge/PR-STATUS.md) |
| See verified progress and decisions needed | [Current state](knowledge/CURRENT.md) |
| Track owners, blockers and next actions | [Active work](knowledge/WORK.md) |
| Resume an agent task quickly | [Agent entrypoint](knowledge/INDEX.md) |
| Run a guided agent session | [Start or resume](knowledge/START-SESSION.md) |
| Understand the proposed agent/plugin workflow | [Agent workspace rollout](knowledge/AGENT-WORKSPACE.md) |
| Understand architecture | [System and ADRs](architecture/SYSTEM.md) |
| Specify/review a feature | [Feature contracts](features/README.md) |
| Find historical evidence or rationale | [History index](knowledge/HISTORY.md), on demand |
| Set up a workstation | [Start here](development/START_HERE.md) |
| Start Flutter work with Claude CLI | [Flutter CLI guide](development/FLUTTER-CLAUDE-CLI.md) |
| Open prototype/Architecture Atlas | [Workspace guide](development/KNOWLEDGE-WORKSPACE.md) |

## Human routine

Read [Pull requests and next steps](knowledge/PR-STATUS.md) for the human overview, then CURRENT and WORK for project context. Follow a task's handoff for details. Open the linked PR before trusting CI/merge status; notes are snapshots. Record decisions in their ADR or contract, then update the task pointer. A checkbox does not approve product behavior.

## Dedicated repository vault

Open this worktree's **docs folder** as an Obsidian vault and open `HOME.md`, following #30's existing convention. The notes stay versioned with code while build outputs and archived HTML stay outside the note browser. No personal vault, new database, community plugin or automatic sync is required. Local `.obsidian` state stays ignored; share notes through normal Git workflow.

Use `docs/HOME.md` in one clean, current repository checkout, and open that checkout's `docs` folder as the vault. For this workstation, the stable `main` checkout is `C:\ws_c\ForgedAndSent\ForgedAndSentFitness-main\docs`. After a docs PR merges, refresh that checkout from `origin/main` to see its notes in Obsidian. A different vault or feature-branch checkout shows different files. Avoid editing the same note in multiple worktrees. This public vault must contain no credentials, personal journals, real member records, prayers or health data.
