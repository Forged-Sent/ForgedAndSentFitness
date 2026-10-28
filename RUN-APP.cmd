@echo off
setlocal
title Forged and Sent - Preview
cd /d "%~dp0"
echo.
echo Starting the Forged and Sent Flutter preview...
echo Keep this window open while the app runs.
echo Close the window to stop the preview.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tooling\windows\run-app.ps1"
set "result=%errorlevel%"
echo.
if not "%result%"=="0" (
  echo The app did not start. Please run SETUP-WINDOWS.cmd first.
  echo If it still fails, send a screenshot of this window.
)
echo.
pause
exit /b %result%
