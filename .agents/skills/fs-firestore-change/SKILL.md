---
name: fs-firestore-change
description: Add or change a Firestore collection, document shape, security rule, Storage rule or index for Forged & Sent, with rules tests. Protected zone; requires label contract-change, an ADR reference and two human approvals.
---
# Firestore / Storage contract change

1. Update `docs/architecture/02-data-architecture-firestore.md` first: path, owner/writer, readers, size bound, indexes, lifecycle.
2. Rules (`firebase/firestore.rules`, `firebase/storage.rules`):
   - Deny by default.
   - Privileged collections are Functions-only (`allow write: if false`).
   - Facts are create-only with id and `uid == request.auth.uid` checks and `receivedAt == request.time`.
   - Updates use `changedOnly([...])`.
   - Keep each request to 3 or fewer `get()`/`exists()` calls (billed reads; hard limit 10 per single-document request).
3. Queries the app will run must be provable by the rules (include the same constraints, e.g. `audienceUids array-contains uid`).
4. Avoid unbounded arrays and hot documents. Grow by subcollection; recompute projections in Functions.
5. Tests: add allow and deny cases for owner, other member, leader, reviewer, non-member and unauthenticated in `firebase/tests/rules/`. Run `npm --prefix firebase test`.
6. Indexes: `firebase/firestore.indexes.json` holds composite indexes only.
7. Run `python3 tools/validate_architecture.py`. Add the requirement or test ids to `docs/requirements/`.
