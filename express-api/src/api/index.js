// Registra una ruta por modelo: /mercados, /proveedores, /productos, /precios, /ofertas
const express = require('express');
const modelos = require('../models');
const BaseRepository = require('../repositories/baseRepository');
const crearRutas = require('./crearRutas');

const router = express.Router();
for (const modelo of modelos) {
  router.use('/' + modelo.ruta, crearRutas(modelo, new BaseRepository(modelo)));
}
module.exports = router;
