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

## Everyday Android emulator commands

For the maintainer's Windows workstation, in PowerShell 7. On the evening of 2026-11-26 the emulator `FS_S1_Restart_API_36` (Android 16, API 36; emulator 36.2.12, Flutter 3.47.8) was prepared for him to try the app by hand on a lifting day, and afterwards put back for the device tests. Two AI sessions did that, and this page was written by the second. Each command below is marked:

- **[run]**: run by the session that wrote this page, and seen to work.
- **[reported]**: run that evening by the other session. It is taken from that session's report and was not run again for this page.

Some were run from PowerShell and some from Git Bash or a helper script; what follows `adb` is the same in both. Where the PowerShell spelling itself matters and was not run, that is said. Anything else is said to be NOT VERIFIED.

### Once per PowerShell window: the tools

```powershell
$fsFlutter = Join-Path $env:USERPROFILE 'develop\flutter\bin\flutter.bat'
$sdk = Join-Path $env:LOCALAPPDATA 'Android\Sdk'
$adb = Join-Path $sdk 'platform-tools\adb.exe'
$emu = Join-Path $sdk 'emulator\emulator.exe'
$AVD = 'FS_S1_Restart_API_36'
$APP = 'com.forgedandsent.forged_and_sent'
& $emu -list-avds
```

**Expect:** four names, one of them `FS_S1_Restart_API_36`. **[run]** That is the Android emulator the device tests in [mobile/README.md](../../mobile/README.md) were run on. Once started it is the device `emulator-5554`.

- `emulator` is not on this workstation's PATH, so the full path is needed. `adb` is on PATH, from `C:\adb\platform-tools`; it and the copy in the Android SDK are both version 36.0.0.
- Give every `adb` command `-s emulator-5554`. That evening `adb devices` also listed a second device, connected over Wi-Fi, so each command has to say which one it means.

### Start, stop and restart the emulator

```powershell
Start-Process $emu -ArgumentList '-avd', $AVD, '-no-snapshot', '-no-boot-anim', '-gpu', 'host' -WindowStyle Minimized   # start, with its window
& $adb devices                                              # expect: emulator-5554   device
& $adb -s emulator-5554 shell getprop sys.boot_completed    # 1 when Android has finished starting
& $adb -s emulator-5554 shell sync                          # before stopping: write what the app saved to the emulator's disk
& $adb -s emulator-5554 emu kill                            # stop
```

- **The start, with its window: [reported].** It opened on the first try and had started in 33 seconds; the window's title is "Android Emulator - FS_S1_Restart_API_36:5554". `-WindowStyle Minimized` minimizes only the console window that comes with it. The spelling of this line is from that session's notes.
- **The start without a window: [run]**, from Git Bash by a helper script: the same options with `-no-window` added. Android had started in 40 seconds. That is how the emulator was left for the device tests. The PowerShell spelling, `'-no-window'` added to the list above, was not run.
- **The other four lines: [run].**
- `-no-snapshot` starts the emulator as a phone that was switched off, not from where it was last left. Every start that evening was of this kind.
- Stopping the emulator keeps the app and what it has saved. **[reported]** The app's four finished workouts and one unfinished were there after a stop and a start. **[run]** After a second stop and start the app was still installed; its workouts were not looked at again. Removing the app (below) is what clears it.
- Fifteen seconds after a start, `adb -s emulator-5554 shell date` gave the same time as the workstation. **[run]**
- To restart: stop, wait until `adb devices` no longer lists `emulator-5554`, then start.

### Run the app

For work on the code, with hot reload, use section B with `emulator-5554` as the device id. That is a debug build.

To try the app by hand, install a **profile** build. It has no hot reload. The debug build felt slow on this emulator when he tried it on 2026-11-21; a profile build is the one to judge the app's speed by. From `mobile/`:

