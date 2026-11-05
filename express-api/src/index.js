require('dotenv').config();
const express = require('express');
const cors = require('cors');
const pool = require('./core/database');
const rutas = require('./api');
const modelos = require('./models');
const { noEncontrado, manejarErrores } = require('./core/errores');

const app = express();
const origenes = (process.env.CORS_ORIGINS || '').split(',').map((o) => o.trim()).filter(Boolean);
app.use(cors(origenes.length ? { origin: origenes } : {}));
app.use(express.json());

app.get('/', (req, res) =>
  res.json({
    api: 'Corabastos - API auxiliar (Express + MySQL)',
    endpoints: modelos.map((m) => '/' + m.ruta),
  })
);
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.json({ status: 'ok', base_de_datos: 'conectada' });
  } catch {
    res.status(503).json({ status: 'error', base_de_datos: 'sin conexion' });
  }
});

app.use(rutas);
app.use(noEncontrado);
app.use(manejarErrores);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`API auxiliar escuchando en http://localhost:${PORT}`));
