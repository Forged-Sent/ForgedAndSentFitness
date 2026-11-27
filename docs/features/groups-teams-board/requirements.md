---
kind: feature-spec
feature_id: FNS-006
status: proposed
risk: high
owner: maintainer
source_ref: claude/s4a-contract
source_sha: 1c1339b25dad47a5760ea7b7eb4ab12fb260c4c4
approved_by: none
test_plan: not written, this is a stub that holds the parked questions until S4a is merged
verified_tests: none
implementation_paths: none
verification: none
---

# S4b: groups, teams, scoring and the first board (stub)

The second half of build step S4. **This is a stub, not a contract to approve.** It holds the questions and constraints that were moved out of [S4a](../sign-in-own-data-sync/requirements.md) on 2026-11-19, so that none is lost. Nothing in it is designed, approved or built.

Companion pages, both stubs: [design](design.md) and [tasks](tasks.md).

> [!IMPORTANT] Parked until S4a is merged
> The maintainer moved every question below to S4b and said not to ask them again until S4a is merged. An agent that reads this page does not raise them before then.

## What S4b is

Groups, teams, scoring and the board: a man joins a group, the server turns his events into points, and he sees a board for his group that the server computed. It starts after S4a is merged, with its own contract, written then.

## What is already decided for it

| Decision | The answer |
|---|---|
| Q2, the board | "Team board is the default view. A selector on the Board switches to an individual ranking of the men in his own group. Each man can hide himself from the individual ranking in Settings; he still counts toward his team. Expanding a team shows each man's total, not a per-category breakdown. Devotional (faith) points count toward the team total only and are never shown per man: not on the individual ranking and not in the expanded team view. A man sees his own." |
| Q3, fasting | "Private by default, an explicit 'ask the brothers to pray' action, no points." |
| Q4, the four Phase 0 decisions | Group isolation, the scoring ledger, membership-document authorization and faith-participation privacy. On `main` they are ADR-0006 to ADR-0009 once pull request #80 merges |
| ADR-0008, membership documents authorize | It stays Proposed until S4b starts (decided 2026-11-19). Whether it becomes Accepted is one of the first things S4b settles |
| Q5, points on screen | Hidden until server scoring exists |
| The ordering rule | R2, decided 2026-11-19; see S4a |
| Standing rules | Group and role authorization is enforced server-side. Scoreboards are server-authoritative. No scoring of spiritual quality and no points for eating less (`AGENTS.md`) |

## Parked questions

Each is undecided. The numbers are the ones the earlier single draft used, so nothing that cites "B3" changes meaning. B1, B9, B10, B14, B15 and B19 were answered on 2026-11-19 and are in S4a.

| # | Question for the maintainer | What it blocks | A default the earlier draft offered (not a decision) |
|---|---|---|---|
| **B2** | **What is the official rule set, version 1?** Which boxes score, how many points each, and any caps. Q5 calls the prototype's values "preview, not official" | The scoring step, every number on the board, and whether the preview switch (Q5) stays | None |
| **B3** | **What is a team?** Who makes teams inside a group, who puts a man on one, how many men, may a man be on none, may he change. Q2 assumes teams. The Phase 0 branch described them in its own ADR-0009, which Q4 does not carry forward and which is not `main`'s ADR-0009 | The team board, which is Q2's default view | None |
| **B4** | **How is a team's total computed when teams differ in size?** A sum favors the larger team | The team total | None |
| **B5** | **Roles.** The sign-in design names a group owner who can remove a man. What else may an owner do or see, and is there any other role? May an owner see a man's faith participation? | The role on the membership document and any owner-only rule | Owner can remove a member and nothing more; he sees exactly what a member sees |
| **B6** | **How does a man get into a group, and out?** Invite code, link, or added by the owner. Who creates a group. May a man be in more than one group. When he leaves or is removed, do his past points stay in his team's total | The join flow, the Function that writes membership, and what the board shows for a past member | None |
| **B7** | **How late may an event arrive and still count, and how far may its claimed local date be from the time the server receives it?** The date is the phone's (Q9) and a phone's clock can be set | The scoring step's validation. S4a stores events of any date | None |
| **B8** | **Where does "ask the brothers to pray" for a fast go?** Who sees the request, what it says, can he withdraw it | Only the ask action | Leave the action for the step that builds Rally |
| **B11** | **Does "hide me from the individual ranking" also hide his total when a team is expanded?** | What the server writes for a hidden man | None |
| **B12** | **Faith points can be worked out.** A team's total includes faith points; each man's shown total does not. On a small team the difference gives a man's faith points away. They can also be worked out from two totals taken at different times, or from a total together with visible individual scores, even when several men contributed | Whether Q2's "never shown per man" holds in practice | None |
| **B13** | **Which boxes are "faith"?** Is the devotional the only one | Which points are kept out of per-man totals | Devotional only, as Q2's wording says |
| **B16** | **Which terms text and version does the app show**, and must an email address be verified before a man can join a group or have events counted | The agreement text; one validation step. S4a shows a marked placeholder | Verified email before joining a group |
| **B17** | **What do members see of each other?** Display name only, or a picture too | The membership document's fields | Display name only |
| **B18** | **What period does the board cover?** Today, this week, a season, all time. When does a week start, and in whose time zone | The standings documents and when totals stop changing | None |
| **B20** | **Do events sent before scoring exists earn points when it arrives?** S4a puts events on a man's account for weeks before anything scores them. New with the split | Whether scoring starts from a date or from each man's first event | None |

## Constraints the S4b contract must meet

These come from the reviews of the earlier single draft and of the Phase 0 records. They are requirements on a design that does not exist yet.

1. **Nothing about one man that a peer can read may change when he does something private.** This covers per-man documents and any other signal tied to one man. The earlier draft put each man's ledger revision in the standings documents; a peer who saw it move, while the man's shown total did not, learned he had done something private. Revisions stay in server-only data. A team total does change when a man earns faith points, as Q2 says it must; publishing it depends on B12 being answered and on the tests in constraint 7.
2. **Standings are tied to the roster they were computed from.** A calculation that started before a removal or a team change must not publish the old roster afterwards.
3. **Membership is confirmed by the server before any board data is shown.** A removed member who stays signed in and offline must not be shown group data kept on his phone. Removing the membership document stops later server reads; it does not remove what a phone already holds.
4. **"Counted" is written only after scoring has committed**, and the phone has a name for every state the server can write for an event.
5. **A man's events stay under his own path.** They do not move under a group, and no group query returns them.
6. **Scoring runs rule R2's check itself** before it gives credit. S4a's server stores chain lengths without checking them.
7. **Faith points cannot be worked out by a peer** (B12), with tests for a team where one man earned them, for two totals taken at different times, and for a total combined with visible individual scores.

## Evidence and traceability

- **Baseline:** `main` at `1c1339b25dad47a5760ea7b7eb4ab12fb260c4c4`.
- **Decisions:** [Decisions page](../../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md), rows Q2, Q3, Q4, Q5. The split into S4a and S4b was decided in conversation on 2026-11-19 and is not on that page yet.
- **Prompts:** [P08](../../reviews/2026-11-10-prototype-to-flutter/prompts/P08-S4-contract-identity-groups-board.md) and [P09](../../reviews/2026-11-10-prototype-to-flutter/prompts/P09-S4-implement-identity-groups-board.md) were written for one S4 and have not been rewritten for the split.
- **Prototype:** not used as a source of rules.
- **Checks actually run:** `python3 tooling/knowledge/check.py` only.
