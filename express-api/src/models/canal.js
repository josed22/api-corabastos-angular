// Modelo: canal_notificacion (catalogo: aplicacion, correo, WhatsApp, Telegram)
module.exports = {
  tabla: 'canal_notificacion',
  ruta: 'canales',
  singular: 'Canal',
  soloAdminEscritura: true, // todos pueden leerlo; solo el administrador lo modifica
  campos: {
    nombre: { tipo: 'string', requerido: true, max: 40 },
  },
};
