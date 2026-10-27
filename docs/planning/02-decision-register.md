# 02 · Architecture decision register

**Status definitions used here**

| Status | Meaning | Binds agents? |
|---|---|---|
| **Approved** | The project owners stated it. Source quoted. Becomes **ratified** when recorded in `decision-log.yaml` through a PR that both owners approve. | Yes, from ratification. Until then, agents treat it as binding direction but must not build on it in a protected zone. |
| **Recommended** | My professional recommendation, written as an ADR on the reconciliation branch | No, until the PR that accepts it merges |
| **Open** | Needs an owner answer (workshop W-item) or an engineering decision that hasn't been made yet | No |
| **Challenged** | An approved decision with a formal objection on file | Still binding until the owners rule |
| **Deferred** | Deliberately postponed, with a revisit trigger | No |

> **Correction to the reconciliation branch.** ADR-0001..0019 on `arch/firebase-reconciliation` show `Status: Accepted` (except 0016 and 0018). Only the decisions in table A are owner-approved. The rest are recommendations. When you merge, either approve them as written (the merge then *is* the acceptance, per `docs/adr/README.md`), or mark the ones you haven't agreed to as `Proposed` in the same PR. Agents may not change ADR statuses (AGENTS.md), so this is the owners' edit.

## A. Approved by the owners

Source: the "Approved product direction" brief, 27 Oct 2026, morning (§2 A–E), and the planning brief, 27 Oct 2026, afternoon.

| ID | Decision | Source wording (abridged) | Recorded in | Ratified |
|---|---|---|---|---|
| AP-01 | **Flutter/Dart** for native iOS and Android | "Flutter/Dart for native iOS and Android" | ADR-0002 · DEC-0001 | Pending |
| AP-02 | **Firebase** as the managed production backend (Auth, Firestore, Functions, Storage, notifications, distribution). Not Supabase. | "Do not replace Firebase with Supabase merely because another proposal recommended it" | ADR-0003 · DEC-0002 | Pending |
| AP-03 | Shared cloud dev, staging and prod environments; emulators optional; **no personal servers** | §2A | ADR-0014 · DEC-0003 | Pending |
| AP-04 | **Offline-first** with durable local storage and an outbox; **modular monolith**; typed repositories; testable business logic | §2A | ADR-0006 · DEC-0004 | Pending |
| AP-05 | **Devotional Workout Experience Engine**: five placements (before, after, rest prompts, separate times, workout-only or devotional-only); independent of navigation; no reading during exertion; private reflections stay private | §2B | ADR-0008 · DEC-0005 | Pending |
| AP-06 | **Team competition is primary**, with individual participation; normalized team scores; two difficulty levels; approved alternates; one or two non-workout missions a week; server-authoritative, immutable, versioned, with appeals | §2C | ADR-0005, ADR-0009 · DEC-0006 | Pending |
| AP-07 | **Faith participation may earn points in principle; the weights are open.** Never based on content or quality. | "The exact faith-participation point weights remain open" | ADR-0012 · DEC-0007 | Pending (weights: W04) |
| AP-08 | **Video proof supported in the first challenge-capable release**; not every challenge requires video | §2D | ADR-0010 · DEC-0008 | Pending |
| AP-09 | **Nutrition tracking is part of the product** and may earn **bounded** participation points; never rewards under-eating | §2E | ADR-0011 · DEC-0009 | Pending (caps: OD-04) |
| AP-10 | **Adult pilot first**; spouses, families, other groups, churches later; youth only after its own design | §2 intro, D29 | ADR-0013 · DEC-0010 | Pending |
| AP-11 | **Keep the prototype**: an independent visual and functional reference, not the production foundation | "Do not delete it"; "can continue evolving independently" | ADR-0001 · DEC-0011 | Pending |
| AP-12 | **Product framing:** a fitness platform built around Christian discipleship; training, progress, nutrition, health and challenges are core pillars | Planning brief, 27 Oct afternoon | This package · DEC-0012 | Pending |
| AP-13 | **A collaborative planning hub** is a first-class requirement, operational before substantial independent agent development | Planning brief, 27 Oct afternoon | `09-planning-hub-spec.md` · DEC-0013 | Pending |

**Note on AP-11:** the newer brief says the prototype "can continue evolving independently". ADR-0001 currently says *frozen*, and changes need the `legacy-change` label. Those are compatible: it can evolve, but each change is labeled so agents never treat a prototype edit as a production requirement. Workshop W12 confirms this.

