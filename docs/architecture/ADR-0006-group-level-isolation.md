# ADR-0006: Group-level isolation

- Status: **Accepted** on 2026-10-27 (Phase 0); carried forward by decision Q4. **Planned: nothing here is built.**
- Date: 2026-10-27. Brought to `main` and renumbered on 2026-11-19.
- Decision owner: project maintainer (answer Q4 on the [Decisions](../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md) page)

## Where this record comes from

This is **Phase 0 ADR-0004**, "Group-level isolation; optional organization layer", from branch `arch/firebase-reconciliation` (commit `0d21d21`, file `docs/adr/ADR-0004-group-level-isolation-optional-organization-layer.md`). It has a new number because `main` already has an [ADR-0004](ADR-0004-hosted-ai-review-gate.md), which is a different decision.

The five sections from **Context** to **Requirements and verification** are the Phase 0 text, word for word. Nothing was added to the decision and nothing was taken out. The sections after them are new and say how the record stands on `main`.

| Phase 0 number (branch only) | Number on `main` | Decision |
|---|---|---|
| ADR-0004 | **ADR-0006** (this record) | Group-level isolation |
| ADR-0005 | [ADR-0007](ADR-0007-server-scoring-ledger.md) | Server-authoritative scoring ledger |
| ADR-0018 | [ADR-0008](ADR-0008-membership-document-authorization.md) | Membership documents authorize |
| ADR-0012 | [ADR-0009](ADR-0009-faith-participation-privacy.md) | Faith participation and privacy |

## Context

Pilot is one men's group; growth means many independent groups and possibly churches.

## Decision

`groups/{gid}` is the isolation boundary. Every shared document lives under a group path. Membership is `groups/{gid}/members/{uid}` (written only by Functions). Rules check membership and role. `organizations/{oid}` (future) links groups for administration only and **grants no member data access**. Cross-group feeds are off.

## Alternatives considered

Organization-first tenancy (premature). Custom-claims-only membership (token refresh lag, 1,000-byte claims limit).

## Consequences

+ Simple pilot, additive growth. − Rules reads per request; queries must always include the group path.

## Requirements and verification

Requirements: FS-ACC-001..006. Verification: Rules tests: non-member denied; member of group A denied group B.

## How this stands on `main`

- **Nothing is built.** `firebase/firestore.rules` denies every read and write, apart from one owner-only path the emulator check uses (`developer_smoke`). There is no group, no membership document and no Cloud Function. The verification named above has not been written or run.
- **The requirement ids are not on `main`.** `FS-ACC-001..006` are defined in `docs/requirements/` on the Phase 0 branch. Q4 carries this decision forward, not that requirements file.
- **How membership is checked** is its own record: [ADR-0008](ADR-0008-membership-document-authorization.md).
- **Roles, teams, invitations and the organization layer** are named here and not designed. They belong to the feature contract for groups, which the maintainer has not approved.
- Agrees with the standing rule in `AGENTS.md`: group and role authorization is enforced on the server.
