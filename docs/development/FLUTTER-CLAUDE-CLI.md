# Starting Flutter work with Claude CLI

The maintainer can stay in the Codex chat while the coordinator invokes Claude CLI for a focused Flutter builder task. An interactive Claude session is optional. Open `docs/` as the Obsidian vault and use [HOME](../HOME.md) for human navigation; agents start from `AGENTS.md`, [START_HERE](START_HERE.md), [SYSTEM](../architecture/SYSTEM.md), and the relevant ADR/feature contract. [ADR-0005](../architecture/ADR-0005-flutter-client-stack.md) is the accepted package direction, but no package or production feature is implemented yet.

## Before the first code branch

1. Use the Flutter SDK pinned in `.github/workflows/ci-gate.yml` (currently **3.47.8**). The default `flutter` on this PC still reports **3.44.8** / Dart **3.12.2**, but a separate verified **3.47.8** / Dart **3.13.7** checkout is available at `C:\ws_c\flutter-3.47.8`. Use its `bin\flutter.bat` explicitly for project work; do not assume the default `flutter` command selects it. Other workstations need their own matching SDK. Avoid committing a lockfile rewritten by the older SDK.
2. On Windows, run `flutter doctor`. If Android licenses are outstanding, the person who accepts the terms runs `flutter doctor --android-licenses`. Start an installed emulator with `flutter emulators --launch Medium_Phone_API_35` (or choose a name from `flutter emulators`). Check it with `flutter devices`. iOS builds require macOS/Xcode.
3. Merge the documentation ADR before implementing its packages. Define one owner-only completion contract in `docs/features/` with observable saved/pending/error states, synthetic data and tests. Keep private prayer, health data, scoring and cloud Firebase out of the first slice.
4. Start one short-lived feature branch/worktree from updated `main`. The builder changes only that slice, updates [SYSTEM](../architecture/SYSTEM.md) and the generated code map when Dart changes, and runs local checks. Follow the repo's protected push rules before sharing the branch.

## Running the builder

From the feature worktree's repository root in PowerShell:

```powershell
claude auth status
claude --agent flutter-builder
```

If `claude auth status` says you are logged in but the builder reports `Invalid API key`, an inherited `ANTHROPIC_API_KEY` may be taking precedence. In that PowerShell session only, run `Remove-Item Env:ANTHROPIC_API_KEY -ErrorAction SilentlyContinue`, then retry `claude auth status` and the builder. Do not print or paste a key. This exact override was needed for the local read-only Claude review while the account login remained valid.

Give Claude the approved feature contract and ask it to implement one vertical slice with widget and repository tests. Tell it to run Flutter commands with the explicit pinned SDK path above and record the version in its handoff. The `.claude/agents/flutter-builder.md` role and `CLAUDE.md` are in the repo. A non-interactive coordinator can invoke the same agent with `claude --agent flutter-builder -p "<bounded task>"`; the agent must use the feature worktree, not `main`. Label the PR `authorship:claude` and follow the [functional review-gate guide](FLUTTER-AI-REVIEW-GATE.md); its separate required-status ruleset remains disabled until hosted acceptance finishes. The authoring agent cannot count as its own independent reviewer. Codex can review a Claude-authored diff; findings go back to the builder for one fix pass, and later findings pause for maintainer triage.

On this PC, the existing scaffold passed `pub get`, `analyze --no-pub`, and all five Flutter tests using `C:\ws_c\flutter-3.47.8\bin\flutter.bat`; the committed lockfile stayed unchanged. Use that explicit executable for new dependency work and check `git diff --exit-code -- mobile/pubspec.lock` after setup. The Windows **Run the app** launcher currently uses the default Flutter on `PATH`, so do not treat its result as a pinned-SDK test. Its web behavior is a preview only: native Drift durability, Firebase sync, Android/iOS hosts and device behavior require separate implementation and verification. Do not use cloud Firebase credentials or production options on contributor devices.

Official references: [Flutter install and doctor](https://docs.flutter.dev/get-started/install), [Claude Code CLI reference](https://code.claude.com/docs/en/cli-reference), [Drift native setup](https://drift.simonbinder.eu/platforms/vm/).
