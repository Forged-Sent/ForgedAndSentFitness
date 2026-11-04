@echo off
setlocal
title Forged and Sent - Optional AI code review
cd /d "%~dp0..\..\.."
echo Forged ^& Sent: optional independent AI review
echo This uses any signed-in reviewer CLI you select and may incur usage charges.
set "PYTHON_CMD="
py -3 -c "import sys;sys.exit(0 if sys.version_info >= (3,11) else 1)" >nul 2>nul
if not errorlevel 1 set "PYTHON_CMD=py -3"
if not defined PYTHON_CMD (
  python -c "import sys;sys.exit(0 if sys.version_info >= (3,11) else 1)" >nul 2>nul
  if not errorlevel 1 set "PYTHON_CMD=python"
)
if not defined PYTHON_CMD (
  echo Python 3.11+ is missing. Double-click START-WINDOWS.cmd, choose 2 to set up as a Contributor, and retry.
  pause
  exit /b 1
)
%PYTHON_CMD% tooling\review\review.py %*
set "RESULT=%errorlevel%"
if "%RESULT%"=="0" (echo Review preparation or verification completed.) else (echo Review NOT verified. Read .review\summary.md if generated.)
if not defined CI pause
exit /b %RESULT%
