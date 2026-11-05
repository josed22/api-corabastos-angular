// Conexion a MySQL: un solo pool compartido por todos los repositorios.
const mysql = require('mysql2/promise');

const opciones = process.env.MYSQL_URL
  ? { uri: process.env.MYSQL_URL }
  : {
      host: process.env.DB_HOST || 'localhost',
      port: Number(process.env.DB_PORT || 3306),
      database: process.env.DB_NAME || 'corabastos_aux',
      user: process.env.DB_USER || 'root',
      password: process.env.DB_PASSWORD || '',
    };

const pool = mysql.createPool({
  ...opciones,
  waitForConnections: true,
  connectionLimit: 10,
  dateStrings: true, // las fechas llegan como texto (YYYY-MM-DD) y no cambian por zona horaria
});

module.exports = pool;
