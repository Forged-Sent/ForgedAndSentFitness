# Claude Code instructions

Read `AGENTS.md` as the shared source of truth and `docs/development/START_HERE.md` before modifying files.

Workflow: every change uses a short-lived branch and a pull request. Only the explicit low-risk prototype exceptions defined in `tooling/policy/review_scope.py` have optional formal human review; ALL other files, including new paths, developer scripts, Firebase settings and Flutter code, require the other person's approval under GitHub's path-specific ruleset. Never merge or bypass controls yourself.

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
- Ask a human before changing accepted product decisions.

Repository agents live in `.claude/agents/` and repeatable workflows in `.claude/skills/`.
