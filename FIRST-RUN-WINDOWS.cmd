@echo off
setlocal
title Forged and Sent - Guided First Run
cd /d "%~dp0"
echo.
echo ===============================================
echo       Forged and Sent - First Run Wizard
echo ===============================================
echo This wizard explains missing tools and how to fix them.
echo It never creates accounts or deploys your app.
echo.
if not exist "%~dp0tooling\windows\bootstrap-pwsh.ps1" (
  echo ERROR: The required setup files are missing.
  echo Use a full Git clone of Forged-Sent/ForgedAndSentFitness; see the Windows quickstart.
  echo Do not run a partial copy of the repository.
  pause
  exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tooling\windows\bootstrap-pwsh.ps1" -Mode wizard
set "result=%errorlevel%"
echo.
if not "%result%"=="0" echo Please share the generated AI help report if you get stuck.
echo.
pause
exit /b %result%
