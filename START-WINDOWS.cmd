@echo off
setlocal
title Forged and Sent - Start here
cd /d "%~dp0"
if not exist "tooling\windows\bootstrap-pwsh.ps1" (
  echo ERROR: The project files around this launcher are missing.
  echo Use a full Git clone of Forged-Sent/ForgedAndSentFitness; see docs\development\WINDOWS-QUICKSTART.md.
  pause
  exit /b 1
)
echo.
echo ===============================================
echo       Forged and Sent - Start here
echo ===============================================
echo This guided menu sets up your computer and explains anything missing.
echo It never creates accounts or deploys your app.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "tooling\windows\bootstrap-pwsh.ps1" -Mode wizard
set "result=%errorlevel%"
echo.
if not "%result%"=="0" (
  echo Please share the generated AI help report if you get stuck.
) else (
  echo You can reopen this menu any time; nothing is reinstalled.
)
echo.
pause
exit /b %result%
