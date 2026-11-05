# API auxiliar de Corabastos (Express + MySQL)

Segunda API del parcial. Guarda informacion de **referencia externa** a la central: otros mercados, los precios que manejan,
los proveedores y lo que ofrecen. La API principal (FastAPI + PostgreSQL, carpeta raiz) no depende de esta.

## Base de datos MySQL (`db/corabastos_aux.sql`)

5 tablas normalizadas. Todas tienen **llave primaria** (`id`), **campos unicos**, `estado`, `creado` y `actualizado`.

| Tabla | Descripcion | Campos unicos |
|-------|-------------|---------------|
| `mercado_externo` | Otros mercados o centrales de abasto | `nombre` |
| `proveedor_externo` | Productores que ofrecen producto | `nit`, `correo` |
| `producto_externo` | Catalogo de productos de referencia | `nombre` |
| `precio_externo` | Precio de un producto en un mercado y fecha | `(mercado_id, producto_id, fecha)` |
| `oferta_proveedor` | Producto que un proveedor tiene disponible | `(proveedor_id, producto_id, disponible_hasta)` |

Relaciones: `precio_externo` -> `mercado_externo` y `producto_externo`; `oferta_proveedor` -> `proveedor_externo` y `producto_externo`.

Reglas de los tres campos obligatorios:
- **estado**: `1` activo, `0` eliminado. Por defecto `1`. `DELETE` es logico: solo cambia `estado`, el registro no se borra.
- **creado**: se llena solo al insertar.
- **actualizado**: MySQL lo cambia solo en cada `UPDATE` (`ON UPDATE CURRENT_TIMESTAMP`).

## Estructura por capas (igual que la API principal)

```
express-api/
├── db/corabastos_aux.sql        # tablas + datos de ejemplo
└── src/
    ├── index.js                 # arranque de la app (CORS, rutas, errores)
    ├── api/                     # rutas (equivale a app/api): crearRutas.js + index.js
    ├── repositories/            # SQL (equivale a app/repositories): baseRepository.js
    ├── models/                  # definicion y validacion de campos (equivale a app/models)
    └── core/                    # conexion a MySQL y manejo de errores (equivale a app/core)
```

## Endpoints

Cada recurso tiene los mismos cinco: `GET /recurso`, `GET /recurso/:id`, `POST /recurso`, `PUT /recurso/:id`, `DELETE /recurso/:id`.

| Recurso | Tabla |
|---------|-------|
| `/mercados` | mercado_externo |
| `/proveedores` | proveedor_externo |
| `/productos` | producto_externo |
| `/precios` | precio_externo (devuelve tambien `mercado`, `producto`, `unidad`) |
| `/ofertas` | oferta_proveedor (devuelve tambien `proveedor`, `producto`) |

Tambien: `GET /` (lista de endpoints) y `GET /health` (revisa la conexion a la base).

Respuestas de error: `400` datos invalidos o id mal escrito, `404` no encontrado, `409` valor unico repetido, `500` error interno.
Al crear o editar solo se aceptan los campos del modelo; `id`, `estado`, `creado` y `actualizado` no se pueden enviar.

Ejemplo:

```bash
curl -X POST http://localhost:3000/mercados -H "Content-Type: application/json" \
  -d '{"nombre":"Plaza de Mercado de Tunja","ciudad":"Tunja","tipo":"minorista"}'
```

## Ejecutar en local

1. Tener MySQL instalado y ejecutar el script (crea la base `corabastos_aux`, las tablas y los datos):
   ```bash
   mysql -u root -p < db/corabastos_aux.sql
   ```
2. En esta carpeta: `cp .env.example .env` y completar `DB_USER` y `DB_PASSWORD` (o `MYSQL_URL`).
3. `npm install` y luego `npm start` (o `npm run dev`). Abrir http://localhost:3000/health.

## Despliegue

1. **Base de datos en la nube (Railway):** crear un servicio MySQL, abrir su pestana *Connect* y copiar la URL publica.
   Ejecutar el script `db/corabastos_aux.sql` contra esa base (con MySQL Workbench, DBeaver o `mysql -h HOST -P PUERTO -u USER -p < db/corabastos_aux.sql`).
   En Railway el nombre de la base suele ser `railway`: si es asi, borra o cambia las dos primeras lineas del script (`CREATE DATABASE` y `USE`) por `USE railway;`.
2. **API en Render:** subir el proyecto a GitHub y crear un *Web Service* con:
   - Root Directory: `express-api`
   - Build Command: `npm install`
   - Start Command: `npm start`
   - Variable de entorno: `MYSQL_URL` con la URL del paso anterior (y opcional `CORS_ORIGINS` con la URL del frontend).
3. Probar `https://TU-API.onrender.com/health` y `/precios`.
