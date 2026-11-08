---
status: active
updated: 2026-11-07
owner: Maintainer / gate implementor
stage: Active
next_action: Diagnose PR handoff HTTP 403 and finish hosted acceptance before enabling the ruleset
source_ref: main
source_sha: b5f44a20c36b667d1799ad1490c467d99ceadbf3
---
# Functional Flutter AI review gate

## Outcome so far

[PR #41](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/41) merged the hosted coordinator. [PR #43](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/43) added a trusted Dependabot route. [PR #44](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/44) fixed whole-second GitHub comment timestamps being compared with Codex microsecond timestamps. [PR #42](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/42) then received a green exact-head native Codex gate status and merged. PR #30 also received a clean native Codex review before merging.

The separate [Functional Flutter AI review ruleset](https://github.com/Forged-Sent/ForgedAndSentFitness/rules/26653964) is **disabled**. Existing Protect main still requires `ci-gate` and zero human approvals. AI reviews are advisory and do not act as human approval. The user authorized this merge batch; these notes do not authorize later pushes, merges or rule changes.

## Open acceptance work

1. The publisher has `issues: write`, but hosted runs failed `POST issues/{PR}/comments` with HTTP 403. A green `flutter-ai-review` commit status can coexist with a red workflow run because the notification step follows status publication. Inspect the GitHub permission response and repair the handoff without silently hiding failure. The implementor is not automatically awakened by a PR comment.
2. A trusted Dependabot dispatch that fails before posting status is suppressed for that same head after a completed run. A maintainer must inspect and manually retry it. Test the failure path and decide whether a bounded automatic retry is worth adding before enforcement.
3. Run the [hosted acceptance checklist](../../development/FLUTTER-AI-REVIEW-GATE.md#activation-checklist) for each authorship route, stale heads, missing credentials, docs exemption and branch/base changes. Activate the ruleset only after the producer behaves reliably; the account-backed Codex route alone is not full acceptance.
4. Review GitHub's [pull_request_target policy notice](https://docs.github.com/en/actions/reference/security/securely-using-pull_request_target) before December 2, 2026. Verify whether an explicit repository or organization event policy is needed for this public repository's trusted workflow.

## Evidence and limits

- Local review/policy tests passed on PRs #43 and #44. PR #44's required `ci-gate` passed. Its optional hosted Claude job failed before producing a valid review, and a local Claude report was rejected as incomplete; independent review of that exact fix is **NOT VERIFIED**.
- PR #42's native Codex summary and `flutter-ai-review` status were bound to its exact head after the timestamp fix. This is a successful live Codex-route case, not proof of every route or of the disabled ruleset.
- No OpenAI API key or copied local Codex login is used. Claude subscription OAuth remains a GitHub Actions secret. Never paste or log credential values.

The [implementation guide](../../development/FLUTTER-AI-REVIEW-GATE.md) and [ADR-0004](../../architecture/ADR-0004-hosted-ai-review-gate.md) own scope, trust boundaries and the full acceptance checklist. Update this handoff with the next hosted result; keep historical review runs as linked evidence rather than transcripts.
