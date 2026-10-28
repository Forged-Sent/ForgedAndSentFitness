@echo off
setlocal
title Forged and Sent - Windows setup
cd /d "%~dp0"
echo.
echo ==========================================
echo  Forged and Sent - Setup for Windows
echo ==========================================
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tooling\windows\setup.ps1" %*
set "result=%errorlevel%"
echo.
if not "%result%"=="0" (
  echo Setup did not finish. Please copy the error or send a picture of this window.
) else (
  echo Setup complete. Double-click RUN-APP.cmd to launch the app.
)
echo.
pause
exit /b %result%
