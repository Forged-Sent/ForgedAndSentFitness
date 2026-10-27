# 02 · Data and domain architecture (Cloud Firestore)

Status: **Accepted (Phase 0)**. The collection layout below is a protected-zone contract (ADR-0015). Rules: `firebase/firestore.rules`. Indexes: `firebase/firestore.indexes.json`.

## Design rules

1. **The group path is the isolation boundary.** Every shared document lives under `groups/{gid}/…`. Personal-private data lives under `users/{uid}/…`.
2. **No unbounded arrays.** Arrays are capped and documented (e.g., `audienceUids ≤ 20`, `exercises ≤ 30`, `sets per exercise ≤ 20`). Anything that grows over time becomes a subcollection.
3. **No hot documents.**
   - No group-wide counters.
   - Standings use one document per team or member, recomputed by Functions and debounced.
   - Reactions are one document per user per post.
   - Firestore's documented per-document limit is 1 MiB, and its write rate is limited per document. Design for ≤ 1 write/s per document.
4. **Client-created facts use deterministic or client-generated IDs** with create-only rules, so retries are idempotent.
5. **Privileged fields are server-written.** Status, points, review outcome and membership role are never client-writable; rules check `request.resource.data.diff(resource.data).affectedKeys()`.
6. **Time:**
   - `localDate` is `YYYY-MM-DD` plus an IANA `tz` on day-scoped facts.
   - Instants use `serverTimestamp()` (`request.time` in rules).
   - Client claims are stored separately (`performedAt`).
7. **Every query is group-scoped and paginated.** Whole-collection listeners are banned (validator check).

## Collection map

