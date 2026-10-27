---
id: ADR-0016
title: "Crash reporting and diagnostics: Crashlytics with redaction"
status: Proposed
date: 2026-10-27
relations: "Supersedes Blueprint D35 recommendation (Sentry)"
requirements: "FS-OPS-005"
---
# ADR-0016: Crash reporting and diagnostics: Crashlytics with redaction

**Status:** Proposed · Supersedes Blueprint D35 recommendation (Sentry)

## Context
Firebase is the platform; diagnostics must not leak faith, health or food data.

## Decision
Firebase Crashlytics + Cloud Logging. Logging sink redacts journal, prayer, nutrition, health and proof metadata; no custom keys carrying user content. Sentry remains a fallback if Functions tracing needs more.

## Alternatives considered
Sentry.

## Consequences
+ One vendor. − Crashlytics has less server-side tracing.

## Requirements and verification
Requirements: FS-OPS-005. Verification: Redaction unit test; log snapshot review.
