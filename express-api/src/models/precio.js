// Modelo: precio_externo (precio de un producto en otro mercado en una fecha)
module.exports = {
  tabla: 'precio_externo',
  ruta: 'precios',
  singular: 'Precio',
  campos: {
    mercado_id: { tipo: 'int', requerido: true },
    producto_id: { tipo: 'int', requerido: true },
    precio: { tipo: 'numero', requerido: true, min: 0 },
    fecha: { tipo: 'fecha', requerido: true },
  },
  // Para mostrar nombres en lugar de solo ids
  extra: ', m.nombre AS mercado, p.nombre AS producto, p.unidad',
  joins: 'JOIN mercado_externo m ON m.id = t.mercado_id JOIN producto_externo p ON p.id = t.producto_id',
};
