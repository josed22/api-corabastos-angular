// Modelo: producto_externo (catalogo de productos de referencia)
module.exports = {
  tabla: 'producto_externo',
  ruta: 'productos',
  singular: 'Producto',
  campos: {
    nombre: { tipo: 'string', requerido: true, max: 80 },
    categoria: { tipo: 'string', requerido: true, max: 40 },
    unidad: { tipo: 'string', max: 20, defecto: 'kg' },
  },
};
