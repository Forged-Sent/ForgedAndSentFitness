@echo off
setlocal
title Forged and Sent - Optional engineering shell
cd /d "%~dp0..\..\.."
if not exist "tooling\windows\bootstrap-pwsh.ps1" (
  echo Use the complete Git clone; see docs\development\WINDOWS-QUICKSTART.md.
  pause
  exit /b 1
)
echo Adds a personal PowerShell command menu, bookmarks, tasks and focus tools if you choose Yes.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "tooling\windows\bootstrap-pwsh.ps1" -Mode shell
set "result=%errorlevel%"
if not "%result%"=="0" echo Optional shell needs attention. Your application setup is independent.
pause
exit /b %result%
