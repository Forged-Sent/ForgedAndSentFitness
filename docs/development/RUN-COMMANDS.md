# Run it without asking an AI

> [!TIP] First choice
> **A: Chrome preview** is the quickest demo. Use **B: Android** to check native saving.
> **C: Firebase** checks practice backend connectivity. It does not add cloud sync.

## Before any command

Open VS Code on the **repository/worktree folder**, not just `docs`. Open Terminal. These root commands should work:

```sh
git status
git branch --show-current
git log -1 --oneline
```

No Git clone yet? Use [Windows setup](WINDOWS-QUICKSTART.md) or [Mac setup](MACBOOK-QUICKSTART.md). Do installation before the lesson. Keep one running app/backend set at a time; worktrees can compete for the same ports.

### Check the Flutter version

The pin lives in [tooling/versions.json](../../tooling/versions.json) and CI. Do not use `flutter upgrade` to fix a mismatch.

**Windows, PowerShell 7:** select the SDK that the numbered launchers prefer:

```powershell
$fsFlutter = Join-Path $env:USERPROFILE 'develop\flutter\bin\flutter.bat'
if (-not (Test-Path -LiteralPath $fsFlutter)) { $fsFlutter = (Get-Command flutter.bat -ErrorAction Stop).Source }
$fsExpected = (Get-Content tooling/versions.json -Raw | ConvertFrom-Json).flutter
Write-Host "Required Flutter: $fsExpected"
& $fsFlutter --version
```

**Mac:**

```bash
cat tooling/versions.json
flutter --version
```

**Expect:** versions match. If they do not, use the setup guide to select/install the pinned SDK. The Windows launcher currently prefers `~/develop/flutter`, so a different `flutter` on PATH can give different results. Keep using `& $fsFlutter` below in that terminal. Mac scripts check their selected SDK against the pin.

## A. Browser preview

**Windows, from repo root:**

```powershell
& '.\launchers\windows\2 - Run the app.cmd'
```

**Mac, from repo root:**

```bash
bash 'launchers/mac/2 - Run the app.command'
```

**Expect:** Chrome opens the Flutter app. Today and the reading work. Five tabs are placeholders on the reviewed baseline. The launcher may create ignored web-host files and download pinned dependencies. Its old “foundation screen” console wording does not mean you opened the HTML prototype.

**Stop:** press `q` in the Flutter terminal. `r` requests hot reload, `R` hot restart, `h` shows available keys. Browser refresh/restart can reset the preview's in-memory data.

**Direct command after web setup, Windows:**

```powershell
Set-Location mobile
& $fsFlutter pub get
& $fsFlutter run -d chrome
```

Mac: `cd mobile`, then `flutter pub get`, then `flutter run -d chrome`. Return to repo root with `cd ..` after stopping.

## B. Android phone emulator

An **Android emulator** is a pretend phone. It is different from Firebase's practice backend.

**Once:** use `launchers/windows/more/Android setup.cmd`, then Android Studio's Device Manager to create an Android Virtual Device if none exists. Mac users need Android Studio/SDK setup separately; the repo's Mac extra targets iPhone.

**Windows, after selecting `$fsFlutter` above, from repo root:**

```powershell
& $fsFlutter emulators
```

Copy an emulator ID from that output, then substitute it below (do not type the angle brackets):

```powershell
& $fsFlutter emulators --launch <emulator-id>
& $fsFlutter devices
```

Wait for Android to finish booting. Copy its **device ID** from `devices`. It is not necessarily the emulator ID.

```powershell
Set-Location mobile
& $fsFlutter pub get
& $fsFlutter run -d <device-id>
```

Mac/Linux with Android already configured use the same Flutter arguments without `& $fsFlutter`, for example `flutter devices`.

**Expect:** app opens on the pretend phone in preview mode. Native preview uses SQLite, so it can test local saving **without** Firebase.

**Manual save check:** finish a devotional; stop/close the app; launch it again without clearing its data. Expect that day's completion to remain. Record date, device, branch and result. Hot reload alone does not test process-restart durability. Uninstalling or clearing app data removes its local records.

## C. Practice Firebase: two terminals

The **Firebase emulators** are pretend Auth, Firestore and Storage services. They run on your computer; an Android emulator is not required to start them.

### Terminal 1: backend, from repo root

Windows:

```powershell
& '.\launchers\windows\3 - Start practice Firebase.cmd'
```

Mac:

```bash
bash 'launchers/mac/3 - Start practice Firebase.command'
```

