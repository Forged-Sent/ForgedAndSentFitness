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
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tooling\windows\first-run.ps1"
set "result=%errorlevel%"
echo.
if not "%result%"=="0" echo Please share the generated AI help report if you get stuck.
echo.
pause
exit /b %result%
