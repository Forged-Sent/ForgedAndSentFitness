# ADR-0002: Emulator-first development and least-privilege Firebase

Status: Accepted baseline; implementation belongs to PR #4.
Date: 2026-10-28.

## Context
The app stores potentially sensitive fitness, faith and family information. Firebase MCP --dir / --only are not security boundaries; core tools remain exposed and use the Firebase CLI identity.

## Decision
1. Preview/Contributor development defaults to the Firebase Local Emulator Suite and demo-forgedandsent (a demo-* project), without firebase login.
2. No cloud Firebase MCP in default VS Code, Claude or Codex. Maintainer-only DEV opt-in in PR #4 needs independently least-privileged IAM credentials and explicit approval.
3. No production credentials on colleague workstations. Production deployment only through CI workload identity and protected environment human approval.
4. flutterfire configure must never run automatically.
5. App environments emulator/dev/production chosen via --dart-define=FS_ENV=... . Contributor builds contain no production FirebaseOptions.
6. In emulator mode, enforce project ID demo-* at runtime (not only Dart assert); never silently fall back to a real project.
7. Connect Auth, Firestore, Storage emulators before first operation. Web host 127.0.0.1; Android emulator 10.0.2.2; physical device uses explicit host LAN address.
8. Debug-only Android cleartext policy for emulator hosts. Binding emulators to 0.0.0.0 is Mobile-only and opt-in with LAN exposure warning.
9. Test that traffic reaches the local emulators and that an unavailable emulator fails clearly.

## Consequences
PR #3 removes unrestricted Firebase MCP, defines guardrails and verifies no default cloud access. PR #4 implements emulator services, FirebaseOptions, app wiring, tests and maintainer opt-in.

## Security boundary
Restrict users and IAM. Project flags, MCP feature filters and agent instructions alone do not prevent cloud access.
