// Errores de la API y manejo central (middleware).
class ErrorHttp extends Error {
  constructor(status, mensaje, detalles) {
    super(mensaje);
    this.status = status;
    this.detalles = detalles;
  }
}

// Envuelve un controlador async para que cualquier error llegue al middleware.
const asyncHandler = (fn) => (req, res, next) => Promise.resolve(fn(req, res, next)).catch(next);

const noEncontrado = (req, res) => res.status(404).json({ error: 'Ruta no encontrada' });

// eslint-disable-next-line no-unused-vars
const manejarErrores = (err, req, res, next) => {
  if (err instanceof ErrorHttp) {
    return res.status(err.status).json({ error: err.message, ...(err.detalles && { detalles: err.detalles }) });
  }
  if (err.type === 'entity.parse.failed') return res.status(400).json({ error: 'El cuerpo no es un JSON valido' });
  // Errores de MySQL mas comunes
  if (err.code === 'ER_DUP_ENTRY') return res.status(409).json({ error: 'Ya existe un registro con ese valor unico' });
  if (err.code === 'ER_NO_REFERENCED_ROW_2') return res.status(400).json({ error: 'El registro relacionado no existe' });
  console.error(err);
  res.status(500).json({ error: 'Error interno del servidor' });
};

module.exports = { ErrorHttp, asyncHandler, noEncontrado, manejarErrores };
