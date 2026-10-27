# 09 · Operations, cost and observability

## Observability

| Signal | Tool | Notes |
|---|---|---|
| Crashes and non-fatal errors | Firebase Crashlytics | Redacting logger; no user content in custom keys (ADR-0016, Proposed) |
| Functions logs | Cloud Logging | Structured JSON with `correlationId` (from the outbox entry) and `uid` hashed |
| Sync health | Custom non-PII metrics: outbox `needs_attention` count, ack latency | Reported as Crashlytics non-fatals with codes |
| Scoring health | Finalization job success, ledger write conflicts | Alert on failure |
| Cost | Budget alerts at 50 / 90 / 100 % per project | Required (FS-OPS-001) |

## Incident response (runbook outline)

1. **Triage** within the SLA (OD-17).
2. **Contain:**
   - Disable the feature via a Remote Config flag.
   - Tighten rules through a hotfix PR, which requires two approvals even in an emergency.
3. **Assess data exposure** using audit logs and Firestore access patterns.
4. **Notify** affected members if private data was exposed.
5. **Post-incident:** write an ADR or requirement update and add a regression test.

## Moderation accountability

- Group leaders are the first line.
- Project owners handle escalation.
- Named owners and response times are set in OD-17.
- Every moderation action is recorded in `moderationActions` and `auditLog`.

## Cost model (illustrative, not a quote)

**Verified 2026-10-26** ([Firebase pricing](https://firebase.google.com/pricing), [Firestore pricing](https://cloud.google.com/firestore/pricing), [Cloud Storage pricing](https://cloud.google.com/storage/pricing)):

| Service | Free allowance | Rate beyond it |
|---|---|---|
| Firestore reads | 50k/day | $0.03 per 100k (default column; location rates may differ) |
| Firestore writes | 20k/day | $0.09 per 100k |
| Firestore deletes | 20k/day | $0.01 per 100k |
| Firestore storage | 1 GiB | — |
| Cloud Functions | 2M invocations/month | $0.40 per million, plus compute |
| Storage (new buckets) | 5 GB-months | Cloud Storage standard ≈ $0.02/GiB-month (us-central1, derived from the hourly rate) |
| Internet egress | — | $0.12/GiB (first 10 TiB, worldwide excl. Asia/Australia) |
| FCM | No cost | — |

**Scenario:** `docs/architecture/evidence/firebase_cost_model.py` (output in `firebase_cost_model.out.md`) (assumptions printed with the output). The dominant drivers are video storage and egress, then scoped Firestore reads. The prototype's whole-collection listener pattern would cost roughly 70M reads/day at 1,000 users, which is why the validator bans it.

**Sustainability levers:**

- Proof policy per challenge.
- Compression.
- Retention deletion.
- Reviewer-only playback.
- Paginated, group-scoped queries.
- Cached content packages instead of per-user reads.

Illustrative output (compute excluded; it ignores the 100 GB/month free download allowance on default buckets, so it is conservative):

| Active users | Video proof | Reads $ | Writes $ | Functions $ | Storage $ (GiB) | Egress $ | Total $/mo |
|---:|---|---:|---:|---:|---:|---:|---:|
| 100 | no | 0 | 0 | 0 | 0 (5) | 0 | **0** |
| 100 | yes | 0 | 0 | 0 | 0 (11) | 1 | **1** |
| 1,000 | no | 2 | 1 | 0 | 1 (47) | 4 | **7** |
| 1,000 | yes | 2 | 1 | 0 | 2 (105) | 11 | **15** |
| 10,000 | no | 22 | 10 | 0 | 9 (469) | 38 | **79** |
| 10,000 | yes | 22 | 10 | 0 | 21 (1,055) | 108 | **161** |
| 100,000 | no | 225 | 107 | 9 | 94 (4,688) | 375 | **809** |
| 100,000 | yes | 225 | 107 | 9 | 211 (10,547) | 1,078 | **1,630** |

These figures cover infrastructure only, excluding Apple and Google developer fees and nutrition-provider fees. Video proof roughly doubles the cost at scale, and egress dominates.
