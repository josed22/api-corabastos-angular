// Modelo: mercado_externo (otros mercados / centrales de abasto de referencia)
module.exports = {
  tabla: 'mercado_externo',
  ruta: 'mercados',
  singular: 'Mercado',
  campos: {
    nombre: { tipo: 'string', requerido: true, max: 100 },
    ciudad: { tipo: 'string', requerido: true, max: 80 },
    tipo: { tipo: 'enum', valores: ['mayorista', 'minorista'], defecto: 'mayorista' },
  },
};
