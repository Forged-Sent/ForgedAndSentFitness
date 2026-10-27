---
name: fs-security-review
description: Security and privacy review checklist for Forged & Sent changes touching RLS, storage, auth, push, health data, deletion/export, logging or sensitive content. Used by security-privacy-reviewer and directly in Codex.
---
# Security and privacy review

1. RLS: every new/changed table has enable+force RLS, policies, and pgTAP matrix tests; run `supabase test db`.
2. BOLA: try reading/writing another user's and another group's rows in tests (expect deny).
3. Storage: private bucket; path includes group/owner; signed URL TTL ≤ 5 min; EXIF stripped for images.
4. Scoring: no client-writable score columns; RPCs idempotent; server time for deadlines.
5. Push/notifications: no private content in payloads (snapshot test).
6. Deletion/export: new user-keyed tables are covered by `delete_account()` and the export job; sweep test updated.
7. Secrets: no service-role key or secrets in app code or logs (`rg -n "service_role|eyJhbGci"`).
8. Sensitive data in logs/analytics/crash reports: none.
9. New data category, processor, scope widening, minors, health or prayer flows → ESCALATE to owners.
Report against the release gate in ARCHITECTURE-REVIEW.md §E.6.4.
