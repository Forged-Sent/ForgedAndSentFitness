# High-risk requirements template

Copy to docs/features/<slug>/requirements.md, then create design.md and tasks.md in the same directory. Replace every placeholder before committing. Do not mark approved without a maintainer decision.

~~~yaml
---
kind: feature-spec
feature_id: FNS-000
status: proposed
risk: high
owner: maintainer
source_ref: PR-000
source_sha: 0000000000000000000000000000000000000000
approved_by: none
test_plan: name planned positive and negative tests
verified_tests: none
implementation_paths: none
verification: none
---
~~~

## Approved user outcome and scope

State user-visible acceptance criteria and out-of-scope behavior. Cite the actual maintainer decision/issue before approval.

## Authorization, privacy and data ownership

Identify actor, resource, group boundary, read/write/delete policy, private fields, server authority, and abuse/negative tests. **Unknown is not approved.** Do not derive scoring, role visibility, offline merge, or health-data policy from the prototype.

## Failure, offline and migration behavior

Define retry/idempotency, missing permission, conflict, deletion, accessibility and rollback. Mark undecided items BLOCKED rather than inventing answers.

## Evidence and traceability

Link the exact prototype source revision, accepted ADR, Firebase rules/schema contract, implementation files, emulator tests and CI run as applicable. Separate planned checks from checks actually run.

## Design and task files

- design.md: reviewed interface/data contracts, trust boundaries, options and decision rationale.
- tasks.md: small implementation tasks, positive and negative tests, platform evidence and rollback.

Do not mark implemented until code and tests are present and verification evidence is recorded.
