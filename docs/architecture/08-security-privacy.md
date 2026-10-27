# 08 · Security, privacy and moderation

Status: **Accepted**. Rules drafts: `firebase/firestore.rules`, `firebase/storage.rules`. Rule tests: `firebase/tests/rules/`.

## Role boundaries

| Role | Can | Cannot |
|---|---|---|
| Platform admin | Publish rulesets and content (callable); see the audit log; break-glass support via an audited callable with a reason | Read journals or private prayers through the client; there is no admin UI for private data |
| Organization admin (future) | Link groups, appoint group owners | Read any member data |
| Group owner / leader | Invite and remove, configure seasons and missions, moderate, see aggregates and the review queue | Read journals, private prayers, nutrition, body or health data, or proof outside reviewer duty |
| Reviewer | Review attempts and proof via signed URL (audited) | Download or retain media; see proof for other groups |
| Coach (future) | Training data a member explicitly shares | Anything not shared |
| Member | Own data; group content; scoped prayer requests | Other groups; others' private data |
| Guest / invitee | The invite landing only | Any group data before redemption |
| Multi-group member | Each group's data in that group's context | Cross-posting or cross-visibility by default |
| Household member / guardian (future, inactive) | Nothing by default; only items explicitly shared | Journals, health, messages or prayers by virtue of household (FS-FAM-002) |

## Threat model (Firebase-specific)

| Threat | Control | Verification |
|---|---|---|
| Broken object-level authorization (rules gap) | Deny-by-default `match /{document=**}`; every collection has explicit rules; protected-zone review | Rules test matrix (TC-001, TC-002, TC-016, TC-019–021, TC-037) |
| Cross-group exposure via collection-group queries | Collection-group rules require `uid == request.auth.uid` or a group membership check | TC-001 |
| Client writes privileged fields | `affectedKeys().hasOnly([...])` on updates; Functions-only collections | TC-037 |
| Score tampering or replay | Facts create-only; deterministic IDs; Functions-only ledger | TC-004 |
| Leaked or reused media URLs | No `getDownloadURL` for proof; signed URLs ≤ 15 min; static check | TC-010 |
| Malicious or oversized uploads | Storage rules size and type limits; client compression; EXIF strip | TC-046 |
| Abuse of API keys / scripted clients | App Check enforced in staging and prod (OD-19); callable rate limits per uid | TC-018 |
| Harassment | Report, block, mute; leader moderation callable; reporter hidden; escalation SLA | TC-049, TC-050 |
| Sensitive data in notifications | Content-free payloads | TC-023 |
| Sensitive data in diagnostics | Redacting logger; Crashlytics without content keys | TC-024 |
| Account takeover | Apple, Google or email-link sign-in (no passwords held); re-auth before deletion | Manual |
| Admin SDK misuse in Functions | Least-privilege service accounts; Functions code in a protected zone; audit log | Review |
| Secrets | API keys for providers in Secret Manager (Functions `defineSecret`); none in the app; gitleaks in CI | CI |
| Backups | Daily managed exports to a bucket with restricted IAM; restore drill before the pilot | TC-056 |
| Deletion or export gaps | `deleteAccount` and `exportAccount` sweep every path in the collection map | TC-014 |
| Youth exposure | Reserved paths denied; 18+ attestation; youth flag off | TC-015, TC-052 |

## Minimum security requirements for the first production release

1. Deny-by-default rules, with **all rules tests green** in CI against the emulator.
2. Functions-only writes for membership, ledger, standings, snapshots, reviews and moderation actions.
3. App Check enforced (OD-19).
4. No proof `getDownloadURL`; signed playback URLs ≤ 15 min.
5. Owner-only journals, nutrition, body and health data; content-free push payloads.
6. Complete deletion and export; re-auth before deletion.
7. Reports reach a named owner within the SLA (OD-17); blocks enforced server-side.
8. 18+ attestation; reserved family, youth and messaging paths denied.
9. Daily exports plus one restore drill.
10. Budget alerts on all projects; secrets in Secret Manager.
