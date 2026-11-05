from datetime import date
from typing import Optional
from pydantic import BaseModel, Field


class Reserva(BaseModel):
    id_usuario: Optional[int] = None
    id_tienda: int
    id_estado_reserva: int
    codigo: Optional[str] = Field(None, min_length=1, max_length=30)  # si no se envía, la API genera RES-0001...
    fecha_retiro: date
    observacion: Optional[str] = Field(None, max_length=300)
    estado: bool = True
