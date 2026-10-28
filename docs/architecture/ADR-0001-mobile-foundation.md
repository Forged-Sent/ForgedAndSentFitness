# ADR-0001: Flutter mobile app, Firebase backend, independent developer environments

- Status: Accepted product direction; implementation pending
- Date: 2026-10-27

## Decision
Use Flutter/Dart for iOS and Android, with feature-first modular presentation, application/domain code, and typed repository interfaces. Prefer managed Firebase (Auth, Firestore, Cloud Functions, Storage). Keep local emulators optional; both developers and their test devices must work independently without access to a particular home server.

## Context and consequences
The legacy Claude Artifact is a functional prototype, not reusable mobile infrastructure. Firebase provides managed scaling, but does not automatically guarantee efficient data models, tamper-resistant scoring, or offline media recovery. The Flutter SDK and firebase deployments must be validated separately. No cloud resources are provisioned by this ADR.

## Guardrails
Separate DEV/PROD; deny-by-default rules; server authoritative competition; no unrestricted private data access; local durable workout events; no family/youth account features enabled without additional design.
