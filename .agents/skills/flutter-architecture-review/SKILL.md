---
name: flutter-architecture-review
description: Independently audit Flutter app boundaries, architecture changes, source dependency diagrams, and ADR compliance.
---
# Flutter architecture review (read-only)
1. Read AGENTS.md, docs/architecture/SYSTEM.md, generated docs/architecture/CODE-MAP.md, and relevant ADRs.
2. Review only the proposed diff and its direct dependencies. Do not edit files, run installers, sign into services, deploy, push, or merge.
3. Check Flutter UI/view-model/repository/service separation, immutable one-way state, lifecycle cleanup, errors, cancellation, and testability. Domain use-cases are optional, not boilerplate.
4. Identify forbidden dependencies (UI to Firebase SDK, domain to platform IO), cross-group leaks, privacy regressions, untrusted scoring, and missing offline idempotency.
5. Compare the actual declared functions/import graph to the diagram, flag missing or inaccurate boundaries, and recommend an ADR when a lasting decision changed.
6. For each finding return path:line, severity, concrete evidence, user impact, and smallest verifiable fix. If evidence is absent say unverified; do not invent files.
7. State tests observed versus recommended. The reviewer is advisory and cannot satisfy GitHub's human approval requirement.
Trusted reference: https://docs.flutter.dev/app-architecture/recommendations
