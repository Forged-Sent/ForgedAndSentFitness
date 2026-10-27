---
id: ADR-0015
title: "AI-assisted development workflow"
status: Accepted
date: 2026-10-27
relations: "Supersedes review ADR-016"
requirements: "FS-DEV-001..006"
---
# ADR-0015: AI-assisted development workflow

**Status:** Accepted · Supersedes review ADR-016

## Context
Two developers using Claude Code and Codex in parallel risk conflicting edits to schema, rules and contracts.

## Decision
`AGENTS.md` is canonical; `CLAUDE.md` imports it. Specialist catalog in `.claude/agents/`; 2–4 active roles per change. Protected zones (`docs/adr/`, `docs/requirements/`, `contracts/`, `firebase/firestore.rules`, `firebase/storage.rules`, `firebase/firestore.indexes.json`, `functions/src/scoring/`) require label `contract-change`, an ADR reference and two human approvals. Shared skills canonical in `.agents/skills/` and copied to `.claude/skills/` (CI checks drift). No agent merges.

## Alternatives considered
Free-for-all; large concurrent agent teams.

## Consequences
+ Reviewable changes. − Some process overhead.

## Requirements and verification
Requirements: FS-DEV-001..006. Verification: `tools/check_zones.sh`, `tools/validate_architecture.py --skills` in CI.
