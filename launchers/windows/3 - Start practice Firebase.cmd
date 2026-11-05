@echo off
setlocal
title Forged and Sent - Practice Firebase
cd /d "%~dp0..\.."
if not exist "tooling\windows\bootstrap-pwsh.ps1" (
  echo ERROR: The project files around this launcher are missing.
  echo Use a full Git clone of Forged-Sent/ForgedAndSentFitness; see docs\development\WINDOWS-QUICKSTART.md.
  pause
  exit /b 1
)
echo.
echo Starts the local practice Firebase: Auth, Firestore and Storage on this PC only.
echo No Firebase account is needed. Keep this window open.
echo Wait for: All emulators ready! It is now safe to connect your app.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "tooling\windows\bootstrap-pwsh.ps1" -Mode emulators
set "result=%errorlevel%"
echo.
if not "%result%"=="0" (
  echo Practice Firebase failed to start. Run 5 - Check my setup.cmd for help.
) else (
  echo Practice Firebase has stopped.
)
echo.
pause
exit /b %result%
