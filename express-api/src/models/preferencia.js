// Modelo: preferencia_notificacion (por que canal quiere cada usuario recibir avisos)
module.exports = {
  tabla: 'preferencia_notificacion',
  ruta: 'preferencias',
  singular: 'Preferencia',
  propietario: 'id_usuario',
  campos: {
    id_usuario: { tipo: 'int', requerido: true },
    id_canal: { tipo: 'int', requerido: true },
  },
  extra: ', c.nombre AS canal',
  joins: 'JOIN canal_notificacion c ON c.id = t.id_canal',
};
