@echo off
setlocal
cd /d "%~dp0"
echo Forged ^& Sent: independent pre-push code review
echo This uses your signed-in AI CLIs and may count against their usage.
where py >nul 2>nul
if %errorlevel%==0 (
  py -3 "tooling\review\review.py" %*
) else (
  python "tooling\review\review.py" %*
)
set "RESULT=%errorlevel%"
echo.
if "%RESULT%"=="0" (echo Review preparation/verification succeeded.) else (echo Review did NOT pass. Read .review\summary.md if generated.)
if not defined CI pause
exit /b %RESULT%
