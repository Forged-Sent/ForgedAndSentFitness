# Reconciliation of Blueprint decisions D01–D35

| | |
|---|---|
| Status | **Accepted for Phase 0.** Every "Open" item below needs human sign-off (see `open-decisions.md`) |
| Repository audited | `main` @ `b66e93ebb8a1e7be44368301c87a4ec87280b0e0` (v162, 2026-10-26 22:08 MST) |
| Inputs | Blueprint discussion page (35 decisions; the PDF print `Discusison website.pdf` has no votes, notes or comments recorded, and the live page's store was empty on 2026-10-27); independent review `docs/reviews/2026-10-26-independent-architecture-review/`; **approved product direction** of 2026-10-27 (Firebase, integrated devotional workouts, team competition, video proof, bounded nutrition points, adult pilot first) |
| Not found | The "Forged & Sent Firebase Architecture and Agent Kit" is not in the repository, the local working copy or the conversation attachments. It was not reviewed. Supply it to have it reconciled against this document. |

**Classifications:**

- **Aligned:** already consistent with the approved direction.
- **Improvement:** worth incorporating.
- **Conflict:** contradicts an approved decision; resolved here in favor of the approved decision.
- **Open:** needs human approval.
- **Superseded:** replaced by a later decision.

A decision can be both Conflict and Open: the conflict is resolved, but a parameter is left for humans to set.

## Summary

| ID | Blueprint recommendation | Class | Final disposition | ADR / OD | Approval? |
|---|---|---|---|---|---|
| D01 | Rebuild; prototype = spec | Aligned | Rebuild in Flutter. The prototype is **kept** as an executable behavioral reference, never as a foundation. | ADR-0001 | No |
| D02 | Flutter (conditional on team skills) | Aligned | Flutter/Dart is approved. The condition is dropped. | ADR-0002 | No |
| D03 | Supabase (PostgreSQL) | **Conflict → Superseded** | **Firebase** (Auth, Firestore, Functions, Storage, FCM, App Distribution). The review's Supabase ADR is marked Rejected. Its integrity goals move into Firebase controls: server-only ledger, rules tests, deterministic IDs. | ADR-0003 | No (approved) |
| D04 | Local DB + outbox | Aligned + Improvement | Drift (SQLite) outbox **in front of** Firestore's offline cache. Both layers and their conflict behavior are defined. | ADR-0006, OD-08 | Library choice only |
| D05 | Group as tenant; orgs later | Aligned + Improvement | Group isolation now. **Organization and Household** are optional future layers that grant nothing by themselves. | ADR-0004, ADR-0013 | No |
| D06 | Templates + versioned packages | Aligned | Programs are generated from templates, with **equivalence tests** against all 1,460 existing day rows | ADR-0007 | No |
| D07 | Protected zones + 3 agents | Improvement | A specialist **catalog**. **2–4 active roles** per change. File ownership map. Independent reviewers. No autonomous merges. | ADR-0015 | No |
| D08 | "Both, separate spaces" | **Conflict → resolved** | Faith and training are **integrated** in the Devotional Workout Experience Engine. Only private spiritual content stays out of competition. | ADR-0008 | No |
| D09 | No individual points for spiritual practice | **Conflict + Open** | **Participation-only** faith points are permitted, bounded and **never based on content or quality**. Weights are open. Journals and prayers are never scored or shared. | ADR-0012, OD-01 | **Yes (weights)** |
| D10 | Fasting private, unscored, safety screen | Aligned | Private by default; shared only by explicit action; no points; safety screen | ADR-0011, ADR-0012 | No |
| D11 | Prayer default = partner | Aligned + Open | Private by default. The author picks the audience per request. The default audience is open. | OD-05 | **Yes** |
| D12 | Leaders see aggregates only | Aligned | No broad leader access. Private journals are never visible to leaders. | ADR-0004 | No |
| D13 | Inclusive family variants | Aligned | Missions offer variants for single, divorced, widowed, childless and other households. The domain model never assumes a spouse or children. | ADR-0013 | No |
| D14 | Faithfulness calendar + grace days | Aligned (explore) | Adopted as the default. Grace-day count is configurable. | OD-21 | Parameter |
| D15 | Pastor/elder approval; BSB default | Aligned | Content approval workflow; BSB default; ESV only with notice or license | ADR-0007 | Reviewers named (OD-10) |
| D16 | Devotional rights | Aligned + Open | Rights **must be established before public release**. This blocks publication, not development. | OD-11 | **Yes** |
| D17 | Server ledger, versioned rules | Aligned | Cloud Functions write an append-only ledger with deterministic IDs. Rules are versioned; seasons are finalized. | ADR-0005 | No |
| D18 | Tiered proof (honor + spot checks) | **Conflict → resolved** | **Video capture is required in the first challenge release.** Whether proof is optional or required is **set per challenge by admins**. Spot checks remain a valid configuration. | ADR-0010 | No |
| D19 | No video in v1 | **Conflict → Superseded** | Video is supported. Cost and privacy controls go in its place: client compression, reviewer-only access, retention limits. | ADR-0010, OD-06 | Retention (OD-06) |
| D20 | Divisions instead of flat 50 | **Conflict → reconciled** | **Two difficulty tiers** (Standard, Foundation) plus **approved alternates** mapped to a tier. Point differences are published. Injured men can still contribute meaningfully, and the max(flat, std) loophole is removed. | ADR-0009, OD-03 | **Yes (multipliers)** |
| D21 | Personal improvement vs brackets | Aligned + Improvement | Personal-improvement points against a frozen baseline. Age brackets are retired as the primary fairness tool. | ADR-0009 | No |
| D22 | Strict PRs (variant, e1RM, baseline) | Aligned | Adopted. PRs feed personal progress; PR points are bounded. | ADR-0009, OD-18 | Cap |
| D23 | Cap steps; device data only | Aligned | Daily cap. Only health-sourced steps earn bonus points. | ADR-0009, OD-14 | Cap |
| D24 | One board | **Improvement** | **Team rankings first**, with a published score breakdown. Individual personal-progress views are always available. | ADR-0009 | No |
| D25 | Grace window + review flag | Aligned + Open | Server time plus a configurable grace window; late offline attempts go to review | ADR-0009, OD-13 | Window length |
| D26 | No prizes | Aligned | **No cash or gambling-like prizes**, by design. Small recognition only. | ADR-0009 | No |
| D27 | Run Nov 2 on honor system | **Superseded** | The Nov 2 start is **not binding**. Seasons are configurable. **Practice competitions** run until rules and scoring tests pass. | ADR-0019, OD-12 | Pilot date |
| D28 | Fresh start + optional export | Aligned | Optional portability; migration is not a release blocker | ADR-0001 | No |
| D29 | Adult men only in v1 | Aligned + Improvement | Adult pilot. The model is gender-neutral and family-extensible. Youth stays inactive behind a flag until it has its own design. | ADR-0013 | No |
| D30 | Calories personal, unscored | **Conflict → resolved** | **Bounded nutrition participation points** (logging and hydration), never deficit or weight-loss based | ADR-0011, OD-04 | **Yes (caps)** |
| D31 | Health in Release 2 | Aligned + Improvement | Delivery can be staged, but the **data architecture includes health sources now** (provenance, dedupe, consent) | ADR-0011 | No |
| D32 | No DMs in v1 | Aligned | No direct or youth messaging without an approved moderation and safety design | ADR-0017 | No |
| D33 | Free (ministry) | Open | Cost-sustainability plan plus a budget alert. The commercial model stays open. | OD-16 | Yes |
| D34 | Leaders first, owners escalate | Aligned + Open | Moderation accountability with named owners and SLAs | OD-17 | Yes |
| D35 | Sentry | **Superseded** | Firebase Crashlytics, because Firebase is now the platform, with a redaction policy. Sentry stays a fallback. | ADR-0016 | No |

**Counts by primary class** (35 total):

| Primary class | Count | Decisions |
|---|---:|---|
| Aligned | 23 | D01, D02, D04, D05, D06, D10–D17, D21–D23, D25, D26, D28, D29, D31, D32, D34 |
| Improvement | 2 | D07, D24 |
| Conflict, resolved | 7 | D03, D08, D09, D18, D19, D20, D30 |
| Superseded | 2 | D27, D35 (D03 and D19 are also superseded) |
| Open | 1 | D33 |

13 decisions carry an open parameter even though their class is settled.

---|---|
| Aligned | 21 |
| Improvement | 2 (D07, D24) |
| Conflict, resolved | 6 (D03, D08, D18, D19, D20, D30) |
| Superseded | 3 (D27, D35, and D19 together with D03) |
| Carry open parameters | 13 |

---

## Detail per decision

Format: **Repo** = what the prototype at v162 does · **Approved** = the approved requirement · **Assessment** · **Disposition** · **Trade-offs** · **Affects** · **Verification**.

### D01: Rebuild vs wrap
- **Repo:** A single 7,152-line `index.html` with client-authoritative scoring and claude.ai `window.claude` capabilities. 162 version snapshots.
- **Approved:** The HTML prototype must not be the foundation. It must not be deleted; keep it as a behavioral reference.
- **Assessment:** Agree. The rules worth keeping (water coalescing, ramp sets, lift-day scheduling, Sabbath rest) are extracted as golden fixtures.
- **Disposition:** Rebuild. Freeze the prototype at tag `prototype-v162` and keep `index.html`, `seed/` and `versions/` in place.
- **Trade-offs:** Parity takes time. The prototype keeps serving the group meanwhile.
- **Affects:** ADR-0001 · FS-PAR-001..003.
- **Verification:** Legacy characterization fixtures in `contracts/golden/legacy/` (Phase 0 deliverable).

### D02: Flutter
- **Repo:** No Flutter code yet. dart-lang agent skills exist locally (untracked).
- **Approved:** Flutter/Dart.
- **Disposition:** Accepted. The team-skill caveat is withdrawn.
- **Affects:** ADR-0002.
- **Verification:** `flutter analyze` and `flutter test` in CI.

### D03: Backend
- **Repo:** claude.ai `db` (a Firestore-like document API).
- **Approved:** Firebase (Auth, Firestore, Functions, Storage, notifications, distribution). Do not swap it for Supabase.
- **Assessment:** The review preferred Postgres for its relational integrity. That preference doesn't make Firebase unworkable. Each concern is closed with a Firebase-native control:

| Concern | Firebase control |
|---|---|
| Scoring integrity | A ledger collection that **only Cloud Functions can write**; deterministic ledger IDs; transactional create-if-absent |
| Cross-group privacy | Membership-doc rules plus a rules unit-test matrix in CI |
| Aggregation | Standings projections recomputed by functions, never client counters |
| Cost from broad listeners | Group-scoped, paginated queries only; a validator bans whole-collection listeners |
| Exit | Scheduled Firestore exports to Cloud Storage plus documented schemas |

  **Residual risks:**
  - Rule reads are billed, and capped at 10 per request.
  - Relational reporting needs a BigQuery export later.
  - Event-triggered functions are at-least-once, so every trigger must be idempotent.

  All three are documented in ADR-0003.
- **Disposition:** Firebase accepted. The review's Supabase recommendation is **Rejected (superseded by ADR-0003)**.
- **Affects:** ADR-0003, ADR-0005, ADR-0018 · FS-ACC-*, FS-CMP-*.
- **Verification:** `firebase/tests/rules/*.test.mjs` (CI with the emulator), plus function idempotency tests.

### D04: Offline
- **Repo:** Debounced remote writes with `catch(noop)` (`saveWkNow`, idx L3261). One workout document per date.
- **Approved:** Offline-first, with durable local storage and an outbox.
- **Assessment:** Firestore's own offline cache is on by default on mobile (100 MB default, LRU cleanup, last-write-wins on reconnect). It isn't enough alone:
  - Pending writes are opaque to the app.
  - Cached documents can be evicted.
  - Transactions and callables need a connection.
  - There is no structured local query store for workout history.
- **Disposition:** Drift is the **device source of truth** for in-progress personal records. The outbox hands writes to Firestore with deterministic document IDs, and the outbox entry is marked "acknowledged" only after the server confirms (`hasPendingWrites == false`). Firestore's cache serves shared reads.
- **Trade-offs:** There are two local stores, so the ownership of each collection is written down (`05-offline-sync.md`).
- **Affects:** ADR-0006 · FS-OFF-001..008.
- **Verification:** A kill-and-restart integration test, plus the "synced once" test.

### D05: Groups
- **Repo:** One implicit global group. America/Phoenix hard-coded.
- **Approved:** Group isolation now; organization and household layers later.
- **Disposition:** `groups/{gid}` is the isolation boundary. `organizations/{oid}` is optional and links groups but grants no data access. `households/{hid}` is future, inactive, and **never** grants access to journals, health, messages or prayers.
- **Affects:** ADR-0004, ADR-0013 · FS-ACC-001..006, FS-FAM-001..004.
- **Verification:** Two-group isolation rules test; household-grants-nothing test.

### D06: Workout templates
- **Repo:** 1,460 materialized day rows. RPE/RIR stripped from the embedded copy. v158 and v162 added **effective-dated lift-day selection** (`plan.lifts: [{from, days}]`).
- **Disposition:** Versioned templates (`content/programs/*`) feed a generator, which produces schedules. An **equivalence test** must reproduce all 1,460 seed rows exactly before any template edit. Lift-day selection is carried forward as `enrollment.liftDays` history.
- **Affects:** ADR-0007 · FS-TRN-001..006.
- **Verification:** `tools/fs_content` round-trip test (Phase 3).

### D07: AI agents
- **Approved:** Keep a specialist catalog; 2–4 active roles per change; file ownership; independent reviews; no autonomous merging.
- **Disposition:** Catalog of 8 roles in `.claude/agents/`; an ownership map in `AGENTS.md`; CODEOWNERS; a protected-zone guard.
- **Affects:** ADR-0015 · FS-DEV-001..006.
- **Verification:** `tools/check_zones.sh` in CI.

### D08: What is Forged & Sent first?
- **Approved:** A faith-centered devotional workout, accountability and community platform. Faith and training are **integrated**.
- **Assessment:** The Blueprint recommended "separate spaces", which conflicts with integration.
- **Disposition:** The **Devotional Workout Experience Engine** integrates the two (before, after, during rest, split day, single-mode). The competitive firewall applies only to *private spiritual content*.
- **Affects:** ADR-0008 · FS-DWE-001..010.

### D09: Spiritual practice and points
- **Approved:** Faith-participation point weights stay open. Never score prayer or reflection content or quality.
- **Assessment:** The Blueprint's "no points at all" goes beyond the approved direction.
- **Disposition:** Allowed signals are boolean participation events only (stage opened or completed), capped per day and week. **Disallowed:** any text, length, word count, sentiment, AI assessment, or public per-man display of devotional completion unless the man opts in. Weights → OD-01.
- **Affects:** ADR-0012 · FS-CMP-012, FS-PRV-004.
- **Verification:** A ruleset schema test (no scoring input can reference journal or prayer fields); a function unit test.

### D10: Fasting
- **Disposition:** Private by default; explicit share to a partner; never scored; safety screen. The prototype's public tag and its Calories auto-check (idx L2017, L5003) are retired.
- **Affects:** FS-NUT-006, FS-PRV-003.

### D11: Prayer audience
- **Disposition:** The audience is chosen per request (`private | partners | leaders | group`). **Default audience is open (OD-05)**; this design defaults to `private` until it's decided. Notifications never contain prayer text.
- **Affects:** FS-PRV-002, FS-COM-004.

### D12: Leader visibility
- **Disposition:** Leaders see group content, review queues and aggregates. They never see journals, private prayers, nutrition, body or health data. Any exception needs the member's explicit, revocable share.
- **Verification:** Test: a leader can't read a private journal.

### D13: Family challenge variants
- **Repo:** 13 of 52 family challenges mention a wife, 9 mention children, 30 assume a household.
- **Disposition:** Every mission has variants (household, single, any relationship, church or community). Members pick a variant without disclosing why. Variant choice is never visible to others.
- **Affects:** FS-CMP-009, FS-FAM-001.

### D14: Streaks
- **Disposition:** A faithfulness calendar with grace days (default 2 per week, OD-21). It never resets visible history. Prototype streaks (idx L1977) are retired.

### D15: Content approval
- **Disposition:** Content packages flow draft → in review → approved → published → retired. They need named human approvers. AI may flag issues but never approves. BSB is the default translation.
- **Affects:** ADR-0007 · FS-CNT-001..005.

### D16: Devotional rights
- **Disposition:** Rights unknown → **blocks publication** of the 366 entries outside the private pilot. It does not block development. OD-11.

### D17: Ledger
- **Disposition:** Cloud Functions are the only writer of `ledger` and `standings` (enforced in rules). Ledger docs are append-only, with deterministic IDs `{sourceType}_{sourceId}_{ruleVersion}_{kind}`. Corrections are new `adjustment` entries. Seasons are finalized into hashed snapshots.
- **Verification:** "Repeated submissions cannot duplicate points"; "finalized seasons unchanged by rule change".

### D18–D19: Proof
- **Approved:** Video capture is required in the first challenge release; proof policy is configurable per challenge; durable local copy; reviewer-only access; no guessable or reused URLs.
- **Disposition:**
  - Camera capture to **app-private storage**, with an explicit "Save to Photos" export.
  - A proof record in Drift with resumable upload.
  - Storage path is scoped to group, season and owner.
  - Rules allow the owner to write, and the owner plus reviewers to read.
  - **`getDownloadURL` is banned** for proof, because its tokens are bearer links. Playback goes through rules-checked SDK reads or a reviewer-only Function issuing short-lived signed URLs.
  - Retention → OD-06.
- **Affects:** ADR-0010 · FS-PRF-001..012.

### D20–D22: Fairness and PRs
- **Approved:** Two difficulty levels; approved alternates; published point differences; injured or less experienced men can contribute meaningfully; personal baselines; normalized teams.
- **Disposition:**
  - Each physical challenge has a `standard` and a `foundation` tier with published multipliers (OD-03; suggested 1.0 / 0.8).
  - Approved alternates map to a tier and keep that tier's multiplier unless the admin publishes otherwise.
  - Personal-improvement points come from the man's own frozen baseline.
  - PRs are variant-keyed and e1RM-based, with a baseline period and a cap.
  - The prototype's `max(flat 50, standard)` loophole (idx L4343) is removed.
- **Verification:** "Approved injury alternatives follow their configured rules"; property tests.

### D23: Steps
- **Disposition:** Daily cap (OD-14); only health-sourced steps earn points; manual entry checks the box only.

### D24: Leaderboards
- **Disposition:** Team board first, normalized (OD-02), with a breakdown per component. Personal-progress views are always on. An individual leaderboard is optional per season.

### D25: Late submissions
- **Disposition:** Deadlines use the server's `request.time` in the season's IANA time zone, plus `graceMinutes` (OD-13). Offline attempts carry `performedAt`. If `receivedAt − performedAt > 24h`, the attempt goes to review.

### D26: Prizes
- **Disposition:** No cash, wagering, paid entry or gambling-like rewards. The ruleset schema forbids prize fields.

### D27: Season dates
- **Disposition:** Seasons are data (`groups/{gid}/seasons/{sid}`). `practice: true` seasons run until the rules test suite and the scoring tests pass in staging. No date is hard-coded.

### D28: Migration
- **Disposition:** An optional "export my training history" in the prototype; an import tool in Phase 3; not a release blocker.

### D29: Families and youth
- **Disposition:** Adult pilot. The profile has no required gender or marital fields. The `youth` feature flag defaults off and **rules deny** youth-scoped collections until ADR-0013 is amended.

### D30: Nutrition points
- **Approved:** Nutrition may earn bounded participation points, with no reward for under-eating or restriction.
- **Disposition:** Points for **logging consistency** and hydration only, capped per week (OD-04). **No** points for calorie deficit, weight loss or being under a target. Logs below a safety floor earn no "complete day" credit and prompt a gentle check-in.
- **Verification:** "Nutrition logging cannot reward under-eating."

### D31: Health integration
- **Disposition:** `healthSources`, `healthSamples` (daily aggregates with provenance) and consent records are modeled now. Device sync may arrive in Phase 7.

### D32: Messaging
- **Disposition:** No DMs or youth messaging. The feed, comments and prayer requests are the only channels until ADR-0017 is amended.

### D33–D35: Operations
- **Disposition:**
  - Budget alerts on every Firebase project.
  - A cost model in `09-operations.md`.
  - A named moderation owner and SLAs (OD-17).
  - Crashlytics with redaction (ADR-0016).
  - An incident runbook.
