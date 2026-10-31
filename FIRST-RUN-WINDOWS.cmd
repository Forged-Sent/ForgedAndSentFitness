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
  echo In File Explorer, choose Extract All on the downloaded ZIP, then open the extracted folder.
  echo Never run launchers from inside the ZIP preview.
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
