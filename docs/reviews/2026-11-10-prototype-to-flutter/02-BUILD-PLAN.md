---
title: "Build plan"
updated: 2026-11-10
status: review, not an approved decision record
source_ref: main
source_sha: 94daa63fe1dea96398bcb3f2286baa1906c44ec0
---

[Start here](00-START-HERE.md) · Back: [Decisions (fill in once)](01-DECISIONS.md) · Next: [Agent prompts](03-AGENT-PROMPTS.md)

# Build plan

> [!IMPORTANT] In one minute
> - Merge the native hosts, then build **S0 → S1 → S2 → S3 → S4**.
> - S0 and S1 need no account, group or server.
> - Each step has one prompt and a done-checklist.

## Before S0

- [ ] Answers filled in on the [Decisions](01-DECISIONS.md) page
- [ ] [P12](prompts/P12-let-ci-accept-binary-assets.md) merged: CI accepts reviewed images and fonts
- [ ] [P01](prompts/P01-publish-review-and-record-decisions.md) merged: review, decisions and rules cleanup on `main`
- [ ] [P03](prompts/P03-native-hosts-pr.md) merged: Android and iOS hosts on `main`
- [ ] [P02](prompts/P02-reconcile-prototype-baseline.md) merged, only if Q1 says to reconcile the prototype

## S0 · Design foundation and tab shell

**A man can see:** The app opens looking like Forged & Sent: brand bar, hero header, six-tab bar, light and dark. Other tabs show a titled placeholder.

| | |
|---|---|
| Prompt | [P04](prompts/P04-S0-design-foundation-and-shell.md) |
| Needs answers | Q1 |
| Leave for later | Round action buttons' behavior, help, search |

**Done when**

- [ ] Golden images at 390×844, dark and light, approved side by side with the prototype reference
- [ ] No overflow at 1.3× text
- [ ] Android back from a nested page returns to its tab
- [ ] Each tab keeps its scroll position
- [ ] Analyzer clean, tests green, debug APK builds

## S1 · Today and Devotional, real and saved

**A man can see:** Today shows the date, mission line, ring and boxes. Devotional opens today's real reading. Scroll to the end, tap Amen, the box checks, and it is still checked after the app is killed and reopened.

| | |
|---|---|
| Prompt | [P05](prompts/P05-S1-today-and-devotional.md) |
| Needs answers | Q5, Q6, Q7, Q9, Q10 |
| Leave for later | Points display if Q5 says so, habits, first orders, mission-complete dialog, sync |

**Done when**

- [ ] Complete, kill, relaunch: still complete
- [ ] Replaying the same event id leaves one completion
- [ ] Past midnight, Today is a new day and yesterday counts toward the streak
- [ ] Amen is disabled until the end of the scroll and reachable by a screen reader
- [ ] Other boxes render but are visibly not yet active
- [ ] Nothing is written to Firebase

## S2 · Private journal

**A man can see:** "Write it down" under the devotional saves to a private journal. The Journal page lists, edits and deletes entries.

| | |
|---|---|
| Prompt | [P06](prompts/P06-S2-private-journal.md) |
| Needs answers | Q8 |
| Leave for later | Prayer tabs, tags, search, export, sync |

**Done when**

- [ ] A failed save keeps the text and offers retry
- [ ] Retry never duplicates an entry
- [ ] Entries survive restart
- [ ] A test proves no journal data reaches any Firebase call

## S3 · Workout logging, one program

**A man can see:** Train shows this week. Today's session opens. Prayer, then sets with previous values, rest timer, finish, locked summary. The Workout box on Today checks.

| | |
|---|---|
| Prompt | [P07](prompts/P07-S3-workout-logging.md) |
| Needs answers | Q11, L11 |
| Leave for later | Swaps, add exercise, supersets, PR points, share, image, charts, plan editor |

**Done when**

