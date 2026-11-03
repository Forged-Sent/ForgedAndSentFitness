@echo off
setlocal EnableExtensions
pushd "%~dp0"
if errorlevel 1 (echo Could not open project folder.& pause & exit /b 1)
echo.
echo  FORGED ^& SENT  /  ARCHITECTURE ATLAS
echo  Indexing repository files, functions, and dependencies...
echo.
set "PYTHON_CMD="
py -3 -c "import sys;sys.exit(0 if sys.version_info >= (3,11) else 1)" >nul 2>nul
if not errorlevel 1 set "PYTHON_CMD=py -3"
if not defined PYTHON_CMD (
  python -c "import sys;sys.exit(0 if sys.version_info >= (3,11) else 1)" >nul 2>nul
  if not errorlevel 1 set "PYTHON_CMD=python"
)
if not defined PYTHON_CMD (
  echo  Python 3.11+ is missing. Run FIRST-RUN-WINDOWS.cmd, choose Contributor, and retry.
  pause
  popd
  exit /b 1
)
%PYTHON_CMD% tooling\architecture\build_explorer.py --write
if errorlevel 1 (
  echo  Atlas generation failed. Confirm a complete Git checkout and read the error above.
  pause
  popd
  exit /b 1
)
start "" "%CD%\build\architecture-explorer\Architecture-Atlas.html"
if errorlevel 1 echo Open build\architecture-explorer\Architecture-Atlas.html manually.
popd
exit /b 0
