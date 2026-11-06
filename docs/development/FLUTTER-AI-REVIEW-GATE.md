# Functional Flutter AI review gate

The maintainer selected automatic GitHub Actions reviews: Codex authorship routes
to Claude, and Claude authorship to Codex. The workflow is implemented locally;
server enforcement stays disabled until hosted activation checks pass.

## Current state

[Ruleset 26653964](https://github.com/Forged-Sent/ForgedAndSentFitness/rules/26653964)
is **disabled**. Its [payload](../../.github/rulesets/flutter-ai-review.json)
requires the GitHub Actions status `flutter-ai-review` on the default branch.
Existing `ci-gate` and zero required human approvals are unchanged.
The producer is [flutter-ai-review.yml](../../.github/workflows/flutter-ai-review.yml)
with a [trusted coordinator](../../tooling/review/github_gate.py). It publishes on
the PR head, not the pull_request_target base SHA. Automatic triggers need the
workflow merged into main first.

## Credential setup

1. Open [repository Actions secrets](https://github.com/Forged-Sent/ForgedAndSentFitness/settings/secrets/actions).
2. Connect the repository in [Codex code review settings](https://chatgpt.com/codex/settings/code-review)
   and enable automatic reviews for the desired PR events. Codex reviews use the
   maintainer's connected Codex account. No OpenAI API key or exported desktop
   login is used in GitHub Actions. The gate verifies the native GitHub review
   receipt on the current PR head; Codex must actually post one for this route
   to pass.
3. Run `claude setup-token` in PowerShell/Terminal on your own PC. Complete the
   browser flow and paste the generated token directly into a GitHub secret named
   `CLAUDE_CODE_OAUTH_TOKEN`. `ANTHROPIC_API_KEY` is an alternative; if both exist,
   the API key wins.
4. Keep values out of chat, issues, commits and review reports. Agents can check
   secret names without reading values. This custom Claude CLI workflow does not
   need a separate write-capable Claude GitHub App.
5. Optional variable `AI_REVIEW_CLAUDE_MODEL` chooses a model available to your
   Claude account. Otherwise the pinned CLI selects its default.

## Scope and routing

[flutter_scope.py](../../tooling/review/flutter_scope.py) includes functional files
under mobile/, firebase/ and tooling/firebase/: code, tests, dependencies, assets
and native hosts. Root Firebase rules/configuration and the gate's own files also
require review. Renames inspect both paths; removals count. README/changelog and
docs-directory Markdown/reStructuredText are exempt. Bundled Markdown assets count
as functional. The listed behavioral prototype files are outside this gate.
Unknown or newly added paths require review until explicitly classified; this
includes a future root `functions/` backend. Comment-only Dart
edits conservatively count; the classifier does not infer harmless semantics.

| Declared authorship label | Reviewer |
|---|---|
| authorship:codex | Claude |
| authorship:claude | Codex |
| authorship:human | Codex by default |
| authorship:mixed | Both, with overlap disclosed |

Missing, unknown or conflicting labels block functional review. Labels are a
maintainer declaration, not proof of identity. Mixed-provider reviews do not
establish an independent provider for every part; human assessment may be needed.

## Execution and evidence

- Open, ready, push, base-edit and authorship-label events trigger review.
  Irrelevant labels do not spend provider usage. Re-review an unchanged head from
  Actions → Functional Flutter AI review → Run workflow, entering the PR number.
  Use **Re-run all jobs** for retries: artifacts are isolated by run attempt.
- GitHub can emit both `opened` and `labeled` when a PR is created with an
  authorship label. The runs are serialized but may both spend Claude usage on
  the same head. Check this case during hosted acceptance before relying on
  automatic cost control.
- A trusted default-branch schedule checks for newly completed Codex reviews
  every 15 minutes and dispatches a fresh gate run. The native Codex route waits
  in a pending state until its exact-head review is available; it does not send
  an implementor handoff merely because Codex is still working.
- Scheduled dispatches run as GitHub Actions on the default branch and can
  initiate the already-classified review; human dispatches still require a
  repository collaborator. This schedule-to-dispatch path must be checked live
  before enforcement is enabled.
- Functional drafts stay blocked until ready; docs-only PRs pass without models.
  A write/maintain/admin actor must trigger paid review. For outside contributors,
  a maintainer inspects the PR and uses Run workflow.
- Preparation checks out trusted default-branch policy and fetches PR objects
  without checking out PR files. Only scoped diffs and baseline guidance become
  review data; PR code is never executed. Functional lockfiles are included.
- Claude reviewer jobs have no write-capable GitHub token and receive only the
  Claude subscription token in isolated configuration. Claude tools/MCP/skills
  are disabled. Codex runs as the connected GitHub review service; the gate reads
  its bot-authored summary or submitted review and verifies identity, GitHub App,
  exact commit and review completion time. Raw
  model/auth output is not logged. A separate publisher validates evidence.
- Stale, missing, cancelled, incomplete or changes-required reviews fail. PASS
  requires every slice and no unresolved critical/high findings. Findings and
  limitations are in the review-summary artifact. This is not a human approval.
- After publication, GitHub comments once per review run on the PR and mentions
  its author with the result and a link to the evidence. The author hands findings
  to the declared Codex or Claude implementor session. A local agent session is
  not awakened by a GitHub comment; automatic fix pushes are not enabled.
- The implementor addresses the first review's findings once. If a later review
  on a new head still has findings, the handoff directs the implementor to pause
  for maintainer review instead of starting another fix cycle.
- Native Codex is accepted only when its GitHub bot publishes a completed
  machine-readable summary for the exact PR head after any base retargeting,
  reporting no findings, with no inline findings in submitted reviews on that
  head. Its clean thumbs-up reaction alone is insufficient because the reaction
  has no commit SHA. A new commit is needed after findings are fixed. The
  summary format is observed GitHub behavior, not a documented stable API;
  malformed or changed formats fail closed.
- Limits: 3000 files, 400000 functional diff characters, four slices, ten minutes
  per model call. Binary functional changes fail closed and require a reviewable
  text/source representation in this first version.

## Activation checklist

1. Review and merge the workflow PR under existing protections.
2. Create the four authorship labels and declare all substantial authoring providers.
3. Confirm the Claude subscription secret and enable Codex GitHub automatic review.
4. Exercise docs-only, Codex-authored functional and Claude-authored functional PRs
   on GitHub. Confirm routing, the implementor handoff, inspect findings and verify
   exact-head success. Specifically test a clean native Codex review and its receipt.
5. Verify that new commits invalidate prior evidence, missing credentials and
   incomplete reviews block merging, and GitHub Actions app 15368 emits the status.
   Test base retargeting and a second PR sharing one head; observe the short
   interval before the new run posts pending, since commit statuses persist across
   PR context changes.
6. Activate ruleset 26653964 only after those hosted checks pass. Keep Protect main
   unchanged. The maintainer requested activation, but it needs a working producer.

The required integration identifies GitHub Actions, not one exact workflow. This
is not tamper-proof against administrators or contributors able to create an
equivalent write-capable workflow. Stronger enforcement needs a separately
controlled GitHub App or organization-enforced trusted workflow. Base identity is
checked during publication; unrelated later main updates do not automatically
rerun every PR unless another configured PR event occurs.

## Verification

Run `python -m unittest discover -s tooling/review -p 'test_*.py' -v`.
Tests cover routing, secret isolation, stale evidence, failed jobs, incomplete
results and actual object fetching without a PR checkout. Hosted execution,
GitHub status publication and active enforcement remain **NOT VERIFIED** until
the activation checklist is run.

References: [required checks](https://docs.github.com/en/pull-requests/how-tos/merge-and-close-pull-requests/troubleshooting-required-status-checks),
[Codex authentication](https://learn.chatgpt.com/docs/auth),
[Claude setup](https://code.claude.com/docs/en/github-actions),
[Claude tool restrictions](https://code.claude.com/docs/en/cli-reference).
