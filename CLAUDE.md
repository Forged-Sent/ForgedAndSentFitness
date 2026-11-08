# Claude Code instructions

Read `AGENTS.md` as the shared source of truth and `docs/development/START_HERE.md` before modifying files.

Workflow: every change uses a short-lived branch and a pull request. The live ruleset currently requires ci-gate and zero human approvals; do not imply another person's approval is enforced. For functional Flutter/backend changes, declare authorship:claude and follow docs/development/FLUTTER-AI-REVIEW-GATE.md so Codex reviews the current diff. The hosted rule remains staged until its documented activation checks pass. Other AI reviews remain optional. Agents may push to a non-`main` branch only under the agent push rule in `AGENTS.md`: explicit human authorization in this session, all PR review threads closed, and `ci-gate` green (or the push fixes a red `ci-gate`). Agents never push to `main`, force-push, approve or merge. Never bypass controls.

When working on the prototype (`index.html`, `versions/`, `seed/`, `dev/`):
- Read the root `AGENTS.md`, including its HTML prototype workflow.
- Make focused visual or content changes without modifying `mobile/` unless explicitly requested.
- Preserve historical `versions/app-vN.html` snapshots.
- Run `python3 dev/make_preview.py` and report any browser or Claude-runtime behaviors not tested.
- Escalate changes to scoring, privacy, authorization, dependencies or product decisions to a human, even when only the prototype changes.
- Never report the local mock as proof of real identity, persistent storage or sharing behavior.

When implementing Flutter:
- Preserve existing prototype and `seed/` references.
- Use feature-first modules and small, testable classes.
- Provide explicit acceptance tests.
- Do not introduce Firebase credentials or deploy cloud infrastructure.
- Do not write competition scores from untrusted clients.
- Do not add custom authentication or expose confidential group content.
- Escalate product decisions to the project maintainer, who may approve them without another reviewer.

Repository agents live in `.claude/agents/` and repeatable workflows in `.claude/skills/`.

Use the shared skills in `.claude/skills/` (checked for parity with `.agents/skills/`) and review `docs/architecture/SYSTEM.md` / `CODE-MAP.md`. For independent code reviews follow `docs/development/AI-REVIEW-WORKFLOW.md`. Claude may not be its own reviewer.
