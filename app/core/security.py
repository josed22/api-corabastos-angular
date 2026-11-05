import os
import secrets
from datetime import datetime, timedelta, timezone

import bcrypt
import jwt
from dotenv import load_dotenv

# Carga JWT_SECRET, JWT_ALGORITHM y JWT_EXPIRE_MINUTES del archivo .env
load_dotenv()

ALGORITMO = os.getenv("JWT_ALGORITHM", "HS256")
MINUTOS_EXPIRACION = int(os.getenv("JWT_EXPIRE_MINUTES", "60"))


class TokenError(Exception):
    """El token falta, es inválido o expiró."""


def _secreto() -> str:
    secreto = os.getenv("JWT_SECRET")
    if not secreto:
        raise RuntimeError("Falta la variable JWT_SECRET en el archivo .env")
    return secreto


def crear_token(datos: dict) -> str:
    ahora = datetime.now(timezone.utc)
    payload = {**datos, "iat": ahora, "exp": ahora + timedelta(minutes=MINUTOS_EXPIRACION)}
    return jwt.encode(payload, _secreto(), algorithm=ALGORITMO)


def decodificar_token(token: str) -> dict:
    try:
        return jwt.decode(token, _secreto(), algorithms=[ALGORITMO])
    except jwt.ExpiredSignatureError:
        raise TokenError("El token ha expirado")
    except jwt.InvalidTokenError:
        raise TokenError("Token inválido")


# ---------- Contraseñas ----------
def es_hash(valor: str) -> bool:
    """True si el valor ya es un hash bcrypt ($2a$, $2b$ o $2y$)."""
    return isinstance(valor, str) and valor[:4] in ("$2a$", "$2b$", "$2y$") and len(valor) == 60


def hashear_password(password: str) -> str:
    return bcrypt.hashpw(password.encode(), bcrypt.gensalt()).decode()


def verificar_password(password: str, guardada: str) -> bool:
    """Compara con bcrypt. Si en la base aún hay una clave en texto plano (datos importados),
    la compara directamente; el login la convierte en hash en el mismo momento."""
    if es_hash(guardada):
        return bcrypt.checkpw(password.encode(), guardada.encode())
    return secrets.compare_digest(password.encode(), guardada.encode())
