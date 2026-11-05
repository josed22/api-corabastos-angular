from fastapi import APIRouter, Depends, HTTPException

from app.api.dependencias import obtener_usuario_actual
from app.core.security import crear_token, es_hash, hashear_password, verificar_password
from app.models.auth import LoginRequest
from app.repositories.modulo_repo import ModuloRepository
from app.repositories.usuario_repo import UsuarioRepository

router = APIRouter(prefix="/auth", tags=["Autenticación"])
usuario_repo = UsuarioRepository()
modulo_repo = ModuloRepository()


@router.post("/login")
def login(datos: LoginRequest):
    usuario = usuario_repo.obtener_por_correo(datos.correo)
    # Mismo mensaje si el correo no existe o la contraseña falla, para no revelar cuál fue
    if not usuario or not verificar_password(datos.password, usuario["password_hash"]):
        raise HTTPException(status_code=401, detail="Correo o contraseña incorrectos")
    if not es_hash(usuario["password_hash"]):
        usuario_repo.guardar_password(usuario["id"], hashear_password(datos.password))  # clave en texto plano -> hash

    token = crear_token({"sub": str(usuario["id"]), "rol": usuario["rol"], "correo": usuario["correo"]})
    return {
        "access_token": token,
        "token_type": "bearer",
        "usuario": {"id": usuario["id"], "nombre": usuario["nombre"], "apellido": usuario["apellido"],
                    "correo": usuario["correo"], "rol": usuario["rol"]},
        "modulos": modulo_repo.obtener_por_rol(usuario["id_rol"]),
    }


@router.get("/me")
def perfil(actual: dict = Depends(obtener_usuario_actual)):
    return {
        "usuario": {"id": actual["id"], "nombre": actual["nombre"], "apellido": actual["apellido"],
                    "correo": actual["correo"], "rol": actual["rol"]},
        "modulos": modulo_repo.obtener_por_rol(actual["id_rol"]),
    }
