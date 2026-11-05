// Modelo: notificacion (aviso generado por una alerta y enviado por un canal)
module.exports = {
  tabla: 'notificacion',
  ruta: 'notificaciones',
  singular: 'Notificacion',
  propietario: 'id_usuario',
  campos: {
    id_usuario: { tipo: 'int', requerido: true },
    id_alerta: { tipo: 'int', requerido: true },
    id_canal: { tipo: 'int', requerido: true },
    mensaje: { tipo: 'string', requerido: true, max: 255 },
    leida: { tipo: 'bool' },
  },
  extra: ', c.nombre AS canal, a.tipo AS tipo_alerta, a.id_producto',
  joins: 'JOIN canal_notificacion c ON c.id = t.id_canal JOIN alerta_precio a ON a.id = t.id_alerta',
};
