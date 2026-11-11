---
name: flutter-vertical-slice
description: Build or change one Flutter feature end to end, with view, view model, repository, durable local storage and tests. Use for any feature work under mobile/.
---
# Flutter vertical slice
1. Read AGENTS.md, mobile/AGENTS.md, ADR-0005 (Riverpod, go_router, Drift), the task's prompt or feature contract, and your row in docs/knowledge/WORK.md. Check docs/architecture/CODE-MAP.md rather than assuming planned components exist.
2. State the user-visible outcome, one failure state, and one privacy or offline boundary before coding. If a product decision the task needs is still TODO in the decisions page, stop and ask.
3. Use a view and a Riverpod view model for the UI layer and a repository for data. Add a domain use case only when logic spans repositories or is reused.
4. Pass data through immutable state and one-way events. Widgets and view models never import Firebase SDK classes; keep SDK calls in data adapters.
5. Persist a user action as a local event with a client-generated id, in the same Drift transaction as the state derived from it, before showing it as saved. Do not treat the Firebase cache as durable storage.
6. Keep private prayer, reflection, nutrition and body data out of shared documents and logs. Never compute competition scores in the client. No PROD credentials and no cloud fallback.
7. Add unit tests for rules and repositories, a close-and-reopen test for anything saved, and widget tests for success, failure and one boundary case.
8. Run the formatter, analyzer, tests and `python3 tooling/architecture/generate.py --write`. In the same pull request, update your WORK.md row and every page listed under "Docs are part of done" in AGENTS.md, then run `python3 tooling/knowledge/live_status.py --pull`. List what ran and what is NOT VERIFIED. Never push or merge on your own.
Reference: https://docs.flutter.dev/app-architecture/recommendations and https://docs.flutter.dev/app-architecture/design-patterns/offline-first
