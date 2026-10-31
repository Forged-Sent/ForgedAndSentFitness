# Independent agent review: beginner workflow

**Start here:** The goal is for both contributors to use the same checked-in Codex and Claude skills, give changes to a reviewer that DID NOT write them, and receive a clear report before pushing. AI reviews are advisory. They do not substitute for server-enforced CI, Firebase security-rule tests, or another person's approval when required.

## The quick path (Windows)

1. Open the repository's **feature branch**, not `main`. In VS Code Terminal, run `git branch --show-current` to verify.
2. Ensure Python 3 is installed: open PowerShell and run `py -3 --version` (or `python --version`). Sign in to any CLI reviewer you choose to use.
3. Save your files. If you added new files, stage them using VS Code Source Control (`+` beside each file) or `git add path/to/file`. The review stops if untracked files could be omitted.
4. Double-click `REVIEW-WINDOWS.cmd`, or from VS Code Terminal run `py -3 tooling/review/review.py --dry-run` first. If the tool says `origin/main` is missing, run `git fetch origin main` and retry.
5. For an actual review, run `py -3 tooling/review/review.py --reviewers codex,claude --author human`. Two installed/authenticated CLIs are needed by default. This may use paid AI quotas.
6. Open `.review/summary.md` in VS Code. Critical/high findings, unavailable reviewers, invalid JSON, contradictory verdicts, or insufficient independent reviewers are **NOT VERIFIED**. Fix code and run review again.
7. Run `python tooling/skills/sync.py --check`, `python tooling/architecture/generate.py --write`, and your Flutter tests. Commit both source and generated CODE-MAP.md when Flutter declarations change.
8. Run `git status`, commit the changes, **rerun the review after the commit** (a new HEAD invalidates the old report), then `git push` and open a Draft PR. Do not merge until GitHub required CI is green.

## The quick path (Mac)

Use Terminal in the same feature branch. Check `python3 --version`, then run `python3 tooling/review/review.py --dry-run`. The `REVIEW-MAC.command` double-click launcher is equivalent to running `python3 tooling/review/review.py --reviewers codex,claude --author human` from the repository root. Mac users also need the same authenticated provider CLIs. If macOS warns about the launcher, inspect its text in an editor before launching it.

## When an AI wrote the code

| Author | Recommended independent reviewers | Command arguments |
|---|---|---|
| Human | Codex + Claude | `--author human --reviewers codex,claude` |
| Codex | Claude + Gemini CLI | `--author codex --reviewers claude,gemini` |
| Claude | Codex + Gemini CLI | `--author claude --reviewers codex,gemini` |
| Gemini | Codex + Claude | `--author gemini --reviewers codex,claude` |

Agents must not count themselves as independent reviewers. The script enforces the `--author` exclusion. If you only have one independent provider, request a human review instead of claiming the two-provider process passed. **Never change `--author` merely to bypass this rule.**

## One-time agent preparation on each computer

**Codex:** install its official CLI/extension, sign in, and check `codex --version`. Repository skills live in `.agents/skills/`. They should appear in the Codex skills selector. They are version-controlled, not manually installed into each person's home directory.

**Claude Code:** install its official CLI/extension, sign in (`claude auth status`), and check `claude --version`. Repository skills live in `.claude/skills/`. They have the **exact same bytes** as the Codex copies, enforced by `tooling/skills/sync.py --check`.

**Gemini CLI (optional):** install and authenticate according to the [official Gemini CLI](https://github.com/google-gemini/gemini-cli). Check `gemini --help` for your available model and `--approval-mode plan` / `--sandbox`. This path is experimental. If it falls back to an unsafe mode, errors, or cannot guarantee safe isolation, do not count it as an independent pass. Do not hard-code unverified model nicknames such as Argon.

Providers run in separate short-lived temporary working directories, receive only a bounded git diff and selected public architecture/policy text, and are asked for strict JSON findings. Claude is started with no built-in tools and MCP tools denied; Codex with a read-only sandbox; Gemini with plan mode plus sandbox. These are **defense-in-depth safeguards**, not a hard OS-level data security guarantee. They can still send supplied code to the provider. Review public project code only and never secrets, private member data, prayers, health notes, or untrusted outside PR content.

## Useful commands

| Purpose | Command |
|---|---|
| Preview setup and provider availability | `python3 tooling/review/review.py --dry-run` |
| Review a human-authored branch | `python3 tooling/review/review.py --author human` |
| Review code authored by Codex | `python3 tooling/review/review.py --author codex --reviewers claude,gemini` |
| Verify the exact current diff was reviewed | `python3 tooling/review/review.py --verify` |
| Regenerate actual Dart import/symbol map | `python3 tooling/architecture/generate.py --write` |
| Check generated map isn't stale | `python3 tooling/architecture/generate.py --check` |
| Check shared skills match | `python3 tooling/skills/sync.py --check` |
| Sync Codex skills into Claude after approved edits | `python3 tooling/skills/sync.py --fix` |

These commands assume `origin/main` is already fetched. Use `--base main` if only a local `main` reference exists and is current. Review reports in `.review/` are intentionally gitignored, so users don't accidentally publish a provider's notes.

### Optional stricter local pre-push hook

The existing repository pre-push hook runs Flutter analysis and tests. If you **opt in**, set `FS_REQUIRE_AI_REVIEW=1` in your shell before pushing. The hook then calls `review.py --verify` and refuses to push if no current passing report matches HEAD and the working diff. It never starts paid AI calls automatically. Local hooks are bypassable and are NOT an adequate substitute for GitHub required checks.

## Review quality and cost safeguards

- Run cheap deterministic checks before spending tokens: Flutter analysis/tests, Python tests, `tooling/policy/check.py`, and architecture/skill drift checks.
- Use small PRs and an explicit base commit. The reviewer rejects oversize diffs, binary patches, and some recognizable secret patterns, but that scanner is incomplete. A human must inspect sensitive content before using cloud AI.
- Reviewer findings must include severity, path/line, concrete impact and smallest fix. The runner rejects malformed JSON and fails closed on errors.
- For high-risk rules, privacy, authentication and scoring changes, add **human approval** and adversarial Firebase emulator tests, even with green AI results.
- For unsupported interfaces or paid services, skip the reviewer and record NOT VERIFIED instead of silently relaxing the quality gate.

## How we keep the development architecture current

Start with [SYSTEM.md](../architecture/SYSTEM.md) for current-vs-planned component boundaries. Use [CODE-MAP.md](../architecture/CODE-MAP.md) for actual Flutter file imports and declared classes/functions. The code map is generated; CI refuses a stale copy. A new persistence strategy, Auth boundary, repository API or server score path also requires the human-maintained system diagram and, for durable decisions, an ADR.

## Official references

- [Codex CLI and skills](https://learn.chatgpt.com/docs/developer-commands?surface=cli) and [OpenAI code review rules](https://developers.openai.com/blog/custom-code-review-rules-for-codex).
- [Claude Code CLI](https://code.claude.com/docs/en/cli-reference) and [skills/agents best practices](https://claude.com/resources/articles/steering-claude-code-skills-hooks-rules-subagents-and-more).
- [Gemini CLI docs](https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/cli-reference.md).
- [Flutter architecture](https://docs.flutter.dev/app-architecture/recommendations) and [Firebase emulator rules testing](https://firebase.google.com/docs/rules/unit-tests).
