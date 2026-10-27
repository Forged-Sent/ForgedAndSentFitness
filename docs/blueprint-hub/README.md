# Blueprint discussion page: source

The published shared page (claude.ai artifact "Forged & Sent Blueprint") is built from these files.

| File | Purpose |
|---|---|
| `decisions.js` | D01–D35 content, plus `RECON` (the 27 Oct reconciliation per decision) and the glossary |
| `template.html` | Page layout, styles and runtime script, with `{{DECISIONS_JS}}` / `{{DIAGRAM2:name}}` placeholders |
| `index.html` | The assembled page as published (diagrams from `docs/diagrams/` inlined) |

**Shared data** (votes, notes, suggestions and recorded outcomes) lives in the artifact's database, not in this repository. The page has an "Export everything (JSON)" button.

On 2026-10-27 the database held **no votes, notes, outcomes or comments**. The reconciliation therefore preserved all decision ids (D01–D35) and every pre-existing option key, so any later votes stay valid.

To change decisions, edit `decisions.js` (keep ids and existing option keys), reassemble, then republish through Claude.
