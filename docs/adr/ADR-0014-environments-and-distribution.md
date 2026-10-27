---
id: ADR-0014
title: "Environments and distribution"
status: Accepted
date: 2026-10-27
relations: ""
requirements: "FS-OPS-001..004"
---
# ADR-0014: Environments and distribution

**Status:** Accepted

## Context
Approved: shared cloud dev environments; dev/staging/prod as warranted; emulators optional; no dependency on personal servers.

## Decision
Three Firebase projects: `forged-sent-dev` (shared by both developers), `forged-sent-staging`, `forged-sent-prod` (names illustrative). Flutter flavors map to projects via FlutterFire-generated options. Tester builds via Firebase App Distribution (Android, iOS ad hoc) and TestFlight. Emulators used in CI for rules tests; optional locally.

## Alternatives considered
Single project with prefixes (no isolation).

## Consequences
+ Safe testing. − Three projects to configure.

## Requirements and verification
Requirements: FS-OPS-001..004. Verification: CI deploys rules/functions to dev on merge; staging on tag.
