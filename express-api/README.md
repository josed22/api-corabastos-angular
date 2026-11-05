# API auxiliar de Corabastos (Express + MySQL)

Segunda API del proyecto. Guarda lo **personal de cada usuario** de la web: sus favoritos, sus alertas de precio y sus notificaciones.
Usa el **mismo JWT** que emite la API principal (FastAPI + PostgreSQL), asi que el usuario inicia sesion una sola vez.

## Base de datos MySQL (`db/corabastos_aux.sql`)

5 tablas normalizadas. Todas tienen **llave primaria** (`id`), **campos unicos**, `estado`, `creado` y `actualizado`.

| Tabla | Descripcion | Campos unicos |
|-------|-------------|---------------|
| `canal_notificacion` | Catalogo: aplicacion, correo, WhatsApp, Telegram | `nombre` |
| `favorito` | Producto que un usuario marca como favorito | `(id_usuario, id_producto)` |
| `alerta_precio` | Aviso cuando un producto sube o baja un porcentaje | `(id_usuario, id_producto, tipo)` |
| `preferencia_notificacion` | Por que canal quiere recibir avisos cada usuario | `(id_usuario, id_canal)` |
| `notificacion` | Aviso generado por una alerta y enviado por un canal | — |

`id_usuario` e `id_producto` son referencias a la base principal (PostgreSQL); entre bases distintas no hay llave foranea.
Dentro de MySQL si hay: `preferencia_notificacion` y `notificacion` -> `canal_notificacion`; `notificacion` -> `alerta_precio`.

- **estado**: `1` activo, `0` eliminado. `DELETE` es logico: solo cambia `estado`, el registro no se borra.
- **creado**: se llena solo al insertar. **actualizado**: MySQL lo cambia solo en cada `UPDATE`.

El script solo crea las tablas y los 4 canales. Los registros (20 en las tablas principales y 10 en las secundarias) los
registra el equipo; `db/verificar_registros.sql` cuenta cuantos hay en cada tabla.

## Estructura por capas (igual que la API principal)

```
express-api/
├── db/                          # corabastos_aux.sql y verificar_registros.sql
└── src/
    ├── index.js                 # arranque de la app (CORS, rutas, errores)
    ├── api/                     # rutas (equivale a app/api): crearRutas.js + index.js
    ├── repositories/            # SQL (equivale a app/repositories): baseRepository.js
    ├── models/                  # definicion y validacion de campos (equivale a app/models)
    └── core/                    # conexion MySQL, JWT y errores (equivale a app/core)
```

## Autenticacion y permisos

Todas las rutas exigen `Authorization: Bearer <token>`, el token que devuelve `POST /auth/login` de la API principal.
Ambas APIs deben tener **el mismo `JWT_SECRET`**.

- Recursos personales (`/favoritos`, `/alertas`, `/preferencias`, `/notificaciones`): cada usuario solo ve y modifica lo suyo;
  al crear, `id_usuario` se toma siempre del token. El Administrador ve todo.
- `/canales`: cualquier usuario autenticado lo lee; solo el Administrador lo modifica.

## Endpoints

Cada recurso tiene `GET /recurso`, `GET /recurso/:id`, `POST /recurso`, `PUT /recurso/:id` y `DELETE /recurso/:id`
(`/favoritos`, `/alertas`, `/canales`, `/preferencias`, `/notificaciones`). Tambien `GET /` y `GET /health`.

Errores: `400` datos invalidos, `401` sin token o token invalido, `403` sin permiso, `404` no encontrado, `409` valor unico repetido.

## Ejecutar en local

1. Con MySQL instalado: `mysql -u root -p < db/corabastos_aux.sql`
2. `cp .env.example .env` y completar `DB_USER`, `DB_PASSWORD` y `JWT_SECRET` (el mismo de la API principal).
3. `npm install` y `npm start`. Abrir http://localhost:3000/health.

## Despliegue

1. **MySQL en la nube (Railway):** crear el servicio MySQL, copiar la URL publica (pestana *Connect*) y ejecutar `db/corabastos_aux.sql` contra esa base.
   Si la base se llama `railway`, cambia las dos primeras lineas del script (`CREATE DATABASE` y `USE`) por `USE railway;`.
2. **API en Render:** Web Service con Root Directory `express-api`, Build `npm install`, Start `npm start`.
   Variables: `MYSQL_URL`, `JWT_SECRET` (igual al de la API principal) y `CORS_ORIGINS` (URL del Angular).
