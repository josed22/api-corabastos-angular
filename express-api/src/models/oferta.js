// Modelo: oferta_proveedor (producto que un proveedor tiene disponible)
module.exports = {
  tabla: 'oferta_proveedor',
  ruta: 'ofertas',
  singular: 'Oferta',
  campos: {
    proveedor_id: { tipo: 'int', requerido: true },
    producto_id: { tipo: 'int', requerido: true },
    cantidad_kg: { tipo: 'numero', requerido: true, min: 0 },
    precio_kg: { tipo: 'numero', requerido: true, min: 0 },
    disponible_hasta: { tipo: 'fecha', requerido: true },
  },
  extra: ', pv.nombre AS proveedor, p.nombre AS producto',
  joins: 'JOIN proveedor_externo pv ON pv.id = t.proveedor_id JOIN producto_externo p ON p.id = t.producto_id',
};
