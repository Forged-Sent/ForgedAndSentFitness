@echo off
setlocal EnableExtensions
cd /d "%~dp0..\..\.."
echo.
echo  FORGED ^& SENT / KNOWLEDGE WORKSPACE
echo  No cloud account or Obsidian plugin required.
echo.
set "PYTHON_CMD="
py -3 -c "import sys;sys.exit(0 if sys.version_info >= (3,11) else 1)" >nul 2>nul
if not errorlevel 1 set "PYTHON_CMD=py -3"
if not defined PYTHON_CMD (
  python -c "import sys;sys.exit(0 if sys.version_info >= (3,11) else 1)" >nul 2>nul
  if not errorlevel 1 set "PYTHON_CMD=python"
)
if not defined PYTHON_CMD (
  echo Python 3.11+ is required. Double-click START-WINDOWS.cmd, choose 2 to set up as a Contributor, and retry.
  pause
  exit /b 1
)
echo  The preview runs only while this window stays open.
echo  To stop: close this window, or press Ctrl+C and answer Y to "Terminate batch job (Y/N)?".
%PYTHON_CMD% tooling\preview\serve_project.py --build-atlas --open-browser
if errorlevel 1 (
  echo Preview could not start. Read the error above and check port 43117.
  pause
  exit /b 1
)
exit /b 0
