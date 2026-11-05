// Capa de datos: SQL de una tabla. Cada modelo define tabla, campos y (opcional) joins.
const pool = require('../core/database');

class BaseRepository {
  constructor(modelo) {
    this.modelo = modelo;
  }

  get _select() {
    const { extra = '', joins = '' } = this.modelo;
    return `SELECT t.*${extra} FROM ?? AS t ${joins}`;
  }

  async obtenerTodos() {
    const [filas] = await pool.query(`${this._select} WHERE t.estado = TRUE ORDER BY t.id ASC`, [this.modelo.tabla]);
    return filas;
  }

  async obtenerPorId(id) {
    const [filas] = await pool.query(`${this._select} WHERE t.id = ? AND t.estado = TRUE`, [this.modelo.tabla, id]);
    return filas[0] || null;
  }

  async crear(datos) {
    const [r] = await pool.query('INSERT INTO ?? SET ?', [this.modelo.tabla, datos]);
    return this.obtenerPorId(r.insertId);
  }

  async actualizar(id, datos) {
    if (!(await this.obtenerPorId(id))) return null;
    // "actualizado" lo cambia MySQL solo (ON UPDATE CURRENT_TIMESTAMP)
    await pool.query('UPDATE ?? SET ? WHERE id = ?', [this.modelo.tabla, datos, id]);
    return this.obtenerPorId(id);
  }

  // Eliminacion logica: el registro se conserva con estado = 0
  async eliminar(id) {
    const [r] = await pool.query('UPDATE ?? SET estado = FALSE WHERE id = ? AND estado = TRUE', [this.modelo.tabla, id]);
    return r.affectedRows > 0;
  }
}

module.exports = BaseRepository;
