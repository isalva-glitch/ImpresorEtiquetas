@echo off
setlocal

REM Go to script directory
cd /d "%~dp0"

echo ==========================================
echo   ImpresorEtiquetas - Startup helper
echo ==========================================

echo [1/6] Detecting a working Python interpreter...
set "PY_CMD="

REM First try Python Launcher (usually avoids Microsoft Store alias issues)
where py >nul 2>&1
if %errorlevel%==0 (
  py -3 -c "import sys" >nul 2>&1
  if %errorlevel%==0 set "PY_CMD=py -3"
)

REM Fallback to python in PATH
if not defined PY_CMD (
  where python >nul 2>&1
  if %errorlevel%==0 (
    python -c "import sys" >nul 2>&1
    if %errorlevel%==0 set "PY_CMD=python"
  )
)

if not defined PY_CMD (
  echo ERROR: No working Python interpreter was found.
  echo Install Python 3.10+ from python.org and enable "Add Python to PATH".
  echo If Windows redirects to Microsoft Store, disable app execution alias for python.exe in:
  echo Settings ^> Apps ^> Advanced app settings ^> App execution aliases
  pause
  exit /b 1
)

echo Python command: %PY_CMD%

echo [2/6] Creating virtual environment if needed...
if not exist ".venv\Scripts\python.exe" (
  %PY_CMD% -m venv .venv
  if not %errorlevel%==0 (
    echo ERROR: Failed to create .venv
    pause
    exit /b 1
  )
)

set "VENV_PY=.venv\Scripts\python.exe"
set "VENV_PIP=.venv\Scripts\pip.exe"

if not exist "%VENV_PY%" (
  echo ERROR: Virtual env python not found at %VENV_PY%
  pause
  exit /b 1
)

echo [3/6] Ensuring pip is available in virtual env...
"%VENV_PY%" -m ensurepip --upgrade >nul 2>&1

echo [4/6] Installing dependencies (requirements.txt)...
"%VENV_PY%" -m pip install -r requirements.txt
if not %errorlevel%==0 (
  echo ERROR: Dependency installation failed.
  echo Check internet/proxy and try again.
  pause
  exit /b 1
)

echo [5/6] Opening browser...
start "" "http://127.0.0.1:5000"

echo [6/6] Starting local server...
"%VENV_PY%" server.py

endlocal
