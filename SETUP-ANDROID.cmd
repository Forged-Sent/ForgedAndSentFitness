@echo off
setlocal
title Forged and Sent - Android development setup
cd /d "%~dp0"
echo This optional step adds Android Studio to the browser preview setup.
echo It is NOT required to preview the app on your PC.
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tooling\windows\bootstrap-pwsh.ps1" -Mode android
set "result=%errorlevel%"
echo.
if not "%result%"=="0" (
  echo Android setup was not completed. Browser preview may still work.
  echo Please copy the error or send a picture of this window.
) else (
  echo Initial setup finished. If Android Studio just opened, complete its SDK wizard.
  echo Android development may require further setup inside Android Studio.
)
echo.
pause
exit /b %result%
