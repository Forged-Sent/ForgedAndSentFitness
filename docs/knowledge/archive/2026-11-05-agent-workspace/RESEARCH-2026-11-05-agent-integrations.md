---
status: archived
updated: 2026-11-05
owner: Codex research team
source_ref: codex/obsidian-current-and-history
source_sha: 1ef8ce67ae15f78801e234f71aaad20511a9c913
superseded_by: docs/knowledge/AGENT-WORKSPACE.md
---

# Obsidian agent integrations: research, 2026-11-05

Status: proposal and documentation research; no plugin installed, account authenticated, paid generation made, or integration tested. Local source baseline: `1ef8ce67ae15f78801e234f71aaad20511a9c913`, branch `codex/obsidian-current-and-history`. This note does not approve dependencies or change project policy.

## Recommendation

Keep the existing external coding-agent workflow as the initial fallback. Pilot **Agent Client** as the optional Obsidian front end after checking the actual installed release and account. It best matches a friend opening a task note and starting work in a separate code worktree: its documented “New chat in directory” keeps the code working directory distinct from the `docs/` vault. Do not promise that an embedded button selects that worktree automatically; the documented button options do not include a directory. Treat a successful Windows and Mac pilot as a prerequisite for a beginner-facing launch flow.

Use one writer per task/worktree. Astra is the requested coordinator role, but an exact Astra model in either plugin is **NOT VERIFIED**. A coordinator prompt is not an implemented orchestration service, and the plugins do not automatically apply this repository’s review runner or Git protections.

## Documented options

