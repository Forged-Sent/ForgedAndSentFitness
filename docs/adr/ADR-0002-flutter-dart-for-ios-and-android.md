---
id: ADR-0002
title: "Flutter/Dart for iOS and Android"
status: Accepted
date: 2026-10-27
relations: ""
requirements: "FS-QLT-001..004"
---
# ADR-0002: Flutter/Dart for iOS and Android

**Status:** Accepted

## Context
Approved product direction (2026-10-27).

## Decision
Single Flutter codebase, stable channel, flavors `dev|staging|prod`, Riverpod for state/DI, go_router, freezed/json_serializable, Drift for local persistence (see ADR-0006).

## Alternatives considered
React Native/Expo (review fallback), KMP, native. Not pursued per approval.

## Consequences
+ One UI engine, strong offline tooling, `health` plugin for HealthKit/Health Connect. − No code sharing with a web console.

## Requirements and verification
Requirements: FS-QLT-001..004. Verification: `flutter analyze` (zero warnings), `flutter test`, integration tests on CI.
