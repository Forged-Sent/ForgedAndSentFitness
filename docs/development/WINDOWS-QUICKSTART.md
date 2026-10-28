# Forged & Sent: Windows setup (no programming experience needed)

These instructions are for teammates who want to **see the Flutter app running on their own Windows computer** or start making changes. You do not need your friend's Linux server, a Firebase account, or Android Studio for the initial browser preview.

## First time: three simple steps

1. Open the GitHub pull request or branch provided by your teammate. Choose **Code > Download ZIP** and use **Extract All** in Windows File Explorer. **Do not run scripts directly from inside the ZIP.**
2. Open the extracted folder. Double-click **SETUP-WINDOWS.cmd**. Read any Windows installer prompts and follow them. It installs or reuses Git, Visual Studio Code, Google Chrome, and Flutter. It also downloads Flutter's project dependencies and checks the starter app.
3. Double-click **RUN-APP.cmd**. Chrome opens the current Flutter app. Keep the black command window open while using it. Close that window to stop the app.

> Only run the setup from the repository you trust. Windows may show a first-run security or install prompt. The command file limits PowerShell's execution-policy bypass to that one process; it does not permanently weaken the computer's policy.

## What you'll see

At this stage, the Flutter app shows a smoke-test welcome screen: **Forged & Sent / Faith. Training. Brotherhood.** It is not yet the full devotional/fitness prototype. It does not connect to Firebase or sync data.

## Want to work on Android phones too?

Double-click **SETUP-ANDROID.cmd** (optional). It additionally installs Android Studio and creates Android project files. On first launch, Android Studio still needs you to finish the SDK download/first-run wizard, review Android SDK licenses (\`flutter doctor --android-licenses\`), and set up a phone or emulator. This setup does not silently accept licenses.

For iPhone simulator builds, you need a Mac with Xcode. On Windows, use Chrome and/or an Android phone.

## Making changes

Open Visual Studio Code, choose **File > Open Folder**, and select the extracted repository folder. The Flutter code is under \`mobile/lib\`. If VS Code asks about Flutter/Dart extensions, accept. For long-term collaboration, use Git clone and separate branches rather than repeatedly downloading ZIPs.

## If something goes wrong

- Rerun SETUP-WINDOWS.cmd; installed tools are reused.
- Copy the error message or take a screenshot of the command window.
- The setup also writes a log named \`ForgedAndSent-setup-*.log\` in your Windows temporary folder (press Win+R, type \`%TEMP%\`).
- If Windows reports that \`winget\` is missing, install or update Microsoft's **App Installer** and rerun.
- If setup is blocked by a corporate laptop policy, ask your IT team for help. Do not disable company security controls.
- If Chrome cannot launch, verify Chrome is installed and rerun setup.
- The first SDK download can be large, and normal internet access is required.

## What gets installed

| Tool | Why |
|---|---|
| Git for Windows | Downloads the official Flutter SDK; supports code collaboration |
| Visual Studio Code | Editor for Flutter and Dart |
| Google Chrome | Runs the starter Flutter app on Windows |
| Flutter stable SDK | Compiles and runs the app; also includes the Dart SDK |
| Android Studio (optional) | Android SDK, emulator and Android build tools |

The script uses Microsoft WinGet for Windows applications and clones Flutter's official stable GitHub repository into your user folder (\`%USERPROFILE%\develop\flutter\`). It does not sign in to Firebase, install AI tools, deploy services, or access anyone's private data.

## Official help

- Flutter Windows setup: https://docs.flutter.dev/install/manual
- Flutter Android setup: https://docs.flutter.dev/platform-integration/android/setup
- Windows Package Manager: https://learn.microsoft.com/en-us/windows/package-manager/winget/install