- [ ] Kill mid-set and relaunch: all sets present, clock correct
- [ ] Finish twice: one completion
- [ ] A session started at 23:50 can be finished at 00:10
- [ ] Changing the plan afterwards does not alter the finished session

## S4 · Sign-in, group membership, first shared board

**A man can see:** Sign in. The local profile is adopted. Completions sync. A server-computed board for his group, as defined by my Q2 answer.

| | |
|---|---|
| Prompt | [P08](prompts/P08-S4-contract-identity-groups-board.md) then [P09](prompts/P09-S4-implement-identity-groups-board.md) |
| Needs answers | Q2, Q3, Q4 |
| Leave for later | Rally, campaigns, challenges and video proof, Fuel, health, owner tools |

**Done when**

- [ ] Rules tests: a member cannot read another group, write another member's events, or write totals
- [ ] Airplane-mode completions appear on the board after reconnect, once
- [ ] A second account on the same phone sees none of the first account's data

## After S4

Follow your staged plan: brotherhood (Rally, with report and block working), then challenges with video proof, then nutrition and health. These steps are not prompted yet.

## 7.1 Is the current sequence sound?

Current order from `WORK.md` and `CURRENT.md`: (1) hosted review gate acceptance, (2) Obsidian pilot, (3) native hosts PR, (4) synthetic Today PR, (5) durable completion (blocked), (6) Firebase DEV and authorization (later).

- Items 1 and 2 ship nothing a man can use.
- Item 3 is right and ready.
- Item 4 is a throwaway by contract. Its 290-line screen and 252-line screen test assert demo copy that must be deleted. What survives is the router, `StartupStatus`, the seam and the test pattern, about a third of it.
- Item 5 is the first real work and has no contract.
- Nothing after item 6 exists.

**Avoidable rework if followed exactly:** the Today screen and its tests, the repository interface, and every screen built before tokens exist.

## 7.2 Prerequisites for the first slice

| Prerequisite | Needed? | Note |
|---|---|---|
| Prototype baseline (Q1) | **Yes** | Today differs between forks |
| Decisions R1, R2, R4 at least for what Today displays (Q2, Q5, Q6) | **Yes** | Whether the row shows "+2 PTS", and what "streak" means |
| Scripture translation (Q7) | **Yes** | Content is bundled |
| Native hosts merged | **Yes** | Drift needs real Android and iOS builds |
| Sign-in, groups, rules, Functions | **No** | Slice 1 is single-user and local |
| An owner id on every row | **Yes, cheaply** | Generate a local profile id on first run and store it with every row. When Firebase Auth arrives, the first sign-in adopts that profile. Ownership is in the schema from day one without building auth |
| Sensitive-data policy (Q8) | **No for slice 1** | Completion events are not sensitive. It gates S2 |

## 7.4 Work to stop or simplify

| Work | Action | Reason |
|---|---|---|
| Hosted AI review gate: PR #48 acceptance matrix, `tooling/review` | **Pause.** Keep `ci-gate` required | It protects 194 lines. Revisit when rules, auth or scoring code exists; run a non-author review by hand on S4 |
| Architecture Atlas, `CODE-MAP.md` generation and its CI check | **Pause** | No value below a few dozen Dart files |
| `CURRENT.md` + `WORK.md` + `PR-STATUS.md` + per-task handoffs | **Collapse** to `WORK.md` plus the PR description | Three snapshots of one open PR |
| Obsidian first-use pilot | **Defer** | Not on the path to a feature |
| Feature-contract metadata (12 front-matter fields, CI validation) for low-risk UI | **Simplify** to the light template: user outcome, acceptance, evidence | Keep the heavy template for auth, rules, scoring, private data |
| ADR-0003 desktop and durable-web scope | **Leave proposed**; stop testing wide layouts | Not in the approved platform priority |
| Unlabelled prototype feature work on a side branch | **Stop the drift,** not the work | Each prototype change lands on `main` with its version file, or is labelled as not yet a requirement |

