# 11 · Implementation roadmap (vertical slices)

There are no calendar dates on purpose. Each phase exits only when its gate passes and its approvals are recorded. "Approval" means a named human decision recorded in a PR.

## Changes to the suggested order, and why

1. **A minimal content tool moves into Phase 2.** A guided workout needs a generated program. Phase 2 generates **one** program (Forged), with the equivalence test for its 365 days. Phase 3 does the other three.
2. **Account deletion and export move to Phase 4**, alongside the first shared data, because the store and privacy gates need them before any real member joins (Phase 6).
3. **Practice seasons start in Phase 5.** The adult pilot (Phase 6) runs a real season only after Phase 5 gates pass in staging (ADR-0019).
4. **OD-15 (Firestore location) is a Phase 1 prerequisite.** It is irreversible.

## Phases

| Phase | Prerequisites | Deliverables | Acceptance tests | Exit criteria | Risks | Human approvals |
|---|---|---|---|---|---|---|
| **0 · Reconciliation** (this branch) | — | Reconciliation matrix; ADR-0001..0019; requirements and test catalog; Firestore data architecture; diagrams; rules drafts plus tests; agent guidance; validators; updated Blueprint page | `tools/validate_architecture.py` green; diagrams render; rules tests green in CI | PR merged by humans; ADR-0016 and ADR-0018 decided; blocking ODs triaged | Scope churn | Merge PR; accept or amend ADRs |
| **1 · Flutter/Firebase foundation** | Phase 0; OD-15, OD-19 | Flutter app with flavors; Firebase dev/staging/prod; FlutterFire options; Auth (Apple, Google, email link); onboarding with 18+; `redeemInvite` callable; groups and members; rules deployed; App Check; CI (analyze, test, rules emulator, functions tests); App Distribution and TestFlight lanes; Crashlytics | TC-001, TC-016, TC-017, TC-019, TC-052, TC-057, TC-058 | Two testers on separate devices join the same dev group via invite; a third account in group B is denied by tests and manually | iOS signing; App Check setup | Project names, location, bundle IDs |
| **2 · Offline devotional workout** | 1; OD-08, OD-21 | `fs_domain/experience` engine; Experience templates (content); Drift schema; outbox and sync engine; Forged program generated (equivalence for its 365 days); session logger; rest timer; private journal; days and sessions sync | TC-003, TC-012, TC-025, TC-026, TC-029, TC-030, TC-031, TC-033 (Forged), TC-002 | Airplane-mode guided workout, kill mid-set, resume, reconnect: exactly one session server-side; switching the mode mid-day preserves completed stages | Sync bugs; timer edge cases | Experience templates approved by content reviewers (OD-10) |
| **3 · Training and nutrition** | 2; OD-07 | All 4 programs generated with equivalence; substitutions; lift-day selection parity; PRs (variant e1RM); history; nutrition provider proxy; food log; hydration; fasting (private); optional prototype import | TC-033 (all), TC-034, TC-035, TC-036, TC-047, TC-021 | Program equivalence for 1,460 days; food search through the proxy; no client API keys | Provider terms | Provider choice; PR rule (OD-18) |
| **4 · Brotherhood and group** | 2; OD-05, OD-09, OD-17 | Feed, comments, reactions; prayer requests with audiences; partners; report, block, moderation queue; push (content-free); account deletion and export | TC-020, TC-023, TC-049, TC-050, TC-014 | Apple 1.2 UGC checklist; deletion sweep zero-rows | Moderation load | Prayer default audience; leader visibility; moderation owner |
| **5 · Competition** | 3, 4; OD-01..04, OD-06, OD-13, OD-14, OD-18, OD-20, OD-22 | Rulesets; seasons (practice first); teams; challenges with two tiers and alternates; missions with inclusive variants; attempts; native camera proof (app-private, resumable upload, reviewer signed URLs); review and appeal; ledger; standings; finalization; retention job | TC-004–TC-011, TC-013, TC-037–TC-046 | A practice season runs end to end in staging; re-finalization gives the identical hash; unauthorized proof read denied | Policy disputes; video cost | **All scoring ODs**; proof retention |
| **6 · Adult pilot** | 5; OD-11, OD-12, OD-16 | Production project hardening; restore drill; privacy policy and terms; store listings; pilot season | E.6.4-equivalent security gate (`08-security-privacy.md`); TC-055, TC-056 | 2+ weeks with the men's group, zero data-loss incidents, cost within budget | Store review | Pilot go/no-go; devotional rights |
| **7 · Broader release** | 6 | HealthKit/Health Connect import; leader admin tools; observability dashboards; organizations (optional); household design ADR (inactive) | TC-048, TC-015 | Health declarations accepted; scaling review | Platform review | Any family or youth activation needs a new ADR |

## Phase 0: remaining tasks after this branch merges