```powershell
& $fsFlutter pub get
& $fsFlutter build apk --profile --target-platform android-x64
& $adb -s emulator-5554 install -r build\app\outputs\flutter-apk\app-profile.apk
& $adb -s emulator-5554 shell monkey -p $APP -c android.intent.category.LAUNCHER 1   # open the app
```

- **The first two lines: [run]**, in a checkout of `main` at `cf5f744`. The build took a minute and a half and ended with "Built build\app\outputs\flutter-apk\app-profile.apk (36.7MB)". That file was not installed.
- **The last two lines: [reported]**, with a build of `main` at `50ddfc0`.
- `install -r` installs over the app that is there and keeps what it has saved. That evening the profile build went over a debug build that held sample workouts, and the workouts were still there.
- The emulator is an `x64` device; `--target-platform android-x64` builds only for it.

Is the app installed, and remove it with everything it has saved:

```powershell
& $adb -s emulator-5554 shell pm list packages | Select-String forged   # [run]
& $adb -s emulator-5554 uninstall $APP                                  # [reported]
```

### See another day: move the emulator's date

On the plan every member gets, Train offers a workout to start only on a Monday, Wednesday or Friday. That evening was a Thursday, so the emulator's clock was moved 24 hours ahead, and Train showed "Friday, November 27" and "Ready to train". **[reported]** The app reads the emulator's clock; nothing in the app was changed.

Move it ahead by one day, with the app closed (the only order tried):

```powershell
& $adb -s emulator-5554 shell settings put global auto_time 0
$ms = [DateTimeOffset]::Now.AddDays(1).ToUnixTimeMilliseconds()
& $adb -s emulator-5554 shell cmd alarm set-time $ms
& $adb -s emulator-5554 shell date
```

- **The two `adb` lines that change something: [reported]**, with the number worked out in Git Bash. The `$ms` line was run on the workstation and gives this time tomorrow; passing it to `set-time` from PowerShell is NOT VERIFIED.
- `$ms` is the new time in milliseconds since 1970. Work it out on the workstation, as here. Worked out inside the emulator's own shell, the multiplication overflowed and the clock read January 1970 for a few seconds. **[reported]**
- For another day, change `AddDays(1)`.
- `adb shell date <new date>` does not work on this emulator: "Operation not permitted". **[reported]**
- With `auto_time` at 0 the emulator keeps the date it was given, and the clock still runs: more than four hours later it was one day ahead of the workstation, to within a second. **[run]**

Put it back **[run]**:

```powershell
& $adb -s emulator-5554 shell settings put global auto_time 1
& $adb -s emulator-5554 shell date
```

**Expect:** the workstation's date and time. Eight seconds after the first line it matched to the second.

Before any device test, start the emulator afresh **[run]**:

```powershell
& $adb -s emulator-5554 shell sync
& $adb forward --remove-all
& $adb -s emulator-5554 emu kill
```

Then start it as above. After the start the date still matched and `auto_time` was still 1. The reason for the fresh start is an earlier session's note, not in this repository: on 2026-11-21, after the date had been put back, the test runner could not connect to the emulator until this was done. No device test was run for this page, so whether it is still needed is NOT VERIFIED.

Do not move the date between the files of one device test: each set must run within one day by the emulator's clock.

### While he is using the emulator

A set of device tests installs its own build and ends by removing the app, and with it what he was looking at. If an AI session is running device tests, tell it before the emulator is prepared for use by hand, and again when he is finished. That evening the session with the test queue held every device test until it was told.

### Device tests on the emulator

The commands, what each test proves and when each last passed on this emulator are in [mobile/README.md](../../mobile/README.md). They are run from `mobile/` with `& $fsFlutter test ... -d emulator-5554`. None was run for this page. Before a set:

```powershell
& $adb -s emulator-5554 shell pm list packages | Select-String forged   # expect nothing: start with the app removed
& $adb -s emulator-5554 shell df -h /data                               # free space; 2.5 GB that evening
```

Both **[run]**.

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