| Path | Purpose | Owner / writer | Readers | Size bound | Notes |
|---|---|---|---|---|---|
| `users/{uid}` | Account root: tz, adultAttestedAt, createdAt, locale | Owner (limited fields); Functions | Owner | < 2 KB | No gender, marital or child fields required (FS-FAM-001) |
| `users/{uid}/settings/{key}` | Preferences, experience plan, units, notification prefs | Owner | Owner | < 16 KB each | `experiencePlan` lives here |
| `users/{uid}/journal/{entryId}` | Reflections, personal prayers, confessions | **Owner only** | **Owner only** | < 64 KB | Never read by Functions for scoring or notifications (FS-PRV-001) |
| `users/{uid}/days/{localDate}` | Experience run: stage states, template version, plan snapshot | Owner | Owner | < 32 KB | Stage map bounded by the template (≤ 20 stages) |
| `users/{uid}/sessions/{sessionId}` | Workout session aggregate: prescription snapshot, exercises[] with sets[], lease, revision | Owner (single-device lease) | Owner | < 200 KB | ≤ 30 exercises × ≤ 20 sets; `sessionId` is a client UUIDv7 |
| `users/{uid}/prs/{variantId_metric}` | Derived PRs | Functions | Owner | < 2 KB | Recomputable |
| `users/{uid}/foodEntries/{entryId}` | Meals and macros with provider provenance | Owner | Owner | < 4 KB | Query by `localDate` |
| `users/{uid}/nutritionDays/{localDate}` | Daily totals and hydration | Owner (client-computed mirror) | Owner | < 4 KB | Scoring uses participation facts, not totals |
| `users/{uid}/fasting/plan` | Fasting plan, safety acknowledgment | Owner | Owner | < 4 KB | Never scored |
| `users/{uid}/healthSources/{type}` | Consent and source per health type | Owner | Owner | < 2 KB | Revocable |
| `users/{uid}/healthDays/{localDate_type}` | Daily aggregate with provenance and dedupe keys | Owner | Owner | < 8 KB | `platformIds` capped at 200; overflow goes to a hash |
| `users/{uid}/bodyMetrics/{id}` · `progressPhotos/{id}` | Weight, measurements, photos (Storage path refs) | Owner | Owner | < 2 KB | Private (FS-PRV-003) |
| `users/{uid}/shares/{shareId}` | Record of items the user explicitly shared | Owner | Owner | small | Audit for revocation |
| `users/{uid}/exports/{id}` | Export job status and signed link | Functions | Owner | small | |
| `groups/{gid}` | Name, tz, settings, organizationId? | Functions | Members | < 16 KB | |
| `groups/{gid}/members/{uid}` | role (`member`, `leader`, `reviewer`, `owner`), state, displayName, photoPath, joinedAt | **Functions only** | Members | < 2 KB | Rules source of truth for authorization |
| `groups/{gid}/invites/{inviteId}` | Code hash, expiry, uses | Functions | Leaders | small | |
| `groups/{gid}/partnerships/{pairId}` | Accountability pair, accepted flags | Members (create request), Functions (accept) | Both partners | small | `pairId = sorted(uidA,uidB)` |
| `groups/{gid}/checkins/{uid}_{habitId}_{localDate}` | Habit or participation fact | Owner, create-only | Owner; Functions | < 1 KB | Deterministic ID prevents duplicates (FS-CMP-002) |
| `groups/{gid}/activity/{activityId}` | Opt-in public summaries ("Finished Full Body A") | Functions (from owner opt-in) | Members | < 2 KB | No loads unless opted in |
| `groups/{gid}/posts/{postId}` | Feed post | Author create; author edit body; Functions moderate | Members (minus blocks) | < 8 KB | `media[] ≤ 4` |
| `groups/{gid}/posts/{postId}/comments/{cid}` | Comments | Author | Members | < 4 KB | |
| `groups/{gid}/posts/{postId}/reactions/{uid}` | One reaction per user | Owner | Members | < 200 B | No arrays of likers |
| `groups/{gid}/prayerRequests/{rid}` | title, body, `audience`, `audienceUids[] ≤ 20`, status | Author | Audience (see rules) | < 8 KB | Queries must filter on `audience` / `audienceUids` |
| `…/prayerRequests/{rid}/updates/{id}` · `/prayed/{uid}` | Updates; "I prayed" markers | Author / prayer | Audience; requester sees counts | small | |
| `groups/{gid}/reports/{rid}` | Moderation report | Reporter create | Leaders; reporter | small | Reporter identity hidden from the reported user |
| `groups/{gid}/moderationActions/{id}` | Actions taken | Functions | Leaders | small | Audit |
| `groups/{gid}/seasons/{sid}` | Season config: tz, start/end, `rulesetId`, `practice`, normalization, `state` | Functions (leader-requested callable) | Members | < 16 KB | |
| `…/seasons/{sid}/teams/{tid}` | Team name, captain | Functions | Members | small | |
| `…/seasons/{sid}/enrollments/{uid}` | teamId?, baselines (frozen), enrolledAt | Functions | Members (own full; others limited) | < 4 KB | Individuals may have `teamId = null` |
| `…/seasons/{sid}/challenges/{cid}` | Instance: definitionRef, tiers, alternates, `proofPolicy`, opensAt, closesAt, graceMinutes, state | Functions | Members | < 32 KB | |
| `…/challenges/{cid}/attempts/{attemptId}` | Fact: uid, tier, alternateId?, value(s), performedAt, receivedAt (server), proofIds[] ≤ 3, status (server) | Owner create-only; Functions status | Owner; reviewers; members see approved summaries via projection | < 8 KB | `attemptId` client UUIDv7 |
| `…/attempts/{attemptId}/reviews/{rid}` | Reviewer decisions | Functions (reviewer callable) | Owner; reviewers | small | |
| `…/seasons/{sid}/missions/{mid}` · `/completions/{uid}` | Weekly non-workout missions and their completion facts | Functions / owner create-only | Members (counts), owner | small | Variant choice is private |
| `…/seasons/{sid}/ledger/{entryId}` | **Append-only** score events | **Functions only** | Members (own); leaders (all) | < 2 KB | `entryId = {sourceType}_{sourceId}_{rulesetVersion}_{kind}` |
| `…/seasons/{sid}/standings/{teamId or u_{uid}}` | Projection with component breakdown | Functions only | Members | < 16 KB | Recomputed, not incremented |
| `…/seasons/{sid}/snapshots/{weekOrFinal_vN}` | Finalized results with SHA-256 | Functions only | Members | < 256 KB | Never rewritten; a new version for appeals |
| `…/seasons/{sid}/appeals/{id}` | Appeals | Owner create; Functions resolve | Owner; leaders | small | |
| `rulesets/{rulesetId}` | Immutable ruleset (schema `contracts/ruleset.schema.json`) | Platform admin via Function | Authenticated | < 64 KB | `approvedBy`, `approvedAt` required |
| `content/{packageId}/versions/{version}` | Manifest: license, approvals, sha256, storagePath | Functions (publish gate) | Authenticated | small | Payload in Storage `content/` |
| `organizations/{oid}` | Future: links groups | Functions | Org admins | small | **Grants no member data** (FS-ACC-005) |
| `households/{hid}`, `guardianLinks/{id}` | **Reserved, denied** until approved | — | — | — | FS-FAM-002 |
| `conversations/**` | **Reserved, denied** | — | — | — | ADR-0017 |
| `auditLog/{id}` | Privileged actions | Functions | Platform admins | small | |

