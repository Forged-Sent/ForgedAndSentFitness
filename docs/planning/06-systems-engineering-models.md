# 06 · Systems engineering models worth maintaining

**Rule:** keep a model only if it answers a question someone will actually ask, and update it in the same PR as the change that invalidates it. Everything is plain text in the repo (YAML, Markdown, Mermaid), so both developers and both AI tools can read and edit it. **No MBSE tool:** a Cameo or Capella model would be a second source of truth that only one of us can edit.

## The models

| # | Model | Notation | File(s) | Question it answers | Update when | Checked by |
|---|---|---|---|---|---|---|
| 1 | Stakeholder needs and goals | Table | `01-product-architecture-brief.md` §1–3, §5 | Why does this exist; for whom; what's out? | Owners change scope | Review |
| 2 | Owner decisions | YAML | `docs/planning/decision-log.yaml` | What did we decide, who decided, why? | Every hub ruling | `validate_architecture.py` (schema, links) |
| 3 | ADRs | Markdown | `docs/adr/` | Why is the architecture this way? | Architecture, data-contract, security or long-term behavior decisions | Validator (status, supersession) |
| 4 | System requirements | YAML (`FS-*`), SysML-style `«requirement»` with `verify` | `docs/requirements/requirements.yaml` | What shall the system do; how do we verify it? | New behavior or acceptance change | Validator (every FS has a TC; ids unique) |
| 5 | Verification plan | YAML (`TC-*`) | `docs/requirements/test-catalog.yaml` | Which test proves which requirement? | New FS or test | Validator; tests named with TC ids |
| 6 | Functional decomposition | Mermaid flowchart | `diagrams/15-product-domains.mmd` | Which domain owns a capability; what facts flow between domains? | A new domain or fact type | Render in CI |
| 7 | System context (C4 L1) | Mermaid | `diagrams/01-system-context.mmd` | Which external systems and actors exist? | New integration (provider, store, health) | Render |
| 8 | Containers and components (C4 L2/L3) | Mermaid | `diagrams/02-component-architecture.mmd` + `docs/architecture/01-system-architecture.md` §2–3 | Which module owns what; the dependency rule? | A new module or a changed boundary | architecture-reviewer |
| 9 | Deployment | Mermaid | `diagrams/03-deployment.mmd` | Environments, projects, CI/CD paths | New environment or lane | Render |
| 10 | Domain and data model | Mermaid class + ER | `diagrams/04-domain-model.mmd`, `05-data-relationships.mmd`, `16-community-hierarchy.mmd`; `docs/architecture/02-data-architecture-firestore.md` | Entities, ownership, paths, who may write | Any collection or field change (protected zone) | Rules tests |
| 11 | Access model | Mermaid | `diagrams/06-group-role-access.mmd` | Who can see what? | Roles or audiences change | Rules test matrix |
| 12 | Key behaviors | UML state machines and sequences | `07`, `08`, `09`, `10`, `11`, `12`, `13`, `14`, `17` | How do the risky flows work (engine, offline, proof, scoring, content, planning)? | The flow's logic changes | Golden tests / property tests |
| 13 | Interfaces | JSON Schema + golden fixtures | `contracts/` | What exactly crosses the client–server boundary? | Any payload change (protected zone) | Schema validation in Dart and TS tests |

## Traceability chain

```text
Need (brief §1–5) ─► Owner decision (DEC-#### in decision-log.yaml)
                       └─► ADR-#### (if architectural) ─► FS-* requirement ─► TC-* test ─► PR (feat/FS-…)
```

- `tools/validate_architecture.py` enforces the links that can be checked mechanically:
  - FS → TC.
  - ADR references resolve.
  - DEC entries of kind `architecture`, `data-contract` or `security` cite an ADR.
  - DEC entries with status `implemented` cite a PR.
- A PR that implements an FS id must name it in the branch and the title (AGENTS.md).

## What I deliberately did not include

- **SysML block definition and internal block diagrams:** the C4 component view plus the dependency rule carry the same information for a two-person app.
- **Formal parametric models:** the cost model is a Python script (`evidence/firebase_cost_model.py`), which is runnable and diffable.
- **A requirements tool (Polarion, DOORS):** YAML plus the validator gives ids, links and CI checks without licenses or a second UI.
