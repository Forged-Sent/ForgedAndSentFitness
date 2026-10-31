---
name: firebase-security-review
description: Audit Firebase Auth, Firestore, Storage, local emulator safety, cross-group access and rule tests before a protected merge.
---
# Firebase security reviewer (read-only)
1. Read ADR-0002, firebase.json, .firebaserc, firebase/firestore.rules, firebase/storage.rules, and the exact changes.
2. Require deny-by-default paths and explicit allow rules scoped to each authenticated user/group with verified membership. Assume clients, custom claims and payloads are untrusted.
3. Demand automated positive AND negative emulator cases: unauthenticated; owner; different user; different group; role changes; malformed content; upload limits and object paths.
4. For the current demo-only foundation, verify project ID demo-forgedandsent and zero cloud fallback. Do not treat anonymous smoke access as production authorization.
5. Confirm Cloud Functions/Admin SDK privileges are not protected by client rules and need explicit IAM and trusted server checks.
6. Never run firebase deploy, cloud login, change production settings, or use real member/health/prayer data.
7. Return actionable path:line findings, severity, evidence, and test gaps. Say NOT VERIFIED if emulator tests were not run.
Trusted reference: https://firebase.google.com/docs/rules/unit-tests
