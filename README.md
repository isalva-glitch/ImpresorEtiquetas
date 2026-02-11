# ImpresorEtiquetas (Web + Backend local)

Aplicación web (single page) para cargar datos de una etiqueta Zebra en ZPL, ver preview y enviar impresión usando flujo Windows (`cmd.exe`) vía backend local en Python.

## Requisitos
- Python 3.10+
- Windows para el flujo real de impresión (`cmd`, `net use`, `copy /b`)
- Acceso de red a `\\10.0.0.1\ZebraS600`

## Instalación
```bash
pip install -r requirements.txt
```

## Ejecución
```bash
python server.py
```

Abrir en Chrome:
- http://127.0.0.1:5000


## Inicio rapido en Windows (.bat)
También podés levantar todo con doble click en:
- `levantar_app_web.bat`

Este script:
1. Detecta Python funcional (prioriza `py -3` para evitar el alias de Microsoft Store)
2. Crea `.venv` si no existe
3. Instala dependencias desde `requirements.txt`
4. Abre Chrome en `http://127.0.0.1:5000` y ejecuta `server.py`

## Endpoints
- `POST /api/preview`: valida campos y devuelve `zpl` final.
- `POST /api/print`: valida, genera ZPL, guarda en `C:\prueba_etiqueta.txt`, ejecuta comando de impresión y devuelve `returncode/stdout/stderr`.
- `GET /api/template`: devuelve el template base.

## Comando de impresión fijo
El backend ejecuta exactamente:

```cmd
cmd /c "net use \\10.0.0.1\ZebraS600 && copy /b C:\prueba_etiqueta.txt \\10.0.0.1\ZebraS600 && net use \\10.0.0.1\ZebraS600 /delete"
```

## Notas operativas
- El frontend no escribe en `C:\` ni ejecuta `cmd`; eso lo hace el backend local.
- Si la impresión falla, el backend devuelve `stdout/stderr` para mostrar en el panel de log.
- El archivo local `C:\prueba_etiqueta.txt` no se borra ante error.

## Testing
```bash
python -m py_compile server.py
pytest -q
```

### Error frecuente en Windows (alias de Microsoft Store)
Si ves un mensaje como "no se encontró Python; ejecutar sin argumentos para instalar desde Microsoft Store", desactiva el alias de ejecución de `python.exe` en:

`Configuración > Aplicaciones > Configuración avanzada de aplicaciones > Alias de ejecución de aplicaciones`

El `.bat` nuevo intenta evitar este problema usando `py -3` primero.