| Task | Description | Owner |
|---|---|---|
| P0-1 | Humans review this branch. Accept or amend ADR-0016 and ADR-0018. Triage the ODs blocking Phase 1–2 (OD-08, OD-15, OD-19, OD-21) | Project owners |
| P0-2 | Tag `prototype-v162`. Agree that further prototype edits need the `legacy-change` label | Project owners |
| P0-3 | Legacy characterization harness (Node) for pure prototype functions, writing `contracts/golden/legacy/*.json` tagged `keep` or `changed-by` | content-engineer + test-engineer |
| P0-4 | Run the rules tests in GitHub CI (they could not run in the authoring environment) and fix any failures | firebase-backend |
| P0-5 | Add the second developer's GitHub handle to `.github/CODEOWNERS`. Enable branch protection with the required checks | Project owners |

## Stage B: first vertical slice readiness (Phase 1)

### Directory scaffold

The tree is in `01-system-architecture.md` §3. Phase 1 creates `app/`, `functions/`, `firebase/` (this branch adds rules drafts and tests), `packages/fs_domain/`, `contracts/`.

### Module interfaces (Phase 1)

```dart
abstract interface class AuthRepository { Stream<AppUser?> authState(); Future<Result<AppUser, AuthFailure>> signInWithApple(); Future<Result<AppUser, AuthFailure>> signInWithGoogle(); Future<Result<void, AuthFailure>> sendEmailLink(String email); Future<void> signOut(); }
abstract interface class MembershipRepository { Stream<List<GroupMembership>> myGroups(); Future<Result<GroupMembership, MembershipFailure>> redeemInvite(String code); Stream<List<MemberSummary>> members(GroupId gid); }
abstract interface class ProfileRepository { Stream<Profile> me(); Future<Result<void, ProfileFailure>> attestAdult(); Future<Result<void, ProfileFailure>> update(ProfilePatch p); }
```

### Firebase configuration strategy

- **Projects:** three, `forged-sent-{dev,staging,prod}` (names illustrative).
- **App config:** `flutterfire configure` per flavor generates `firebase_options_{flavor}.dart`. These files are committed because they are not secrets. Real protection comes from rules and App Check.
- **Deploys:** `firebase.json` targets per project alias in `.firebaserc`. CI deploys rules, indexes and functions to dev on merge and to staging on an rc tag; prod needs manual approval.
- **Secrets:** provider keys go in Secret Manager via `defineSecret`. GitHub Actions authenticates with Workload Identity Federation, so no JSON keys sit in the repo.
- **Emulators:** used in CI for the rules and functions tests. Optional on developer machines (the developers can use the shared dev project instead).

### Development and test setup

| Tool | Command |
|---|---|
| Flutter | `flutter analyze` · `flutter test` · `flutter test integration_test` (device or emulator) |
| Functions | `npm --prefix functions test` (Jest + firebase-functions-test) |
| Rules | `npm --prefix firebase test` (emulator via `firebase emulators:exec`) |
| Architecture | `python3 tools/validate_architecture.py` |

### Testable user stories (Phase 1)

| Story | Acceptance |
|---|---|
| US-1.1 As a new man, I sign in with Apple or Google and confirm I'm 18+ | Account created; `adultAttestedAt` set; no gender, marital or child field required |
| US-1.2 As an invited man, I enter or open an invite code and join my group | Membership doc created by the Function; an expired code shows a clear error |
| US-1.3 As a member, I see my group's members and nothing from other groups | Rules tests TC-001 and TC-016 pass |
| US-1.4 As a leader, I create an invite that expires in 7 days with 10 uses | Invite doc with a hashed code; uses decrement in the Function |
| US-1.5 As a tester, I install a dev build from App Distribution or TestFlight | Build lanes documented and executed once |

### Task breakdown and PR sequence (each PR ≤ ~400 changed lines excluding generated files)

| # | PR | Owner role | Reviewer roles | Zone |
|---|---|---|---|---|
| 1 | Merge this Phase 0 branch (docs, ADRs, rules drafts, validators, agent guidance) | Architect | Security reviewer + 2 humans | contract-change |
| 2 | Flutter app skeleton: flavors, bootstrap, routing, design tokens, CI analyze and test | Flutter implementer | Architecture reviewer | — |
| 3 | Firebase projects documented; `firebase.json`, `.firebaserc`; rules and indexes deploy to dev from CI | Firebase/backend | Security reviewer | contract-change |
| 4 | Functions skeleton (TS, lint, tests) + `redeemInvite`, `createInvite` callables + tests | Firebase/backend | Security reviewer | contract-change (membership) |
| 5 | Auth and onboarding (Apple, Google, email link, 18+) + `AuthRepository`, `ProfileRepository` | Flutter implementer | Architecture reviewer | — |
| 6 | Groups UI: my groups, member list, join by invite + `MembershipRepository` | Flutter implementer | Architecture reviewer | — |
| 7 | App Check + Crashlytics with a redacting logger | Flutter implementer | Security reviewer | — |
| 8 | Distribution lanes (App Distribution, TestFlight) + release checklist | Release engineer | Architecture reviewer | — |

**Claude Code / Codex assignment:**

- **One implementer agent per PR**, on its own branch and worktree.
- Reviewer agents are read-only.
- PRs 3 and 4 are contract-changes and must not run in parallel with any other contract-change.
- PRs 2, 5 and 6 can run in parallel only after PR 3 merges.
