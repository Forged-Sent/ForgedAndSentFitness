---
status: active
updated: 2026-11-06
owner: Codex / maintainer
source_ref: codex/flutter-ai-review-gate
source_sha: 0cfc9dfc9b77788a0e7a894b3207903538d7d1ec
---
# Functional Flutter AI review gate

The maintainer requested a repository rule requiring Codex or Claude review for
functional Flutter PRs, preferably cross-provider. This supersedes optional-only
AI review for the requested scope once implemented; it does not authorize an
unrelated human approval requirement, production deployment or credential copying.

[Implementation guide](../../development/FLUTTER-AI-REVIEW-GATE.md) records exact
scope, routing, activation criteria and remaining decisions. A disabled GitHub
ruleset exists at ID 26653964. Existing Protect main was not modified. Local scope
and coordinator tests pass. [PR #41](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/41)
is ready and `ci-gate` passed on head `0cfc9df` before the current fix. The hosted review workflow
cannot run until the PR is merged into the default branch.

The user selected account-backed reviews. GitHub currently has the
CLAUDE_CODE_OAUTH_TOKEN secret. Codex must use its connected native GitHub code
review, with no OpenAI API key or copied local login. Verify secret names only.
Claude's independent local review returned PASS (advisory) on predecessor
`6723703`; its mixed-route race finding was fixed in `0cfc9df`.
Codex's native GitHub review of PR #41 on `0cfc9df` completed cleanly. Its
connector posted a commit-bound machine-readable summary and a thumbs-up
reaction, but no PR review object. The gate is being updated to consume that
summary. The hosted gate posts
an implementor handoff when review finishes, without treating an AI review as
human approval. A GitHub comment does not automatically wake a local agent.

Next action: publish the summary-evidence fix after confirming PR #41's current-head
`ci-gate` and closed/outdated review threads, then rerun CI. After the maintainer
merges the PR under existing protection, run hosted acceptance, including a real
clean Codex review through the gate, before activating the ruleset. Hosted gate
behavior is NOT VERIFIED.
The agent push rule still applies to every subsequent branch update. Prior
merge-batch authorization does not authorize merging this new PR.
Keep this handoff current; historical review reports from other PRs do not satisfy
this new gate. Do not claim the disabled ruleset is active enforcement.
