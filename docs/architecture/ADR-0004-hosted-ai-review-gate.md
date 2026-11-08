# ADR-0004: Hosted AI review evidence for functional changes

Status: Proposed; implementation is staged and the GitHub ruleset is disabled.
Date: 2026-11-05.

## Context

The maintainer wants functional Flutter and backend pull requests reviewed by a provider other than the principal author. Documentation and prototype-only changes should not spend review usage. The active branch protection requires `ci-gate` and zero human approvals. AI feedback is advisory; GitHub rules, not a model verdict, control required statuses.

The maintainer prefers existing Codex and Claude subscriptions. Codex's native GitHub Code Review can use the connected Codex account. Claude Code GitHub Actions can authenticate with `CLAUDE_CODE_OAUTH_TOKEN`, generated from that maintainer's Claude subscription. A personal Codex CLI `auth.json` must not be copied into GitHub Actions, especially for this public repository.

## Decision

1. Classify the live GitHub PR file list conservatively. Functional Flutter/backend changes and review-policy files require the hosted status; documentation-only and prototype-only changes do not require a model run.
2. Declare principal authorship with one `authorship:codex`, `authorship:claude`, `authorship:human`, `authorship:automation`, or `authorship:mixed` label. Codex authorship routes to Claude, Claude authorship to native Codex GitHub Code Review, human authorship to Codex, and mixed authorship to both. Automation authorship routes verified same-repository Dependabot PRs to native Codex from a trusted default-branch dispatch. Labels are maintainer declarations, not identity proof.
3. The trusted coordinator must verify current PR head, base, label, and reviewer evidence before publishing `flutter-ai-review`. A missing, stale, incomplete, failed, or changes-required review must not pass. One commit shared by multiple open PRs cannot receive a PR-specific success from a commit-wide status without additional disambiguation; fail closed in that case. For a functional PASS, the publisher writes `pending` first; final `success` follows only after a delivered or deduplicated implementor handoff and renewed identity, head, ownership and native Codex receipt checks. A failed handoff or final status write leaves an existing pending status in place. If the initial pending write fails, the notifier refuses to finalize; the check may be absent rather than pending.
4. The reviewer does not approve or merge. A completed review must produce a human-readable PR handoff to the implementor, identifying findings and the next action. GitHub PR notifications can alert the PR author; a workflow notification must not expose provider credentials or untrusted output as executable instructions. The trusted publisher job grants both `issues: write` for the handoff and `statuses: write` for the final commit status.
5. Keep the separate ruleset disabled until the producer has passed live tests for each route, stale heads, missing credentials, and documentation exemption. Existing `ci-gate` remains active. The maintainer decides when to merge after all active rules pass.

## Consequences and limits

- The Claude OAuth token uses the subscription of the person who created it and is stored only in GitHub Actions secrets. Usage and GitHub Actions minutes still have limits. Native Codex review requires the repository to be connected and Code Review enabled in Codex settings.
- A GitHub review or machine-readable summary from the Codex connector is evidence of a review, not approval. The coordinator verifies the immutable bot and GitHub App identities, exact reviewed commit, completed state, findings state, and completion time after base retargeting. A thumbs-up reaction by itself has no commit binding. The summary format is observed behavior and can change; the gate fails closed if it cannot parse it. The account-backed route cannot be replaced by copying local login files to a hosted runner.
- GitHub's required status integration identifies GitHub Actions, not this exact workflow. Administrators or contributors with workflow write rights can create another status producer under the same integration. Stronger isolation would require a separately controlled GitHub App or organization-enforced workflow.
- Commit statuses have no atomic conditional update. Another run can claim the same head between the notifier's ownership check and final status write; the pending status from a newer run normally supersedes the older success, but this residual race remains a limitation.
- The current implementation and hosted behavior remain **NOT VERIFIED** until the PR is merged and the acceptance cases run. Model findings still require human judgment, and mixed-provider authorship may lack an independent provider for some lines.
- A maintainer with write access can push to a Dependabot branch while its PR author remains the bot. The automation route then reviews that content under the maintainer's account-backed Codex connection. This is accepted because write access already authorizes a maintainer to dispatch paid review manually; the coordinator still never executes PR code. Scheduled dispatches include the expected PR head and do not reuse a prior head's completed run as evidence or a retry guard.
