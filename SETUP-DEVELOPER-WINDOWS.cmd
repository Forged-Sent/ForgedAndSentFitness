@echo off
setlocal
title Forged and Sent - Full Windows Developer Setup
cd /d "%~dp0"
echo.
echo ==================================================
echo    Forged and Sent - Developer Workstation Setup
echo ==================================================
echo.
echo This installs or checks Flutter, Git, Chrome, VS Code,
echo Node.js, Firebase CLI, GitHub CLI, coding agents,
echo recommended extensions and project MCP tools.
echo.
echo You will sign in to AI/Firebase accounts yourself.
echo No cloud deployments or subscriptions are created.
echo.
if not exist "%~dp0tooling\windows\bootstrap-pwsh.ps1" (
  echo ERROR: The required setup files are missing.
  echo In File Explorer, choose Extract All on the downloaded ZIP, then open the extracted folder.
  echo Never run launchers from inside the ZIP preview.
  pause
  exit /b 1
)
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tooling\windows\bootstrap-pwsh.ps1" -Mode developer
set "result=%errorlevel%"
echo.
if not "%result%"=="0" (
  echo Some tools need attention. See the messages above.
  echo Run VERIFY-DEVELOPER-WINDOWS.cmd for a diagnostic report.
) else (
  echo Developer setup complete. Restart VS Code and sign in.
)
echo.
pause
exit /b %result%
