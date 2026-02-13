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
  if not errorlevel 1 set "PY_MODE=LAUNCHER"
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
    "%LocalAppData%\Programs\Python\Python314\python.exe"
    "%LocalAppData%\Programs\Python\Python313\python.exe"
    "%LocalAppData%\Programs\Python\Python312\python.exe"
    "%LocalAppData%\Programs\Python\Python311\python.exe"
    "%LocalAppData%\Programs\Python\Python310\python.exe"
    "%ProgramFiles%\Python314\python.exe"
    "%ProgramFiles%\Python313\python.exe"
    "%ProgramFiles%\Python312\python.exe"
    "%ProgramFiles%\Python311\python.exe"
    "%ProgramFiles%\Python310\python.exe"
    "%ProgramFiles(x86)%\Python314\python.exe"
    "%ProgramFiles(x86)%\Python313\python.exe"
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

REM Opcion D: rutas de accesos directos del Start Menu (como la que compartiste)
if not defined PY_MODE (
  for %%D in (
    "%AppData%\Microsoft\Windows\Start Menu\Programs\Python\Python 3.14"
    "%AppData%\Microsoft\Windows\Start Menu\Programs\Python\Python 3.13"
    "%AppData%\Microsoft\Windows\Start Menu\Programs\Python\Python 3.12"
    "%AppData%\Microsoft\Windows\Start Menu\Programs\Python\Python 3.11"
    "%AppData%\Microsoft\Windows\Start Menu\Programs\Python\Python 3.10"
  ) do (
    if exist "%%~D" (
      for %%L in ("%%~D\*.lnk") do (
        if exist "%%~fL" (
          for /f "usebackq delims=" %%T in (`powershell -NoProfile -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%%~fL').TargetPath; if($s){Write-Output $s}"`) do (
            if exist "%%~T" (
              "%%~T" -c "import sys" >nul 2>&1
              if not errorlevel 1 (
                set "PY_MODE=EXE"
                set "PY_EXE=%%~T"
                goto :python_found
              )
            )
          )
        )
      )
    )
  )
)

REM Opcion E: ingreso manual (acepta exe, carpeta o .lnk)
if not defined PY_MODE (
  echo.
  echo No se pudo detectar Python automaticamente.
  echo Pega la ruta de python.exe, o una carpeta de Python, o un .lnk de Python.
  echo Ejemplo 1: C:\Users\windows\AppData\Local\Programs\Python\Python314\python.exe
  echo Ejemplo 2: C:\Users\windows\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Python\Python 3.14
  set /p "MANUAL_PY=Ruta (ENTER para cancelar): "

  if defined MANUAL_PY (
    set "CAND=!MANUAL_PY!"

    REM Si es carpeta, intentar python.exe dentro
    if exist "!CAND!\" (
      if exist "!CAND!\python.exe" set "CAND=!CAND!\python.exe"
    )

    REM Si es .lnk, resolver target
    if /I "!CAND:~-4!"==".lnk" (
      for /f "usebackq delims=" %%T in (`powershell -NoProfile -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('!CAND!').TargetPath; if($s){Write-Output $s}"`) do (
        set "CAND=%%~T"
      )
    )

    REM Si es carpeta con .lnk, tomar el primer acceso directo
    if exist "!CAND!\" (
      for %%L in ("!CAND!\*.lnk") do (
        for /f "usebackq delims=" %%T in (`powershell -NoProfile -Command "$s=(New-Object -ComObject WScript.Shell).CreateShortcut('%%~fL').TargetPath; if($s){Write-Output $s}"`) do (
          set "CAND=%%~T"
          goto :manual_candidate_ready
        )
      )
    )

:manual_candidate_ready
    if exist "!CAND!" (
      "!CAND!" -c "import sys" >nul 2>&1
      if not errorlevel 1 (
        set "PY_MODE=EXE"
        set "PY_EXE=!CAND!"
        goto :python_found
      ) else (
        echo ERROR: La ruta indicada no parece ser un Python funcional.
      )
    ) else (
      echo ERROR: La ruta indicada no existe.
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
