---
status: active
updated: 2026-11-05
owner: Codex / maintainer
source_ref: codex/flutter-ai-review-gate
source_sha: 296f73e0dce0893938f3ae7049210cfc71dc7d90
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
Claude's independent local reviews found security and workflow issues. The latest
findings have fixes staged after the source commit above; verify the eventual
branch head before publication. The hosted gate posts an implementor handoff when
review finishes, without treating an AI review as human approval. A GitHub comment
does not automatically wake a local Codex or Claude session.

Next action: publish the bootstrap PR through an authorized path, then run hosted
acceptance, including a real clean Codex review, before activation. The local
review tests and policy/architecture checks pass; hosted behavior is NOT VERIFIED.
The agent push rule requires a current PR's green CI before an agent push; this
new branch has no PR yet. Bootstrap publication needs a maintainer push or an
explicit one-time exception. Prior merge-batch authorization does not authorize
merging this new PR.
Keep this handoff current; historical review reports from other PRs do not satisfy
this new gate. Do not publish this draft as an active enforcement claim.
