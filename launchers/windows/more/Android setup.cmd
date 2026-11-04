@echo off
setlocal
title Forged and Sent - Android setup
cd /d "%~dp0..\..\.."
if not exist "tooling\windows\bootstrap-pwsh.ps1" (
  echo ERROR: The project files around this launcher are missing.
  echo Use a full Git clone of Forged-Sent/ForgedAndSentFitness; see docs\development\WINDOWS-QUICKSTART.md.
  pause
  exit /b 1
)
echo.
echo Optional: adds Android Studio for testing on an Android emulator or phone.
echo It is NOT required to run the app in Chrome.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "tooling\windows\bootstrap-pwsh.ps1" -Mode android
set "result=%errorlevel%"
echo.
if not "%result%"=="0" (
  echo Android setup was not completed. The Chrome app may still work.
  echo Copy the error or send a picture of this window.
) else (
  echo Initial setup finished. If Android Studio opened, complete its SDK wizard.
)
echo.
pause
exit /b %result%
