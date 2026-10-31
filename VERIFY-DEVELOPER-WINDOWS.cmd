@echo off
setlocal
title Forged and Sent - Developer Setup Check
cd /d "%~dp0"
if not exist "%~dp0tooling\windows\bootstrap-pwsh.ps1" (
  echo ERROR: The required setup files are missing.
  echo In File Explorer, choose Extract All on the downloaded ZIP, then open the extracted folder.
  echo Never run launchers from inside the ZIP preview.
  pause
  exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tooling\windows\bootstrap-pwsh.ps1" -Mode verify
echo.
set "result=%errorlevel%"
pause
exit /b %result%
