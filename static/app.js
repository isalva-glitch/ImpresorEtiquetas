const form = document.getElementById('label-form');
const previewBox = document.getElementById('preview');
const logBox = document.getElementById('log');
const toast = document.getElementById('toast');

const btnPreview = document.getElementById('btn-preview');
const btnPrint = document.getElementById('btn-print');
const btnClear = document.getElementById('btn-clear');
const btnCopy = document.getElementById('btn-copy');

const fieldNames = ['cliente', 'pedido', 'ancho', 'alto', 'descripcion'];

function showToast(message, isError = false) {
  toast.textContent = message;
  toast.style.background = isError ? '#991b1b' : '#111827';
  toast.classList.add('show');
  window.setTimeout(() => toast.classList.remove('show'), 2500);
}

function getPayload() {
  return {
    cliente: form.cliente.value,
    pedido: form.pedido.value,
    ancho: form.ancho.value,
    alto: form.alto.value,
    descripcion: form.descripcion.value,
  };
}

function clearErrors() {
  fieldNames.forEach((name) => {
    const holder = document.querySelector(`[data-error-for="${name}"]`);
    if (holder) {
      holder.textContent = '';
    }
  });
}

function validateClient(payload) {
  const errors = {};

  if (!payload.cliente.trim()) errors.cliente = 'Cliente es obligatorio.';
  if (!payload.pedido.trim()) errors.pedido = 'Nro Pedido es obligatorio.';
  if (!payload.descripcion.trim()) errors.descripcion = 'Descripción del vidrio es obligatoria.';

  const anchoInt = Number(payload.ancho);
  if (!payload.ancho.toString().trim()) {
    errors.ancho = 'Ancho (mm) es obligatorio.';
  } else if (!Number.isInteger(anchoInt) || anchoInt <= 0) {
    errors.ancho = 'Ancho (mm) debe ser entero mayor a 0.';
  }

  const altoInt = Number(payload.alto);
  if (!payload.alto.toString().trim()) {
    errors.alto = 'Alto (mm) es obligatorio.';
  } else if (!Number.isInteger(altoInt) || altoInt <= 0) {
    errors.alto = 'Alto (mm) debe ser entero mayor a 0.';
  }

  return errors;
}

function renderErrors(errors) {
  clearErrors();
  let hasErrors = false;
  Object.entries(errors).forEach(([field, message]) => {
    const holder = document.querySelector(`[data-error-for="${field}"]`);
    if (holder) {
      hasErrors = true;
      holder.textContent = message;
    }
  });
  if (hasErrors) {
    showToast('Hay errores de validación. Revisá los campos.', true);
  }
  return hasErrors;
}

function setLoading(isLoading) {
  btnPreview.disabled = isLoading;
  btnPrint.disabled = isLoading;
  btnClear.disabled = isLoading;
  btnCopy.disabled = isLoading;
  btnPrint.textContent = isLoading ? 'Imprimiendo...' : 'Imprimir';
}

function writeLog(data) {
  const lines = [
    `Comando: ${data.command ?? '(sin comando)'}`,
    `Return code: ${data.returncode ?? '(n/a)'}`,
    '',
    'STDOUT:',
    data.stdout || '(vacío)',
    '',
    'STDERR:',
    data.stderr || '(vacío)',
    '',
    `Archivo local: ${data.output_file || 'C:\\prueba_etiqueta.txt'}`,
  ];

  logBox.textContent = lines.join('\n');
}

async function requestPreview() {
  const payload = getPayload();
  const clientErrors = validateClient(payload);
  if (renderErrors(clientErrors)) return;

  try {
    const response = await fetch('/api/preview', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    const data = await response.json();

    if (!response.ok) {
      renderErrors({});
      if (data.errors) {
        showToast(data.errors.join(' | '), true);
      } else {
        showToast(data.message || 'Error generando preview.', true);
      }
      return;
    }

    previewBox.value = data.zpl;
    showToast('Preview generado correctamente.');
  } catch (error) {
    showToast(`Error de red al generar preview: ${error}`, true);
  }
}

async function requestPrint() {
  const payload = getPayload();
  const clientErrors = validateClient(payload);
  if (renderErrors(clientErrors)) return;

  setLoading(true);
  try {
    const response = await fetch('/api/print', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    const data = await response.json();

    if (data.zpl) {
      previewBox.value = data.zpl;
    }

    writeLog(data);

    if (!response.ok || !data.ok) {
      if (data.errors) {
        showToast(data.errors.join(' | '), true);
      } else {
        showToast('Falló la impresión. Revisá el panel de log.', true);
      }
      return;
    }

    showToast('Impresión enviada correctamente.');
  } catch (error) {
    logBox.textContent = `Error de red en impresión: ${error}`;
    showToast(`Error de red en impresión: ${error}`, true);
  } finally {
    setLoading(false);
  }
}

btnPreview.addEventListener('click', requestPreview);
btnPrint.addEventListener('click', requestPrint);

btnClear.addEventListener('click', () => {
  form.reset();
  clearErrors();
  previewBox.value = '';
  logBox.textContent = 'Sin actividad.';
  showToast('Formulario limpiado.');
});

btnCopy.addEventListener('click', async () => {
  if (!previewBox.value.trim()) {
    showToast('No hay preview para copiar.', true);
    return;
  }

  try {
    await navigator.clipboard.writeText(previewBox.value);
    showToast('Preview copiado al portapapeles.');
  } catch (error) {
    showToast(`No se pudo copiar: ${error}`, true);
  }
});
