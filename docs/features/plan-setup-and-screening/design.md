# Plan setup and health screening: design (proposed)

Canonical metadata: [requirements](requirements.md) (FNS-007). Not approved; nothing is built.

## Data

Two records, kept apart so the sensitive one can be handled on its own.

| Record | Holds | Sensitivity |
|---|---|---|
| Plan settings | goal, history, consistency, level, days, session time, rest day, lifting days, equipment inventory, impact choice, program, Foundation choice, plan start | Plan data; private to him, not health data |
| Screening | each red-flag answer, the body areas to work around, whether plan building is stopped, when he last answered | Health-related; device only, never shared, scored or logged |

Field names for equipment and body areas come from `seed/` once the library branch lands. They are not invented here.

## Rules

- **Level suggestion.** From history and consistency. When the answers disagree or are missing, the lower level is suggested.
- **Red flag.** Any yes stops the build. There is no weighting and no partial plan.
- **Matching.** A movement is offered only when every item it needs is ticked and no selected body area excludes it. When no movement fits a pattern, the pattern is reported as missing; the app does not substitute a different pattern silently.
- **Beginner.** No prescription with a single above RPE 7 reaches a beginner, whatever the program.

All four are pure functions of the answers and the seed, so they can be tested without a screen.

## Trust boundaries

Everything is on the device. Nothing here is read by another member, a leader or a server. A later sync (decision Q8 asks that one stay possible) must leave the screening record out unless the maintainer decides otherwise.

## Options still open

Foundation as a separate block or as level modifiers; the health screen; the fate of heavy singles. Each is listed BLOCKED in the requirements. The data shape above does not depend on any of the three.

## Targets

One contract, two builds. Proposed order: the prototype, then Flutter as its own slice. Neither build takes a rule from the other; both take them from this page.
