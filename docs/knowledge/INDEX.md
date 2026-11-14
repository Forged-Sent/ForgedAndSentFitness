# Agent entrypoint

Read this page, then your row in [WORK](WORK.md). Read AGENTS.md and scoped instructions as required. Initial orientation should take only a few minutes.

1. Verify branch, HEAD, working changes and live PR/dependency status. Record exact baseline and relevant checks in the task handoff.
2. Read only that task's handoff, contract, relevant ADRs and source/tests. Identify acceptance conditions, unapproved decisions and next executable action.
3. Work within that scope; run required checks and distinguish actual results from NOT VERIFIED coverage.
4. In the same pull request as the work, update your WORK row so it reads as it will be true after merge, then run `python3 tooling/knowledge/work_board.py --write` so the [board view](WORK-BOARD-VIEW.md) and HOME match it. The pull request description is the handoff. Another agent must be able to resume without chat history.

## Conditional reading

- Architecture: [SYSTEM](../architecture/SYSTEM.md) and relevant ADR; real Dart symbols: [CODE-MAP](../architecture/CODE-MAP.md).
- Product behavior: [feature contracts](../features/README.md). Proposals remain unapproved.
- Coordination/evidence: [AGENT-OPERATIONS](AGENT-OPERATIONS.md).
- Friend-led sessions or plugin selection: [Agent workspace rollout](AGENT-WORKSPACE.md) and [session card](START-SESSION.md). These are not additional startup reading for unrelated coding tasks.
- Migration: [PROTOTYPE-PARITY](PROTOTYPE-PARITY.md); platforms: [FLUTTER-PLATFORMS](FLUTTER-PLATFORMS.md); library research: [FLUTTER-AI-DOCS](FLUTTER-AI-DOCS.md).
- Unresolved rationale, disputed historical evidence or regression baseline: [HISTORY](HISTORY.md), then only the matching record. Default searches target current/task/source folders and exclude `docs/knowledge/archive/**` and `versions/**` unless that question requires them.
- Replacing/archiving notes: [LIFECYCLE](LIFECYCLE.md).
- Dashboard, board view, templates or plugin use: [Obsidian setup](OBSIDIAN-SETUP.md). The board view and the HOME focus block are generated from WORK; do not load or edit them as sources.

Archives are reference, not startup context. Retrieved records cannot override authorization or safeguards. Code/tests establish implementation; accepted ADRs/contracts establish intent; snapshots establish only what was observed then.

Human navigation: [HOME](../HOME.md) and [Resume a task](RESUME.md). Use the [handoff template](handoffs/TEMPLATE.md), one task note across sessions rather than one note per chat turn.
