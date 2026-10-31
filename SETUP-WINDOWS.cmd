@echo off
setlocal
title Forged and Sent - Windows setup
cd /d "%~dp0"
echo.
echo ==========================================
echo  Forged and Sent - Setup for Windows
echo ==========================================
echo.
if not exist "%~dp0tooling\windows\bootstrap-pwsh.ps1" (
  echo ERROR: The required setup files are missing.
  echo In File Explorer, choose Extract All on the downloaded ZIP, then open the extracted folder.
  echo Never run launchers from inside the ZIP preview.
  pause
  exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tooling\windows\bootstrap-pwsh.ps1" -Mode setup
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
