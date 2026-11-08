---
status: active
updated: 2026-11-08
owner: Codex coordinator / gate implementor
stage: Active
next_action: Push the first findings fix after current-head CI, thread, and authorization checks, then rerun hosted acceptance
source_ref: codex/review-gate-acceptance
source_sha: 0dc76f5fa9f3d99be741a99ee8cb6f21323a63c1
profile: deep
coordinator_model: gpt-6 (host family; exact variant unavailable)
coordinator_provider: openai
author_providers: [openai]
---
# Functional Flutter AI review gate

## Current session checkpoint

- Profile: deep, because the hosted reviewer and notification have repeated unexplained failures. Coordinator: Codex, host-exposed GPT-6 family (exact variant not reported). One Codex implementation writer owns `tooling/review/` and the review workflow in `C:\ws_c\ForgedAndSentFitness-gate-acceptance`; the coordinator owns this handoff. No other worker edits this task's files.
- Base: `origin/main` at `901b284b37412f59b42dc32abc602e0d9447a4f5`; implementation commit `192dc4186b0afd7e9eb782c2b61b796ffa5cc03e` is local on `codex/review-gate-acceptance`. PR #41 is merged; no PR is currently open. Ruleset 26653964 was confirmed disabled. GitHub Actions has the `CLAUDE_CODE_OAUTH_TOKEN` secret name; its value and usability have not been inspected.
- Review plan: deterministic review and policy tests first, then a non-author Claude review of the exact diff. A same-provider Codex subagent does not count as independent review. Hosted acceptance remains separate from local review.
- Live evidence: PR #42 passed an exact-head native Codex route. PR #44's hosted Claude review failed with only a generic provider error; its publisher had `issues: write` but `POST issues/44/comments` returned HTTP 403. A docs-only PR #45 workflow succeeded with the reviewer skipped, which does not exercise the notification write path. The publisher log explicitly showed `Issues: write`; the API's reason for the 403 was not recorded. [Failed run](https://github.com/Forged-Sent/ForgedAndSentFitness/actions/runs/42455529417), [docs-only run](https://github.com/Forged-Sent/ForgedAndSentFitness/actions/runs/42456329723).
- No push, merge, or ruleset activation is authorized by this checkpoint. Current local work and hosted gaps must be updated below before transfer.

## November 8 local result and next hosted step

- The implementor added bounded GitHub HTTP diagnostics (fixed reason category and validated `X-Accepted-GitHub-Permissions` header) and Claude CLI failure categories without printing raw provider output, API response bodies, or credential values. Changed code: `tooling/review/github_gate.py` and `tooling/review/test_github_gate.py`. The coordinator refreshed this handoff and removed stale pre-merge wording from `docs/HOME.md`.
- `python -m unittest discover -s tooling/review -p 'test_*.py' -q` passed all 78 tests; `python tooling/policy/check.py`, `python tooling/knowledge/check.py`, `python -m compileall -q tooling/review`, `git diff --check`, and a one-slice `review.py --dry-run` passed locally. This is local evidence only; no new GitHub CI run has checked this diff.
- Independent local review is **NOT VERIFIED**. The first Claude attempt used an exported API credential instead of the signed-in account; after clearing it only for the child process, Claude returned a PASS that admitted a review-coverage gap, which the runner correctly rejected. Gemini was installed but its runner process failed to start on Windows. No model verdict is counted as approval.
- Next: publish this branch and open a focused PR. This is the initial push, so there is no PR head with a green `ci-gate` yet; the agent push rule in `AGENTS.md` does not let an agent make that first push. The maintainer must publish the prepared branch from his own Git session. Afterward, inspect the new hosted Claude failure category and GitHub permission header, fix the root cause, then exercise the remaining [activation checklist](../../development/FLUTTER-AI-REVIEW-GATE.md#activation-checklist): Claude and Codex functional routes, docs exemption, stale/missing evidence, retry, base retargeting, shared head, and final status producer identity. Keep ruleset 26653964 disabled until all required hosted cases pass.
- The scheduled Dependabot failed-dispatch path currently requires a maintainer retry; automatic retry was not added because repeated dispatch could spend model usage. Revisit only if live failure evidence shows manual recovery is inadequate.

## PR #46 first hosted review and fix pass

- The maintainer made the first push; [PR #46](https://github.com/Forged-Sent/ForgedAndSentFitness/pull/46) opened at `a72eda8e18b7c6631598d67ea9cacd002150c9ff` with `authorship:codex`. Both automatic Claude runs completed an exact-head review. Their [first](https://github.com/Forged-Sent/ForgedAndSentFitness/actions/runs/42461941359) and [second](https://github.com/Forged-Sent/ForgedAndSentFitness/actions/runs/42461948664) summary artifacts reported PASS with low-severity diagnostic/test findings, and no blocking finding. This is real hosted Claude review evidence for that head, not an approval for a later commit.
- Both publisher jobs failed to POST the implementor handoff with HTTP 403. The second run still placed a green `flutter-ai-review` commit status on `a72eda8`, so required status alone could falsely look satisfied despite a missing requested handoff. The current default-branch policy produced those runs; this branch's new diagnostics were not executed there.
- The implementor completed **one** findings fix pass at local code commit `0dc76f5fa9f3d99be741a99ee8cb6f21323a63c1`: narrowed Claude stderr categories, prevented arbitrary `GateError` text from entering review artifacts, added error-path tests, and made a failed required notification set the still-owned review status to failure. Pending Codex, docs-only, and superseded runs retain their existing handling. `82` review tests, `27` policy tests, `tooling/policy/check.py`, and `git diff --check` passed locally. Hosted review and CI of this new head are **NOT VERIFIED** until pushed.
- The one-fix limit now applies: if the next review of the new head reports more findings, pause implementation and wait for maintainer review. No automatic second correction cycle.

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
