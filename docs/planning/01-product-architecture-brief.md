# 01 · Product architecture brief

## 1. Mission

> Help Christian men grow **stronger in body and in faith, together**, through structured training, daily discipleship woven into that training, and a small brotherhood that encourages, prays and competes as a team.

**Product category:** a fitness platform built around Christian discipleship. It is **not** a Bible-study app with optional workouts. Training is what a man does every day. Discipleship gives it purpose and runs through it.

**Biblical frame:** 1 Timothy 4:8 (bodily training is of some value; godliness is of value in every way), 1 Corinthians 9:24–27 (discipline with purpose), Proverbs 27:17 (iron sharpens iron), Hebrews 10:24–25 (stir one another up; don't neglect meeting together), Galatians 6:2 (bear one another's burdens), Matthew 6:1–18 (practice righteousness without performing it for others). The last passage is the design constraint behind the faith-privacy rules.

## 2. Audience

| Stage | Who | Notes |
|---|---|---|
| Pilot (now) | 10–30 adult men in one church Bible study | Mixed fitness, ages and life situations (single, married, divorced, widowed, fathers and not). Some are injured or older. |
| Next | Wives and other adult women; other men's groups; other churches | Adults only. Women's groups are ordinary groups; nothing in the model assumes male. |
| Later | Couples and families sharing challenges | Needs the household design (ADR-0013, reserved and inactive) |
| Much later | Youth | Needs its own ADR (consent, moderation, messaging, guardians). Not before Stage 3 (W10). |

## 3. Product boundaries

| In | Out (by design) | Out (for now) |
|---|---|---|
| Structured programs, guided workout logging, progress, substitutions | Cash prizes, wagers or anything gambling-like | Direct messages (ADR-0017) |
| Devotionals, Scripture, prayer, private reflection, workout-specific faith content | Scoring the **content** of prayer, journals or devotion | Youth accounts |
| Group feed, encouragement, prayer requests, partners | Public social network; following strangers | Public discovery of groups |
| Team challenges, missions, seasons, proof | Weight-loss or calorie-deficit competitions | Coach marketplaces, paid plans |
| Nutrition logging, hydration, health import (opt-in modules) | Medical advice | AI coach that reads private content |

## 4. The five domains and how they relate

`docs/diagrams/15-product-domains.mmd` draws this.

| Domain | Role in the product | Depends on | Feeds |
|---|---|---|---|
| **Fitness & training** (core loop) | Today's workout, logging, progression, PRs, history | Content (programs, movements) | Experience Engine (workout state), competition (participation facts), community (completion posts, opt-in) |
| **Faith & discipleship** (woven in) | Devotional stages, Scripture, prayer, reflection, memorization, study plans, service | Content (devotionals, reflections) | Experience Engine (stages), community (prayer requests the author chooses to share), competition (boolean participation facts only) |
| **Nutrition & wellness** (opt-in module) | Food log, hydration, health import, optional private fasting | Provider proxy, HealthKit and Health Connect | Personal progress; competition (bounded logging and hydration facts; never deficits) |
| **Community & fellowship** | Group, members, partners, feed, prayer, encouragement, notifications | Identity and membership | Accountability: what members choose to share |
| **Team challenges & missions** | Seasons, teams, challenges with tiers and alternates, missions, proof, standings | Facts from the other four domains; rulesets | Recognition and team standings |

**The integrating idea is the Experience Engine (ADR-0008).** It composes the training domain's workout with the faith domain's stages into one daily experience. The man picks a mode (before, after, rest prompts, split across the day, workout only or devotional only). The engine is pure Dart and independent of navigation, so the domains stay separable.

**Rule of separation:** domains exchange **facts** (for example, "workout session completed", "devotional stage completed", "meal logged") and never their private content. Competition consumes facts and never reads journals, prayers or food details.

## 5. Principal user journeys (MVP first)

| # | Journey | Milestone |
|---|---|---|
| J1 | Join: an invite link, sign in with Apple or Google, confirm 18+, choose a program, lift days and equipment, and pick a devotional placement | M1 / M2 |
| J2 | Today: open Today, see the workout and devotional in the chosen order, do a guided workout offline (sets, rest timer, rest prompts), complete it, write a private reflection | M1 |
| J3 | Progress: the faithfulness calendar with grace days, PRs, history and program position | M1 |
| J4 | Brotherhood: share a completion (opt-in), encourage, post a prayer request with a chosen audience, pray for others, partner check-in | M2 |
| J5 | Season: join a team, see the week's challenge (Standard or Foundation tier, or an approved alternate), record proof, submit, see team standings and the breakdown | M3 |
| J6 | Fuel: log meals and water, import steps | M4 |
| J7 | Leader: invite members, set up a season and teams, review proof, moderate | M2 (invites) / M3 (seasons) |