## Domain entities and lifecycles

| Entity | States | Immutability |
|---|---|---|
| Membership | invited → active → left / removed | Role changes are audit-logged |
| Experience run | per stage: pending → available → in_progress → completed / skipped / deferred | Completed stages are never reset (FS-DWE-002) |
| Workout session | in_progress → finished / discarded | After finish, an edit means `revision+1` and re-evaluation produces superseding ledger entries |
| Check-in | recorded → (retracted the same local day) | The fact is immutable; retraction is a field written by a Function |
| Attempt | submitted → in_review → approved / rejected / needs_info → (withdrawn) | Value fields are immutable; corrections are a new attempt |
| Proof | captured → queued → uploading → uploaded → attached → reviewed → retained → purged | See `06-proof-media.md` |
| Challenge | draft → scheduled → open → closed → in_review → finalized → under_appeal → finalized(vN) | |
| Season | planned → active → closed → finalized | `practice` seasons are never archived as history |
| Ledger entry | — | **Append-only** |
| Content package version | draft → in_review → approved → published → retired | A published version is immutable |
| Prayer request | open → answered / closed | The author edits; audience changes are logged |
| Report | open → actioned / dismissed → appealed | |

## Composite indexes (initial)

| Collection | Fields | Query |
|---|---|---|
| `posts` | `createdAt desc` | Group feed page |
| `prayerRequests` | `audience asc, createdAt desc` | Group-visible requests |
| `prayerRequests` | `audienceUids array-contains, createdAt desc` | Partner-scoped requests |
| `checkins` | `uid asc, localDate desc` | Own history |
| `attempts` (collection group) | `uid asc, receivedAt desc` | My attempts across challenges |
| `attempts` | `status asc, receivedAt asc` | Review queue |
| `ledger` | `uid asc, createdAt desc` | My points breakdown |
| `foodEntries` | `localDate asc, createdAt asc` | Day log |

## Authorization summary

| Role | Reads | Writes |
|---|---|---|
| Owner (self) | All of `users/{uid}/**`; own facts | Own personal docs; create-only facts; own posts, comments and reactions; own prayer requests |
| Member | Group config, members, posts, scoped prayer requests, standings, snapshots, approved activity | Posts, comments, reactions, reports, partnership requests |
| Reviewer | + attempts and reviews in the group; proof via signed URL | Via the review callable only |
| Leader | + reports, invites, moderation actions, aggregate participation | Via callables only (invite, moderate, configure season) |
| Org admin (future) | Org metadata only | Via callables |
| Platform admin | Rulesets, content manifests, audit log | Via callables; break-glass is audited |
| Household / guardian (future) | **Nothing by default** | — |

## Query implications

- Prayer requests cannot be fetched with a single query that mixes audiences under rules. The client runs two queries: `audience == 'group'`, and `audienceUids array-contains me`. Leaders add a third: `audience == 'leaders'`.
- Standings are read as a small collection per season (≤ teams + members docs).
- The board never aggregates on the client.
- A cross-group "my attempts" query uses a collection-group query with a `uid ==` constraint matching the rules.
