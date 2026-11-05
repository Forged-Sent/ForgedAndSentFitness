---
status: active
updated: 2026-11-05
owner: Codex / maintainer
source_ref: codex/flutter-ai-review-gate
source_sha: b50f4514208f7e2b3b3a6bcb06fcdb653cff43bd
---
# Functional Flutter AI review gate

The maintainer requested a repository rule requiring Codex or Claude review for
functional Flutter PRs, preferably cross-provider. This supersedes optional-only
AI review for the requested scope once implemented; it does not authorize an
unrelated human approval requirement, production deployment or credential copying.

[Implementation guide](../../development/FLUTTER-AI-REVIEW-GATE.md) records exact
scope, routing, activation criteria and remaining decisions. A disabled GitHub
ruleset exists at ID 26653964. Existing Protect main was not modified. Local scope
and coordinator tests pass. The hosted workflow is implemented locally but has
not run on GitHub yet.

The user selected account-backed reviews. GitHub currently has the
CLAUDE_CODE_OAUTH_TOKEN secret. Codex must use its connected native GitHub code
review, with no OpenAI API key or copied local login. Verify secret names only.
Claude's independent local review found security and workflow issues; the fixes
are staged after the source commit above and must be checked against the eventual
branch head before publication. The hosted gate posts an implementor handoff when
review finishes, without treating an AI review as human approval.

Next action: finish fixes and independent review, publish the bootstrap PR through
an authorized path, then run hosted acceptance before activation.
The agent push rule requires a current PR's green CI before an agent push; this
new branch has no PR yet. Bootstrap publication needs a maintainer push or an
explicit one-time exception. Prior merge-batch authorization does not authorize
merging this new PR.
Keep this handoff current; historical review reports from other PRs do not satisfy
this new gate. Do not publish this draft as an active enforcement claim.
