---
title: "Evidence and limits"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](00-START-HERE.md) · Back: [Architecture](07-ARCHITECTURE.md) · Next: [Agent rules audit](09-AGENT-RULES-AUDIT.md)

# Evidence and limits

> [!IMPORTANT] In one minute
> - **Baseline:** `main` at `94daa63`. Only PR #48 is open, and it is tooling.
> - **Rendered:** the prototype at 390×844 with the repo's mock backend, including the live v254 snapshot.
> - **Not run:** Flutter, Firebase emulators, any device. Flutter visuals are inferred from source.
> - Local, unpushed branches were read from your workstation and are reported separately from `main`.

## 2.1 Revisions

| Item | Revision | Status |
|---|---|---|
| Default branch `main` | `94daa63fe1dea96398bcb3f2286baa1906c44ec0` (2026-11-10 00:09 -0700, PR #52) | Reviewed baseline |
| Open PR #48, hosted AI review acceptance | head `97acf7a1` | Tooling only; no app code. Only open PR |
| `app/v241-bold` (remote, unmerged) | `3ff4a6f3` | Prototype snapshots v239–v254 under `versions/` |
| `arch/firebase-reconciliation` (remote, unmerged) | `0d21d21d` (2026-10-27) | Phase 0 set: ADR-0001…0019, `requirements.yaml`, data architecture, roadmap |
| `workout-library-seed` (remote, unmerged) | `79994241` (2026-11-08) | Coach Gideon content library |
| `codex/native-host-skeleton` (local only) | `bc4fd82b` | Committed Android and iOS hosts |
| `codex/native-host-acceptance` (local only) | `b638041b` | Hosts plus current `main` merged in |
| `codex/today-demo-contract` (local only) | `54be9449` | FNS-001 synthetic Today demo; based on `61e1b7d`, 4 commits behind `main`; does **not** contain the native hosts |

How the open-PR list was established: only PR #48 has a live `refs/pull/48/merge` ref, and `docs/knowledge/PR-STATUS.md` agrees. The GitHub API was not available to me, and the public pulls page I could fetch was a stale copy (it listed #30 and #42 as open; both are merged in `main` history).

Local branches were read from `C:\ws_c\ForgedAndSent\ForgedAndSentFitness\.git` with read-only git commands. The three relevant worktrees had no uncommitted changes under `mobile/` or `docs/features/`. **None of the local work is treated as available on `main`.**

## 2.2 The authoritative prototype: a conflict

| Candidate | What it is | Evidence |
|---|---|---|
| `main:index.html` | v238 plus nine hardening merges on 2026-11-05 (awaited journal saves with retry, mentoring deferred, superset permissions, bodyweight volume refresh). Not archived as a version file | Differs from `versions/app-v238.html` in 34 hunks; contains `jrPendingWrites` and "Pair management is deferred" |
| `versions/app-v254.html` on `app/v241-bold` | Sixteen later snapshots described as the "live working app" | Tab bar is Today, Fuel, Train, **Walk**, Board, Rally; wizard step is "Your **two**"; contains "Bold Step" and Instagram sharing; contains none of the hardening markers |
| `versions/app-v1…v238.html` on `main` | Append-only history | 238 files, 346 MB |

`AGENTS.md` and `PROTOTYPE-PARITY.md` name `index.html` as the active prototype. The 2026-10-27 workshop default (W12) says the prototype "keeps evolving independently". Both are happening, in different places.

**Provisional baseline for this review:** `main:index.html` at `94daa63` for all code-level analysis, because it is what the repository declares, what CI tests, and what carries your privacy fixes. Differences in v254 that affect a finding are called out. I did not merge the two.

Observed v238 → v254 differences that affect the rebuild (Verified by rendering both):

| Area | `main` (v238+) | v254 |
|---|---|---|
| Bottom tabs | Today, Fuel, Train, Board, **Campaign**, Rally | Today, Fuel, Train, **Walk**, Board, Rally; Campaign moves under Board |
| Personal habits | "Your three" | "Your two" |
| Creed box | "Morning Motto / My Creed" | "My Mission" |
| Today rows | Plain boxes | Boxes tagged Stand Firm / In Love / Be Strong; creed card at top; "This week's Bold Step +25" |
| Mentoring | Information only, deferred for privacy | Live pairing: "Ask a brother to be your Paul" |
| New point sources | none | Bold Step +25 a week; Share to Instagram +5 a day (per commit message at `2b42a0b`) |

## 2.3 What I inspected

- **Prototype:** static HTML for all 17 pages (L1952–2557); CSS tokens and media queries (L6–1924); JavaScript L2561–9487 and L10151–11165 through three parallel reviewers with line-cited reports; `seed/*.json`; `dev/mock-claude.js`; `seed/db-rules.json`.
- **Flutter on `main`:** every file under `mobile/` (3 source files, 2 test files, pubspec, lockfile header, analysis options).
- **Flutter on local branches:** all 8 new or changed source files and the test inventory of `codex/today-demo-contract`; the file tree and Android settings of `codex/native-host-acceptance`.
- **Firebase:** `firebase.json`, `.firebaserc`, both rules files.
- **Decisions and plans:** ADR-0001…0005, `SYSTEM.md`, `CODE-MAP.md`, `CURRENT.md`, `WORK.md`, `PR-STATUS.md`, `PROTOTYPE-PARITY.md`, `FLUTTER-PLATFORMS.md`, `docs/features/*`, `docs/design/sign-in.md`, `docs/architecture-notes.md`, the archived execution blueprint header, and the 2026-10-27 workshop, reconciliation matrix and executive assessment held in the Claude Project.
- **CI:** `ci-gate.yml` job list and path filters.

## 2.4 What I ran

| Check | Result |
|---|---|
| Prototype in headless Chrome at 390×844, dark theme, real typefaces served locally, repo mock backend | Legal gate → 8-step setup wizard → Today, Devotional, Fuel, Train, Board, Campaign, Rally, Profile, Settings, Owner tools. No console errors |
| Same, clock advanced to the plan's first day | Train day panel → workout page → prayer gate → started workout → exercise detail |
| v254 snapshot, same harness | Wizard, Today, Walk, Board |
| Embedded content vs `seed/` | Scripted comparison of challenge scoring and RPE/RIR text |
| Reviewer claims | 16 line references re-read by me; all held |

## 2.5 What I could not verify

- **Flutter was not run.** No Flutter SDK in my environment. No `flutter analyze`, `flutter test`, build, emulator or device run. Every statement about how the Flutter app looks is **inferred from source**.
- **Firebase emulators and rules tests were not run.** There are no rules tests in the repository to run.
- **Package pins on the local branch.** `flutter_riverpod 3.5.0` and `go_router 18.1.4` did not appear in the pub.dev listings I could reach (latest shown: 3.4.3 and 18.1.1; the listing looked about two weeks old). The branch lockfile resolves them and its contract records 34 passing tests locally, so they probably exist. Treat as unconfirmed by me.
- **Prototype lines 9487–10150** (photo-upload diagnostic, confirm dialog, the food-logging UI) were not systematically read. `compressVideo` (L10725–10760) was not read. "My routine" (L8811–9084) was skimmed.
- **Not exercised in the browser:** light theme, text scaling, Rally with posts, anything multi-user, food logging, challenge submission, set entry (the harness reached the open workout but not a typed set).
- **The claude.ai runtime's real access control** for paths that `seed/db-rules.json` does not mention. The repository cannot show it.
- The prototype has no doctype, charset or viewport tag; the claude.ai host supplies them. My preview copy added them. Without the viewport tag the page renders at desktop width on a phone.

## Sources

- Repository at the pinned revisions in section 2.1.
- Claude Project documents: `planning/2026-10-27-decision-workshop.md`, `architecture/2026-10-27-reconciliation-matrix.md`, `planning/2026-10-27-executive-assessment.md`.
- [Flutter architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations)
- [Flutter offline-first design pattern](https://docs.flutter.dev/app-architecture/design-patterns/offline-first)
- [Cloud Firestore: access data offline](https://firebase.google.com/docs/firestore/manage-data/enable-offline)
- [go_router: nested stateful navigation with shell routes](https://flutter.googlesource.com/mirrors/packages/+/refs/tags/go_router-v7.1.0%5E%21/)
- [pub.dev: flutter_riverpod versions](https://pub.dev/packages/flutter_riverpod/versions), [go_router versions](https://pub.dev/packages/go_router/versions), [drift versions](https://pub.dev/packages/drift/versions)
