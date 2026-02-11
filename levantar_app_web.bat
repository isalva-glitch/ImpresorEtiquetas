@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

REM Ir al directorio donde está este .bat
cd /d "%~dp0"

echo ==========================================
echo   ImpresorEtiquetas - Inicio automatico
echo ==========================================

echo [1/5] Detectando interprete de Python...
set "PY_CMD="

REM Prioridad 1: py launcher (evita el alias de Microsoft Store)
where py >nul 2>&1
if not errorlevel 1 (
  py -3 -c "import sys" >nul 2>&1
  if not errorlevel 1 (
    set "PY_CMD=py -3"
  )
)

REM Prioridad 2: python en PATH
if not defined PY_CMD (
  where python >nul 2>&1
  if not errorlevel 1 (
    python -c "import sys" >nul 2>&1
    if not errorlevel 1 (
      set "PY_CMD=python"
    )
  )
)

if not defined PY_CMD (
  echo ERROR: No se encontró una instalación funcional de Python.
  echo Sugerencia: instala Python 3.10+ desde python.org y marca "Add Python to PATH".
  echo Si aparece el mensaje de Microsoft Store, desactiva el alias de "python.exe" en:
  echo Configuración ^> Aplicaciones ^> Configuración avanzada de aplicaciones ^> Alias de ejecución.
  pause
  exit /b 1
)

echo Python detectado: %PY_CMD%

echo [2/5] Creando entorno virtual (.venv) si no existe...
if not exist ".venv\Scripts\python.exe" (
  %PY_CMD% -m venv .venv
  if errorlevel 1 (
    echo ERROR: No se pudo crear el entorno virtual.
    pause
    exit /b 1
  )
)

echo [3/5] Activando entorno virtual...
call ".venv\Scripts\activate.bat"
if errorlevel 1 (
  echo ERROR: No se pudo activar el entorno virtual.
  pause
  exit /b 1
)

echo [4/5] Instalando/actualizando dependencias...
python -m pip install --upgrade pip
pip install -r requirements.txt
if errorlevel 1 (
  echo ERROR: Falló la instalación de dependencias.
  echo Revisa conexión a internet/proxy y volvé a intentar.
  pause
  exit /b 1
)

echo [5/5] Iniciando servidor y abriendo Chrome...
start "Chrome" "chrome" "http://127.0.0.1:5000"
python server.py

endlocal
