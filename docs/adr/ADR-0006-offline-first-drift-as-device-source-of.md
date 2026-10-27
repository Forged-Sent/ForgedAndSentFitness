---
id: ADR-0006
title: "Offline-first: Drift as device source of truth with an outbox in front of Firestore"
status: Accepted
date: 2026-10-27
relations: ""
requirements: "FS-OFF-001..008"
---
# ADR-0006: Offline-first: Drift as device source of truth with an outbox in front of Firestore

**Status:** Accepted

## Context
Gyms and churches have poor reception; prototype loses workouts. Firestore mobile persistence is on by default (100 MB cache, LRU eviction, last-write-wins) but pending writes are opaque, cached documents can be evicted, and transactions/callables need connectivity.

## Decision
Drift (SQLite) stores in-progress and personal records; every set commits locally before UI confirmation. An outbox drains to Firestore using deterministic document IDs; entries are `acknowledged` only when Firestore reports no pending writes for that document. Firestore's cache serves shared reads (feed, standings). Server-only actions (callables, finalization, review) are queued as intents and shown as pending.

## Alternatives considered
Firestore cache alone (no durable, inspectable outbox; eviction). PowerSync (not applicable to Firestore). Online-only.

## Consequences
+ Crash-safe sessions, inspectable pending work. − Two local stores; ownership per collection documented in `05-offline-sync.md`.

## Requirements and verification
Requirements: FS-OFF-001..008. Verification: Kill-and-restart test; synced-once test; outbox property tests. Library choice Drift is OD-08.
