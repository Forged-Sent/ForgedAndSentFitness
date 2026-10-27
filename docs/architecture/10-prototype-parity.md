# 10 · Prototype functional parity inventory

Audited at `main` @ `b66e93e` (v162; `index.html` 7,152 lines). The prototype is **preserved unchanged** as the executable behavioral reference (ADR-0001, FS-PAR-001). Line references are to v162.

**Legend for "Claude-dep":** **Y** means it depends on claude.ai `window.claude` capabilities (`db`, `user`, `assets`, `sample`, `downloads`) and cannot run elsewhere.

## Inventory

| Feature | Status in prototype | Claude-dep | Rules to extract (→ fixtures) | Migratable data | Production disposition |
|---|---|---|---|---|---|
| Daily checklist (8 tasks + 3 custom habits) | Implemented | Y (`db` checkins) | Auto-derive rules: water ≥ 101.4 oz, calorie window by goal, Sabbath workout auto-check (`derive` L2000) | Task definitions (`seed/tasks.json`) | Redesign: group habits + personal habits; participation facts |
| Points, board, streak | Implemented (client-computed) | Y | Spec only; many rules retired (see `04-competition-scoring.md`) | No (recomputed) | Replace with the server ledger |
| Devotional reader (366) | Implemented; scroll-to-bottom gate | N (embedded data) | Calendar-day selection | `seed/devotionals.json` (rights pending OD-11) | Redesign into Experience Engine stages |
| Morning motto, mission-complete popup | Implemented | N | Copy | Copy (editorial review) | Keep as content |
| Workout programs (4 × 365 days) | Implemented from embedded `PLAN` (RPE/RIR stripped) | N | Schedule: plan day from rest day plus **three chosen lift days, effective next plan week** (v158/v162); ramp-set parsing (`parseSets` L3239) | `seed/workouts.json`, `workout-meta.json`, `workout-themes.json` (incl. new `purpose`) | Generated from templates with an equivalence test |
| Workout logger, rest timer, warm-ups | Implemented | Y (`db` workouts) | Set validation ("fix these sets"); last-time suggestion (L2515ff; fix the deload bug) | Per-user workout docs (private, owner export only) | Redesign: crash-safe sessions in Drift |
| Coach Gideon guidance, exercise page (muscles, video, how-to) | Implemented (v155–v160) | N | — | `movements.json` howTo, cues, video links | Keep as content (license review of video links) |
| Exercise swaps (equipment, injury) | Implemented | N | Swap selection, always-swap preference | `seed/alternates.json` | Keep; substitution graph |
| Muscle diagrams | Implemented (SVG generator) | N | — | SVG paths | Replace with assets |
| PRs | Implemented (weight/volume, 25 pts) | Y | Spec only | Optional: per-user history export | Redesign: variant e1RM |
| Lift PR board (manual entry) | Implemented | Y | — | Profile PRs (shared) | Retire |
| Weekly challenges (52 × 3) | Implemented (client scoring, age brackets) | Y (`chsubs`) | Challenge definitions, movement standards, units/scoredBy | `seed/weekly-challenges.json`, `movement-standards.json` | Redesign: tiers, alternates, missions, ledger |
| Challenge proof upload | Implemented (assets ≤ 20 MiB; IndexedDB local copy; save to phone v151) | Y (`assets`, `downloads`) | "Keep proof until submitted" behavior | No | Redesign: native camera, app-private storage, Storage rules |
| Food log, macros, water, targets | Implemented | Y (`db`, `sample`) | Mifflin-St Jeor calculator; water coalescing (v11) | Private logs (owner export) | Redesign with a provider abstraction |
| Food search, photo estimate | **Simulated** by an LLM (`sample`, L1693ff) | **Y** | — | No | Replace with a provider |
| Fasting days | Implemented (public tag; Calories auto-check) | Y | — | No | Redesign: private, unscored |
| Steps | Manual entry; health bridge **stubbed** (`window.ForgedHealth`) | Y / stub | Step goal by Sabbath | No | Redesign: health sources |
| Health integration | **Documented only** (`docs/health-integration.md`) | — | — | — | Implement in Phase 7 |
| Reminders | **Stored only, never delivered** | Y | Default times | Settings | Implement: local notifications |
| Rally feed (posts, replies, reactions, @mentions, edit) | Implemented | Y | Mention parsing; reaction kinds | Posts (shared; owner can list) | Redesign: group-scoped |
| Report and block | Partial (reports never reviewed) | Y | — | — | Redesign: moderation queue |
| Meal-prep ideas board | Implemented | Y | — | Ideas (shared) | Defer |
| Progress photos | Implemented | Y (`assets`) | — | Private | Redesign: private bucket |
| Profiles, handles, avatars | Implemented (client uniqueness) | Y (`user`) | Handle format | Shared profiles | Redesign: Functions-enforced uniqueness |
| Onboarding, tour, help | Implemented | Partly | Step order and copy | — | Redesign: progressive disclosure, 18+ |
| Account deletion | Partial, non-atomic | Y | — | — | Replace with a server job |
| Theme ("Forged Iron") | Implemented | N | Tokens | CSS variables | Extract tokens |
| Test-date control, upload diagnostics | Implemented (shipped to all users) | Y | — | — | Retire (debug builds only, with an injected clock) |
| Local preview mock (`dev/mock-claude.js`) | Implemented | Simulates Y | — | — | Retire after the Flutter slice |

## Missing capabilities (relative to the approved direction)

- Experience modes (before, after, rest prompts, split day).
- Private journal.
- Prayer requests with audiences.
- Accountability partners.
- Teams and normalized scoring.
- Missions with inclusive variants.
- Two difficulty tiers.
- Review and appeal.
- Native camera proof.
- Nutrition provider.
- Health sync.
- Notifications.
- Moderation queue.
- Multi-group support.
- Export.

## Risks and technical debt carried by the prototype

All 15 risks from the independent review persist at v162 (`docs/reviews/…/ARCHITECTURE-REVIEW.md`, Addendum). The most important:

- Unruled shared collections (R1).
- Client-authoritative scoring (R2).
- The shipped test-date control (R3).
- Retroactive score mutation (R4).
- Lost workouts (R5).

**Operational recommendation:** freeze the prototype at tag `prototype-v162` when Phase 1 begins, and treat further prototype edits as UX experiments labelled `legacy-change`.

## Data migration (optional, not a release blocker; FS-PAR-*)

| Data | Extractable by | Plan |
|---|---|---|
| Seed content | Repository | Phase 1/3 content packages |
| Shared docs (posts, checkins, profiles, chsubs) | Artifact owner via the artifact DB tools | Optional one-off import; ids mapped by a claim code |
| Private docs (`data/users/<id>/…`: food, workouts, photos, settings) | **Only the member himself** (platform-private) | Optional "Export my training history" button in the prototype (a `legacy-change` PR), then an import in Phase 3 |
