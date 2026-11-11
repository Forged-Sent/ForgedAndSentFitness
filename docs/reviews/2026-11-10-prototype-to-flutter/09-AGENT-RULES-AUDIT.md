---
title: "Agent rules, skills and status pages audit"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](00-START-HERE.md) · Back: [Evidence and limits](08-EVIDENCE.md) · Publish the fixes: [P01](prompts/P01-publish-review-and-record-decisions.md)

# Agent rules, skills and status pages audit

> [!IMPORTANT] In one minute
> 1. **Your Obsidian pages fall behind by design, not by agent error.** No file an agent loads tells it to update them in its own PR. The rules say only a "coordinator" may edit them, "after merge", and nothing triggers that.
> 2. **Claude never loads `AGENTS.md`.** Claude Code reads `CLAUDE.md` only. Yours says "read AGENTS.md" in prose, which is a request, not a load. Codex loads it every time. The two tools work from different rules.
> 3. **Rules a machine checks are followed. Rules written only in prose drift.** Skill mirroring and the code map are enforced by CI and are clean. Handoffs and status pages are prose-only and are not.
> 4. **Your personal Codex allow-list lets `git push` run without asking,** which overrides the repository's push rule on this workstation.
> 5. **The required CI check rejects any pull request containing an image or font.** That blocks the native hosts and the design foundation until it is changed (A13).

