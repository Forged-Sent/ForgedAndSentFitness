# PROPOSED agent configuration — NOT INSTALLED

Review drafts for Section J of ARCHITECTURE-REVIEW.md. Nothing here is active: the folder sits inside
the review directory, and the dot-folders are renamed `dot-claude/` and `dot-agents/` so neither Claude Code
(which scans `.claude/agents` subfolders) nor Codex can discover them by accident. Rename on install.

Install (after approval) by copying into the new production repository root:

| Draft here | Goes to | Read by |
|---|---|---|
| `AGENTS.md` | `/AGENTS.md` | Codex, and Claude Code via the CLAUDE.md import |
| `CLAUDE.md` | `/CLAUDE.md` | Claude Code |
| `dot-claude/agents/*.md` | `/.claude/agents/` | Claude Code subagents |
| `dot-agents/skills/*/SKILL.md` | `/.agents/skills/` (canonical) | Codex |
| (mirror of the above) | `/.claude/skills/` | Claude Code. It does **not** read `.agents/` |
| `dot-claude/settings.hooks.json` | merge into `/.claude/settings.json` | Claude Code PreToolUse guard |
| `tools/check_zones.sh` | `/tools/` + CI | Everyone (the real enforcement) |

Verified 2026-10-26 against code.claude.com/docs (sub-agents, skills, memory/AGENTS.md) and
OpenAI Codex skills docs: subagent frontmatter `name`, `description` required, `tools`, `disallowedTools`,
`model`, `skills`, `isolation` supported; Codex scans `$REPO_ROOT/.agents/skills`; Claude Code reads AGENTS.md
only when no CLAUDE.md exists, otherwise via `@AGENTS.md` import. Re-verify hook syntax at install time.
