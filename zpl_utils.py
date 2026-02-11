import re

TEMPLATE_ZPL = """^XA

^XFR:EXPEDI.GRF

^FX Nombre del cliente, despues de FD
^FN1^FDIvan  Salva^FS


^FX Numero de Pedido, despues de FD
^FN2^FD22654^FS



^FX Dejar vacios, no cambiar
^FN3^FD^FS
^FN4^FD^FS
^FN5^FD^FS

^FX Ancho de vidrio, despues de FD
^FN6^FD500^FS


^FX Alto de vidrio, despues de FD
^FN7^FD1200^FS

^FX Dejar vacios, no cambiar
^FN8^FD^FS


^FX Composicion ej: Float 3mm Incoloro, Templado 8mm Incoloro, Laminado 4+4 Incoloro, etc, despues de FD
^FN9^FDMirage 4 mm. Incoloro + con filos matados^FS


^FX Lugar para el codigo de barras, no cambiar de momento
^FN10^FD820226540100101^FS


^FX Dejar vacios, no cambiar
^FN11^FD3^FS

^XZ^
"""


def replace_fn_field(zpl: str, fn_number: int, value: str) -> str:
    pattern = rf"(\^FN{fn_number}\^FD)(.*?)(\^FS)"
    return re.sub(pattern, lambda m: f"{m.group(1)}{value}{m.group(3)}", zpl)


def build_final_zpl(template_zpl: str, cliente: str, pedido: str, ancho: str, alto: str, descripcion: str) -> str:
    final_zpl = template_zpl
    final_zpl = replace_fn_field(final_zpl, 1, cliente)
    final_zpl = replace_fn_field(final_zpl, 2, pedido)
    final_zpl = replace_fn_field(final_zpl, 6, ancho)
    final_zpl = replace_fn_field(final_zpl, 7, alto)
    final_zpl = replace_fn_field(final_zpl, 9, descripcion)
    return final_zpl
