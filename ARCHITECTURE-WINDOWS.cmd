@echo off
setlocal EnableExtensions
pushd "%~dp0"
if errorlevel 1 (echo Could not open project folder.& pause & exit /b 1)
echo.
echo  FORGED ^& SENT  /  ARCHITECTURE ATLAS
echo  Indexing repository files, functions, and dependencies...
echo.
where py >nul 2>nul
if not errorlevel 1 (
  py -3 tooling\architecture\build_explorer.py --write
) else (
  python tooling\architecture\build_explorer.py --write
)
if errorlevel 1 (
  echo.
  echo  Index generation failed. Use a real Git clone with Python 3.
  pause
  exit /b 1
)
start "" "%CD%\build\architecture-explorer\index.html"
if errorlevel 1 (
  echo  Open build\architecture-explorer\index.html manually.
)
popd
exit /b 0
