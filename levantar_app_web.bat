@echo off
setlocal EnableExtensions

cd /d "%~dp0"

echo =========================================
echo   ImpresorEtiquetas - Inicio
echo =========================================

REM Si tu Python esta instalado en otra ruta, cambia esta variable.
set "PYTHON_EXE=C:\Users\windows\AppData\Local\Programs\Python\Python314\python.exe"

echo [1/5] Buscando Python...
if exist "%PYTHON_EXE%" goto :python_ok

REM Fallback: launcher de Python
where py >nul 2>&1
if not errorlevel 1 (
  py -3 -c "import sys" >nul 2>&1
  if not errorlevel 1 (
    set "PYTHON_CMD=py -3"
    goto :python_ok
  )
)

REM Fallback: python en PATH
where python >nul 2>&1
if not errorlevel 1 (
  python -c "import sys" >nul 2>&1
  if not errorlevel 1 (
    set "PYTHON_CMD=python"
    goto :python_ok
  )
)

echo ERROR: No se encontro Python funcional.
echo - Verifica la ruta en PYTHON_EXE dentro de este .bat
echo - O instala Python 3.10+ y marca "Add Python to PATH"
pause
exit /b 1

:python_ok
if defined PYTHON_CMD (
  echo Python detectado via comando: %PYTHON_CMD%
) else (
  echo Python detectado via ruta: %PYTHON_EXE%
)

echo [2/5] Creando .venv si no existe...
if not exist ".venv\Scripts\python.exe" (
  if defined PYTHON_CMD (
    %PYTHON_CMD% -m venv .venv
  ) else (
    "%PYTHON_EXE%" -m venv .venv
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

echo [3/5] Instalando dependencias...
"%VENV_PY%" -m pip install -r requirements.txt
if errorlevel 1 (
  echo ERROR: Fallo la instalacion de dependencias.
  pause
  exit /b 1
)

echo [4/5] Abriendo navegador...
start "" "http://127.0.0.1:5000"

echo [5/5] Iniciando servidor...
"%VENV_PY%" server.py

endlocal
