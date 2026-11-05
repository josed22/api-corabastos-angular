// Registra una ruta por modelo: /favoritos, /alertas, /canales, /preferencias, /notificaciones
// Todas exigen el JWT emitido por la API principal.
const express = require('express');
const modelos = require('../models');
const BaseRepository = require('../repositories/baseRepository');
const { autenticar } = require('../core/auth');
const crearRutas = require('./crearRutas');

const router = express.Router();
for (const modelo of modelos) {
  router.use('/' + modelo.ruta, autenticar, crearRutas(modelo, new BaseRepository(modelo)));
}
module.exports = router;
