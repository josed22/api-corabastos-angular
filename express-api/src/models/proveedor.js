// Modelo: proveedor_externo (productores que ofrecen producto a la central)
module.exports = {
  tabla: 'proveedor_externo',
  ruta: 'proveedores',
  singular: 'Proveedor',
  campos: {
    nombre: { tipo: 'string', requerido: true, max: 120 },
    nit: { tipo: 'string', requerido: true, max: 20 },
    correo: { tipo: 'email', requerido: true },
    telefono: { tipo: 'string', max: 20 },
    municipio_origen: { tipo: 'string', requerido: true, max: 80 },
  },
};
