# Open-decision register

Each item needs a named human decision. The decision goes into the referenced ADR or ruleset in a PR labelled `contract-change`. **Blocking** means a phase can't exit until the item is decided.

| ID | Decision needed | Options / proposed default | Blocks | Owner | Status |
|---|---|---|---|---|---|
| OD-01 | Faith-participation point weights and caps | Boolean stage completion only. Proposed default: 1 pt per day for completing that day's devotional stages, capped at 5 per week, shown only in the team total. Or 0 (no faith points). | Phase 5 exit | Project owners + pastoral advisor | Open |
| OD-02 | Team score normalization formula | (a) **Mean of capped member points per enrolled member** (proposed); (b) mean of top-N; (c) participation-rate × mean | Phase 5 exit | Owners | Open |
| OD-03 | Tier point multipliers (Standard / Foundation) and the default for approved alternates | Proposed 1.0 / 0.8; alternates inherit their tier | Phase 5 exit | Owners + fitness reviewer | Open |
| OD-04 | Nutrition participation points | Proposed: 1 pt per day with ≥ 2 meals logged, 1 pt per day for meeting hydration; weekly cap 10; no points for deficits | Phase 5 exit | Owners + clinical reviewer | Open |
| OD-05 | Default audience for new prayer requests | `private` (current default), `partners`, `leaders` or `group` | Phase 4 exit | Owners + pastor | Open |
| OD-06 | Proof retention period after season finalization | Proposed: 30 days after the appeal window closes, then delete media and keep the hash and decision | Phase 5 exit | Owners | Open |
| OD-07 | First nutrition provider | FatSecret Platform (Basic: free, US-only, 5,000 calls/day, attribution required; Premier Free: barcode, verification needed); USDA FoodData Central (public domain, US); Open Food Facts (ODbL obligations) | Phase 3 exit | Developers | Open |
| OD-08 | Local database library | **Drift** (proposed), sqflite plus a hand-written layer, or Isar | Phase 2 start | Developers | Open |
| OD-09 | Leader visibility of faith participation | Aggregates only (proposed) or per-member with consent | Phase 4 exit | Owners | Open |
| OD-10 | Named content reviewers (theology, fitness) | — | Publication of any content package | Owners | Open |
| OD-11 | Devotional rights (366 entries) | Owned or AI-generated (record it, then review), licensed (permission), or replace | Public release | Owners | Open |
| OD-12 | First real (non-practice) season date | After Phase 5 exit gates pass in staging | Phase 6 | Owners | Open |
| OD-13 | Late-submission grace window | Proposed: 120 minutes, plus review if `receivedAt − performedAt > 24h` | Phase 5 exit | Owners | Open |
| OD-14 | Step points cap | Proposed: health-sourced steps only, +1 per 2,000 over 8,000, capped at +3 per day | Phase 5 exit | Owners | Open |
| OD-15 | Firestore and Storage location | **Irreversible per project.** Proposed `nam5` (US multi-region) or `us-central1`. Must be chosen before creating the prod database. | Phase 1 start | Developers | Open |
| OD-16 | Commercial model | Free ministry, donations, or paid. Affects ESV/API and Open Food Facts licensing. | Public release | Owners | Open |
| OD-17 | Moderation owner, SLAs, incident contact | Proposed: group leaders first line within 24 h; project owners escalate within 72 h | Phase 6 entry | Owners | Open |
| OD-18 | PR points rule | Variant-keyed e1RM gain ≥ 2.5 %, baseline period 4 weeks, cap 2 PR awards per week | Phase 5 exit | Owners + fitness reviewer | Open |
| OD-19 | App Check enforcement timing | Proposed: monitor in dev, enforce in staging and prod from Phase 1 | Phase 1 exit | Developers | Open |
| OD-20 | Workout participation cap | Proposed: up to 5 scored sessions per week; at most 1 scored session per day | Phase 5 exit | Owners | Open |
| OD-21 | Grace days per week for the faithfulness calendar | Proposed: 2 | Phase 2 exit | Owners | Open |
| OD-22 | Weekly missions count and evidence | 1 or 2 per week; evidence optional, never of family members' faces | Phase 5 exit | Owners | Open |
