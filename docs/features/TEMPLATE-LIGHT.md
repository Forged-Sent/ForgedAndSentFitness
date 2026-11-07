# Lightweight feature contract template

Copy to docs/features/<slug>/feature.md. Replace all examples and placeholders before committing. Do not mark approved without a maintainer decision.

~~~yaml
---
kind: feature-spec
feature_id: FNS-000
status: proposed
risk: low
owner: maintainer
source_ref: PR-000
source_sha: 0000000000000000000000000000000000000000
approved_by: none
test_plan: manual acceptance to be defined
verified_tests: none
implementation_paths: none
verification: none
---
~~~

## User outcome

Who needs what, and why? Link to the GitHub issue or decision.

## Acceptance and failure cases

State visible behavior, empty/error/accessibility states, and what must not change. Distinguish approved behavior from prototype observations.

## Boundaries and evidence

Relevant source files, accepted ADR, prototype revision, proposed tests, open decisions, and what is NOT VERIFIED.

## Tasks

Small checkable steps and deterministic checks. No implied permission to deploy, alter authorization, or invent product rules.
