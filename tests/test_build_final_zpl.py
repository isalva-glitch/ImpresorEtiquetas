from pathlib import Path
import sys

sys.path.append(str(Path(__file__).resolve().parents[1]))

from zpl_utils import TEMPLATE_ZPL, build_final_zpl


def test_build_final_zpl_replaces_only_required_fields():
    result = build_final_zpl(
        TEMPLATE_ZPL,
        "Cliente X",
        "123",
        "500",
        "1000",
        "Templado 8mm",
    )

    assert "^FN1^FDCliente X^FS" in result
    assert "^FN2^FD123^FS" in result
    assert "^FN6^FD500^FS" in result
    assert "^FN7^FD1000^FS" in result
    assert "^FN9^FDTemplado 8mm^FS" in result
