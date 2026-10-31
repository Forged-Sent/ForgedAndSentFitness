---
name: flutter-vertical-slice
description: Implement or refactor one Flutter feature with views, view models, repositories, and tests, without mixing Firebase SDK into widgets.
---
# Flutter vertical slice
1. Read AGENTS.md, docs/architecture/SYSTEM.md, the related ADR, and the issue's acceptance criteria. Check the actual code map rather than assuming planned components exist.
2. Define a user-visible outcome, failure state, and one privacy or offline boundary before coding.
3. Use Flutter's UI (view + view model) and data (repository + external service) layers. Add a domain use-case only when cross-repository, reused, or complex logic warrants it.
4. Pass data through immutable state and one-way events. UI widgets never import Firebase SDK classes; isolate client SDK calls in data adapters.
5. For offline workout actions, persist a local event/outbox with an idempotency identifier before reporting durable completion. Do not mistake Firebase cache for a durable outbox.
6. Preserve group authorization and private prayer/reflection boundaries. No score-calculation authority in untrusted Flutter clients. No PROD credentials or implicit Firebase cloud fallback.
7. Add unit tests for state and repositories and widget tests for success, failure, and one boundary case. Update diagram and code map when boundaries or declarations change.
8. Run formatter, analyzer, tests and architecture generator. List what actually ran and what was not verified. Never auto-push or self-merge.
Trusted reference: https://docs.flutter.dev/app-architecture/guide and https://docs.flutter.dev/app-architecture/recommendations
