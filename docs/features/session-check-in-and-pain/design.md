# Pre-session check-in and pain flow: design (proposed)

Canonical metadata: [requirements](requirements.md) (FNS-008). Not approved; nothing is built.

## Data

| Record | Holds | Sensitivity |
|---|---|---|
| Check-in | session, sleep, soreness, pain answer, drive, whether skipped, which session he chose (as written, lighter, rest) | Health-related; device only |
| Stop event | session, lift, time, his choice (skip or end) | Health-related; device only |

No free text, no body area, no severity. The lighter session is derived from the prescription when it is shown; the written prescription is never changed.

## Rules

Pure functions, tested without a screen:

- **Pain yes** gives the rest screen. Nothing else is evaluated.
- **Poor signals at or over the threshold, or a performance drop** gives the lighter suggestion.
- **Otherwise** the session is as written.
- **Lighter session:** sets and target effort reduced inside the maintainer's ranges; never raised; never below one set.
- **Stop · Pain:** the only outcomes are skip this lift or end the workout. The alternates list is not opened from this screen.

Every threshold is a named pilot default in one place, so the pilot can change it without touching the rules.

## Trust boundaries

Everything is on the device. A leader or brother sees only what he would see for any skipped lift or rest day. A later sync must leave both records out unless the maintainer decides otherwise.

## Why this shape

The maintainer's decision of 2026-11-24: the app tells him to stop and points him to his doctor, and does not sort symptoms. So the pain screens carry no lists and collect nothing beyond the fact of the tap.
