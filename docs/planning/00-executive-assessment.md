# 00 · Executive architecture assessment

| | |
|---|---|
| Date | 2026-10-27 |
| Builds on | Branch `arch/firebase-reconciliation` @ `0d21d21` (ADR-0001..0019, FS-* requirements, OD-01..22) |
| Scope | Product architecture first, then the engineering path. **No Flutter code, no prototype edits.** |
| Evidence tags | **[V]** verified in the repo or vendor docs · **[A]** owner-approved · **[R]** my recommendation · **[O]** open for the owners · **[D]** deferred |

## Bottom line

1. **The technical foundation is sound and should not be reopened.** Flutter, Firebase, offline-first with Drift, group-scoped data, and a Functions-only scoring ledger fit two developers, 10–30 pilot users and a path to 100k. [A] + [R]
2. **The product framing has sharpened, and the repo lags behind it.** The morning brief on 27 Oct said *"faith-centered devotional workout … platform; not simply a fitness tracker with Bible verses"*, and `AGENTS.md` copied that wording. The newer brief says it is **a fitness platform built around Christian discipleship, not a Bible-study app with fitness as an optional extra**. The two agree on what it is *not*, but the newer one makes training the core pillar, and the newer one governs. The requirement set shows the earlier tilt: competition has 14 requirements, training has 6, and progression, deload, equipment profiles, recovery and ability onboarding have none. [V] This package updates `AGENTS.md`, restates the product (`01-product-architecture-brief.md`) and proposes the missing training requirements (§7 of the brief).
3. **The roadmap delays real use too long.** Today the men can't use anything until Phase 6, after the competition machinery is finished. I recommend **five milestones**, each usable by real people. The owners use the app daily from **M1**, and the men's group starts a pilot alpha at **M2**, before competition exists (`05-mvp-roadmap-milestones.md`). [R]
4. **Only about 12 decisions really belong to you.** The 22 open decisions on the branch mix product questions with engineering parameters. I've split them: **12 workshop questions** for you (`03-decision-workshop.md`), with a recommended default for each so work can proceed, and a list of engineering decisions I recommend outright.
5. **Collaboration needs a real system of record.** Recommendation: a **hybrid**. The existing Blueprint page, upgraded into a Planning Hub, is where you discuss and vote. **GitHub** is the authoritative record: issues, a `docs/planning/decision-log.yaml` protected by CODEOWNERS, and ADRs. I don't recommend building a custom portal now (`09-planning-hub-spec.md`). [R], owner decision W12.
6. **There's one honesty gap to close at merge.** ADRs on the reconciliation branch say *Accepted*, but only the direction you stated on 27 Oct is actually owner-approved. Everything else is my recommendation until both owners merge the PR. `02-decision-register.md` separates the two. Merging should either ratify those ADRs or flip specific ones back to *Proposed*. Agents may not change ADR statuses, so that's your call. [V]

## What Forged & Sent is (one paragraph)

Forged & Sent is a **training app for Christian men who want to get stronger in body and faith, together**. Each day a man opens a program workout that fits his ability and equipment. The devotional sits where he prefers it: before, after, in his rest periods, or at another time of day. He logs the workout even without signal and sees his own progress. His small group encourages him, prays with him and holds him accountable. Seasonal team challenges make the effort shared and fun, and they never turn spirituality into a performance. Private practices (journal, fasting, prayer content) stay private.

## How the recommendations score against your priorities

| # | Priority | Assessment | Main trade-off accepted |
|---|---|---|---|
| 1 | Correctness and security | Strong: deny-by-default rules, Functions-only privileged writes, rules tests in CI (not yet run; P0-4) | Firestore rules are harder to reason about than SQL row-level security, so we rely on the rules test matrix |
| 2 | Useful product experience | Improved by the M1–M5 resequencing | Competition arrives later (M3) than the prototype suggests |
| 3 | Maintainable by two developers | Modular monolith, one repo, managed services, 2–4 agent roles per change | Some Firebase lock-in |
| 4 | Offline reliability | Drift as the device source of truth, outbox, idempotent Functions | More client code than relying on Firestore's cache alone |
| 5 | Cross-platform consistency | Flutter with a single design system | Native look per platform is deliberately not pursued |
| 6 | Development efficiency | Vertical slices; contracts before code | Phase 0 docs are heavy up front (now done) |
| 7 | Reasonable initial cost | About $0–5/month for the pilot; about $7–15/month at 1,000 users (`docs/architecture/09-operations.md`) | Video proof roughly doubles cost at scale |
| 8 | Future extensibility | Groups, optional organizations, reserved households, versioned content and rulesets | We model a few things we don't build yet (reserved paths, flags) |
| 9 | Incremental scaling | Stage triggers defined (`04-staged-growth.md`) | No multi-region or search infrastructure until needed |
| 10 | Fellowship and fitness alignment | Team-first boards, participation-only faith points, privacy by default | Some men may want individual leaderboards; individual views show personal progress only |

## What I would challenge if you asked for my strongest objections

None of these reverses an approved decision. They are scope cautions.

| Item | Concern | Proposal |
|---|---|---|
| Experience Engine: six modes at once | Six modes plus reminders is a lot for M1 | Ship 5 modes in M1 and add `split_day` (scheduled reminders) in M2. The engine supports all six from day one. |
| Video proof | Approved. The risk isn't cost; it's men skipping challenges they don't want to film at home or at the gym | Proof policy per challenge (already in ADR-0010). Default to video for the weekly "proof challenge" only (W05). |
| Faith participation points | Approved as bounded. Even boolean points can feel like spiritual scorekeeping | Team total only, never on an individual board, capped. Revisit after the practice season with pastoral input (W04). |
| Four year-long programs at launch | 1,460 day rows to verify for equivalence, plus fitness review | Ship **Forged** first (M1), the other three in M4 (W07) |

## Package contents

| File | Answers |
|---|---|
| `01-product-architecture-brief.md` | Mission, audience, boundaries, journeys, the five domains and their relationships, community hierarchy |
| `02-decision-register.md` | What is Approved, Recommended, Open, Challenged and Deferred, with sources |
| `03-decision-workshop.md` | The 12 owner decisions, with defaults; the engineering decisions I'm making for you |
| `04-staged-growth.md` | Stages 1, 2 and 3: what to build, cost drivers, bottlenecks, what not to build |
| `05-mvp-roadmap-milestones.md` | MVP definition, feature tiers, M1–M5 with exit criteria |
| `06-systems-engineering-models.md` | Which models to keep, what each contributes, when to update it |
| `07-engineering-collaboration-plan.md` | Repo, branches, reviews, CI/CD, releases, what must be final before agents work alone |
| `08-agent-and-skill-architecture.md` | A smaller active agent set, deterministic gates, the decision guard |
| `09-planning-hub-spec.md` | Collaborative Planning Hub specification |
| `decision-log.yaml` | Authoritative, version-controlled owner decisions (seeded with the 27 Oct direction, pending ratification) |
