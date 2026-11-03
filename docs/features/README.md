# Risk-based feature contracts

This directory holds **approved product intent**, not evidence that a feature already works. The maintainer decides product behavior. Agents may draft proposals, but may not promote a feature to approved, change scoring/privacy semantics, or infer rules from the HTML prototype.

## Choose the smallest useful contract

- **Low/medium-risk UI or documentation behavior:** copy [the light template](TEMPLATE-LIGHT.md) to `docs/features/<slug>/feature.md`.
- **High/security-critical risk:** copy [the requirements template](TEMPLATE-HIGH-RISK.md) to `docs/features/<slug>/requirements.md`, then add `design.md` and `tasks.md`. This applies to authentication, Firebase authorization/rules, group membership, privacy, scoring, offline synchronization, health-related data and architectural boundaries.
- Tiny typo or refactor changes with no user-visible semantic change need no new feature contract. Reference an existing approved contract where relevant.

Use a stable unique `feature_id` such as `FNS-042`. Canonical metadata belongs in `feature.md` or `requirements.md`; the other high-risk documents link back to it. All metadata values are simple one-line YAML scalars; comma-separated paths are repo-relative. Do not add a second spec for the same feature.

## Status and authority

`proposed` means unapproved intent. `approved` requires an explicit maintainer product decision recorded in the PR/issue and `approved_by`. `implemented` requires observed source, test paths, and a verification run; it does not mean production deployment. `superseded` requires `superseded_by` pointing to the successor. CI validates structure and path existence, **not the authenticity of approval, test success, security, or correctness**.

The `source_sha` must be an existing full 40-character commit SHA for the source/behavior being specified, not a placeholder or automatically generated current-head claim. On a new feature draft, reference the known baseline commit; after merging, update provenance in a reviewable change. `test_plan` is a comma-separated list of proposed test names or paths; `verified_tests` contains actual repository test paths only after execution. `verification` identifies the CI run or other observed evidence.

For every change, compare [prototype parity](../knowledge/PROTOTYPE-PARITY.md), accepted [architecture decisions](../architecture/SYSTEM.md), relevant code, and the branch-specific [handoff process](../knowledge/AGENT-OPERATIONS.md). Do not silently change Firebase direction, dependencies or state management.

## CI

Run `python3 tooling/knowledge/check.py` from the repository root. The checker rejects malformed canonical metadata, duplicate active feature IDs, broken local links, missing high-risk design/task files, missing implementation/test paths, invalid source SHAs, and absent supersession targets. Templates are exempt; Obsidian is not required in CI.
