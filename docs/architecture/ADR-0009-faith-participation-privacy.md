# ADR-0009: Faith participation and privacy

- Status: **Accepted** on 2026-10-27 (Phase 0); carried forward by decision Q4. **Planned: no server part is built.**
- Date: 2026-10-27. Brought to `main` and renumbered on 2026-11-19.
- Decision owner: project maintainer (answer Q4 on the [Decisions](../reviews/2026-11-10-prototype-to-flutter/01-DECISIONS.md) page)

## Where this record comes from

This is **Phase 0 ADR-0012**, "Faith participation and privacy", from branch `arch/firebase-reconciliation` (commit `0d21d21`, file `docs/adr/ADR-0012-faith-participation-and-privacy.md`). It is renumbered so that the four records Q4 carries forward sit together after `main`'s ADR-0005.

The five sections from **Context** to **Requirements and verification** are the Phase 0 text, word for word. The sections after them are new and say how the record stands on `main`. The table of old and new numbers is in [ADR-0006](ADR-0006-group-level-isolation.md).

## Context

Approved: never score content or perceived quality of prayers or reflections; personal prayers, confessions and reflections private unless explicitly shared; faith participation weights open.

## Decision

Journals (`users/{uid}/journal`) are owner-only; no leader, admin-client or Function reads for scoring. Faith participation may emit boolean facts (stage completed) only; weights and caps per ruleset (OD-01). Sharing is an explicit per-item action creating a separate shared document; revocable. Push payloads carry no private text.

## Alternatives considered

No faith points at all (Blueprint D09).

## Consequences

+ Honors integration without surveillance. − Weights need pastoral input.

## Requirements and verification

Requirements: FS-PRV-001..006, FS-CMP-012. Verification: Leader-cannot-read-journal test; ruleset schema bans journal-field inputs.

## How this stands on `main`

Later answers on the Decisions page narrow this record. Where they differ from the Phase 0 text above, the later answer is the rule.

- **Q8: the journal stays on the phone for the pilot.** It is device-only with a manual export, designed so that encrypted sync can be added later. So the path `users/{uid}/journal` is not used in the pilot, and no journal text is sent anywhere.
- **Q2: faith points are never shown per man.** They count toward his team's total only. They are not on the individual ranking and not in the expanded team view. A man sees his own. Q2 says it updates the 2026-10-27 direction (matrix D24 and D09).
- **Q3: fasting** is private by default, has an explicit "ask the brothers to pray" action, and earns no points.
- **Open: a team where one man earned the faith points.** If a team total includes faith points and only one man on the team earned any, the total shows his. Neither Q2 nor the Phase 0 text says what happens then. The contract for groups and the board must answer it, with a test for a viewer looking at such a team, before a board is built.
- **Weights and caps are still open.** `OD-01` is an open decision in `docs/requirements/open-decisions.md` on the Phase 0 branch. No weight is approved by this record.
- **The requirement ids and "Blueprint D09" are not on `main`.** The ids are in `docs/requirements/` on the Phase 0 branch. D09 is a row of the 2026-10-27 reconciliation matrix (`docs/architecture/00-reconciliation-matrix.md` on that branch).
- **Nothing on the server is built.** There is no rule, no rule set schema, no sharing action and no push message. The two checks named above have not been written or run.
- Agrees with the standing rules in `AGENTS.md`: private prayers and reflections never appear in group queries, and nothing scores the quality of a man's spiritual life.
