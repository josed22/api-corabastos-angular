// Validacion de los datos de entrada segun la definicion de campos de cada modelo.
const validadores = {
  string: (v, c) => typeof v === 'string' && v.trim() !== '' && v.length <= (c.max || 255),
  email: (v) => typeof v === 'string' && /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(v) && v.length <= 150,
  int: (v, c) => Number.isInteger(Number(v)) && v !== '' && Number(v) >= (c.min ?? 1),
  numero: (v, c) => v !== '' && v !== null && !isNaN(Number(v)) && Number(v) >= (c.min ?? 0),
  fecha: (v) => typeof v === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(v) && !isNaN(Date.parse(v)),
  enum: (v, c) => c.valores.includes(v),
};

/**
 * Devuelve { datos, errores }. Con parcial = true (PUT) solo se validan los campos recibidos.
 * Campos desconocidos (id, estado, creado, actualizado...) se ignoran: no se pueden enviar desde fuera.
 */
function validar(modelo, body, { parcial = false } = {}) {
  const datos = {};
  const errores = [];
  const entrada = body && typeof body === 'object' ? body : {};
  for (const [campo, def] of Object.entries(modelo.campos)) {
    const valor = entrada[campo];
    const vacio = valor === undefined || valor === null || valor === '';
    if (vacio) {
      if (def.requerido && !parcial && def.defecto === undefined) errores.push(`${campo} es obligatorio`);
      continue;
    }
    if (!validadores[def.tipo](valor, def)) {
      errores.push(`${campo} no es valido${def.valores ? ' (use: ' + def.valores.join(', ') + ')' : ''}`);
      continue;
    }
    datos[campo] = def.tipo === 'int' || def.tipo === 'numero' ? Number(valor) : typeof valor === 'string' ? valor.trim() : valor;
  }
  if (parcial && Object.keys(datos).length === 0 && errores.length === 0) errores.push('No se envio ningun campo para actualizar');
  return { datos, errores };
}

module.exports = { validar };
