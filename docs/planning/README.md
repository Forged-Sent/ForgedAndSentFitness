# docs/planning: product and planning package

Start with `00-executive-assessment.md`. The **binding** owner decisions are in `decision-log.yaml` (protected: both owners approve changes, agents never edit it).

| File | Contents |
|---|---|
| `00-executive-assessment.md` | Bottom line, scorecard against your priorities, scope cautions |
| `01-product-architecture-brief.md` | Mission, audience, boundaries, five domains, journeys, community hierarchy, proposed training requirements |
| `02-decision-register.md` | Approved / Recommended / Open / Challenged / Deferred |
| `03-decision-workshop.md` | W01–W12 owner decisions with defaults; engineering decisions recommended outright |
| `04-staged-growth.md` | Stages 1–3: what to build, costs, bottlenecks, what not to build |
| `05-mvp-roadmap-milestones.md` | MVP, feature tiers, milestones M1–M5 |
| `06-systems-engineering-models.md` | Which models to keep, and when to update them |
| `07-engineering-collaboration-plan.md` | Repo, reviews, CI/CD, releases, what must be final before agents work alone |
| `08-agent-and-skill-architecture.md` | Active agent set per milestone, deterministic gates, decision guard |
| `09-planning-hub-spec.md` | Collaborative Planning Hub specification (ADR-0020, Proposed) |
| `decision-log.yaml` | DEC-#### owner decisions (schema `fs-decision-log/1`) |
| `hub-snapshots/` | Committed Planning Hub exports (created by `tools/planning/import_hub_export.py`) |
