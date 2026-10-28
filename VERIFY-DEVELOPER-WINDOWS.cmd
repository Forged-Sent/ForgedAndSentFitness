@echo off
setlocal
title Forged and Sent - Developer Setup Check
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tooling\windows\verify-developer.ps1"
echo.
pause
