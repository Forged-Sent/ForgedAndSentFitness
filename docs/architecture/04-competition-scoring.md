# 04 · Competition and scoring

Status: **Accepted (ADR-0005, ADR-0009, ADR-0019)**. Numbers marked *OD-xx* are proposals awaiting approval and live in the ruleset, not in code.

## Principles

1. **Facts in, points out.** Clients write facts. Only Cloud Functions write `ledger`, `standings` and `snapshots`.
2. **Deterministic and replayable.** `points = evaluate(facts, ruleset@version)`. The same inputs always give the same ledger.
3. **Append-only.** Corrections are `adjustment` entries with `actor`, `reason`, `approvedBy`.
4. **Idempotent under at-least-once delivery.** Ledger IDs are deterministic, `{sourceType}_{sourceId}_{rulesetVersion}_{kind}`, and are created inside a transaction only if absent. Standings are **recomputed** from the ledger, never incremented.
5. **Safe incentives.** Points are capped per day and week. Nothing rewards extra volume, under-eating, unsafe exertion or spiritual disclosure.
6. **Published rules.** Every season shows its ruleset in plain language, including tier and alternate differences.

## Point sources (ruleset components)

| Component | Fact | Rule (proposed) | Caps | OD |
|---|---|---|---|---|
| Workout participation | `sessions/{id}` finished (synced) plus checkin `workout` | Points per scheduled session completed; rest-day template counts as completed rest | ≤ 1/day, ≤ 5/week | OD-20 |
| Weekly physical challenge | `attempts/{id}` approved | `base × tierMultiplier` (Standard 1.0 / Foundation 0.8 proposed); alternates inherit the tier mapped by an admin | 1 best attempt per challenge | OD-03 |
| Personal improvement | Retest attempt vs frozen baseline in `enrollments/{uid}.baselines` | Points for improvement bands (e.g., ≥ 3 %, ≥ 8 %), not for absolute performance | Per retest | — |
| Weekly missions (1–2) | `missions/{mid}/completions/{uid}` | Flat completion points; inclusive variants; evidence optional and never of family faces | Per mission | OD-22 |
| PRs | Derived `prs/*` on variant e1RM gain | Small bonus | ≤ 2/week; none in the 4-week baseline period | OD-18 |
| Steps | `healthDays/*_steps` with `source ≠ manual` | Bonus over a threshold | ≤ +3/day | OD-14 |
| Nutrition participation | Checkins `meals_logged`, `hydration` | Participation only; never deficit or weight-based | ≤ 10/week | OD-04 |
| Faith participation | Checkin `devotion` (boolean) | Optional; zero unless approved | ≤ 5/week | OD-01 |

## Teams and normalization (FS-CMP-005, OD-02)

Proposed default:

```text
memberWeekly(u)  = min(Σ points(u, week), weeklyCap)
teamWeekly(T)    = (Σ_{u ∈ enrolled(T)} memberWeekly(u)) / |enrolled(T)|      # mean per enrolled member
teamSeason(T)    = Σ_weeks teamWeekly(T)
```

**Why the mean over enrolled members, active or not:**

- Size alone gives no advantage.
- Inactive members lower the mean, which rewards carrying a brother rather than dropping him.
- Teams of very different sizes stay comparable.

**Alternatives under OD-02:**

- Mean of the top N members.
- Participation-rate × mean.

**Independent participants** (`teamId = null`) appear in personal-progress views and, optionally, an individual board. They never count toward a team.

**Property tests (TC-007):**

1. Two teams with identical per-member points and sizes 3 and 9 score equally.
2. Adding a zero-point member lowers the mean proportionally.
3. One member's points can never exceed the weekly cap.

## Challenge lifecycle and deadlines

```text
draft → scheduled (ruleset pinned) → open → closed → in_review → finalized → [under_appeal → finalized vN]
```

- **Attempt creation:** the rule allows `create` only if `request.time ≥ opensAt && request.time ≤ closesAt + graceMinutes`, where `request.time` is the server receipt time. An offline attempt reaching the server late is rejected by rules. The client then keeps it locally as `late` and offers "Submit for review". The review callable records `lateReview: true` (OD-13).
- **Claims vs receipt:** `performedAt` is the client's claim and is stored but not trusted. If `receivedAt − performedAt > 24h`, the attempt goes to review.
- **Time zone:** each season stores an IANA tz. Week boundaries are computed in that tz. Phoenix (no DST) and DST zones are both covered by TC-013.

## Review, appeal, adjustment

1. **Review queue:** attempts with `status == submitted` and a proof policy that is `required`, or picked by spot-check sampling.
2. **Reviewer decision:** a callable records approve, reject or needs_info with a reason. The decision is written to `attempts/{id}/reviews` and the status updates.
3. **Finalization:** a scheduled Function runs at `review_until`. It evaluates, writes ledger entries, recomputes standings, writes `snapshots/{week}_v1` with a SHA-256 of its canonical JSON, and sets the challenge to `finalized`.
4. **Appeal:**
   - The owner files an appeal within the window, and the challenge moves to `under_appeal`.
   - The resolution writes an `adjustment` ledger entry and a new snapshot `_v2` referencing v1.
   - v1 is never altered (FS-CMP-004, FS-CMP-013).
5. **Rule change mid-season:**
   - A new ruleset version applies from a declared `effectiveWeek`.
   - Finalized weeks are untouched.
   - A retroactive re-score is a separate admin callable. It writes superseding entries and an audit record.

## Abuse and safety catalogue

| Vector | Control |
|---|---|
| Editing points or others' facts | Rules deny; facts are owner create-only; points are Functions-only |
| Duplicate submissions or trigger redelivery | Deterministic IDs; create-if-absent; recompute projections |
| Backdating (prototype test-date control) | Server `request.time`; `localDate` must be within ±1 day of the server date in the user's tz (rule) |
| Manual steps inflation | Health-sourced only; cap |
| Volume PR farming | Variant-keyed e1RM; weekly cap; baseline period |
| Sandbagging tiers | Tier choice is visible in the breakdown; multipliers published; best attempt per challenge |
| Overtraining for points | Daily and weekly participation caps; no volume points |
| Under-eating for points | Participation-only nutrition points; floor check (FS-NUT-002) |
| Spiritual performance | Boolean, capped, aggregate display; no content-based signals (FS-PRV-004) |
| Fake or old video | Review, metadata check, appeal |
| Cash or wagering incentives | Schema forbids prize, wager and entry-fee fields (FS-CMP-014) |

## Prototype rules retired, with reason

| Prototype rule (v162 line) | Disposition |
|---|---|
| `max(flat 50, standard)` (L4343) | Replaced by tier multipliers; removes the scaled-beats-trying loophole |
| Solo bracket scores 100 (`soloBracketScores`) | Replaced by personal improvement and normalized teams |
| Bracket recomputed from the current birthday (L4867) | Baselines and any brackets frozen at enrollment |
| PR 25 points incl. volume (L1871, L2682) | Bounded variant e1RM PRs |
| Uncapped manual step bonus (L1861, L5622) | Capped, health-sourced |
| Fast day auto-checks Calories (L2017) | Fasting is never scored |
| Points recomputed from current task values (L1971) | Ledger pins the ruleset version |
