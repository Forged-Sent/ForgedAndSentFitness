# Legacy characterization fixtures (Phase 0 deliverable, pending)

Each fixture is generated from the frozen prototype (`index.html` @ tag `prototype-v162`) by a Node harness that
evaluates only pure functions (e.g. `parseSets`, `stepBonus`, lift-day `planIndex`). Tag every case:

- `keep`: production must match (e.g., ramp-set parsing, effective-next-week lift days, water threshold).
- `changed-by:<ADR|OD>`: production intentionally differs (e.g., PR points, flat-50 scaled scoring).

No fixtures are committed yet. The harness is task P0-3 in `docs/architecture/11-roadmap.md`.
