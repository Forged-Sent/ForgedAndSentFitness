# Planning Hub page (formerly "Blueprint"): source

The shared page is the claude.ai artifact **"Forged & Sent Planning Hub"** (same link as the earlier Blueprint). Its specification is `docs/planning/09-planning-hub-spec.md`, and the decision behind it is ADR-0020 (Proposed).

| File | Purpose |
|---|---|
| `index.html` | **Canonical page source, v4, as published** (static content, workshop W01–W12, decisions D01–D35, runtime) |
| `v4-source/workshop.js` | W01–W12 content (option keys are stable; votes reference them) |
| `v4-source/runtime.js` | Page runtime: votes, ideas, owner rulings, per-person history, dashboard, export |
| `v4-source/build_v4.py` | Builds v4 from the v3 page: `python3 build_v4.py v3-source/index.v3.html index.html` |
| `v3-source/` | The v3 page and its earlier template sources (kept for history) |

**Shared data** (votes, notes, ideas, rulings, history, owner list) lives in the artifact's database, not in this repository. The page's **Export everything (JSON)** button produces `fs-planning-hub-export/1`. `tools/planning/import_hub_export.py` merges the owners' rulings into `docs/planning/decision-log.yaml` and commits a full snapshot under `docs/planning/hub-snapshots/`.

Database rules (declared at publish):

- `votes/{self}`, `ideas/{self}`, `log/{self}`: each person writes only their own document. Signed-in viewers read everything.
- `config/owners` and `decisions`: page owner only.

On 2026-10-27 the database held no votes, notes, outcomes or comments, so v4's new data model needed no migration. Every decision id and option key from v3 is preserved.

To change the page: edit `index.html` (or the v4 sources, then rebuild), then republish through Claude to the same artifact link.
