@echo off
setlocal
title Forged and Sent - Preview
cd /d "%~dp0"
echo.
echo Starting the Forged and Sent Flutter preview...
echo Keep this window open while the app runs.
echo Close the window to stop the preview.
echo.
if not exist "%~dp0tooling\windows\bootstrap-pwsh.ps1" (
  echo ERROR: The required setup files are missing.
  echo In File Explorer, choose Extract All on the downloaded ZIP, then open the extracted folder.
  echo Never run launchers from inside the ZIP preview.
  pause
  exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tooling\windows\bootstrap-pwsh.ps1" -Mode run
set "result=%errorlevel%"
echo.
if not "%result%"=="0" (
  echo The app did not start. Please run SETUP-WINDOWS.cmd first.
  echo If it still fails, send a screenshot of this window.
)
echo.
pause
exit /b %result%
