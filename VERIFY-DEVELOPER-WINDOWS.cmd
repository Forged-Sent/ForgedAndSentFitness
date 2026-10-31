@echo off
setlocal
title Forged and Sent - Developer Setup Check
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tooling\windows\bootstrap-pwsh.ps1" -Mode verify
echo.
set "result=%errorlevel%"
pause
exit /b %result%
