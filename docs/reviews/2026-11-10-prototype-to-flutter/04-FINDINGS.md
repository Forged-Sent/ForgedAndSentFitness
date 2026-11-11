---
title: "Findings"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](00-START-HERE.md) · Back: [Agent prompts](03-AGENT-PROMPTS.md) · Next: [Prototype assessment](05-PROTOTYPE.md)

# Findings

> [!IMPORTANT] In one minute
> - **6 immediate blockers.** B1 to B4 stop the rebuild from matching the prototype.
> - **14 before launch.** Mostly things the prototype does that must not be carried over.
> - **6 later.**
> - Most are fixed inside a build step, not as separate tasks. See [Agent prompts](03-AGENT-PROMPTS.md).

| Label | Meaning |
|---|---|
| **Verified** | I read the source or saw it in a rendered run |
| **Reviewer-read** | A parallel reviewer read it and cited lines; I spot-checked a sample, not this item |
| **Inferred** | Follows from the code; not executed |

**Type:** D = confirmed defect · R = evidence-backed risk · P = preference

## 6.1 Immediate blockers

| ID | Sev | Type | Finding | Location | Evidence | User impact | Certainty | Smallest adequate correction |
|---|---|---|---|---|---|---|---|---|
| B1 | 🔴 High | D | The prototype reference is forked | `main:index.html` vs `app/v241-bold:versions/app-v254.html` | [Section 2.2](08-EVIDENCE.md) | Screens get rebuilt against a version the men no longer see, or privacy fixes are lost | Verified | Decide the baseline (Q1); land one reconciled `index.html` plus its version file; tag it |
| B2 | 🔴 High | D | Approved product decisions are not on `main`; two ADR series collide | `docs/architecture/ADR-000x` vs `arch/firebase-reconciliation:docs/adr/` | [Section 5.1](07-ARCHITECTURE.md) | Builders and agents cannot see the rules that settle R1–R3 | Verified | Bring the still-valid decisions onto `main` in one short decisions page; renumber or mark the old set superseded |
| B3 | 🔴 High | D | The plan has no path to the prototype | `WORK.md`, `PROTOTYPE-PARITY.md`, `docs/features/` (templates only) | [Section 4.3](06-SCREENS-AND-UI.md) | Following the plan yields no recognizable screen | Verified | Adopt the sequence in [section 7](02-BUILD-PLAN.md) |
| B4 | 🔴 High | D | No design system; theme uses a superseded palette | `mobile/lib/src/app/forged_sent_app.dart` L13–19 | F1, F2 | Each new screen drifts from the reference | Verified (source) | Design-foundation PR (S0) |
| B5 | 🟠 Med | R | The repository contract omits owner and date and models state as a flag | `today_repository.dart` *(local)* | [Section 5.4](07-ARCHITECTURE.md) | The view model and tests are rewritten when Drift arrives | Verified (source) | Reshape before merging FNS-001, or fold FNS-001 into slice 1 |
| B6 | 🟠 Med | R | Engineering effort is going to process, not product | 391 commits on `main` since 10-27: `tooling` 107, `docs` 81, `.github` 52, `mobile/lib` 4. `tooling/` holds 18,179 tracked lines; the app holds 194 | Git history | Months pass with no feature | Verified | [Section 7.4](02-BUILD-PLAN.md) |

## 6.2 Needed before launch

| ID | Sev | Type | Finding | Location | Certainty | Smallest adequate correction |
|---|---|---|---|---|---|---|
| L1 | 🔴 High | R | Scores are client-computed and self-reported | L2664, L7659 | Verified | Events in, server totals out; never port client totals |
| L2 | 🔴 High | D | Shared documents hold more than the copy admits; habit titles readable | U4, U5 | Verified | Split shared ticks from private detail in the Flutter data model |
| L3 | 🔴 High | D | Report and Block unreachable | U7 | Verified | Wire both into the post menu; rules-tested |
| L4 | 🔴 High | D | Account deletion incomplete | U8 | Reviewer-read | One server-side deletion routine with an emulator test listing every owned path |
| L5 | 🔴 High | R | No membership or group model on `main`; all shared features depend on it | `firebase/firestore.rules` | Verified | High-risk contract before S4 (decision Q4) |
| L6 | 🟠 Med | D | Silent save failures | U10 | Verified | Saved / pending / failed on every persisted control |
| L7 | 🟠 Med | D | Workout history keyed by plan position | U3 | Reviewer-read | Store movement id and prescription per set |
| L8 | 🟠 Med | D | Workouts cannot cross midnight | U2 | Verified (code) | Bind the session to its start date |
| L9 | 🟠 Med | D | Streak window cap; three streak definitions | U11, R4 | Verified | One rule, unit-tested |
| L10 | 🟠 Med | D | PR copy vs code; uncapped step bonus | R5, R6 | Verified / Reviewer-read | Decide values; cap; one constants file |
| L11 | 🟠 Med | D | Embedded content differs from `seed/` | U12 | Verified | Name the source of truth; generate the other from it |
| L12 | 🟠 Med | D | First-week dead zone | U1 | Verified | Start on the next lifting day |
| L13 | 🟡 Low | D | SDK constraint looser than the lockfile; two pins I could not confirm | `mobile/pubspec.yaml` L7; *(local)* pubspec | Verified / unconfirmed | `sdk: '>=3.13.0 <4.0.0'`; confirm pins on pub.dev when adding them |
| L14 | 🟡 Low | R | Android app label is `forged_and_sent`; release build uses the debug signing config | *(local)* `AndroidManifest.xml` L3, `build.gradle.kts` L36 | Verified (source) | Fix the label now; signing before any distribution |

## 6.3 Worthwhile later

| ID | Type | Finding | Note |
|---|---|---|---|
| I1 | D | Rest-timer audio fails when the phone is locked | F10 |
| I2 | P | Units are pounds, ounces and miles only | Fine for the pilot |
| I3 | D | Dead code and stale copy: hold-to-react, `lookupFood`, tour text, README scoring section | Do not port |
| I4 | D | "Rally media is deleted after 30 days" is promised; no retention code exists | Storage lifecycle rule when media ships |
| I5 | R | Replies load oldest-first with a limit of 500; posts capped at 50 with no paging | Design paging in the Flutter feed |
| I6 | P | Demo failure handling replaces the whole list with an error view when one toggle fails | Keep the list; flag the item |
