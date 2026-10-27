---
name: fs-security-review
description: Security and privacy checklist for Forged & Sent changes to rules, Functions, auth, membership, proof media, health, nutrition, journal/prayer, notifications, deletion/export or logging. Preloaded by security-privacy-reviewer; usable directly in Codex.
---
# Security and privacy review

1. **Rules:**
   - Deny-by-default intact.
   - Every new path has allow and deny tests for each role.
   - `npm --prefix firebase test` is green.
2. **BOLA:** tests try another user's and another group's documents and objects, and expect a deny.
3. **Privileged collections stay Functions-only:** membership, ledger, standings, snapshots, reviews, moderation.
4. **Proof:**
   - No `getDownloadURL`.
   - Signed URL TTL ≤ 15 min and audit-logged.
   - Size and type limits.
   - EXIF stripped.
5. **Notifications and logs:** no prayer, journal, nutrition, health or proof content.
6. **Deletion and export:** new user-keyed paths are added to `deleteAccount` and `exportAccount`, and to their tests.
7. **Secrets:** Secret Manager only; nothing in the app; gitleaks clean.
8. **Reserved paths:** households, guardianLinks and conversations stay denied.
9. **ESCALATE** on scope widening, new data categories or processors, minors, or any access to faith content.
