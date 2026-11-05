@echo off
setlocal
title Forged and Sent - Run the app
cd /d "%~dp0..\.."
if not exist "tooling\windows\bootstrap-pwsh.ps1" (
  echo ERROR: The project files around this launcher are missing.
  echo Use a full Git clone of Forged-Sent/ForgedAndSentFitness; see docs\development\WINDOWS-QUICKSTART.md.
  pause
  exit /b 1
)
echo.
echo Starting the Forged and Sent Flutter app in Chrome.
echo Keep this window open while the app runs. Close it to stop.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "tooling\windows\bootstrap-pwsh.ps1" -Mode run
set "result=%errorlevel%"
echo.
if not "%result%"=="0" (
  echo The app did not start. Run 1 - Set up this computer.cmd first.
  echo If it still fails, send a screenshot of this window.
) else (
  echo The app has stopped.
)
echo.
pause
exit /b %result%
