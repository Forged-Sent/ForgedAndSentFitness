@echo off
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tooling\windows\bootstrap-pwsh.ps1" -Mode run-emulator
set "result=%errorlevel%"
echo.
if not "%result%"=="0" echo Start emulators first, then retry. Run the wizard for diagnosis.
pause
exit /b %result%
