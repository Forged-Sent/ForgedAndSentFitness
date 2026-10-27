@AGENTS.md

## Claude Code specifics

- **Subagents** (`.claude/agents/`) are a catalog. Use 2–4 per change, chosen with the ownership table in AGENTS.md.
- Reviewers (`architecture-reviewer`, `security-privacy-reviewer`, `faith-content-reviewer`) are **read-only**.
- `test-engineer` writes tests only.
- Implementer subagents run with `isolation: worktree`.
- The PreToolUse hook in `.claude/settings.json` runs `tools/check_zones.sh --hook` and blocks edits to protected zones and the frozen prototype. If it fires, stop and propose the change instead. Never try to get around it.