**Expect:** “All emulators ready”. Keep this terminal open. Inspect synthetic practice data at [Emulator UI](http://127.0.0.1:4000). Ports in [firebase.json](../../firebase.json): Auth 9099, Firestore 8080, Storage 9199, UI 4000. These URLs work only while the server runs.

### Terminal 2: app, from repo root

For the first browser run, use A once so its web host exists. Stop A, then run:

Windows:

```powershell
& '.\launchers\windows\4 - Run app with practice Firebase.cmd'
```

Mac:

```bash
bash 'launchers/mac/4 - Run app with practice Firebase.command'
```

**Android instead:** select the pinned SDK in this second terminal, start the phone emulator as in B, then from `mobile/`:

```powershell
& $fsFlutter run -d <device-id> --dart-define=FS_ENV=emulator
```

**Expect:** startup reaches the app when the demo connection checks pass. Settings' build-status page reports the mode. Android reaches the host through `10.0.2.2`; Chrome/iOS simulator use `127.0.0.1`. This recipe is for simulators, not a physical phone's network setup.

**Important distinction:** the current devotional record still stays in its local store. You should not expect Amen to appear as a synced Firestore group record.

**Stop:** `q` in the app terminal, then Ctrl+C in the Firebase terminal. If Windows asks to terminate the batch job, answer `Y`. Treat practice backend data as disposable; these launchers do not request export/import persistence. No cloud login or deployment command is needed.

## D. iPhone simulator on Mac

Requires macOS, Xcode and an installed iOS simulator. Run the Mac start menu's iPhone setup first if missing.

```bash
bash 'launchers/mac/more/Run app on iPhone simulator.command'
```

**Expect:** the launcher boots a simulator and reports preview or emulator mode. It chooses emulator mode only if the three local Firebase ports are reachable. `q` stops Flutter. An iOS simulator build in CI is not proof this interactive journey ran on an iPhone.

## Everyday simulator commands

For the maintainer's Mac. Every command in this section was run there on 2026-11-25 and seen to work: Xcode 27.2, Flutter 3.47.8, one iPhone 17 simulator on iOS 27.2, `main` at `49104c9`. Anything that was not run, or that failed, is said so.

### Once per Terminal window: pick the simulator

```bash
SIM=$(xcrun simctl list devices available | grep -m1 'iPhone 17 (' | grep -oE '[0-9A-F-]{36}')
echo $SIM
```

**Expect:** one long id, such as `5F8C7907-4CAF-46AF-9288-79226AFA4E35`. Every command below uses `$SIM`. For another model, change `iPhone 17 (`; `xcrun simctl list devices available` shows what is installed.

### Start, stop and restart the simulator

```bash
xcrun simctl boot $SIM                    # start
xcrun simctl bootstatus $SIM -b           # wait until it has finished starting
open /Applications/Xcode.app/Contents/Applications/DeviceHub.app   # show its window
xcrun simctl list devices booted          # which simulators are running
xcrun simctl shutdown $SIM                # stop
xcrun simctl shutdown $SIM && xcrun simctl boot $SIM && xcrun simctl bootstatus $SIM -b   # restart
```

- The simulator runs without its window. Flutter can install to it and the tests pass either way.
- Xcode 27 has no `Simulator.app`: `open -a Simulator` answers "Unable to find application named 'Simulator'". The window is `DeviceHub.app`.
- `bootstatus` ended with "Data Migration Failed" on every start that day, and still finished without an error. The simulator was running each time and every test below passed afterwards. The cause was not looked into.
- Stopping the simulator keeps the app and what it has saved. Removing the app (below) is what clears it.

### Run the app

From the repository folder, the launcher of section D does everything, including starting the simulator:

```bash
bash 'launchers/mac/more/Run app on iPhone simulator.command'
```

Or by hand, from `mobile/`, with the simulator started:

```bash
flutter pub get
flutter run -d $SIM
```

**Expect:** "Launching lib/main.dart on iPhone 17 in debug mode", then the app on Today. In that Terminal, `r` reloads after a code change, `R` restarts the app, `q` quits it. This is **debug** mode, in preview: nothing is sent anywhere.

**Profile mode does not run on a simulator.** `flutter run -d $SIM --profile` stops at once with "Profile mode is not supported by iPhone 17". Profile and release builds need a real iPhone: `flutter run -d <iPhone id> --profile`, NOT VERIFIED, because no iPhone has been connected to this Mac.

To remove the app and everything it has saved on the simulator:

```bash
xcrun simctl uninstall $SIM com.forgedandsent.forgedAndSent
```

### Host tests (no simulator needed)

From `mobile/`:

```bash
flutter pub get
flutter analyze
flutter test
```

**Expect:** "No issues found!", then "All tests passed!" (634 passed and 34 skipped that day, in about a minute).

### Device tests on the simulator

Each test is two or three files, run in order, one process each; why is in [mobile/README.md](../../mobile/README.md). From `mobile/`, with the simulator started. Start each set with the app removed, and run a whole set on the same day:

```bash
xcrun simctl uninstall $SIM com.forgedandsent.forgedAndSent
```

Devotional (S1): Amen survives a kill and relaunch.

```bash
flutter test integration_test/restart_1_complete_test.dart -d $SIM --no-uninstall
flutter test integration_test/restart_2_verify_test.dart -d $SIM
```

Journal: an entry survives.

```bash
flutter test integration_test/journal_restart_1_write_test.dart -d $SIM --no-uninstall
flutter test integration_test/journal_restart_2_verify_test.dart -d $SIM
```

Workout: a workout in progress survives and can be finished.

```bash
flutter test integration_test/workout_restart_1_start_test.dart -d $SIM --no-uninstall
flutter test integration_test/workout_restart_2_finish_test.dart -d $SIM
```

Journal, changing and deleting an entry (three files):

```bash
flutter test integration_test/journal_edit_restart_1_change_test.dart -d $SIM --no-uninstall
flutter test integration_test/journal_edit_restart_2_delete_test.dart -d $SIM --no-uninstall
flutter test integration_test/journal_edit_restart_3_gone_test.dart -d $SIM
```

**Expect:** each file ends with "All tests passed!". The first file of a set takes a few minutes the first time, while Xcode builds the app; after that each file takes one to two minutes. The last file of each set removes the app from the simulator.

- **The upgrade test** (`upgrade_1`, `upgrade_2`, `upgrade_3`) was not run on the simulator that day. NOT VERIFIED on iOS. Its steps are in [mobile/README.md](../../mobile/README.md).
- **"Failed to copy plugin cloud_firestore ... rsync ... No such file or directory"** before any build starts: the folder `mobile/build/ios/SourcePackages` is missing, and the `rsync` from Homebrew will not create it. `mkdir -p build/ios/SourcePackages` from `mobile/`, then run the command again. Seen that day after `mobile/build` was deleted; the launcher makes the folder itself.
- **Disk space.** The first iPhone build in a checkout or worktree puts about 2 GB into its `mobile/build`. That morning the Mac ran out of space during a build ("No space left on device"), and every test failed before it started. `df -h /System/Volumes/Data` shows what is free. `mobile/build` in a worktree that is no longer used can be deleted; the next build makes it again.

## E. Check a change

**Flutter changes, from `mobile/`, Windows with `$fsFlutter` selected:**

```powershell
& $fsFlutter pub get
& $fsFlutter analyze
& $fsFlutter test
```

Mac: `flutter pub get`, `flutter analyze`, `flutter test`.

**Expect:** exit success, no analysis errors and passing tests. These commands do not by themselves run the complete-kill-relaunch phone test. Do not update golden images just to silence a failure; inspect the visual change first.

**Documentation checks, from repo root:**

After editing WORK, first run `python tooling/knowledge/work_board.py --write` and include the regenerated board and HOME with your change.

```sh
python -B tooling/knowledge/check.py
python -B tooling/architecture/generate.py --check
python -B tooling/architecture/build_explorer.py --check
git diff --check
```

Mac may use `python3` instead of `python`. The map check detects stale Dart documentation; it does not prove every architecture sentence correct.

## F. Prototype and Architecture Atlas

**Prototype with fake in-memory data**, from root:

```sh
python dev/make_preview.py
```

Open the generated `dev/preview.html` in a browser. That is the HTML prototype, not Flutter, not production identity or persistence.

**Architecture Atlas**, from root:

```sh
python tooling/architecture/build_explorer.py --write
```

Open `build/architecture-explorer/Architecture-Atlas.html`. The generated site reads this checkout. Regenerate after source changes. The double-click Atlas launcher does this for you.

## If it fails

| Symptom | Next action |
|---|---|
| Command not found | Run numbered setup, reopen the terminal, check the selected SDK |
| Mac launcher says unexpected end of file in a Windows checkout | This review reproduced that failure in three unchanged launchers under WSL on both main and the docs branch. Use a native Mac clone and report the exact launcher error; Mac execution is not freshly verified here |
| Dart/SDK version conflict | Compare with `tooling/versions.json`; do not casually upgrade packages |
| No Android devices | Boot an AVD, wait, rerun `devices` |
| Firebase port unavailable | Start terminal 1 and wait for readiness |
| Port already in use | Stop the old instance you launched; do not start another worktree's backend on it |
| App opens a build-status error | Read the message; check storage or emulator startup before retrying |
| Browser loses completion on refresh | Expected for this web preview; use native for durability |
| Permission or personal-data question | Pause that action and ask the maintainer |

Report the **command, folder, branch/commit, expected result, actual result and first relevant error**. That is enough to start a useful diagnosis.

Sources: checked-in launchers and runtime, [Flutter CLI](https://docs.flutter.dev/reference/flutter-cli), [Git basics](GIT-101.md). Recipes reviewed 2026-11-13; Windows/Mac/device runtime paths are not all freshly exercised by this docs-only change.
