@echo off
setlocal
title Forged and Sent - Preview-only setup
cd /d "%~dp0..\..\.."
if not exist "tooling\windows\bootstrap-pwsh.ps1" (
  echo ERROR: The project files around this launcher are missing.
  echo Use a full Git clone of Forged-Sent/ForgedAndSentFitness; see docs\development\WINDOWS-QUICKSTART.md.
  pause
  exit /b 1
)
echo.
echo Installs only what is needed to look at the app, not to edit it.
echo To edit and share changes, use 1 - Set up this computer.cmd instead.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "tooling\windows\bootstrap-pwsh.ps1" -Mode preview
set "result=%errorlevel%"
echo.
if not "%result%"=="0" (
  echo Setup did not finish. Copy the error or send a picture of this window.
) else (
  echo Preview setup finished. Next: ..\2 - Run the app.cmd
)
echo.
pause
exit /b %result%
