---
id: ADR-0020
title: "Planning hub: Blueprint page for discussion and voting; GitHub decision log authoritative"
status: Proposed
date: 2026-10-27
relations: "Decides workshop item W12; implements DEC-0013"
requirements: "docs/planning/09-planning-hub-spec.md"
---
# ADR-0020: Planning hub: Blueprint page for discussion and voting; GitHub decision log authoritative

**Status:** Proposed · Decides workshop item W12; implements DEC-0013

## Context
The owners require a shared planning workspace before substantial agent development (DEC-0013): idea submission, advisory voting, discussion, decision alternatives, statuses, owner decisions with rationale, traceability, change history, a dashboard and portable exports. Approved decisions must bind Claude Code and Codex, and agents must never silently reverse them. Collaborators must not need the same AI coding tool. The existing Blueprint page (a claude.ai artifact with a shared database, comments and downloads) already provides voting and comments.

## Decision
Hybrid. The Blueprint page, upgraded to the **Planning Hub** (v4), is the discussion and voting surface: ideas, votes, notes, comments, owner rulings with rationale and links, history, a dashboard and JSON export. **GitHub is the authoritative record:** `docs/planning/decision-log.yaml` (DEC-####), ADRs, requirements, issues (idea, decision, task forms) and PRs. A ruling binds agents only when its decision-log entry is merged with both owners' approval (CODEOWNERS, protected zone). `tools/planning/import_hub_export.py` turns a hub export into decision-log entries and a snapshot in `docs/planning/hub-snapshots/`.

## Alternatives considered
- Blueprint only: no enforceable record for agents; data held in one person's claude.ai account.
- GitHub only: complete and free, but voting and plain-words options are clumsy for non-developers. It remains the fallback if the hub becomes unavailable.
- A custom Firebase portal: a second product to build, secure and maintain; weeks of work before the real app.

## Consequences
+ Usable today; durable, diffable, enforceable record; agent-neutral.
− Two surfaces; an export-and-PR step per batch of rulings; the hub needs claude.ai accounts and Editor invites for outside-organization collaborators.
Revisit if more than about 10 regular participants, if owners need mobile push for votes, or if exports are skipped for more than two weeks.

## Requirements and verification
Requirements: docs/planning/09-planning-hub-spec.md. Verification: `tools/validate_architecture.py` (decision-log schema and links), `tools/check_zones.sh` (decision log protected), and the hub functional check in the spec §8.
