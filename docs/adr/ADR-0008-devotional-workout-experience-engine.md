---
id: ADR-0008
title: "Devotional Workout Experience Engine"
status: Accepted
date: 2026-10-27
relations: ""
requirements: "FS-DWE-001..010"
---
# ADR-0008: Devotional Workout Experience Engine

**Status:** Accepted

## Context
Approved: faith and training are integrated with user-chosen timing (before, after, during rest, split day, single-mode); never require reading or typing during exertion; private reflections stay private.

## Decision
A pure-Dart engine (`packages/fs_domain/experience`) driven by versioned Experience Templates (ordered stages with content refs, anchors, safety contexts, completion criteria) and a per-user Experience Plan. Each day materializes an Experience Run whose stage states persist locally and sync. Re-planning (changing timing) affects only incomplete stages. Rest prompts appear only during rest with ≥ 20 s remaining, are dismissible, never block timers and have no text input.

## Alternatives considered
Hard-code flows in UI navigation (untestable, loses progress on change).

## Consequences
+ Testable, extensible, safety-enforced. − Template authoring tool needed later.

## Requirements and verification
Requirements: FS-DWE-001..010. Verification: Engine unit tests incl. timing-change-preserves-progress; widget test: no input fields in rest prompts.
