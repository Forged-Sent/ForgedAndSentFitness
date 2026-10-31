# Start here: Flutter + GitHub agents foundation

## Baseline
This branch introduces an intentionally small Flutter scaffold and CI, **not a production app**. Existing `index.html` and `seed/` are the functional reference. Repo main was v182 when this work started.

## Guided Windows and MacBook setup

On Windows use FIRST-RUN-WINDOWS.cmd. On a MacBook use FIRST-RUN-MAC.command. Both provide a safe Flutter browser Preview and developer tool setup, without Firebase cloud MCP or login. See docs/development/MACBOOK-QUICKSTART.md for Mac prerequisites. Full iOS/Android device tooling is PR #4.

## Branches, pull requests and reviews

- Every contributor works on a short-lived branch and opens a pull request
  to `main`. Do not commit or merge directly to the default branch.
- Prototype-only UI and content changes need passing `ci-gate` but no
  mandatory human approval by default. Run `python3 dev/make_preview.py`
  and inspect the generated HTML locally.
- Flutter and security-sensitive changes need careful independent review; high-risk Auth/privacy/rules/scoring changes warrant another human. The live ruleset currently requires `ci-gate` but ZERO human approvals.
- Agents use the repository root `AGENTS.md`, Claude `CLAUDE.md`, and
  matching path instructions. Agent reviews are advisory only.
- The ruleset is active; human-approval enforcement depends on its minimum approvals. See `docs/development/REPOSITORY-SECURITY.md` and verify live values before merge.

## Local setup
Install the stable Flutter SDK and run:

```bash
cd mobile
flutter create --platforms=web --org=com.forgedandsent --project-name=forged_and_sent .
flutter pub get
flutter analyze
flutter test
flutter run
```

`flutter create` is an interim bootstrap because generated native Android/iOS platform folders are not part of this initial PR. Commit reviewed platform projects in a dedicated follow-up PR once package IDs, signing approach and Xcode minimum are agreed. iOS compilation requires macOS/Xcode; Android and Dart tests run on Linux.

## Collaboration
- Each developer clones the public repo, uses their own workstation, opens a branch and PR.
- GitHub Actions performs free public-repository standard-runner CI for Flutter (Android) when enabled.
- The repo owner enables paid Copilot cloud agents and Claude/Codex partner agents through GitHub account/repository settings if available. Merely adding .agent.md files does not provision those subscriptions.
- An independent Claude Code GitHub Action or Codex GitHub Action requires its own credentials and model billing. None are activated by this PR.
- Standard GitHub runners are free for public repos; large runners, excessive artifact/cache storage, cloud services and AI use are separate costs.
- Remote app testing comes later via a Firebase DEV project and signed Android/iOS test distributions. No developer-owned Linux server is required.

## Architecture starting point
- Mobile: Flutter feature-first architecture with UI, domain/application services, repositories and adapters.
- Firebase: preferred backend, not yet connected. Establish separate DEV and PROD projects; STAGING can be added at release hardening.
- Auth and Firestore/Storage access must be deny-by-default with emulator tests before use.
- Offline workouts need a local durable database, outbox and upload lifecycle in a follow-up slice.
- Faith content can be before/after/during safe rest periods or elsewhere in the day; private reflections stay private.
- Teams and challenges run through versioned server-controlled scoring rules.
- Youth/family features are future domain work, not enabled in adult pilot.

## First implementation issues
1. Generate and commit reviewed Android/iOS host projects; verify Android CI.
2. Choose local persistence and state management via a short ADR (e.g. Drift + Riverpod, alternatives considered).
3. Implement one offline devotional-workout screen with a fake repository, then add durable local storage.
4. Configure Firebase DEV and Auth + group membership; add cross-group security rule tests before live data.
5. Add integration/test distribution after sign-in and the vertical slice are working.

## Security
This is a public repo. Never commit API secrets, signing credentials, real prayers, health data, member records or test media. Be especially cautious before running AI agents on external PRs or user input. Keep workflow permissions read-only by default.

For Android host compilation, CI temporarily generates Android platform files; Xcode/iOS provisioning and reviewed native projects are PR #4. Preview contributors generate only the web host.

## Architecture and optional local AI review

- [SYSTEM.md](../architecture/SYSTEM.md): living Mermaid design, current vs planned.
- [CODE-MAP.md](../architecture/CODE-MAP.md): generated Dart file/function inventory; refresh with `python3 tooling/architecture/generate.py --write`.
- [AI-REVIEW-WORKFLOW.md](AI-REVIEW-WORKFLOW.md): Windows/Mac setup for independent Codex/Claude/Gemini reviews, optional pre-push verification, costs and limitations.

## Visual architecture Explorer

To understand all tracked files and the current/planned architecture, open the [Architecture Atlas guide](../architecture/explorer/README.md). Windows: `ARCHITECTURE-WINDOWS.cmd`; Mac: `ARCHITECTURE-MAC.command`. Click any system node or source function to see its responsibilities, owning file, dependencies and exact source line. Use `/` for search and `?` for hotkeys. New design boundaries require updates to `docs/architecture/SYSTEM.md` and `docs/architecture/explorer/model.json`.
