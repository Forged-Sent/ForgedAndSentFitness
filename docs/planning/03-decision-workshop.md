# 03 · Decision workshop

These are the 12 decisions that belong to the **project owners**: product priorities, community culture, risk tolerance. Each has a **recommended default**, so work proceeds if an answer is late. A default becomes binding only when it is recorded in `decision-log.yaml`.

The same 12 items are on the Planning Hub (Workshop area, W01–W12), where both owners vote and comment. **Order = when the answer is needed.**

| ID | Question | Needed by | Default |
|---|---|---|---|
| W01 | What does a man open the app for each day? | M1 start | Training-first Today, devotional placed by his chosen mode, grace-day calendar |
| W02 | Which pillars are in the first release the men use? | M1 start | Training + devotion (M1), then brotherhood (M2); challenges M3; nutrition M4 |
| W03 | Are accountability teams the same as competition teams? | M3 design | Yes: persistent teams of 3–6 that also act as accountability circles |
| W04 | How visible and how heavy is faith participation in scoring? | M3 exit | Boolean, team total only, 1 per day, max 5 a week, about 10% of a team's weekly maximum |
| W05 | How much proof culture do we want? | M3 design | Video required only for the one weekly proof challenge; honor plus spot checks otherwise; delete 30 days after appeals |
| W06 | Who sees prayer requests and faith participation, and who moderates? | M2 start | Prayer default = my team (author can widen or narrow); leaders see aggregates only; leaders moderate first, owners escalate |
| W07 | Which training content ships first? | M1 start | Forged program only, plus a quick or custom log; other three programs in M4 |
| W08 | Who approves content, and what are the devotional rights? | M1 content freeze | A named pastor or elder for faith content and a named fitness reviewer; record devotional provenance before the pilot; resolve rights before public release |
| W09 | What's the money model and monthly budget ceiling? | M5 | Free ministry; $25/month budget alert in the pilot; revisit at Stage 2 |
| W10 | When and how do wives, families and youth come in? | Before Stage 2 | Women's groups as ordinary adult groups first; households later; youth not before Stage 3 |
| W11 | What does pilot success look like? | M2 start | 4 weeks; at least 70% of members complete at least 3 workouts a week; zero lost workouts; owners' qualitative review |
| W12 | Where do we plan and decide together, and how does the prototype relate? | **Now** | Hybrid: Planning Hub for discussion and voting; GitHub decision log and ADRs authoritative; the prototype evolves independently, labeled |

---

## W01 · What does a man open the app for each day?

**Why it matters:** this sets the home screen, the notification strategy and the shape of the Experience Engine defaults, and so the first month of UI work.

| Option | What it looks like | Consequence |
|---|---|---|
| **A. Training-first Today (default)** | "Day 12 · Lower strength · 45 min". The devotional sits before, after or in rests per his mode. Faithfulness calendar beneath. | Matches the "fitness platform" framing; the devotional is never more than one tap away |
| B. Devotional-first Today | The morning reading leads; the workout follows | Fits a Bible-study product; risks training feeling secondary |
| C. Dashboard of equal tiles | Workout, devotion, food and team at equal weight | Loses the daily rhythm; more design work |

**Also:** the default grace days in the faithfulness calendar (OD-21). Default 2 a week; no streak-loss shaming.
**Blocks:** M1 UI. **Choosing differently:** B changes Today and the onboarding order, not the architecture.

## W02 · Which pillars are in the first release the men use?

**Why it matters:** scope is the main schedule risk. Every pillar has a privacy and test surface.

| Option | Contents | Consequence |
|---|---|---|
| **A. Staged (default)** | M1 training + devotion (owners and testers); M2 + brotherhood (pilot alpha with the men); M3 + challenges with video; M4 + nutrition and health | The men are using it within two milestones |
| B. Everything before the pilot | All pillars before any man uses it | Months more before real feedback; the current Phase 6 plan |
| C. Challenges first | Competition engine first, because the prototype's energy is there | The hardest subsystem first, with no daily habit loop underneath |

**Note:** nutrition participation points (approved, AP-09) can't count until M4 ships logging. The first practice season (M3) runs without them.
**Blocks:** roadmap. **Choosing differently:** B or C re-sequences the milestones; the architecture doesn't change.

