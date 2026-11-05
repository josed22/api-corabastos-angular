// Modelo: favorito (productos que un usuario marca como favoritos)
module.exports = {
  tabla: 'favorito',
  ruta: 'favoritos',
  singular: 'Favorito',
  propietario: 'id_usuario', // cada usuario solo ve y modifica los suyos (el administrador ve todos)
  campos: {
    id_usuario: { tipo: 'int', requerido: true },
    id_producto: { tipo: 'int', requerido: true },
  },
};
