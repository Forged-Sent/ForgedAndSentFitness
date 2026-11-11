@AGENTS.md

# Claude Code

The line above imports `AGENTS.md`, the shared rule set. Everything there applies to you. This file adds only what is specific to Claude Code.

- Skills are in `.claude/skills/` (a CI-checked mirror of `.agents/skills/`). Subagents are in `.claude/agents/`.
- `mobile/CLAUDE.md` and `dev/CLAUDE.md` import the rules for those folders; they load when you read files there.
- `.claude/settings.json` denies force-push, pushing to `main`, `gh pr merge` and `firebase deploy`, and asks before every commit and push. Do not work around a denied command.
- When you write a functional Flutter or backend change, say so in the pull request description. You may not be the independent reviewer of your own change.
