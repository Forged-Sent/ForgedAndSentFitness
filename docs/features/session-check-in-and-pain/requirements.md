---
kind: feature-spec
feature_id: FNS-008
status: proposed
risk: high
owner: maintainer
source_ref: claude/review-contracts-setup-and-check-in
source_sha: 49104c9d801b853d0dfc14e0c4d26c4ab2101ed3
approved_by: none
test_plan: check-in rules for every combination of signals, a performance drop across two comparable sessions triggers the lighter suggestion, pain before a workout overrides every other signal, Stop Pain offers skip and end and never another loaded lift, the pain screens hold no diagnosis and no claim that core work protects the back, a privacy test that check-in answers and pain reports reach no shared document score log line or analytics event, widget tests of the five screens
verified_tests: none
implementation_paths: none
verification: none
---

# Pre-session check-in and pain flow (proposed)

**Not approved.** A draft for the maintainer. It holds health-related data, so only the maintainer can approve it. Nothing here is built. See [design](design.md) and [tasks](tasks.md).

## Approved user outcome and scope

**Source.** Feature 2 of the maintainer's response to the independent fitness review of 2026-11-24 (review copy at commit 49104c9). The maintainer looked at two versions of a five-screen mockup on 2026-11-24, cut the pain screens down, and said he was good with the second version. The rules below are written from his prompt and that session, **not from the HTML prototype**.

**The rule that governs every item:** there is no coach or clinician inside the app. When a signal is unclear, the app takes the easier option, stops, or refers him to his doctor.

**What he sees**

1. **A thirty-second check before a workout:** sleep last night, soreness (normal, more than usual, none), any pain right now (no, a little, yes), drive to train (low, normal, high). The app adds one line from his own log when recent performance has dropped. He can skip the check.
2. **Several poor signals, or performance down across two comparable sessions:** the app suggests an easier session: sets reduced 25 to 40 percent and effort 1 to 2 RPE lower, for several sessions. It shows what changes on each lift. He can train the lighter session, train it as written, or take a rest day. It is a suggestion and never a lock. The thresholds are labeled as pilot defaults.
3. **Pain before the workout overrides every other signal.** One screen: "Rest today. You said you have pain right now. Do not train on it. If it does not ease, or it worries you, talk with your doctor." One action: mark today as rest. He can change his answer.
4. **A Stop · Pain button on every lift** in a workout.
5. **Stop · Pain:** "Stop this lift. Put the weight down and rest. Do not push through pain. If it does not ease, or it worries you, talk with your doctor." Two choices: skip this lift and carry on, or end the workout here. **No other lift is offered in its place.**

**The maintainer's decision of 2026-11-24, which departs from his own prompt and the reviewer's list.** The prompt asked that Stop · Pain show the stop rules and that pain and emergency wording come from the coaching files. Shown that version, he said: "I don't want those options. To detailed and should be with there doctor." So the pain screens do **not** show a list of stop rules, a list of emergency signs, an "I need help now" button or a question about where it hurts, and the app stores no pain location. It is recorded here so a reviewer can see it was deliberate.

**Acceptance (the maintainer's, as it stands after that decision):** the pain screens make no diagnosis and no claim that core work protects the back.

**Out of scope:** the health check at plan setup ([FNS-007](../plan-setup-and-screening/requirements.md)); progression from the log (feature 5); the after-workout check; any message to another person.

## Authorization, privacy and data ownership

- **Private (the maintainer's rule):** "Injuries, symptoms, pain reports, body measurements and screening answers are private. They stay on the device unless I decide otherwise, and must never appear in group queries or scoreboards."
- **What is kept:** the check-in answers for a session; whether he took the lighter session; that Stop · Pain was tapped, on which lift and when. **Not kept:** where it hurt, a description, a severity.
- **Where.** On the device only (decision Q8's pattern). No shared document, score, log line or analytics event. A skipped lift or a rest day taken for pain looks, to anyone else, like any other skipped lift or rest day.
- **Scoring.** BLOCKED: whether a day marked as rest for pain, or a workout ended by Stop · Pain, counts for or against anything scored. Nothing is assumed.
- **Negative tests:** no check-in answer and no pain report reaches a group query, a board, a log line or a crash report.

**Unknown, so not approved. BLOCKED on the maintainer:**

1. **"Several signals."** How many poor answers trigger the suggestion. Pilot default not yet set.
2. **"Several sessions."** The mockup says three. That number is this draft's.
3. **How much lighter.** The mockup shows one fewer set per lift and three or more reps left. The prompt gives ranges (25 to 40 percent, 1 to 2 RPE); the exact rule is not set.
4. **"A little" pain.** Whether it is treated as pain (rest), as a poor signal (lighter), or asks one more question. Under the governing rule this draft would treat it as pain until told otherwise.
5. **"Comparable sessions."** What makes two sessions comparable for the performance check.
6. **After Stop · Pain.** The first mockup dropped later lifts that load the same area and asked about it at the next check-in. With no location stored, neither is possible. Confirm that the rest of the session simply continues as written when he chooses to carry on.
7. **An emergency.** With the emergency wording removed, the app says nothing specific about chest pain or fainting during a workout. Confirm that is intended.
8. **The pilot's adverse-event gate.** The reviewer's gate is that every adverse event is reviewed before expansion. Pain reports that never leave the phone cannot be reviewed. How the maintainer learns of them (a manual export, or asking the men) is not decided.
9. **Target and order.** As in FNS-007: prototype first, then Flutter, proposed and not decided.
10. **The Flutter workout contract.** [FNS-004](../workout-logging/feature.md) says "The app stores and asks for nothing about his body". This feature changes that and needs FNS-004 amended in the pull request that builds it.

## Failure, offline and migration behavior

- **Everything is local**, so it works the same with no network.
- **He skips the check:** the workout is as written. Skipping is not a poor signal.
- **No log yet** (a new man): the performance line is left out; the other four answers still work.
- **A save fails:** the workout still opens as written, and the screen says the check was not saved. A failed save never hides the pain screen.
- **He taps Stop · Pain by mistake:** "Skip this lift and carry on" is not the only way back. BLOCKED: whether there is a plain Back that records nothing.
- **Accessibility:** Stop · Pain is reachable with one tap and by a screen reader on every lift; its colour is not its only signal.
- **Rollback:** removing the feature leaves workouts as written and deletes the stored answers.

## Evidence and traceability

- Maintainer's prompt and session of 2026-11-24; the mockup "Feature 2 · Pre-session check-in and pain flow", version 2 (five screens), was shown in that session and is not in the repository.
- Decision Q8 on the [Decisions](../../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md) page.
- Baseline: `main` at 49104c9.
- Checks run: none. NOT VERIFIED: everything in this file is intent.
