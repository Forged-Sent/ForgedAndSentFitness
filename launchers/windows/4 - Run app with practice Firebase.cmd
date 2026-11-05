@echo off
setlocal
title Forged and Sent - App with practice Firebase
cd /d "%~dp0..\.."
if not exist "tooling\windows\bootstrap-pwsh.ps1" (
  echo ERROR: The project files around this launcher are missing.
  echo Use a full Git clone of Forged-Sent/ForgedAndSentFitness; see docs\development\WINDOWS-QUICKSTART.md.
  pause
  exit /b 1
)
echo.
echo Runs the app connected to the local practice Firebase only, never the cloud.
echo Start 3 - Start practice Firebase.cmd first and wait until it says it is ready.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "tooling\windows\bootstrap-pwsh.ps1" -Mode run-emulator
set "result=%errorlevel%"
echo.
if not "%result%"=="0" (
  echo The app could not connect. Start 3 - Start practice Firebase.cmd first, then retry.
) else (
  echo The app has stopped.
)
echo.
pause
exit /b %result%
