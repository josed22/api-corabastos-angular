// Modelo: alerta_precio (aviso cuando el precio de un producto sube o baja un porcentaje)
module.exports = {
  tabla: 'alerta_precio',
  ruta: 'alertas',
  singular: 'Alerta',
  propietario: 'id_usuario',
  campos: {
    id_usuario: { tipo: 'int', requerido: true },
    id_producto: { tipo: 'int', requerido: true },
    tipo: { tipo: 'enum', valores: ['sube', 'baja'], requerido: true },
    umbral: { tipo: 'numero', requerido: true, min: 0.01 },
  },
};
