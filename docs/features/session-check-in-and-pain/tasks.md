# Pre-session check-in and pain flow: tasks (proposed)

Canonical metadata: [requirements](requirements.md) (FNS-008). Nothing is started. No task begins until the maintainer approves the contract and answers the BLOCKED items it depends on. Feature 1 ([FNS-007](../plan-setup-and-screening/requirements.md)) is built first: one feature at a time.

## Before any build

1. Maintainer answers BLOCKED items 1 to 9 in the requirements.
2. For Flutter: amend FNS-004 in the same pull request (item 10).

## Build, in order

1. Check-in rules and the lighter-session rule, with unit tests.
2. Storage for the two records, with a restart test.
3. The check, the lighter suggestion and the rest screen.
4. Stop · Pain on every lift and its screen.

## Positive tests

- Every combination of answers gives the expected screen.
- A drop across two comparable sessions gives the lighter suggestion.
- The lighter session is inside the ranges for every prescription shape in the seed, supersets and rounds included.

## Negative tests

- Pain yes never shows a workout, whatever the other answers.
- Stop · Pain never offers another loaded lift and never opens alternates.
- No pain wording makes a diagnosis or says core work protects the back.
- No check-in answer or stop event appears in a shared document, a score, a log line or an analytics event.

## Evidence to record

Test paths, a run on a phone or emulator, and screenshots at 390x844. Rollback: remove the feature and confirm a workout opens as written.
