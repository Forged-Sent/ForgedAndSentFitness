---
kind: feature-spec
feature_id: FNS-007
status: proposed
risk: high
owner: maintainer
source_ref: claude/review-contracts-setup-and-check-in
source_sha: 49104c9d801b853d0dfc14e0c4d26c4ab2101ed3
approved_by: none
test_plan: placement rules for every level and history answer, a red-flag answer stops plan building for each question, no beginner prescription holds a single above RPE 7, equipment inventory to movement matching with a missing pattern reported, a privacy test that screening answers reach no shared document score log line or analytics event, setup screens as widget tests, restart keeps the plan and the answers
verified_tests: none
implementation_paths: none
verification: none
---

# Plan setup and health screening (proposed)

**Not approved.** A draft for the maintainer. It holds health-related data, so only the maintainer can approve it. Nothing here is built. See [design](design.md) and [tasks](tasks.md).

## Approved user outcome and scope

**Source.** Feature 1 of the maintainer's response to the independent fitness review of 2026-11-24 (review copy at commit 49104c9): the reviewer's verdict was a conditional pilot, and asked that the app place a man on a plan he can do safely. The maintainer looked at a mockup of six screens on 2026-11-24 and said he was good with it. The rules below are written from his prompt and that session, **not from the HTML prototype**.

**The rule that governs every item:** there is no coach or clinician inside the app, so each safeguard works alone. When an answer is unclear, the app takes the easier option, stops, or refers him to his clinician.

**What he sees: five steps, then a plan**

1. **You and your goal.** Main goal (get stronger, build muscle, conditioning, athletic and combat), how long he has trained with weights, how consistent he has been in the last three months, and his level (beginner, intermediate, advanced). The app suggests a level from his answers and he can change it.
2. **Your week.** Three training days or three plus an optional fourth, time per session (30 minutes, 45 minutes, longer is fine), his rest day, and his lifting days.
3. **What you have.** An inventory he ticks: bench, rack with safeties, barbell and plates, dumbbells, pull-up bar, bands, a secure anchor for bands, kettlebell, medicine ball, sled, stairs or a step, floor space to lie down. One more question: whether jumping and running are fine or he wants low impact. When a movement pattern cannot be matched with what he has (for example an overhead pull with no bar and no secure anchor), the app says so on this step and again on the plan.
4. **Health check.** The red-flag questions, and the body areas to work around (knee, hip, low back, shoulder, elbow or wrist, nothing). The maintainer confirmed on 2026-11-24 that these questions stay as shown in the mockup and are not shortened.
5. **Your plan.** The program the app recommends, what it changed for him (swaps for a body area, a missing pattern), and the Foundation start.

**Red flags stop the build.** The prompt names: chest pain; dizziness or fainting during exercise; recent surgery; a medication that affects exercise; and, for the women's library, pregnancy or postpartum. Any one of them stops plan building. He sees "Talk with your clinician first", with no diagnosis and no plan. The rest of the app (devotional, journal, his brothers) stays open to him.

**Foundation.** The app offers a 2 to 4 week Foundation pathway: fewer sets, RPE 5 to 7, no singles, low impact.

**Acceptance (the maintainer's):** no beginner is placed on a prescription with a single above RPE 7.

**Out of scope:** the pre-session check-in and pain flow ([FNS-008](../session-check-in-and-pain/requirements.md)); applying restrictions to warm-ups, recovery days, challenges and custom routines (feature 3, no contract yet); progression and missed sessions (feature 5); calorie or macro targets; body measurements.

## Authorization, privacy and data ownership

- **Private (the maintainer's rule):** "Injuries, symptoms, pain reports, body measurements and screening answers are private. They stay on the device unless I decide otherwise, and must never appear in group queries or scoreboards."
- **Owner.** The answers belong to one owner. Before sign-in the owner is the local profile (decision Q10).
- **Where they are kept.** On the device only, as decision Q8 has it for the journal and body data. Not sent to a project server, not part of any shared document, score, log line or analytics event. The red-flag answers and the body areas are the sensitive part; goal, days and equipment are plan settings.
- **No server authority is involved.** Nothing here writes a score.
- **Negative tests:** a screening answer, a body area or the fact that plan building was stopped never reaches a group query, a board, a log line or a crash report.

**Unknown, so not approved. BLOCKED on the maintainer:**

1. **Which health screen.** The prompt lists it as undecided. The mockup shows the prompt's four questions for men plus one this draft added ("A doctor has told you to limit exercise"). Keep, drop or replace with a named screen.
2. **"Recent surgery."** The mockup says the last 12 weeks. That number is this draft's, not the maintainer's.
3. **How Foundation is built:** a separate 4-week block, or level modifiers on the chosen program.
4. **Foundation for a beginner.** The mockup makes it mandatory for a beginner and a choice for others. Not decided.
5. **Heavy singles:** removed from the programs, or kept as an advanced opt-in. The acceptance test depends on it.
6. **The three easier movements for Foundation** (hands-elevated push-up, band-assisted pull-up, knee plank are named as candidates).
7. **The 45-minute promise** (a ceiling with an elective arm finisher is the maintainer's lean, not a decision). It sets what "45 minutes" in step 2 commits the app to.
8. **Coming back after a red flag.** The mockup has "I have talked with my clinician", which asks the questions again. Whether his say-so is enough is not decided.
9. **Wording.** This flow says "clinician"; the pain screens in FNS-008 say "doctor", as the maintainer put it on 2026-11-24. One word or both.
10. **Target and order.** This draft proposes the prototype first and Flutter after, from this one contract. Which app runs the pilot is not decided, and it settles this.
11. **Where the prototype keeps these answers.** Not checked. They must stay on the device before this is built there.
12. **Phone backups, sign-out and export** for these answers: the journal's answers ([FNS-003](../private-journal/requirements.md)) are not assumed to carry over.

## Failure, offline and migration behavior

- **Everything is local**, so it works the same with no network.
- **He leaves partway.** Nothing is a plan until step 5 is confirmed. BLOCKED: whether partial answers are kept.
- **A save fails:** the screen says so, his answers stay on screen, and no plan is started.
- **He changes an answer later** (a new restriction, new equipment, a new red flag): the plan is rebuilt from the answers; a new red flag stops training until he has cleared it. BLOCKED: whether changing the program restarts the plan's day count.
- **A man who already has a plan** (today every member in Flutter gets Forged, a full gym, rest on Sunday): BLOCKED, whether he is asked the health check before his next workout.
- **The library is not there yet.** The women's seed folder, the six coaching files and the program fixes land on another branch. Field names are not assumed; ask before using one.
- **Accessibility:** every question is answerable with large touch targets and a screen reader; colour never carries a meaning alone.
- **Rollback:** removing the feature leaves the earlier fixed plan working and deletes the stored answers.

## Evidence and traceability

- Maintainer's prompt and session of 2026-11-24; the mockup "Feature 1 · Onboarding and plan setup" (six screens) was shown in that session and is not in the repository.
- Decisions Q8 and Q10 on the [Decisions](../../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md) page.
- Baseline: `main` at 49104c9. The work board's Later row "Plan setup and editor" is the Flutter gap this fills.
- Checks run: none. NOT VERIFIED: everything in this file is intent.
