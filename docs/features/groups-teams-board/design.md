# S4b design: groups, teams, scoring and the first board (stub)

Design page for [FNS-006](requirements.md). **There is no design.** This page exists so the parked work has a place, and so nothing below is mistaken for one.

- S4b is designed after S4a is merged, when the parked questions on the [requirements page](requirements.md#parked-questions) can be asked.
- A design for groups, a scoring Function and the board was drafted on 2026-11-19 as part of one contract for the whole of S4. It was never published. Its review found three High problems, which are constraints 1 to 3 on the requirements page. It is not a starting point to copy.
- What S4a leaves in place for S4b: Firebase Authentication; each man's events at `users/{uid}/events/{eventId}`, create-only, with the fields rule R2 needs; a `functions/` folder; and rules that deny every path outside a man's own, `groups/**` included.
- What S4b must add, at the least: membership documents and the rules that read them (ADR-0006 and ADR-0008 once pull request #80 merges), a scoring Function and ledger (ADR-0007), and board documents that keep faith points out of anything shown per man (ADR-0009, Q2).
