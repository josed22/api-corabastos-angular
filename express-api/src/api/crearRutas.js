// Capa de rutas: genera los 5 endpoints CRUD de un modelo.
const express = require('express');
const { asyncHandler, ErrorHttp } = require('../core/errores');
const { validar } = require('../models/validar');

function idValido(valor) {
  const id = Number(valor);
  if (!Number.isInteger(id) || id < 1) throw new ErrorHttp(400, 'El id debe ser un numero entero positivo');
  return id;
}

module.exports = function crearRutas(modelo, repo) {
  const router = express.Router();
  const noExiste = () => new ErrorHttp(404, `${modelo.singular} no encontrado`);

  router.get('/', asyncHandler(async (req, res) => res.json(await repo.obtenerTodos())));

  router.get('/:id', asyncHandler(async (req, res) => {
    const fila = await repo.obtenerPorId(idValido(req.params.id));
    if (!fila) throw noExiste();
    res.json(fila);
  }));

  router.post('/', asyncHandler(async (req, res) => {
    const { datos, errores } = validar(modelo, req.body);
    if (errores.length) throw new ErrorHttp(400, 'Datos invalidos', errores);
    res.status(201).json(await repo.crear(datos));
  }));

  router.put('/:id', asyncHandler(async (req, res) => {
    const id = idValido(req.params.id);
    const { datos, errores } = validar(modelo, req.body, { parcial: true });
    if (errores.length) throw new ErrorHttp(400, 'Datos invalidos', errores);
    const fila = await repo.actualizar(id, datos);
    if (!fila) throw noExiste();
    res.json(fila);
  }));

  router.delete('/:id', asyncHandler(async (req, res) => {
    if (!(await repo.eliminar(idValido(req.params.id)))) throw noExiste();
    res.json({ mensaje: `${modelo.singular} eliminado` });
  }));

  return router;
};
