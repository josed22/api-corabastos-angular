// Capa de rutas: genera los 5 endpoints CRUD de un modelo.
// Reglas de acceso:
//  - modelo.propietario (p. ej. id_usuario): el usuario solo ve y modifica lo suyo; el Administrador ve todo.
//  - modelo.soloAdminEscritura: cualquier usuario autenticado lee, solo el Administrador escribe.
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
  const esAdmin = (req) => req.usuario.rol === 'Administrador';
  const duenoDe = (req, fila) => esAdmin(req) || !modelo.propietario || fila[modelo.propietario] === req.usuario.id;

  const soloAdmin = (req, res, next) =>
    modelo.soloAdminEscritura && !esAdmin(req) ? next(new ErrorHttp(403, 'Solo el Administrador puede modificar este recurso')) : next();

  router.get('/', asyncHandler(async (req, res) => {
    const filtros = modelo.propietario && !esAdmin(req) ? { [modelo.propietario]: req.usuario.id } : {};
    res.json(await repo.obtenerTodos(filtros));
  }));

  router.get('/:id', asyncHandler(async (req, res) => {
    const fila = await repo.obtenerPorId(idValido(req.params.id));
    if (!fila || !duenoDe(req, fila)) throw noExiste();
    res.json(fila);
  }));

  router.post('/', soloAdmin, asyncHandler(async (req, res) => {
    const cuerpo = { ...req.body };
    if (modelo.propietario && !esAdmin(req)) cuerpo[modelo.propietario] = req.usuario.id; // siempre a su nombre
    const { datos, errores } = validar(modelo, cuerpo);
    if (errores.length) throw new ErrorHttp(400, 'Datos invalidos', errores);
    res.status(201).json(await repo.crear(datos));
  }));

  router.put('/:id', soloAdmin, asyncHandler(async (req, res) => {
    const id = idValido(req.params.id);
    const actual = await repo.obtenerPorId(id);
    if (!actual || !duenoDe(req, actual)) throw noExiste();
    const cuerpo = { ...req.body };
    if (modelo.propietario && !esAdmin(req)) delete cuerpo[modelo.propietario]; // no se puede cambiar de dueno
    const { datos, errores } = validar(modelo, cuerpo, { parcial: true });
    if (errores.length) throw new ErrorHttp(400, 'Datos invalidos', errores);
    res.json(await repo.actualizar(id, datos));
  }));

  router.delete('/:id', soloAdmin, asyncHandler(async (req, res) => {
    const id = idValido(req.params.id);
    const actual = await repo.obtenerPorId(id);
    if (!actual || !duenoDe(req, actual)) throw noExiste();
    await repo.eliminar(id);
    res.json({ mensaje: `${modelo.singular} eliminado` });
  }));

  return router;
};
