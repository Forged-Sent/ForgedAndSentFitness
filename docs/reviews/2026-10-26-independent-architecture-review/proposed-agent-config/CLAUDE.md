@AGENTS.md

## Claude Code specifics
- Delegate reviews: `architecture-reviewer` for PRs touching more than one feature or any protected zone;
  `security-privacy-reviewer` for migrations, RLS, storage, auth, push or health code; `test-engineer` after implementation.
- Work in a worktree per task when running in parallel (`isolation: worktree` agents do this automatically).
- The PreToolUse hook in `.claude/settings.json` blocks edits to protected zones; if it fires, stop and propose.