## W03 · Are accountability teams the same as competition teams?

**Why it matters:** with 10–30 men, two kinds of subgroup is overhead. With 200 it might not be.

| Option | Consequence |
|---|---|
| **A. One persistent team (default)**: 3–6 men, also the default prayer and accountability audience; a leader may reshuffle between seasons | Simple; teammates know each other; the team audience is meaningful for prayer |
| B. Separate: persistent accountability circles + season-scoped competition teams | More flexible at scale; two concepts to explain and build |
| C. Season teams only; partners for accountability | Accountability resets each season |

**Also:** weekly missions: **1 a week (default)** or 2 (OD-22). Evidence is optional and never requires family members' faces.
**Blocks:** M3 design. **Choosing differently:** B adds a `circles` collection and an audience type later; no migration if we start with A.

## W04 · How visible and how heavy is faith participation in scoring?

**Approved in principle (AP-07); the weights are yours.** Matthew 6:1–6 is the tension: participation can be encouraged, but performing righteousness for points is the failure mode.

| Option | Consequence |
|---|---|
| **A. Boolean, team total only (default)**: 1 point per day for completing that day's devotional stages; max 5 a week; never on any individual board; about 10% of a team's weekly maximum | Encourages the habit; nobody is ranked on spirituality; content is never read |
| B. Zero faith points; recognition badges only | Safest on perception; loses a gentle motivator the owners wanted |
| C. Higher weight (equal to workouts) | Strong incentive; high risk of checkbox devotion and comparison |

**Recommendation:** run the practice season with A, then hold a 15-minute retrospective with your pastor before the first real season.
**Blocks:** M3 exit (rulesets). **Choosing differently:** a ruleset parameter, so cheap to change between seasons.

## W05 · How much proof culture do we want?

**Approved:** video is supported in the first challenge release; not every challenge requires it (AP-08).

| Option | Consequence |
|---|---|
| **A. One weekly proof challenge requires video (default)**; workouts and missions are honor-based with random spot checks; proof deleted 30 days after the appeal window | Integrity where it matters; low friction; low cost (about $1/month at 100 users) |
| B. Video for every scored physical activity | Strong integrity; men skip rather than film at home or in a gym; more review work for leaders |
| C. Honor only, video optional | Easiest; recreates the prototype's trust problem |

**Also:** who reviews proof? Default: two leaders per group, never reviewing their own team.
**Blocks:** M3. **Choosing differently:** a per-challenge policy field already exists (ADR-0010); retention is a job parameter.

## W06 · Who sees prayer requests and faith participation, and who moderates?

| Sub-question | Options | Default |
|---|---|---|
| New prayer request audience (OD-05) | private · partner · my team · leaders · whole group | **My team** (the author changes it per request) |
| Leader visibility of faith participation (OD-09) | aggregates only · per member with consent | **Aggregates only** |
| Moderation (OD-17) | leaders first (24 h), owners escalate (72 h) · owners only | **Leaders first, owners escalate**; one named incident contact |

**Why it matters:** this is the trust contract with the men. Apple guideline 1.2 requires report, block and timely moderation for user-generated content.
**Blocks:** M2 start.

## W07 · Which training content ships first?

| Option | Consequence |
|---|---|
| **A. Forged program + quick or custom log (default)** | One program to generate and verify (365 days); fast to the pilot |
| B. All four programs | 1,460 days to verify plus fitness review before M1 |
| C. Simplified starter program written new | Cleaner content, but loses tested prototype programming |

**Also needed:** which equipment profiles are supported at launch (default: full gym, home dumbbells, bodyweight).
**Blocks:** M1 content.

## W08 · Who approves content, and what are the devotional rights?

**Why it matters:** the 366 devotionals and Coach Gideon cues are the faith and training voice of the app. Their provenance (written by you, AI-assisted or third-party) decides whether we can publish them (OD-11). Named reviewers are required by the content pipeline (OD-10).

| Option | Consequence |
|---|---|
| **A. Name one pastor or elder and one fitness reviewer now; record provenance per devotional before the pilot (default)** | The pilot can proceed; public release waits on rights |
| B. Owners review everything | Fastest; weaker theological and safety review |
| C. Replace devotionals with a licensed source | Clear rights; cost and less voice |

