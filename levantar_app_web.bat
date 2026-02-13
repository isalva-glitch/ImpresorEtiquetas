@echo off
setlocal EnableExtensions EnableDelayedExpansion

cd /d "%~dp0"

echo =========================================
echo   ImpresorEtiquetas - Startup helper
echo =========================================

echo [1/6] Detectando Python...
set "PY_MODE="
set "PY_EXE="

REM Opcion A: Python Launcher
where py >nul 2>&1
if not errorlevel 1 (
  py -3 -c "import sys" >nul 2>&1
  if not errorlevel 1 (
    set "PY_MODE=LAUNCHER"
  )
)

REM Opcion B: python en PATH
if not defined PY_MODE (
  where python >nul 2>&1
  if not errorlevel 1 (
    python -c "import sys" >nul 2>&1
    if not errorlevel 1 (
      set "PY_MODE=EXE"
      for /f "delims=" %%I in ('where python 2^>nul') do (
        set "PY_EXE=%%I"
        goto :python_found
      )
    )
  )
)

REM Opcion C: rutas comunes de instalacion
if not defined PY_MODE (
  for %%P in (
    "%LocalAppData%\Programs\Python\Python312\python.exe"
    "%LocalAppData%\Programs\Python\Python311\python.exe"
    "%LocalAppData%\Programs\Python\Python310\python.exe"
    "%ProgramFiles%\Python312\python.exe"
    "%ProgramFiles%\Python311\python.exe"
    "%ProgramFiles%\Python310\python.exe"
    "%ProgramFiles(x86)%\Python312\python.exe"
    "%ProgramFiles(x86)%\Python311\python.exe"
    "%ProgramFiles(x86)%\Python310\python.exe"
  ) do (
    if exist "%%~P" (
      "%%~P" -c "import sys" >nul 2>&1
      if not errorlevel 1 (
        set "PY_MODE=EXE"
        set "PY_EXE=%%~P"
        goto :python_found
      )
    )
  )
)

:python_found
if not defined PY_MODE (
  echo ERROR: No se encontro una instalacion funcional de Python.
  echo.
  echo Soluciones:
  echo  1) Instalar Python 3.10+ desde https://www.python.org/downloads/
  echo  2) Marcar "Add Python to PATH" durante la instalacion
  echo  3) Desactivar alias Microsoft Store de python.exe en:
  echo     Settings ^> Apps ^> Advanced app settings ^> App execution aliases
  pause
  exit /b 1
)

if "%PY_MODE%"=="LAUNCHER" (
  echo Python detectado: py -3
) else (
  echo Python detectado: %PY_EXE%
)

echo [2/6] Creando entorno virtual (.venv) si no existe...
if not exist ".venv\Scripts\python.exe" (
  if "%PY_MODE%"=="LAUNCHER" (
    py -3 -m venv .venv
  ) else (
    "%PY_EXE%" -m venv .venv
  )

  if errorlevel 1 (
    echo ERROR: No se pudo crear .venv
    pause
    exit /b 1
  )
)

set "VENV_PY=.venv\Scripts\python.exe"
if not exist "%VENV_PY%" (
  echo ERROR: No existe %VENV_PY%
  pause
  exit /b 1
)

echo [3/6] Verificando pip en entorno virtual...
"%VENV_PY%" -m ensurepip --upgrade >nul 2>&1

echo [4/6] Instalando dependencias...
"%VENV_PY%" -m pip install -r requirements.txt
if errorlevel 1 (
  echo ERROR: Fallo la instalacion de dependencias.
  pause
  exit /b 1
)

echo [5/6] Abriendo navegador...
start "" "http://127.0.0.1:5000"

echo [6/6] Iniciando servidor...
"%VENV_PY%" server.py

endlocal
