# 04 · Staged growth

**Principle:** build for Stage 1, *structure* for Stage 2, and only *reserve* for Stage 3. Each stage below says what triggers moving to the next. Cost figures come from `docs/architecture/evidence/firebase_cost_model.py`; they cover infrastructure only, excluding compute and store fees.

## Summary

| | **Stage 1 · Private pilot** | **Stage 2 · Multiple communities** | **Stage 3 · Larger platform** |
|---|---|---|---|
| Users | 10–30 | 100–5,000 | 10,000–100,000+ |
| Groups | 1 (maybe 2) | 5–200, several churches | Hundreds to thousands |
| Must support | M1–M5 journeys; one group; practice and real seasons; video proof | Self-serve group creation by leaders; organization (church) layer; leagues across groups; leader tools; households (if W10) | Organization admins; content localization; heavy media; analytics; support |
| Infrastructure | 3 Firebase projects (dev, staging, prod) on Blaze with a budget alert; GitHub Actions; App Distribution and TestFlight | + scheduled Firestore exports to a second bucket; Remote Config rollouts; a minimal **admin console** (Flutter web on Firebase Hosting) | + video transcoding (Transcoder API) and CDN-backed delivery; BigQuery export; search (if Firestore can't serve it); on-call alerting |
| Est. cost/month | **$0–5** (about $1 with video at 100 users) | **$7–80** (1,000–10,000 users; video ≈ 2×) | **$160–1,600** (10k–100k users; egress dominates) |
| Cost drivers | None material | Video storage and egress; group-scoped reads | Video egress (≈ 65% at 100k); reads; Functions |
| Likely bottlenecks | People, not tech: content review, iOS signing, moderation habits | Moderation load; support requests; leader onboarding; standings recompute fan-out at season end; hot feed documents in large groups | Media pipeline; per-group fan-out notifications; analytics needs; support staffing; App Store review cadence |
| Operational duties | Owners: deploys, budget, restore drill once, moderation escalations | + on-call rota (two people); incident runbook; monthly restore test; content release cadence | + a support channel; SLOs; security review cadence; a data-protection contact |
| New components | — | Admin console; league entity; household ADR; export jobs | Transcoder and CDN; BigQuery; possibly search; ops dashboards |

## Decisions that protect growth (made now, cheap now)

| Decision | Protects | Cost now |
|---|---|---|
| Every shared document under `groups/{gid}/…`; queries group-scoped and paginated | Stage 2 multi-tenancy without migration; read costs | Nothing |
| Memberships, ledger and standings written only by Functions | Integrity at any scale | A few Functions |
| Deterministic ids, idempotent Functions | Retries and offline replays at scale | Discipline |
| Versioned content packages and rulesets | Multiple churches with different programs and rules | Packaging tool |
| Organization and household layers grant nothing by themselves; reserved paths denied | Adding churches and families without privacy regressions | Rules test |
| Proof policy per challenge; retention job | Video cost and privacy at Stage 3 | One scheduled Function |
| No required gender, marital or child fields | Women's groups and families without schema change | Nothing |
| Analytics events carry ids and counts, **never content** | A Stage 3 warehouse without privacy debt | Nothing |

## What **not** to build early

| Don't build | Until | Instead now |
|---|---|---|
| Microservices or a custom API server | Never likely | Modular monolith on Functions |
| Multi-region or multi-project sharding | A legal or data-residency requirement | `nam5` multi-region |
| Admin web console | Stage 2 (more than one group per leader) | Leader actions in the app and Function callables |
| Search cluster (Algolia, Typesense) | Stage 3 | Bundled content indexes; provider search for food |
| Analytics warehouse | Stage 3 | Firebase Analytics with content-free events |
| Video transcoding pipeline | Stage 3 or a cost trigger | Client-side compression to ≤ 720p, ≤ 60 s |
| Direct messages, youth, public discovery | Their ADRs | Group feed, partners, prayer audiences |
| A generic rules engine for scoring | Never | Versioned ruleset documents with a fixed set of components |
| CMS for content | Stage 2 (more than 2 authors) | Content in the repo, validated and packaged by `tools/fs_content` |

## Stage-transition triggers

| Move to | When any of these happens |
|---|---|
| Stage 2 | A second church or more than 3 groups · more than 100 MAU · a leader asks to run their own group · a couple wants shared challenges |
| Stage 3 | More than 5,000 MAU · video egress above $100/month · a support load the owners can't absorb · an organization wants admin dashboards |
