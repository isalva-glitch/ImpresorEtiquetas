import subprocess
from pathlib import Path

from flask import Flask, jsonify, request, send_from_directory

from zpl_utils import TEMPLATE_ZPL, build_final_zpl

app = Flask(__name__, static_folder="static", static_url_path="/static")

OUTPUT_FILE = Path(r"C:\prueba_etiqueta.txt")
PRINT_COMMAND = 'cmd /c "net use \\\\10.0.0.1\\ZebraS600 && copy /b C:\\prueba_etiqueta.txt \\\\10.0.0.1\\ZebraS600 && net use \\\\10.0.0.1\\ZebraS600 /delete"'


def validate_payload(data: dict) -> list[str]:
    errors: list[str] = []

    cliente = str(data.get("cliente", ""))
    pedido = str(data.get("pedido", ""))
    ancho = str(data.get("ancho", ""))
    alto = str(data.get("alto", ""))
    descripcion = str(data.get("descripcion", ""))

    if not cliente.strip():
        errors.append("Cliente es obligatorio.")
    if not pedido.strip():
        errors.append("Nro Pedido es obligatorio.")
    if not descripcion.strip():
        errors.append("Descripción del vidrio es obligatoria.")

    for field_name, raw_value in (("Ancho (mm)", ancho), ("Alto (mm)", alto)):
        if not raw_value.strip():
            errors.append(f"{field_name} es obligatorio.")
            continue

        try:
            value = int(raw_value)
            if value <= 0:
                errors.append(f"{field_name} debe ser un entero mayor a 0.")
        except ValueError:
            errors.append(f"{field_name} debe ser un entero válido.")

    return errors


def _extract_fields(data: dict) -> tuple[str, str, str, str, str]:
    return (
        str(data.get("cliente", "")).strip(),
        str(data.get("pedido", "")).strip(),
        str(data.get("ancho", "")).strip(),
        str(data.get("alto", "")).strip(),
        str(data.get("descripcion", "")).strip(),
    )


@app.get("/")
def index():
    return send_from_directory("static", "index.html")


@app.get("/api/template")
def get_template():
    return jsonify({"template": TEMPLATE_ZPL})


@app.post("/api/preview")
def preview():
    data = request.get_json(silent=True) or {}
    errors = validate_payload(data)
    if errors:
        return jsonify({"ok": False, "errors": errors}), 400

    cliente, pedido, ancho, alto, descripcion = _extract_fields(data)
    zpl = build_final_zpl(TEMPLATE_ZPL, cliente, pedido, ancho, alto, descripcion)
    return jsonify({"ok": True, "zpl": zpl})


@app.post("/api/print")
def print_label():
    data = request.get_json(silent=True) or {}
    errors = validate_payload(data)
    if errors:
        return jsonify({"ok": False, "errors": errors}), 400

    cliente, pedido, ancho, alto, descripcion = _extract_fields(data)
    zpl = build_final_zpl(TEMPLATE_ZPL, cliente, pedido, ancho, alto, descripcion)

    try:
        OUTPUT_FILE.write_text(zpl, encoding="utf-8")
    except Exception as exc:
        return jsonify({"ok": False, "message": f"No se pudo guardar el archivo local: {exc}"}), 500

    try:
        result = subprocess.run(PRINT_COMMAND, shell=True, capture_output=True, text=True)
    except Exception as exc:
        return jsonify({"ok": False, "message": f"No se pudo ejecutar el comando de impresión: {exc}"}), 500

    response = {
        "ok": result.returncode == 0,
        "returncode": result.returncode,
        "stdout": result.stdout,
        "stderr": result.stderr,
        "output_file": str(OUTPUT_FILE),
        "command": PRINT_COMMAND,
        "zpl": zpl,
    }

    if result.returncode != 0:
        return jsonify(response), 500

    return jsonify(response)


if __name__ == "__main__":
    app.run(host="127.0.0.1", port=5000, debug=False)
