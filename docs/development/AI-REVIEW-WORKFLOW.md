# Independent agent review: beginner workflow

**Start here:** Optional AI review is a second opinion for a solo maintainer, especially for Flutter database, Firebase rules, Auth, scoring and private data. It is not a required merge gate. Pick a model that did not author the change; deterministic CI and emulator tests remain required.

## The quick path (Windows)

1. Open the repository's **feature branch**, not `main`. In VS Code Terminal, run `git branch --show-current` to verify.
2. Ensure Python 3 is installed: open PowerShell and run `py -3 --version` (or `python --version`). Sign in to any CLI reviewer you choose to use.
3. Save your files. If you added new files, stage them using VS Code Source Control (`+` beside each file) or `git add path/to/file`. The review stops if untracked files could be omitted.
4. Double-click `REVIEW-WINDOWS.cmd`, or from VS Code Terminal run `py -3 tooling/review/review.py --dry-run` first. If the tool says `origin/main` is missing, run `git fetch origin main` and retry.
5. For optional review after Codex authored a Flutter database change: `py -3 tooling/review/review.py --reviewers claude --author codex --minimum 1`. If Claude authored it, choose Codex. For two providers specify both explicitly; this may consume paid usage.
6. Inspect `.review/summary.md`. Critical/high findings, incomplete diff slices and invalid or missing reviewer responses are NOT VERIFIED. Resolve any material security defects before real-user data is deployed. The review itself is optional.
7. Run `python tooling/skills/sync.py --check`, `python tooling/architecture/generate.py --write`, and your Flutter tests. Commit both source and generated CODE-MAP.md when Flutter declarations change.
8. Commit your changes, optionally rerun review for the exact new HEAD, then push and open a Draft PR. Do not merge until required GitHub CI passes.

## The quick path (Mac)

Use Terminal in the same feature branch. Check `python3 --version`, then run `python3 tooling/review/review.py --dry-run`. The `REVIEW-MAC.command` launcher is equivalent to running `python3 tooling/review/review.py` from the repository root. Mac users also need the same authenticated provider CLIs. If macOS warns about the launcher, inspect its text in an editor before launching it.

## When an AI wrote the code

| Author | Recommended independent reviewers | Command arguments |
|---|---|---|
| Human | Codex + Claude | `--author human --reviewers codex,claude` |
| Codex | Claude + Gemini CLI | `--author codex --reviewers claude,gemini` |
| Claude | Codex + Gemini CLI | `--author claude --reviewers codex,gemini` |
| Gemini | Codex + Claude | `--author gemini --reviewers codex,claude` |

Agents must not count themselves as independent reviewers. The script enforces the `--author` exclusion. One independent provider is sufficient for the optional second opinion (`--minimum 1`). Never falsify the `--author` value to claim independence.

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
- Prefer focused PRs. Large text diffs are split into bounded hashed slices with required whole-diff coverage for any claimed advisory PASS; binary patches and possible secrets are refused. Lockfiles (`package-lock.json`, `pubspec.lock`) and the generated `docs/architecture/CODE-MAP.md` are left out of the paid AI review because CI verifies them deterministically; `--dry-run` lists them and the report pins each by blob SHA, so changing one invalidates `--verify`. Each reviewer must answer `"slice_complete": true` for a PASS; duplicate keys, unknown keys or an admission of truncated/partial review are NOT VERIFIED. Reviewer CLIs receive an allowlisted environment (no `GITHUB_TOKEN`, Firebase or cloud credentials); add a variable with `FS_REVIEW_ENV_PASSTHROUGH=NAME` only if your provider login needs it. The secret scanner is incomplete; inspect sensitive code before passing it to cloud AI.
- Reviewer findings must include severity, path/line, concrete impact and smallest fix. The runner rejects malformed JSON and fails closed on errors.
- For high-risk rules, privacy, authentication and scoring changes, offer a non-author AI security check, require adversarial Firebase emulator tests, and leave the final decision to the solo maintainer.
- If paid services or tools are unavailable, skip optional AI review and record NOT VERIFIED without relaxing mandatory tests.

## How we keep the development architecture current

Start with [SYSTEM.md](../architecture/SYSTEM.md) for current-vs-planned component boundaries. Use [CODE-MAP.md](../architecture/CODE-MAP.md) for actual Flutter file imports and declared classes/functions. The code map is generated; CI refuses a stale copy. A new persistence strategy, Auth boundary, repository API or server score path also requires the human-maintained system diagram and, for durable decisions, an ADR.

## Official references

- [Codex CLI and skills](https://learn.chatgpt.com/docs/developer-commands?surface=cli) and [OpenAI code review rules](https://developers.openai.com/blog/custom-code-review-rules-for-codex).
- [Claude Code CLI](https://code.claude.com/docs/en/cli-reference) and [skills/agents best practices](https://claude.com/resources/articles/steering-claude-code-skills-hooks-rules-subagents-and-more).
- [Gemini CLI docs](https://github.com/google-gemini/gemini-cli/blob/main/docs/cli/cli-reference.md).
- [Flutter architecture](https://docs.flutter.dev/app-architecture/recommendations) and [Firebase emulator rules testing](https://firebase.google.com/docs/rules/unit-tests).

## Solo-maintainer choices
AI review is opt-in and never CI-required. Run `--dry-run` first to inspect complete diff coverage and cost. When using one reviewer, choose `--minimum 1`; for stronger database assurance choose two different non-author models with `--minimum 2`. The review runner uses trusted base-ref guidance only as reference data, not PR-editable instructions. Its bounded slices cover the full exact diff and verification binds the report to HEAD.
