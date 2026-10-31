# Flutter application agent rules

Read the repository root `AGENTS.md` and accepted architecture ADRs before editing.

- Work only on a focused Flutter vertical slice in `mobile/` unless the issue explicitly calls for cross-cutting changes.
- Treat the prototype (`index.html` and `seed/`) as a behavioral reference, not production code or a backend authority.
- Keep domain and application logic independent from Flutter UI and Firebase SDK types.
- Preserve durable offline workout and devotional events, idempotency, group isolation, and private user data boundaries.
- Do not add real Firebase credentials, production deployment, cloud MCP access, or automatic `flutterfire configure`.
- Tests are required for new behavior. Run `flutter analyze` and `flutter test`; document any platform build that was not run.
- Run independent Flutter architecture reviews and request a human reviewer for sensitive Auth/privacy/rules/scoring changes. The current live ruleset does not require human approval, so do not claim it does. Never merge, approve, or bypass rules as an agent. Keep SYSTEM.md current and regenerate CODE-MAP.md for Dart changes.