**Blocks:** content publication (M1 content freeze for the pilot; rights block public release only).

## W09 · Money model and budget ceiling

| Option | Consequence |
|---|---|
| **A. Free ministry with a budget alert (default)**: $25/month alert in the pilot (expected $0–5) | Simple; ESV, Open Food Facts and provider terms are easier |
| B. Donations | Needs a payment provider; stores have rules for in-app donations |
| C. Paid tier for churches (Stage 2+) | Revenue for scale; changes licensing and support obligations |

**Blocks:** public release (M5). Not the pilot.

## W10 · When and how do wives, families and youth come in?

| Option | Consequence |
|---|---|
| **A. Women's groups first as ordinary adult groups; households (couples, families) at Stage 2; youth not before Stage 3 with its own ADR (default)** | No new access semantics until needed; the model already avoids assuming male, married or parent |
| B. Couples together at Stage 1 | Needs the household design now: consent, what's shared, separation |
| C. Youth with the families | Needs guardian consent, a no-messaging design and moderation staffing; a large legal and safety scope |

**Blocks:** nothing in M1–M3; must be answered before Stage 2 planning.

## W11 · What does pilot success look like?

**Default:** a 4-week pilot alpha after M2, then a practice season after M3. Success is:

- At least 70% of members complete at least 3 workouts a week.
- At least 50% engage with a devotional stage at least 4 days a week.
- Zero lost workouts or data incidents.
- Cost within budget.
- A qualitative review by the owners and the pastor.

The first **real** season date (OD-12) is set only after the practice season passes.
**Blocks:** M2 start (what we measure; it determines the analytics events we keep, without content).

## W12 · Where do we plan and decide together, and how does the prototype relate?

**Default:**

- A **hybrid** (`09-planning-hub-spec.md`).
- The Blueprint page becomes the Planning Hub, where both owners and friends submit ideas, discuss and vote.
- **Owner decisions become authoritative only in GitHub:** `docs/planning/decision-log.yaml` and ADRs, merged by both owners.
- The prototype keeps evolving independently; each change carries the `legacy-change` label and never becomes a requirement without a hub decision.

**Blocks:** substantial independent agent development.

---

## C2 · Engineering decisions I recommend (no owner input needed unless you disagree)

| Topic | Recommendation | Decide by | Why it's an engineering call |
|---|---|---|---|
| OD-08 local DB | **Drift** | M1 start | Type-safe SQL, migrations, streams; Isar's maintenance is uncertain; sqflite is too low-level |
| OD-15 Firestore and Storage location | **`nam5` (US multi-region)** for prod; `us-central1` for dev | Before creating prod; **irreversible** | Pilot is in Arizona; multi-region availability for a small cost premium |
| OD-19 App Check | Monitor in dev; enforce in staging and prod from M1 | M1 | Standard abuse control |
| ADR-0016 diagnostics | Crashlytics with a redacting logger | M1 | Already on Firebase; no extra vendor |
| ADR-0018 authorization source | Membership documents; custom claims only as a cache | M1 | Rules get one `get`; claims go stale |
| OD-07 nutrition provider | Decide at M4: USDA FoodData Central (free, public domain) + FatSecret Basic for search; check terms then | M4 | Terms and quotas change; no need to fix now |
| OD-02 team normalization | Mean of capped member points per enrolled member | M3 | Fairness math; tune in the practice season |
| OD-03 tier multipliers | Standard 1.0 / Foundation 0.8 / alternates inherit the tier | M3 | Ask the fitness reviewer to sanity-check |
| OD-13 grace window | 120 minutes; review if received more than 24 h after performed | M3 | Offline tolerance |
| OD-14 step cap | Health-sourced only, +1 per 2,000 over 8,000, max +3 a day | M4 | Anti-gaming |
| OD-18 PR rule | Variant e1RM gain of at least 2.5% over a 4-week baseline; max 2 PR awards a week | M3 | Anti-sandbagging |
| OD-20 workout cap | At most 5 scored sessions a week, 1 a day | M3 | Safety: no reward for overtraining |
| State management | Riverpod + go_router + freezed (already in AGENTS.md) | M1 | Mainstream, testable, AI-assistant friendly |