> [!TIP] Status: fixed, waiting to be published
> The changes in [section 6](#6-what-i-changed) are made. They sit as **uncommitted edits in your `main` checkout**. Prompt [P01](prompts/P01-publish-review-and-record-decisions.md) puts them on a branch and opens the pull request. Three things remain yours; they are listed at the end of section 6.

## 1. Why the Obsidian pages fall behind

**What the merge history shows.** Nine pull requests merged after the Obsidian workspace landed (PR #30).

| PR | What it was | Status pages touched in that PR |
|---|---|---|
| #44 | Gate timestamp fix | None |
| #42 | Dependabot bump | None |
| **#45** | **"Refresh Obsidian current work after merge batch"** | CURRENT, WORK |
| #46 | Gate diagnostics | CURRENT, WORK |
| #47 | Client-stack ADR | CURRENT, WORK |
| #50 | Claude GitHub workflow | None |
| **#49** | **"Add current Obsidian PR tracker"** | CURRENT, WORK, PR-STATUS |
| #51 | Gate publisher hardening, 12 files | None |
| **#52** | **"Refresh Obsidian gate status after hosted acceptance"** | CURRENT, WORK, PR-STATUS |

- **3 of 9** pull requests exist only to catch the pages up.
- **4 of 9** changed no status page, including #51, which is why #52 was needed.
- **2 of 9** updated the pages in the same PR as the work.

**Five causes, all in the rules themselves**

| # | Cause | Evidence |
|---|---|---|
| 1 | **No loaded rule says "update the board in your PR".** `AGENTS.md` tells agents to *read* `CURRENT.md` and `WORK.md` at the start, and to write a handoff. It never says to update the board. | `AGENTS.md` L92–95 |
| 2 | **The rules forbid the writer from doing it.** "The coordinator owns HOME/CURRENT/WORK updates", and the loop is closed "after merge". A merge on GitHub wakes no agent, so nobody does it until you ask. | `docs/knowledge/AGENT-OPERATIONS.md` L11, L24; `task-coordinator` step 10 |
| 3 | **The pages record facts a PR cannot know about itself.** "Open", "merged", "`ci-gate` green" change on GitHub with no commit. A PR cannot truthfully write its own merge. | `PR-STATUS.md` |
| 4 | **`PR-STATUS.md` is in no rule file at all.** It was added in #49 and touched only by #49 and #52. | Search of `AGENTS.md`, `CLAUDE.md`, skills, PR template |
| 5 | **Nothing checks it.** The PR template has no line for it. `tooling/knowledge/check.py` validates links and metadata, not freshness. | `.github/pull_request_template.md`; `check.py` |

**Two more symptoms of the same design**

- **The Obsidian task table can only show one task.** `ACTIVE-TASKS.base` lists handoff files whose status is `active`. There is exactly one: the review gate. The native-hosts and Today-demo branches created no handoff, so they cannot appear. Verified on both local branches.
- **Editing status pages inside a feature branch collides.** `codex/today-demo-contract` edited `CURRENT.md` and `WORK.md`. `main` has changed both three times since. A trial merge reports 13 conflict hunks across the files changed on both sides.

> [!TIP] The fix in one sentence
> **Lasting pages** are updated by each pull request, in that pull request, **written as they will be true after the merge**, with a CI check where a machine can judge. **Pull request and CI state** is never typed by hand: a small script regenerates a "needs your attention" block on the dashboard from GitHub. That removes the refresh pull requests and still lets you see everything in Obsidian.

## 2. What each tool actually loads

Sizes are bytes divided by four, an approximation of tokens.

| | Claude Code | Codex |
|---|---|---|
| Loaded at start | `CLAUDE.md` (~590) | Root `AGENTS.md` (~3,590; 14 KB of a 32 KiB budget) |
| **`AGENTS.md`** | 🔴 **Not loaded.** Read only if Claude chooses to follow the sentence "Read AGENTS.md" | Loaded |
| `mobile/AGENTS.md`, `dev/AGENTS.md` | 🔴 Not loaded. They are not `CLAUDE.md` files | Loaded only when Codex is started inside that folder (documented behavior) |
| Path-scoped rules | `.claude/rules/prototype.md`, when Claude reads a prototype file. Nothing for `mobile/**` | None; uses nested `AGENTS.md` |
| Skills | 7 in `.claude/skills/`: name and description up front, body when invoked | The same 7 in `.agents/skills/`, plus 1 in `~/.agents/skills` and 6 in `~/.codex/skills` |
| Subagents | 3 in `.claude/agents/` | None |
| Permissions | `.claude/settings.json`: deny force-push, push to `main`, `gh pr merge`, `firebase deploy`; ask before commit and push | `.codex/config.toml`: ask on request, workspace-write sandbox. Plus your personal allow-list (finding A4) |
| Hooks | None | None |

**What the rules then tell an agent to read before starting**

| When | Files | Approx. tokens |
|---|---|---|
| Every session | `AGENTS.md`, `START_HERE.md`, `INDEX.md`, `CURRENT.md`, `WORK.md` | 7,500 |
| Flutter work adds | `SYSTEM.md`, `CODE-MAP.md`, `features/README.md`, `mobile/AGENTS.md` | 4,000 |
| "Functional" changes add | `FLUTTER-AI-REVIEW-GATE.md`, `AI-REVIEW-WORKFLOW.md` | 5,800 |

That is 11,500 to 17,300 tokens of process for an app with 194 lines of Dart. `START_HERE.md` is a workstation setup guide for people. Nearly half of `AGENTS.md` covers onboarding, beginner Git, the Architecture Explorer and review routing.

## 3. Findings

| ID | Sev | Finding | Evidence | Smallest fix |
|---|---|---|---|---|
| A1 | 🔴 High | **Claude does not load the shared rules.** | Claude Code documentation: it reads `CLAUDE.md`, not `AGENTS.md`, and recommends importing it. `CLAUDE.md` L3 only says to read it | First line of `CLAUDE.md` becomes `@AGENTS.md`. Add `mobile/CLAUDE.md` and `dev/CLAUDE.md` containing `@AGENTS.md` |
| A2 | 🔴 High | **Status pages cannot stay current under the present rules.** | Section 1 | P13 |
| A3 | 🔴 High | **"One handoff per task" is not followed for product work.** | No handoff on `codex/native-host-acceptance` or `codex/today-demo-contract`; one active handoff on `main` | Make the PR description the handoff; keep handoff files only for work that spans sessions without a PR |
| A4 | 🔴 High | **Your personal Codex allow-list auto-approves pushes.** It applies in every repository. | `~/.codex/rules/default.rules` L54 allows any command starting `git push -u origin`; L29 allows `git push origin main` through PowerShell; L52 allows `git commit --amend --no-edit` | Delete those three lines yourself. GitHub's ruleset is still what protects `main`; I could not check its live settings |
| A5 | 🟠 Med | **`AGENTS.md` is twice the size it needs to be**, and Claude's docs advise under 200 lines per file because longer files reduce adherence. It has 106 lines, but many are paragraph-length. | 14,348 bytes; section sizes in the table below | Done: 14.3 KB to 11.6 KB. Onboarding, beginner Git, the Explorer contract and review routing were cut to a line each. It did not reach 7 KB because the new docs table and board rule were added |
| A6 | 🟠 Med | **No rule file mentions the accepted stack.** Riverpod, go_router and Drift appear in no `AGENTS.md`, `CLAUDE.md`, skill, subagent or Copilot file. | Search returned nothing | One line in `AGENTS.md` naming ADR-0005 |
| A7 | 🟠 Med | **A third, undocumented reviewer runs on every PR.** `claude-code-review.yml` reviews all pull requests, including docs and Dependabot. ADR-0004 says docs and prototype changes "should not spend review usage". No doc mentions this workflow. | `.github/workflows/claude-code-review.yml` (added in #50); search of docs | Add a `paths:` filter for `mobile/**`, `firebase/**`, `functions/**`, and name it in `AGENTS.md` |
| A8 | 🟠 Med | **Four places describe how to build a Flutter slice,** with small differences. | `flutter-vertical-slice`, `flutter-platform-parity`, `.claude/agents/flutter-builder.md`, `mobile/AGENTS.md` | Merge the two skills; make the subagent a one-line pointer to the skill |
| A9 | 🟡 Low | **Stale line in a review skill:** "cannot satisfy GitHub's human approval requirement". There is no such requirement. | `flutter-architecture-review` step 7 | Reword to "is advisory" |
| A10 | 🟡 Low | **Copilot subagents are not kept in step with Claude's.** The three `.github/agents/*.agent.md` files differ from `.claude/agents/*.md`; only skills are mirror-checked. | Byte comparison | Archive the Copilot and Gemini files (decision A1, prompt P14) |
| A11 | 🟡 Low | **`task-coordinator` and `AGENT-WORKSPACE.md` add about 4,600 tokens of model-routing process** for one maintainer and two tools. | File sizes | Leave in place; the P-prompts do not invoke them |
| A13 | 🔴 High | **The required check rejects any pull request that contains a binary file.** `ci-gate` depends on the `policy` job, whose last step runs `review.py --dry-run`; that raises "Binary changes are outside this text-only AI review". The native hosts (launcher icons), S0 (fonts, hero image, goldens) and this review (screenshots) all contain binaries. | I ran the step against the pending changes and it failed with that message. `tooling/review/review.py` L130–131; `ci-gate.yml` L96–104, L471 | Allow listed folders and file types, pinned by hash. This is a review-policy change, so I did **not** make it: answer A2, then run [P12](prompts/P12-let-ci-accept-binary-assets.md) |
| A12 | 🟡 Low | **Five untracked `.clinerules-*` files** sit in the older checkout (`ForgedAndSentFitness`). They are not in the repository and I did not audit them. | Directory listing | Delete, or tell me to include them |

**Where `AGENTS.md` spends its bytes**

| Section | Bytes | Keep in `AGENTS.md`? |
|---|---|---|
| Product | 289 | Yes |
| Architectural decisions | 1,058 | Yes, plus one stack line |
| Protected operations | 1,810 | Yes, tightened |
| Working agreement | 972 | Yes |
| HTML prototype workflow | 1,617 | Move to `.claude/rules/prototype.md` and `dev/AGENTS.md`, which already cover it |
| Pull request classification | 1,217 | Yes, shortened |
| Platform-specific onboarding | 653 | Move to `START_HERE.md` |
| Checks | 505 | Yes |
| Agent roles | 1,020 | Shorten to three lines |
| Safe beginner Git collaboration | 491 | Move to `GIT-101.md` |
| Living architecture and shared agent instructions | 625 | Yes, shortened |
| Architecture Explorer update contract | 810 | Move to `explorer/README.md` |
| Git-backed development memory and Flutter platform strategy | 2,261 | Replace with the five-line board rule from P13 |
| Risk-based approved requirements | 983 | Yes, shortened |

## 4. Skills and subagents: are they used, are they efficient?

**Used?** I cannot see invocation history. A skill being picked leaves no trace in the repository, and I did not read session transcripts. What the repository shows:

- No commit message, handoff or PR-facing document names a skill as having been used, apart from the handoff for the PR that created them.
- `flutter-vertical-slice` is not mentioned in `AGENTS.md` or `CLAUDE.md`, so it relies entirely on its description being matched.

**To check for yourself:** in Codex run `/skills`; in Claude Code type `/` and look for the names. Then ask each tool "which skill would you use to build S1?" If it names none, the descriptions are not matching.

**Efficient?** Yes, in the way that matters: both tools load only each skill's name and description until it is invoked, so seven skills cost little. The mirror between `.agents/skills` and `.claude/skills` is byte-identical and CI-checked.

| Skill or subagent | Verdict | Action |
|---|---|---|
| `flutter-vertical-slice` | Updated | Names ADR-0005 and Drift events; ends with the docs rule |
| `flutter-platform-parity` | Rewritten | Now covers only prototype comparison: baseline, tokens, side-by-side goldens. No overlap with the slice skill |
| `independent-code-review` | Keep | Used by `tooling/review/review.py` and prompt P10 |
| `flutter-architecture-review` | Fixed | Stale approval line removed (A9) |
| `firebase-security-review` | Keep | First needed at S4 |
| `knowledge-steward` | Rewritten | Was the source of "doc edits in their own small PR". Now: update the board and docs in the same pull request, refresh the live block |
| `task-coordinator` | Leave unused | 1,100 tokens of routing; not needed for S0 to S3 |
| `.claude/agents/flutter-builder` | Updated | Now points to the two skills instead of restating them |
| `.claude/agents/architecture-reviewer`, `firebase-security` | Keep | Read-only tools are enforced by `tooling/policy/check.py` |

## 5. Which rules hold, and why

| Rule | Where stated | Checked by a machine? | Holding? |
|---|---|---|---|
| Never push to `main`, never force-push | `AGENTS.md` | GitHub ruleset; `.claude/settings.json` deny; `pre-commit` and `pre-push` hooks | ✅ In the repository. ⚠️ Your Codex allow-list weakens the local prompt (A4) |
| Skills identical for Codex and Claude | `AGENTS.md` | `tooling/skills/sync.py --check` in CI | ✅ |
| `CODE-MAP.md` matches the Dart source | `AGENTS.md`, `SYSTEM.md` | Generator `--check` in CI | ✅ |
| No cloud Firebase MCP, pinned versions | `AGENTS.md`, ADR-0002 | `tooling/policy/check.py` | ✅ |
| Review subagents are read-only | `AGENTS.md` | `tooling/policy/check.py` | ✅ |
| Feature contracts have valid metadata | `docs/features/README.md` | `tooling/knowledge/check.py` | ✅ (none exist on `main` yet) |
| One handoff per task | `AGENTS.md`, `AGENT-OPERATIONS.md` | No | ❌ (A3) |
| Coordinator updates CURRENT and WORK; close the loop after merge | `AGENT-OPERATIONS.md`, `task-coordinator` | No | ❌ Late, by hand, in separate PRs (A2) |
| Writers do not edit shared status pages | `AGENT-OPERATIONS.md` | No | ❌ The Today-demo branch did |
| Docs-only changes do not spend review usage | ADR-0004 | No | ❌ (A7) |
| Read `AGENTS.md` first | `CLAUDE.md` | No | ⚠️ Unknowable for Claude (A1) |

The pattern is consistent: **every rule with a check holds, and every rule without one has drifted.** So the fix is not more prose. Either make a rule checkable or delete it.

## 6. What I changed

Almost all of this is in your `main` checkout as **uncommitted** edits.

> [!NOTE] The eight files under `.claude/` and `.github/` (five skill mirrors, `flutter-builder.md`, the pull request template and `claude-code-review.yml`) were applied in this pull request, and `sync.py --check` passes.
 I ran your policy job's Python checks on an identical copy first (policy, knowledge, skills, architecture, explorer, CI path scope, review): all pass, including 17 new tests. One step does **not** pass: the reviewable-diff dry run rejects the five screenshot files (finding A13). I did not run the Windows, macOS or Flutter jobs.

| Area | Change | Fixes |
|---|---|---|
| `CLAUDE.md` | Now starts with `@AGENTS.md`, so Claude loads the shared rules. Cut from 2.4 KB to 0.7 KB | A1 |
| `mobile/CLAUDE.md`, `dev/CLAUDE.md` (new) | One line each, importing that folder's `AGENTS.md` | A1 |
| `AGENTS.md` | Trimmed. Added: the accepted stack, a pointer to the Decisions page, **The work board** and **Docs are part of done** with a table of which page goes with which change | A2, A5, A6 |
| `docs/knowledge/WORK.md` | Rewritten as the one board: Now, Later, Paused. No CI or merge state | A2, B3 |
| `docs/knowledge/CURRENT.md`, `PR-STATUS.md` | Marked superseded, pointing to the board and the live block. Not deleted | A2 |
| `docs/HOME.md` | A real dashboard: live "needs your attention" block on top, the board's Now table under it | A2 |
| `tooling/knowledge/live_status.py` (new) | Regenerates `docs/knowledge/LIVE.md` from GitHub: open pull requests, failing checks, ready-to-merge, local branches not on GitHub, decisions still open. `--pull` fast-forwards the vault first. Git-ignored | A2 |
| `tooling/knowledge/check.py` | New check: a pull request that changes `mobile/lib/`, `firebase/` or `functions/` must change `WORK.md`; one that changes `mobile/lib/src/design/` must change the design page | A2 |
| `docs/design/DESIGN-SYSTEM.md` (new) | Tokens, type and components from the prototype, each marked Planned, for S0 to turn into Implemented | B4 |
| `docs/knowledge/PROTOTYPE-PARITY.md` | The 7-row table became a 21-row status tracker, one row per prototype view | B3 |
| `.github/pull_request_template.md` | A "Docs are part of done" checklist | A2 |
| Skills (both mirrors) | Four rewritten or fixed, as in section 4 | A8, A9 |
| `.github/workflows/claude-code-review.yml` | Runs only when `mobile/`, `firebase/` or `functions/` change | A7 |
| `docs/knowledge/INDEX.md`, `AGENT-OPERATIONS.md`, `.gitignore` | Wording brought in line with the rules above; ignore entry for the generated page | A2 |

> [!WARNING] Not verified
> `live_status.py` has unit tests for its logic, but I could not run it against GitHub from my environment. The first real run is on your machine. It needs the GitHub CLI signed in (`gh auth status`).

**How you see current status in Obsidian from now on**

1. Open `HOME.md`. The top block lists what needs you.
2. If it looks old, run `python tooling/knowledge/live_status.py --pull` in the repository. Agents are told to run it whenever they open or update a pull request and at the end of every session.
3. Everything below the top block is ordinary notes that each pull request keeps current.

**Still yours**

- [ ] Answer row **A2** on the [Decisions](01-DECISIONS.md) page and run [P12](prompts/P12-let-ci-accept-binary-assets.md) **before P01** (A13). Otherwise P01's pull request fails the required check because of the screenshots.
- [ ] Delete lines 29, 52 and 54 from `C:\Users\Cornw\.codex\rules\default.rules` (A4). I did not touch that file.
- [ ] Answer row **A1** on the [Decisions](01-DECISIONS.md) page: do you use Copilot or Gemini on this repository? Their rule files are to be archived, not deleted (A10; decision A1, prompt P14). I left them in place.
- [ ] Delete the five `.clinerules-*` files in the older checkout if you no longer use Cline there (A12).
- [ ] Paste [P01](prompts/P01-publish-review-and-record-decisions.md) to publish all of this as one pull request.

## 7. What I looked at, and what I did not

**Read in full, at `main` `94daa63`:** `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `mobile/AGENTS.md`, `dev/AGENTS.md`, `.claude/settings.json`, `.claude/rules/prototype.md`, all three `.claude/agents`, all seven skills in both mirrors, `.codex/config.toml` and its optional example, `.mcp.json`, `.gemini/settings.json`, the Copilot instruction, agent and prompt files, the PR template, `CODEOWNERS`, both git hooks, `claude.yml`, `claude-code-review.yml`, `tooling/skills/sync.py`, `tooling/knowledge/check.py`, and the knowledge pages the rules point to.

**Read on your workstation:** the names of your user-level skills in `~/.agents/skills` and `~/.codex/skills` (none concern this project), and `~/.codex/rules/default.rules` in full.

**Not inspected**

- `~/.claude` (your personal Claude settings, `CLAUDE.md`, skills). It is a protected location I cannot open. If you have a personal `CLAUDE.md`, it loads in every session too.
- `~/.codex/AGENTS.md`, `~/.codex/config.toml` and `~/.codex/memories`. I asked only for the skills and rules folders.
- Session transcripts for either tool, so I cannot say which skills were actually invoked.
- Pull request descriptions and review comments on GitHub; the API was not available to me.
- The live GitHub ruleset.
- `.github/workflows/flutter-ai-review.yml` and `tooling/review/` in detail, beyond confirming how they call Claude.

## Sources

- [Claude Code: how Claude remembers your project](https://code.claude.com/docs/en/memory) (`CLAUDE.md` versus `AGENTS.md`, `@` imports, `.claude/rules` with `paths`, nested files, size guidance, advisory versus enforced)
- [Codex: build skills](https://learn.chatgpt.com/docs/build-skills) (skill locations, up-front loading, required front matter)
- [Codex: custom instructions with AGENTS.md](https://learn.chatgpt.com/docs/agent-configuration/agents-md) (discovery order, 32 KiB limit)
