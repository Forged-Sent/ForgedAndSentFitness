# Start here: Flutter + GitHub agents foundation

## Baseline
`main` contains an intentionally small Flutter scaffold, beginner setup and CI, **not a production app** (merged in PR #4). Existing `index.html` and `seed/` are the behavioral reference.

## Guided Windows and MacBook setup

**For first-time contributors:** follow [Your first contribution](FIRST-CONTRIBUTION.md) after [Windows quickstart](WINDOWS-QUICKSTART.md) or [Mac quickstart](MACBOOK-QUICKSTART.md). Use an existing **Git clone**, not a ZIP. Check `git status`, then `git switch main`, `git fetch origin`, `git pull --ff-only`. On Windows use `START-WINDOWS.cmd`; on Mac use `START-MAC.command` (or the numbered files in `launchers/<os>/`). Both set up Preview or Contributor tools, including the local practice Firebase, without Firebase cloud login. Android (Windows) and iPhone simulator (Mac) setup are optional extras; device testing still needs manual platform steps. See [Windows quickstart](WINDOWS-QUICKSTART.md) and [Mac quickstart](MACBOOK-QUICKSTART.md).

## Branches, pull requests and reviews

- Every contributor works on a short-lived branch and opens a pull request
  to `main`. Do not commit or merge directly to the default branch.
- Prototype-only UI and content changes need passing `ci-gate` but no
  mandatory human approval, as do Flutter and security changes. Run `python3 dev/make_preview.py`
  and inspect the generated HTML locally.
- Functional Flutter/backend changes follow the [cross-provider AI review gate](FLUTTER-AI-REVIEW-GATE.md), including its staged activation status. Extra local AI reviews remain optional. The existing live protection requires `ci-gate` and zero human approvals; the new gate does not impersonate a human approval.
- Agents use the repository root `AGENTS.md`, Claude `CLAUDE.md`, and
  matching path instructions. Agent reviews are advisory only.
- The existing Protect main ruleset is active; retain required CI and protected-main safeguards. The separate Functional Flutter AI review ruleset remains disabled during hosted acceptance. See `docs/development/REPOSITORY-SECURITY.md` for the solo workflow and live-rule verification.

## Local setup
The accepted client package direction is in [ADR-0005](../architecture/ADR-0005-flutter-client-stack.md). Before adding those packages, align the local Flutter SDK with the CI pin and follow the [Flutter + Claude CLI guide](FLUTTER-CLAUDE-CLI.md).

Install the stable Flutter SDK and run:

```bash
cd mobile
flutter create --platforms=web --org=com.forgedandsent --project-name=forged_and_sent .
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```
For demo Firebase testing, start the three local emulators first and instead run `flutter run -d chrome --dart-define=FS_ENV=emulator`. Browser Preview is not an emulator connection test.

`flutter create` is an interim bootstrap because generated native Android/iOS platform folders are not part of this initial PR. Commit reviewed platform projects in a dedicated follow-up PR once package IDs, signing approach and Xcode minimum are agreed. iOS compilation requires macOS/Xcode; Android and Dart tests run on Linux.

## Collaboration
- Each developer clones the public repo, uses their own workstation, opens a branch and PR.
- GitHub Actions performs free public-repository standard-runner CI for Flutter (Android) when enabled.
- The repo owner enables paid Copilot cloud agents and Claude/Codex partner agents through GitHub account/repository settings if available. Merely adding .agent.md files does not provision those subscriptions.
- The proposed functional review gate uses the owner's Codex GitHub code review and a Claude subscription token in GitHub Actions. It remains disabled until its hosted checks pass; see [the review gate guide](FLUTTER-AI-REVIEW-GATE.md). AI usage can consume subscription limits.
- Standard GitHub runners are free for public repos; large runners, excessive artifact/cache storage, cloud services and AI use are separate costs.
- Remote app testing comes later via a Firebase DEV project and signed Android/iOS test distributions. No developer-owned Linux server is required.

## Architecture starting point
- Mobile: Flutter feature-first architecture with UI, domain/application services, repositories and adapters.
- Firebase: local Auth, Firestore and Storage emulators are connected in the Flutter foundation, but **no Firebase cloud account or project is required for local tests**. DEV/PROD projects, real accounts and deployment are later decisions.
- Auth and Firestore/Storage access must be deny-by-default with emulator tests before use.
- Offline workouts need a local durable database, outbox and upload lifecycle in a follow-up slice.
- Faith content can be before/after/during safe rest periods or elsewhere in the day; private reflections stay private.
- Teams and challenges run through versioned server-controlled scoring rules.
- Youth/family features are future domain work, not enabled in adult pilot.

## First implementation issues
1. Generate and commit reviewed Android/iOS host projects; verify Android CI.
2. Implement the accepted [client stack ADR](../architecture/ADR-0005-flutter-client-stack.md) in a focused PR after toolchain alignment.
3. Implement one offline devotional-workout screen with a fake repository, then add durable local storage.
4. Configure Firebase DEV and Auth + group membership; add cross-group security rule tests before live data.
5. Add integration/test distribution after sign-in and the vertical slice are working.

## Security
This is a public repo. Never commit API secrets, signing credentials, real prayers, health data, member records or test media. Be especially cautious before running AI agents on external PRs or user input. Keep workflow permissions read-only by default.

For Android/iOS compilation, CI temporarily generates the native host files and checks Android debug and unsigned iOS simulator builds. Real signing, full Xcode/Android Studio workstation configuration and reviewed committed native hosts remain future steps. Preview contributors generate only the web host.

## Architecture and optional local AI review

- [SYSTEM.md](../architecture/SYSTEM.md): living Mermaid design, current vs planned.
- [CODE-MAP.md](../architecture/CODE-MAP.md): generated Dart file/function inventory; refresh with `python3 tooling/architecture/generate.py --write`.
- [AI-REVIEW-WORKFLOW.md](AI-REVIEW-WORKFLOW.md): Windows/Mac setup for independent Codex/Claude/Gemini reviews, optional pre-push verification, costs and limitations.

## Visual architecture Explorer

To understand all tracked files and the current/planned architecture, open the [Architecture Atlas guide](../architecture/explorer/README.md). Windows: `launchers/windows/more/Architecture Atlas.cmd`; Mac: `launchers/mac/more/Architecture Atlas.command`. The launcher opens the single-file offline `Architecture-Atlas.html`. Click any system node or source function to see its responsibilities, owning file, dependencies and exact source line. Open the Documentation tab to read the actual Markdown and ADRs in the browser. Use `/` for search, `5` for documents and `?` for hotkeys. New design boundaries require updates to `docs/architecture/SYSTEM.md` and `docs/architecture/explorer/model.json`.
