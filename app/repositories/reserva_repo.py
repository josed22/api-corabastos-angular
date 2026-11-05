from uuid import uuid4

from app.repositories.base_repo import BaseRepository


class ReservaRepository(BaseRepository):
    tabla = "reserva"
    columnas = ["id_usuario", "id_tienda", "id_estado_reserva", "codigo", "fecha_retiro", "observacion"]

    def crear(self, datos: dict):
        """Si no llega un código, se genera uno consecutivo (RES-0001, RES-0002...)."""
        if datos.get("codigo"):
            return super().crear(datos)
        datos = {**datos, "codigo": "TMP-" + uuid4().hex[:20]}
        nuevo_id = super().crear(datos)
        self._modificar("UPDATE reserva SET codigo = 'RES-' || LPAD(id::text, 4, '0') WHERE id = %s RETURNING id;", (nuevo_id,))
        return nuevo_id
