---
status: active
updated: 2026-11-05
owner: Codex / maintainer
source_ref: codex/flutter-ai-review-gate
source_sha: 672370313e85ff680cde7b8dca1cacb15406728c
---
# Functional Flutter AI review gate

The maintainer requested a repository rule requiring Codex or Claude review for
functional Flutter PRs, preferably cross-provider. This supersedes optional-only
AI review for the requested scope once implemented; it does not authorize an
unrelated human approval requirement, production deployment or credential copying.

[Implementation guide](../../development/FLUTTER-AI-REVIEW-GATE.md) records exact
scope, routing, activation criteria and remaining decisions. A disabled GitHub
ruleset exists at ID 26653964. Existing Protect main was not modified. Local scope
and coordinator tests pass. [Draft PR #41](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/41)
publishes the workflow; `ci-gate` passed on the source SHA above. The hosted review
workflow cannot run until the PR is merged into the default branch. CI on the
source SHA was running at the time of this handoff; recheck its current result.

The user selected account-backed reviews. GitHub currently has the
CLAUDE_CODE_OAUTH_TOKEN secret. Codex must use its connected native GitHub code
review, with no OpenAI API key or copied local login. Verify secret names only.
Claude's final independent local review returned PASS (advisory) on the source
SHA above and identified follow-up medium/low issues. Their fixes are staged in
the worktree; verify the new branch head after publication. The hosted gate posts
an implementor handoff when review finishes, without treating an AI review as
human approval. A GitHub comment does not automatically wake a local agent.

Next action: publish the follow-up fixes after confirming PR #41's current-head
`ci-gate` and closed/outdated review threads, then rerun CI. After the maintainer
merges the PR under existing protection, run hosted acceptance, including a real
clean Codex review, before activating the ruleset. Hosted behavior is NOT VERIFIED.
The agent push rule still applies to every subsequent branch update. Prior
merge-batch authorization does not authorize merging this new PR.
Keep this handoff current; historical review reports from other PRs do not satisfy
this new gate. Do not publish this draft as an active enforcement claim.
