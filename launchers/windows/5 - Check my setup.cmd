@echo off
setlocal
title Forged and Sent - Check my setup
cd /d "%~dp0..\.."
if not exist "tooling\windows\bootstrap-pwsh.ps1" (
  echo ERROR: The project files around this launcher are missing.
  echo Use a full Git clone of Forged-Sent/ForgedAndSentFitness; see docs\development\WINDOWS-QUICKSTART.md.
  pause
  exit /b 1
)
echo.
echo Checks what is installed and explains how to fix anything missing.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "tooling\windows\bootstrap-pwsh.ps1" -Mode check
set "result=%errorlevel%"
echo.
if not "%result%"=="0" (
  echo Some items need attention. Each one is explained above with WHY and FIX.
) else (
  echo Check finished. Read the report above.
)
echo.
pause
exit /b %result%
