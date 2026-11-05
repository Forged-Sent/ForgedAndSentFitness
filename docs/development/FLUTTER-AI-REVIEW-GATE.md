# Functional Flutter AI review gate — draft

The maintainer requested mandatory Codex or Claude review of functional Flutter
pull requests, preferably by the provider that did not author the change.
This is a new, scoped policy request. Existing documentation describing all AI
reviews as optional must be reconciled when the workflow is implemented.

## Current state

The repository has a **disabled** ruleset named Functional Flutter AI review,
[ID 26653964](https://github.com/Forged-Sent/ForgedAndSentFitness/rules/26653964).
Its payload is [.github/rulesets/flutter-ai-review.json](../../.github/rulesets/flutter-ai-review.json).
It will require a GitHub Actions check named `flutter-ai-review` on the default
branch when activated. Existing `ci-gate` protection remains unchanged.

There is no hosted review workflow yet, and this disabled rule does not enforce
reviews. No repository Actions secrets or variables were present on November 5.
The user has been asked whether reviews should run in Actions, existing GitHub
apps, or local authenticated CLIs with verified publication. That answer remains
pending; no paid automation or credential transfer is authorized by this draft.

## Prepared policy

The tested classifier is [flutter_scope.py](../../tooling/review/flutter_scope.py).
It includes non-documentation files under `mobile/`, `firebase/` and
`tooling/firebase/`, including tests, dependencies, assets and native hosts.
Root Firebase rules/configuration and the gate's own implementation/configuration
also require review. Renames inspect both paths; removals count. Ordinary Markdown
and reStructuredText changes, and the separate HTML prototype, are exempt.
Comment-only Dart changes conservatively count as functional: no semantic
classifier claims that a code edit is harmless.

Proposed declared-author labels route reviews as follows:

| Authorship | Reviewer |
|---|---|
| `authorship:codex` | Claude |
| `authorship:claude` | Codex |
| `authorship:human` | Codex by default |
| `authorship:mixed` | Both, with the overlap disclosed |

Missing or conflicting authorship labels block the functional review path.
Labels are a maintainer declaration, not cryptographic evidence of authorship.
For mixed Codex/Claude authorship, reviewing with both does not establish a fully
independent provider for the entire change. Human assessment may still be needed.

## Workflow acceptance criteria

1. Always publish the required check for each PR head. Exempt changes produce an
   explicit successful "review not required" result; do not skip the required
   workflow using a path filter.
2. Bind results to the exact current head and base, reviewer identity, complete
   scoped diff and review outcome. A comment saying a review ran, an old-head
   report, or an author-supplied JSON file is insufficient.
3. Run scope, routing and result validation from trusted base/default-branch code.
   Treat PR source and comments as untrusted review material. Do not execute PR
   scripts with provider credentials or give the model a write-capable GitHub
   token. Keep model review and authenticated result publication separate.
4. Run the opposite provider for single-provider authorship. Handle unavailable
   providers, missing credentials, timeouts and incomplete reviews explicitly;
   a failed review cannot silently become a passing check.
5. Keep deterministic CI required and human approval count unchanged. The AI
   review completion gate does not impersonate a human approving review.
6. Agree whether successful completion alone or an accepted PASS is required.
   Recommended: complete review with no unresolved critical/high finding.
7. Verify a docs-only case, a Codex-authored functional case and a Claude-authored
   functional case on GitHub before activating the ruleset. Verify that a new
   commit invalidates old review evidence and an absent review blocks merging.
8. Reconcile AGENTS.md, review workflow documentation and applicable skills with
   the approved scope. Do not claim enforcement before the active rule and its
   producer have both been verified.

GitHub Actions as the required check's integration restricts its producer app,
not the precise workflow file. This draft is not a tamper-proof attestation system
against repository administrators or contributors able to create equivalent
write-capable workflows. Stronger enforcement needs a separately controlled
GitHub App or organization-enforced trusted workflow.

## Verification

`python -m unittest discover -s tooling/review -p test_flutter_scope.py -v`
covers seven scope/routing cases. Provider execution, GitHub result publication,
cross-provider hosted review and active merge enforcement are **NOT VERIFIED**.

References: [required-check handling](https://docs.github.com/en/pull-requests/how-tos/merge-and-close-pull-requests/troubleshooting-required-status-checks),
[Claude Action setup](https://github.com/anthropics/claude-code-action/blob/main/docs/setup.md),
[Codex Action](https://github.com/openai/codex-action).