## 6. Community hierarchy: evaluation and recommendation

### Options considered

| Option | Shape | Strengths | Weaknesses |
|---|---|---|---|
| A. One generic **Community** node (`type` = church, group, family, team) in a tree | A recursive parent/child structure | One concept; flexible | Each type needs different privacy semantics (a family must not see what a group sees), so the code branches on `type` everywhere. Recursive rules in Firestore are expensive (10 `get` limit per request). |
| B. **Separate entities** for everything (Platform, Organization, Group, Team, Household, Circle) from day one | Fully modeled | Explicit | Builds structures nobody uses in the pilot |
| **C. Group is the tenant; other layers are optional and grant nothing by themselves** (current ADR-0004 and ADR-0013) | Group → Team (per season) · Organization (optional parent) · Household (reserved) | Matches Firestore path security; small now; extensible | Cross-group competitions need an explicit "league" concept later |

**Recommendation: C.** Keep ADR-0004 and ADR-0013 and add two clarifications:

```text
Platform
└─ Organization (optional; a church)       · admin metadata only; grants NO data access   [Stage 2]
   └─ Group (tenant + privacy boundary)    · membership with role: member | leader         [Day 1]
      ├─ Team (belongs to a Season)        · competition AND accountability unit (W03)     [M3]
      ├─ Partner link (2 members)          · prayer/accountability audience                [M2]
      └─ Season → Challenges / Missions                                                    [M3]
League (cross-group season; references Groups; sees standings only)                         [Stage 2]
Household (separate entity, never a Group type) · grants only explicit shares               [Reserved]
Member (account) ── many memberships ──> Groups                                            [Day 1]
```

`docs/diagrams/16-community-hierarchy.mmd` shows when each layer becomes active.

### The scenarios, mapped

| Scenario | How the model handles it | When |
|---|---|---|
| A man in several groups | One account, many `memberships`; group-scoped data paths; a group switcher | Day 1 (model), M2 (UI) |
| A Bible study with several accountability teams | Teams inside the group. W03 decides whether teams persist across seasons. | M3 |
| Husband and wife both using the app | Two accounts. Each sees only their own groups. Nothing is shared between spouses automatically. | Stage 2 |
| Families in shared challenges | Household plus family-variant missions, after a household ADR. Proof never requires family on camera. | Stage 2–3 |
| Independent churches | Organization layer above their groups; leaders self-serve group creation | Stage 2 |
| A leader configuring local goals or study plans | Group settings plus season rulesets chosen from **approved** templates (no free-form scoring) | M3 |
| Private workouts alongside group activity | Personal data lives under `users/{uid}`; only facts and posts the member chooses reach the group | Day 1 |
| Competitions between groups | A League references groups. Standings are aggregated by a Function; no cross-group data reads. | Stage 2 |
| Youth with age controls | Inactive. Its own ADR before any code: guardian links, no messaging, separate moderation. | Stage 3+ |

**What must exist structurally on day one:** `groups/{gid}` paths for all shared data; memberships written only by Functions; profiles with no required gender, marital or child fields; reserved collections denied by rules; versioned content and rulesets. Everything else can come later without migrating data.

## 7. Proposed training requirements (gap fill)

`docs/requirements/` is a protected zone, so these are **proposals** for the owners to add in a `contract-change` PR. They correct the domain imbalance (training has 6 requirements, competition 14).

| Proposed id | Requirement | Why it matters |
|---|---|---|
| FS-TRN-007 | Onboarding shall capture experience level, available equipment and current limitations, and select a program tier and substitutions from them | "Different abilities and circumstances" |
| FS-TRN-008 | The program shall apply a defined progressive-overload rule per movement type (load, reps, or time), with automatic deload weeks visible in the plan | Core training value; the prototype stripped RPE/RIR |
| FS-TRN-009 | A member shall be able to log a quick or custom session (outside the program) that counts as a workout fact | Travel, injury, and other gyms |
| FS-TRN-010 | Missed days shall shift or skip per a stated rule, without breaking the plan week or shaming language | Real life; works with grace days |
| FS-TRN-011 | A member may record a readiness or soreness check (optional) that can suggest a lighter variant; it is never shared or scored | Recovery and safety |
| FS-TRN-012 | All program content needed for the next 14 days shall be available offline | Offline reliability |
| FS-DWE-008 | Workout-specific faith content (a theme, verse or reflection tied to the day's training focus) shall be selectable for rest prompts and cooldown | "Workout-specific faith content" |
| FS-FTH-001 | Scripture memorization: a member may choose a verse of the week with spaced review prompts; private, unscored | Discipleship depth beyond reading |
