# ADR-0008: Authorization source: membership documents

- Status: **Proposed**, as it was on the Phase 0 branch. Decision Q4 carries it forward. The maintainer decided on 2026-11-19 that it stays Proposed until build step S4b (groups, teams, scoring, the board) starts. **Planned: nothing here is built.**
- Date: 2026-10-27. Brought to `main` and renumbered on 2026-11-19.
- Decision owner: project maintainer (answer Q4 on the [Decisions](../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md) page)

## Where this record comes from

This is **Phase 0 ADR-0018**, "Authorization source: membership documents (claims optional cache)", from branch `arch/firebase-reconciliation` (commit `0d21d21`, file `docs/adr/ADR-0018-authorization-source-membership-documents-claims-optional.md`). It is renumbered so that the four records Q4 carries forward sit together after `main`'s ADR-0005.

The five sections from **Context** to **Requirements and verification** are the Phase 0 text, word for word. The sections after them are new and say how the record stands on `main`. The table of old and new numbers is in [ADR-0006](ADR-0006-group-level-isolation.md).

## Context

Rules need group role checks; claims refresh lags and are size-limited.

## Decision

Membership docs are the source of truth; rules use `get()` on `groups/{gid}/members/{request.auth.uid}`. Custom claims may cache `platformAdmin` only. Keep rule paths to ≤ 3 document reads per request.

## Alternatives considered

Claims-only roles.

## Consequences

+ Immediate revocation. − Billed rule reads.

## Requirements and verification

Requirements: FS-ACC-001..006. Verification: Rules tests; read-count budget review.

## How this stands on `main`

- **Nothing is built.** `firebase/firestore.rules` denies every read and write, apart from one owner-only path the emulator check uses (`developer_smoke`). There is no membership document, and no rules test for one.
- **Status.** Phase 0 left this record Proposed. The maintainer's Q4 answer names "membership-document authorization" among the four decisions to carry forward. On 2026-11-19 he decided that the record stays Proposed until S4b starts: nothing before S4b has a membership document, so nothing before it depends on this record. Whether it becomes Accepted is settled when S4b's contract is written.
- **"Immediate revocation" is about the server.** Removing a man's membership document stops his next read from the server. It does not remove group data that is already on his phone, for example while the phone is offline. What a removed man's phone may still show is for the groups contract to settle.
- **The requirement ids are not on `main`.** `FS-ACC-001..006` are defined in `docs/requirements/` on the Phase 0 branch.
- **The boundary these documents sit inside** is [ADR-0006](ADR-0006-group-level-isolation.md).
- **`platformAdmin`** is named here and not designed. Who may hold it, and what it allows, is undecided.
