@echo off
setlocal
title Forged and Sent - Set up this computer
cd /d "%~dp0..\.."
if not exist "tooling\windows\bootstrap-pwsh.ps1" (
  echo ERROR: The project files around this launcher are missing.
  echo Use a full Git clone of Forged-Sent/ForgedAndSentFitness; see docs\development\WINDOWS-QUICKSTART.md.
  pause
  exit /b 1
)
echo.
echo Installs or reuses everything needed to edit, test and share changes:
echo Flutter, VS Code, Git tools, Node, Firebase emulator tools, Java 21 and Python.
echo You will choose ONE optional AI assistant. No cloud accounts are created.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "tooling\windows\bootstrap-pwsh.ps1" -Mode contributor
set "result=%errorlevel%"
echo.
if not "%result%"=="0" (
  echo Some tools need attention. See the messages above, then run 5 - Check my setup.cmd
) else (
  echo Setup finished. Next: 2 - Run the app.cmd
)
echo.
pause
exit /b %result%
