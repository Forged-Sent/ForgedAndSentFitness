# 05 · Offline storage and synchronization

Status: **Accepted (ADR-0006)**. The library choice (Drift) is OD-08. Diagrams: `diagrams/08-offline-workout-logging.mmd`, `diagrams/09-offline-sync-sequence.mmd`.

## Two local stores, one owner per data class

Firestore's mobile SDK keeps an offline cache and a persisted queue of pending writes. Its documented behavior:

- Persistence is on by default on Android and Apple.
- The default cache size is 100 MB, and older unused documents are evicted beyond that.
- On reconnect, the last write wins for the same document.

That cache stays enabled, but it **is not the system of record for in-progress personal work**:

- Pending writes are not inspectable as business objects.
- Evicted documents vanish from offline reads.
- Transactions and callables need connectivity.
- Workout history needs local relational queries.

| Data class | Device source of truth | Sync path | Conflict rule |
|---|---|---|---|
| In-progress workout session, sets, timers | **Drift** | Outbox → `users/{uid}/sessions/{id}` (set with merge, `revision` guarded) | Single-writer lease; a stale `revision` is rejected by rules and the local copy is kept |
| Experience run stage states | **Drift** | Outbox → `users/{uid}/days/{date}` | Per-stage max-state wins; earliest `completedAt` kept |
| Facts: check-ins, mission completions, attempts | **Drift** (outbox entry) | Outbox → create with deterministic or UUIDv7 ID | Create-only; duplicates are no-ops |
| Food and water entries, journal entries | **Drift** | Outbox → owner collections | Last write wins per entry (single user); entries are separate docs, so no list merges |
| Proof media | **App-private file + Drift record** | Resumable Storage upload, then attach to the attempt | See `06-proof-media.md` |
| Shared reads: feed, prayer requests, standings, members, content manifests | **Firestore cache** | Firestore listeners (scoped, paginated) | Server wins |
| Content packages (programs, devotionals, templates) | **Bundled assets + downloaded files** | Manifest check, then download to app storage | Immutable versions |
| Server-only intents: redeem invite, review, finalize, delete account, export | **Drift intent queue** | Callable when online | Shown as pending; never shown as done before the server responds |

## Outbox entry

```text
id (UUIDv7) · kind · targetPath · op(create|set|merge|delete) · payload (JSON) · createdAt · attempt · nextAttemptAt
status: pending | in_flight | written_local | acknowledged | conflict | needs_attention | discarded
correlationId · lastError
```

## State machine

```text
pending → in_flight          when online and nextAttemptAt ≤ now
in_flight → written_local    Firestore write future accepted into its local queue
written_local → acknowledged snapshot for targetPath has metadata.hasPendingWrites == false (server ack)
in_flight/written_local → conflict          permission-denied on a revision-guarded doc, or lease lost
in_flight/written_local → needs_attention   permission-denied (validation, window closed) or invalid-argument
in_flight → pending (backoff)               unavailable / deadline-exceeded / resource-exhausted
conflict → needs_attention                  local copy kept; user chooses
needs_attention → pending | discarded       explicit user action only (FS-OFF-004)
```

- **Backoff:** full jitter from 2 s, capped at 5 min.
- **Triggers:** app foreground, connectivity change, auth refresh, and a periodic best-effort background task.

## Idempotency and duplicate prevention

- Document IDs are chosen on the client before the first attempt, so any retry, and any two devices, address the same document.
- Facts use create-only rules (`allow create` with validation; `allow update: if false`). A retried `set()` on a document that already exists is evaluated as an **update** and denied with `permission-denied`. When that happens on a create-only path, the outbox **reads the document**:
  - If the document exists and its `payloadHash` matches the entry, the entry is marked **acknowledged**.
  - Otherwise it goes to `needs_attention`.
- Deterministic fact IDs give natural uniqueness:
  - `checkins/{uid}_{habitId}_{localDate}`: one per day per habit across devices.
  - `missions/{mid}/completions/{uid}`: one per mission.
- Functions use deterministic ledger IDs, so trigger redelivery can't double count (FS-CMP-002).

## Crash safety for workouts (FS-OFF-001/002)

1. A session row is created in Drift (`in_progress`, `leaseDeviceId`, `startedAt`) before the first set is shown.
2. Every set edit is a Drift transaction committed **before** the UI shows it as saved. There is no debounce on local writes; debounce applies only to outbox flushes.
3. Timers store wall-clock anchors (`restStartedAt`, `intervalEndsAt`) and are recomputed on resume. Rest-end alerts use local notifications.
4. On cold start, `ResumeSessionGuard` finds `in_progress` sessions and offers Resume, Finish or Discard.

## Time

`localDate` is computed from the member's IANA tz at the moment of the action and stored with `tz`. Server deadlines use `request.time` against the season's tz (FS-OFF-008).

## What does not work offline

These actions show a pending state while offline:

- Joining a group or redeeming an invite.
- Proof review and appeals.
- Finalization and final standings.
- Account deletion and export.
- Push delivery.
- Nutrition provider search (recent and favorite foods are cached for offline logging).
