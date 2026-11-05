---
status: active
updated: 2026-11-05
owner: Codex / maintainer
source_ref: codex/flutter-ai-review-gate
source_sha: 40533288759c9dbf6de0d33bfc18f73555ab1112
---
# Functional Flutter AI review gate

The maintainer requested a repository rule requiring Codex or Claude review for
functional Flutter PRs, preferably cross-provider. This supersedes optional-only
AI review for the requested scope once implemented; it does not authorize an
unrelated human approval requirement, production deployment or credential copying.

[Implementation draft](../../development/FLUTTER-AI-REVIEW-GATE.md) records exact
scope, routing, activation criteria and remaining decisions. A disabled GitHub
ruleset exists at ID 26653964. Existing Protect main was not modified. Local scope
and routing tests pass; no review-producing workflow exists yet.

Pending user input: automatic Actions reviews, existing GitHub review apps, or
local review with verified publication. Repository Actions secrets/variables were
empty at the read-only check. Local sign-in is not GitHub runner authentication.

Next action: obtain the runtime choice, implement its trusted result producer,
arrange provider authentication without exposing secrets in chat, run the three
hosted acceptance cases, and activate the rule only when the check can run.
Keep this handoff current; historical review reports from other PRs do not satisfy
this new gate. Do not publish this draft as an active enforcement claim.
