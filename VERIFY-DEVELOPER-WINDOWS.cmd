@echo off
setlocal
title Forged and Sent - Developer Setup Check
cd /d "%~dp0"
if not exist "%~dp0tooling\windows\bootstrap-pwsh.ps1" (
  echo ERROR: The required setup files are missing.
  echo Use a full Git clone of Forged-Sent/ForgedAndSentFitness; see the Windows quickstart.
  echo Do not run a partial copy of the repository.
  pause
  exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tooling\windows\bootstrap-pwsh.ps1" -Mode verify
echo.
set "result=%errorlevel%"
pause
exit /b %result%