## B. Recommended (my ADRs; accepted when the PR merges)

| ADR | Decision | Why it's mine to recommend |
|---|---|---|
| ADR-0004 | Group-level isolation; optional organization layer that grants nothing | Data-security structure |
| ADR-0005 | Append-only ledger, deterministic ids, recompute standings, finalization hash | Integrity mechanics for AP-06 |
| ADR-0006 | Drift as the device source of truth, with an outbox in front of Firestore's offline cache | Mechanism for AP-04 |
| ADR-0007 | Versioned content packages; programs generated from templates with equivalence tests | Content pipeline |
| ADR-0012 | Faith participation boolean only; journal owner-only; prayer audiences | Privacy mechanics for AP-05 and AP-07 |
| ADR-0013 | Households and youth reserved and inactive | Structure for AP-10 |
| ADR-0014 | Three Firebase projects; App Distribution and TestFlight | Mechanism for AP-03 |
| ADR-0015 | AI workflow: protected zones, 2–4 roles per change, no agent merges | Process |
| ADR-0016 *(Proposed)* | Crashlytics with redaction (Sentry as fallback) | Engineering choice |
| ADR-0017 | No direct messages until a moderation design exists | Safety boundary |
| ADR-0018 *(Proposed)* | Membership documents are the authorization source; custom claims optional | Engineering choice |
| ADR-0019 | Configurable seasons; practice competitions first | Delivery safety |
| *(new)* ADR-0020 *(Proposed)* | Planning hub: Blueprint for discussion, GitHub as the authoritative record (`09-planning-hub-spec.md`) | Owner decision W12; drafted here |

## C. Open

Owner product decisions are workshop items **W01–W12** (`03-decision-workshop.md`). Engineering decisions are in §C2 of the same file, each with my recommendation. The table maps the old OD numbers:

| OD | Goes to | | OD | Goes to |
|---|---|---|---|---|
| OD-01 faith weights | W04 | | OD-12 first real season | W11 |
| OD-02 team normalization | Engineering default; tune in the practice season | | OD-13 grace window | Engineering default |
| OD-03 tier multipliers | Engineering default + fitness reviewer | | OD-14 step cap | Engineering default |
| OD-04 nutrition points | W02 (timing); caps engineering default | | OD-15 Firestore location | **Engineering: decide now** |
| OD-05 prayer default audience | W06 | | OD-16 commercial model | W09 |
| OD-06 proof retention | W05 | | OD-17 moderation owner | W06 |
| OD-07 nutrition provider | Engineering (M4) | | OD-18 PR rule | Engineering default + fitness reviewer |
| OD-08 local DB library | **Engineering: Drift, decide now** | | OD-19 App Check timing | Engineering default |
| OD-09 leader visibility | W06 | | OD-20 workout cap | Engineering default |
| OD-10 content reviewers | W08 | | OD-21 grace days | W01 (default 2) |
| OD-11 devotional rights | W08 | | OD-22 missions per week | W03 |

## D. Challenged

**No formal challenges.** I found no evidence that justifies reversing an approved decision. Four scope cautions are recorded in `00-executive-assessment.md` (Experience Engine mode count in M1, video-proof participation risk, faith-points perception, four programs at launch). Each has a default inside the approved direction.

## E. Deferred (with revisit triggers)

| Item | Deferred until | Trigger to revisit |
|---|---|---|
| Direct messages | After the pilot | A moderation design and an owner who staffs it |
| Households and family sharing | Stage 2 | First couple who both want shared challenges |
| Youth | Stage 3+ | A church asks; then a separate ADR (consent, guardians, moderation) |
| Organization (church) layer, active | Stage 2 | A second church or more than 3 groups |
| Cross-group leagues | Stage 2 | Two groups want to compete |
| HealthKit and Health Connect import | M4 | — |
| Other three programs | M4 | Forged equivalence passes |
| `split_day` mode with scheduled reminders | M2 | — |
| AI coach features over member data | Not planned | Only with an ADR on privacy; never over journals or prayers |
| Admin web console | Stage 2 | Leaders managing more than one group |
| Analytics warehouse (BigQuery export) | Stage 3 | Questions the console can't answer |
| Search infrastructure | Stage 3 | Firestore queries can't serve content or food search |
| Custom planning portal on Firebase | Not planned | Hub limits in `09-planning-hub-spec.md` §2 hit in practice |
