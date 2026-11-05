import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.errores import registrar_manejadores
from app.api import (
    rutas_auth, rutas_catalogo, rutas_roles, rutas_modulos, rutas_modulos_x_rol,
    rutas_municipios, rutas_tipos_identificacion, rutas_usuarios, rutas_categorias,
    rutas_tipos, rutas_productos, rutas_pabellones, rutas_tiendas, rutas_inventarios,
    rutas_precios_dia, rutas_estados_reserva, rutas_reservas, rutas_detalles_reserva,
)

app = FastAPI(
    title="API Corabastos",
    description="Backend modular para consultar productos, precios del día y reservas en Corabastos usando FastAPI y PostgreSQL puro",
    version="1.0.0"
)

# CORS: el frontend Angular vive en otro origen. CORS_ORIGINS = URLs separadas por coma (nube).
origenes = ["http://localhost:4200", "http://127.0.0.1:4200"] + [o.strip() for o in os.getenv("CORS_ORIGINS", "").split(",") if o.strip()]
app.add_middleware(CORSMiddleware, allow_origins=origenes, allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

# Manejo de errores de base de datos y reglas de negocio
registrar_manejadores(app)

# Conectamos los módulos de rutas a la aplicación principal
for modulo in (
    rutas_auth, rutas_catalogo, rutas_roles, rutas_modulos, rutas_modulos_x_rol,
    rutas_municipios, rutas_tipos_identificacion, rutas_usuarios, rutas_categorias,
    rutas_tipos, rutas_productos, rutas_pabellones, rutas_tiendas, rutas_inventarios,
    rutas_precios_dia, rutas_estados_reserva, rutas_reservas, rutas_detalles_reserva,
):
    app.include_router(modulo.router)

@app.get("/")
def estado_api():
    return {"mensaje": "La API de Corabastos se encuentra en línea y funcional"}
