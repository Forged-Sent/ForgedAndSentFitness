# Claude Code instructions

Read `AGENTS.md` as the shared source of truth and `docs/development/START_HERE.md` before modifying files.

When implementing Flutter:
- Preserve existing prototype and `seed/` references.
- Use feature-first modules and small, testable classes.
- Provide explicit acceptance tests.
- Do not introduce Firebase credentials or deploy cloud infrastructure.
- Do not write competition scores from untrusted clients.
- Do not add custom authentication or expose confidential group content.
- Ask a human before changing accepted product decisions.

Repository agents live in `.claude/agents/` and repeatable workflows in `.claude/skills/`.
