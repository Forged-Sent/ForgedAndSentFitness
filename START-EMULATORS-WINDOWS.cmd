@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tooling\windows\bootstrap-pwsh.ps1" -Mode emulators
set "result=%errorlevel%"
echo.
if not "%result%"=="0" echo Emulator failed. Use FIRST-RUN-WINDOWS.cmd to diagnose.
pause
exit /b %result%
