@echo off
setlocal enabledelayedexpansion

REM Ir al directorio donde está este .bat
cd /d "%~dp0"

echo ==========================================
echo   ImpresorEtiquetas - Inicio automatico
echo ==========================================

echo [1/4] Verificando Python...
where python >nul 2>&1
if errorlevel 1 (
  echo ERROR: No se encontro Python en PATH.
  echo Instala Python 3.10+ y volve a intentar.
  pause
  exit /b 1
)

echo [2/4] Creando entorno virtual (.venv) si no existe...
if not exist ".venv\Scripts\python.exe" (
  python -m venv .venv
  if errorlevel 1 (
    echo ERROR: No se pudo crear el entorno virtual.
    pause
    exit /b 1
  )
)

echo [3/4] Instalando/actualizando dependencias...
call ".venv\Scripts\activate.bat"
python -m pip install --upgrade pip
pip install -r requirements.txt
if errorlevel 1 (
  echo ERROR: Fallo la instalacion de dependencias.
  echo Revisa conexion a internet/proxy y volve a intentar.
  pause
  exit /b 1
)

echo [4/4] Iniciando servidor y abriendo Chrome...
start "Chrome" "chrome" "http://127.0.0.1:5000"
python server.py

endlocal