| Option | Documented capabilities | Fit and limits |
| --- | --- | --- |
| [Agent Client — RAIT-09](https://github.com/RAIT-09/obsidian-agent-client) | Desktop community plugin; Claude Code, Codex and Gemini presets; ACP sessions, note mentions, terminal output, arbitrary-directory chats, permission requests. Auto-allow is off by default. | Preferred embedded pilot. The agents retain terminal-like system access; the vault is not a sandbox. Multiple sessions do not establish independent reviews. |
| [Claudian — YishenTu](https://github.com/YishenTu/claudian) | Community plugin, Obsidian 1.13+, macOS/Linux/Windows. Claude Code and Codex plus other harnesses; edits/search/bash, projects and cross-session messaging. Its default working directory is the vault. | Credible alternative, especially for existing Claude/Codex users. Native Gemini CLI is not in the current README harness list. Repository-root coding from this project’s `docs/` vault needs explicit verification. This is not the unrelated Enigmora plugin with the same name. |
| Existing official coding-agent application/CLI | Continue the established project workflow and pass the task note path to it. | Lowest new integration burden; recommended fallback. No new Obsidian-to-app deep link or automatic handoff was implemented or tested here. |

Agent Client supports note-embedded chat and prompt buttons. Buttons default to `autoSend: false`; retain that behavior during a pilot. Persisted session mappings are device-local, so a shared note does not transfer a running session to the friend’s machine. Use the Git-backed task/handoff for continuity. [Embedded block documentation](https://rait-09.github.io/obsidian-agent-client/usage/embeddable-blocks.html)

## Providers, models and costs

- **Claude:** Agent Client uses `@agentclientprotocol/claude-agent-acp`. Subscription authentication additionally requires Claude Code CLI sign-in; Claude Desktop sign-in alone is insufficient. API-key authentication is another route. [Claude setup](https://rait-09.github.io/obsidian-agent-client/agent-setup/claude-code.html)
- **Codex:** Agent Client uses `@agentclientprotocol/codex-acp`; its docs deprecate the older `@zed-industries` package. Account authentication requires separate Codex CLI sign-in; an open ChatGPT/Codex app is insufficient. API keys are another route. [Codex setup](https://rait-09.github.io/obsidian-agent-client/agent-setup/codex.html)
- **Gemini:** The plugin documents native Gemini CLI with experimental ACP. [Setup](https://rait-09.github.io/obsidian-agent-client/agent-setup/gemini-cli.html). Google announced consumer free/Pro/Ultra access ended June 18, 2026; enterprise licenses and paid API-key access remain documented. Do not advertise a free consumer reviewer. [Google announcement](https://developers.googleblog.com/an-important-update-transitioning-gemini-cli-to-antigravity-cli/). Antigravity CLI is not a drop-in replacement for this runner or the plugin preset; the plugin’s migration guide reports no native ACP support. [Migration limits](https://rait-09.github.io/obsidian-agent-client/announcements/gemini-cli-deprecation.html)
- **Exact models:** Agent Client exposes models available from the agent/account; Claudian discovers the configured provider’s catalog. Astra, other GPT variants, Claude variants and Gemini variants for these particular accounts are **NOT VERIFIED**. Do not invent model IDs or imply that Codex app model availability proves ACP availability. [Agent Client model selection](https://rait-09.github.io/obsidian-agent-client/usage/model-selection.html), [Claudian troubleshooting](https://github.com/YishenTu/claudian/blob/main/docs/troubleshooting.md)

The plugins’ source licenses are Apache-2.0 and MIT respectively; model usage remains subject to the provider’s subscription/API billing and limits. No exact dollar estimate, account entitlement or remaining quota was verified. Budget separately for the writer, reviewer and any repair/re-review rounds. A second plugin does not provide free model access.

## Permissions and platform pilot

Keep Agent Client auto-allow disabled. For Claudian verify the installed provider’s normal approval mode and reject YOLO/bypass-permissions defaults; Context7’s indexed permission guide describes normal/plan/YOLO, but current source makes permission values provider-interpreted. Do not treat a plan-mode UI as proof of read-only enforcement. [Indexed permission guide](https://github.com/yishentu/claudian/blob/main/_autodocs/14-permission-system.md), [current settings source](https://github.com/YishenTu/claudian/blob/main/src/core/types/settings.ts)

Agent Client’s setup guides include Windows and macOS paths, and its README documents WSL mode. Claudian has separate PATH discovery behavior for Dock-launched macOS and native Windows, and warns against Claude `.cmd`/`.ps1` wrappers in its own configuration. These are plugin-specific instructions, not interchangeable recipes. [Claudian platform troubleshooting](https://github.com/YishenTu/claudian/blob/main/docs/troubleshooting.md)

Before giving the friend a launch button, test on each target machine: correct repository/worktree and branch; project instructions loaded; only intended note context sent; harmless edit diff; terminal approval rejection; cancellation; reopening from a handoff; exact model/account; and the review runner’s dry run. Review inherited MCP configuration so the project session does not accidentally attach a personal vault or cloud Firebase tooling. No such tests ran in this research.

## Existing independent review boundary

Observed in [review.py](../../../../tooling/review/review.py): reviewers are `codex`, `claude`, or `gemini`. The runner rejects the same provider as `--author`, uses an isolated temporary directory, supplies bounded patch slices, and binds the report to HEAD/diff. Codex receives read-only sandbox flags; Claude receives no tools, strict MCP configuration and plan mode; Gemini receives plan mode plus sandbox. These are static observations, not proof that installed CLIs currently accept/enforce every flag.

For a Codex writer, the proposed first reviewer is authenticated Claude via the existing runner, using `--author codex --reviewers claude --minimum 1`; start with `--dry-run`. Reverse the providers for a Claude writer. A second Codex session or another OpenAI model cannot count as independent in this runner. If a coordinator also writes code, record that authorship and do not count its provider as the reviewer. Multiple author providers need an explicitly considered reviewer choice; the runner has only one `--author` field and cannot prove multi-author independence.

The reviewer sees supplied evidence, not full application behavior. Missing provider/authentication/sandbox or incomplete coverage remains **NOT VERIFIED**. Paid reviews require the user’s authorization; a dry run performs no provider calls. Reviews remain advisory, never approval. Existing CI and human merge decisions remain unchanged.

Research method: Context7 resolved Claudian and ACP documentation; it did not resolve the exact RAIT-09 plugin after two attempts, so that plugin’s own repository and documentation were read directly. Current public documentation was checked on the date above; release-to-installed-version parity remains untested.
