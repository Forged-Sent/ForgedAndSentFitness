# 05 · MVP, feature roadmap and first milestones

## 1. The MVP: the smallest complete experience

> **A man in our group can open the app at the gym with no signal, do today's program workout with the devotional placed where he wants it, write a private reflection, see his progress, and know his brothers are encouraging and praying with him.**

That is **M1 + M2**. It validates the core hypothesis: *integrated training plus discipleship plus a small brotherhood keeps men consistent*. Challenges (M3) amplify a habit that has to exist first.

## 2. Feature tiers

| Tier | Features |
|---|---|
| **Foundational infrastructure** | Three Firebase projects; Auth (Apple, Google, email link); 18+ attestation; membership via Functions; deny-by-default rules and rules tests in CI; App Check; Crashlytics with redaction; Drift DB + outbox + sync; content packages; flavors; App Distribution and TestFlight lanes; the decision log and validators |
| **Minimum viable workflows** (M1) | Program onboarding (level, equipment, lift days); Today; guided workout logger with rest timer and substitutions; Experience Engine modes `full_before`, `full_after`, `rest_prompts`, `workout_only`, `devotional_only`; private journal; faithfulness calendar with grace days; history and PRs |
| **Needed for our initial group** (M2–M3) | Invites and group; members; encouragement feed (opt-in completion posts, reactions, comments); prayer requests with audiences; partners; `split_day` mode with local reminders; push (content-free); report, block, moderation; account deletion and export; teams; practice season; weekly challenge with two tiers and alternates; 1 mission a week; video proof; review and appeal; ledger, standings, finalization |
| **After beta feedback** (M4+) | Nutrition logging (provider proxy), hydration, nutrition participation points; health import (steps); the other three programs; Scripture memorization; workout-specific faith content library; private fasting |
| **Families and youth** | Household ADR and activation; family-variant missions; youth ADR (guardian consent, no messaging, moderation) |
| **Only when scaling** | Admin console; organization layer; leagues; scheduled exports to a second bucket; transcoding and CDN; analytics warehouse; search |
| **Deferred or reconsider** | Direct messages; age brackets (retired in favor of tiers and baselines); manual lift PR board (retire); LLM food photo estimates (replace with a provider); individual leaderboards ranking spiritual activity (never); AI coach over private data (not planned) |

## 3. Milestones (first five after architecture approval)

Each milestone ends with something **real people use**. Phases 1–7 of `docs/architecture/11-roadmap.md` map onto them as shown.

| M | Name | Who uses it | Delivers | Exit criteria | Old phases |
|---|---|---|---|---|---|
| **M1** | **Train with purpose** (private loop) | Both owners + 3 testers on App Distribution and TestFlight | Foundation + sign-in + onboarding + Today + guided offline workout (Forged program) + five Experience modes + journal + calendar + history | Both owners use it daily for 2 weeks. Airplane-mode workout, kill mid-set, resume, reconnect = exactly one session server-side. TC-001/016/017/019/025/026/029–031/033 (Forged) green. | 1 + 2 |
| **M2** | **Brotherhood** (pilot alpha) | The men's group (10–30) | Invites and group; feed and encouragement; prayer with audiences; partners; `split_day` + reminders; moderation and report/block; deletion and export | W11 alpha metrics over 4 weeks; Apple 1.2 UGC checklist; deletion sweep leaves zero rows | 4 |
| **M3** | **Practice season** | The men's group, in teams | Teams; practice season; weekly challenge (two tiers + alternates); 1 mission a week; video proof (capture, upload, review, appeal); ledger; standings; finalization | A full 4-week practice season. Re-finalization gives an identical hash. Unauthorized proof reads denied. Retrospective with the pastor (W04). | 5 |
| **M4** | **Fuel & recover** | The men's group | Nutrition proxy and food log; hydration; health import (steps); nutrition points (bounded); the other three programs (with equivalence) | Food search through the proxy; no client API keys; 1,460-day program equivalence; under-eating is never rewarded (test) | 3 + part of 7 |
| **M5** | **First real season & store readiness** | The men's group; store reviewers | Prod hardening; restore drill; privacy policy and terms; store listings; real season | E.6.4 security gate; 2+ weeks with zero data-loss incidents; cost within the W09 budget; owners' go/no-go | 6 |

Dependencies: M1 → M2 → M3. M4 can start in parallel with M3 once M2 is stable (its nutrition points only count in seasons after M4). M5 needs M3 and M4.

## 4. Major risks

| Risk | Milestone | Mitigation |
|---|---|---|
| Offline sync bugs lose a workout | M1 | Drift first, kill tests, outbox state machine, TC-025/026 |
| iOS signing and TestFlight external review slow the alpha | M1–M2 | Start Apple enrollment and the first TestFlight build in M1 week 1 |
| Moderation load or a pastoral incident in the feed | M2 | W06 roles; report and block from day one; content-free push |
| Men avoid video proof | M3 | W05 default: video only for the weekly proof challenge |
| Scoring disputes | M3 | Practice season; published breakdown; appeals; versioned rulesets |
| Devotional rights unresolved | M5 | W08: record provenance in M1; rights block only public release |
| Two agents build incompatible pieces | All | Contracts, protected zones, decision guard, one implementer per PR (`08-agent-and-skill-architecture.md`) |

## 5. M1 first PR sequence

This replaces the Phase 1 list in `11-roadmap.md` §Stage B. The list there is still valid for PRs 1–8. M1 adds:

| # | PR | Owner role |
|---|---|---|
| 9 | Drift schema + outbox + sync engine skeleton with kill tests | flutter-implementer |
| 10 | `fs_domain/experience` engine (five modes) + golden tests | flutter-implementer |
| 11 | Forged program generator + 365-day equivalence fixtures | content-engineer |
| 12 | Today screen + guided workout logger + rest timer | flutter-implementer |
| 13 | Devotional reader stages + private journal | flutter-implementer |
| 14 | Faithfulness calendar + history + PRs | flutter-implementer |
