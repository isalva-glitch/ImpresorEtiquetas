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
Tambien podes levantar todo con doble click en:
- `levantar_app_web.bat`

Script simplificado:
1. Usa `PYTHON_EXE` (ruta fija editable dentro del `.bat`) como primera opcion.
2. Si no existe, intenta `py -3` y luego `python` en PATH.
3. Crea `.venv` si no existe.
4. Instala dependencias con `.venv\Scripts\python.exe -m pip install -r requirements.txt`.
5. Abre `http://127.0.0.1:5000` e inicia `server.py`.

Si tu Python no esta en la ruta por defecto, edita la variable `PYTHON_EXE` al inicio del `.bat`.

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
Si ves un mensaje como "Python was not found" o redireccion a Microsoft Store, desactiva el alias de `python.exe` en:

`Settings > Apps > Advanced app settings > App execution aliases`

Luego vuelve a ejecutar `levantar_app_web.bat`.


