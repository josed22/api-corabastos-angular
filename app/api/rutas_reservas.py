from fastapi import APIRouter, Depends, HTTPException
from app.api.dependencias import obtener_usuario_actual, requiere_roles
from app.models.reserva import Reserva
from app.repositories.reserva_repo import ReservaRepository
from app.repositories.tienda_repo import TiendaRepository

router = APIRouter(prefix="/reservas", tags=["Reservas"])
repo = ReservaRepository()
tienda_repo = TiendaRepository()
ROLES_ESCRITURA = ("Administrador", "Vendedor", "Comprador")


def _tiendas_del_vendedor(actual: dict) -> set:
    return {t["id"] for t in tienda_repo.obtener_todos() if t["id_usuario"] == actual["id"]}


def _es_visible(registro: dict, actual: dict) -> bool:
    """Comprador: solo sus reservas. Vendedor: solo las de sus tiendas. Administrador: todas."""
    if actual["rol"] == "Comprador":
        return registro["id_usuario"] == actual["id"]
    if actual["rol"] == "Vendedor":
        return registro["id_tienda"] in _tiendas_del_vendedor(actual)
    return True


def _solo_propia(reserva_id: int, actual: dict):
    """Comprador y vendedor solo pueden modificar o eliminar las reservas que les corresponden."""
    registro = repo.obtener_por_id(reserva_id)
    if registro and not _es_visible(registro, actual):
        raise HTTPException(status_code=403, detail="No tienes permiso sobre esta reserva")


@router.get("/")
def listar_reservas(incluir_inactivos: bool = False, actual: dict = Depends(obtener_usuario_actual)):
    filas = repo.obtener_todos(incluir_inactivos)
    return [r for r in filas if _es_visible(r, actual)]


@router.get("/{reserva_id}")
def obtener_reserva(reserva_id: int, actual: dict = Depends(obtener_usuario_actual)):
    registro = repo.obtener_por_id(reserva_id)
    if not registro or not _es_visible(registro, actual):
        raise HTTPException(status_code=404, detail="Reserva no encontrada")
    return registro


@router.post("/", status_code=201)
def crear_reserva(reserva: Reserva, actual: dict = Depends(requiere_roles(*ROLES_ESCRITURA))):
    datos = reserva.model_dump()
    if actual["rol"] == "Comprador" or not datos.get("id_usuario"):
        datos["id_usuario"] = actual["id"]  # el comprador solo reserva a su nombre
    nuevo_id = repo.crear(datos)
    return {"mensaje": "Reserva registrada exitosamente", "id": nuevo_id}


@router.put("/{reserva_id}")
def actualizar_reserva(reserva_id: int, reserva: Reserva, actual: dict = Depends(requiere_roles(*ROLES_ESCRITURA))):
    _solo_propia(reserva_id, actual)
    datos = reserva.model_dump()
    if not datos.get("codigo"):
        datos.pop("codigo", None)  # sin código nuevo: se conserva el actual
    if actual["rol"] == "Comprador":
        datos["id_usuario"] = actual["id"]  # el comprador solo reserva a su nombre
    elif not datos.get("id_usuario"):
        datos.pop("id_usuario", None)  # al editar sin comprador nuevo se conserva el actual
    exito = repo.actualizar(reserva_id, datos)
    if not exito:
        raise HTTPException(status_code=404, detail="Reserva no encontrada")
    return {"mensaje": "Reserva actualizada correctamente"}


@router.delete("/{reserva_id}")
def eliminar_reserva(reserva_id: int, actual: dict = Depends(requiere_roles(*ROLES_ESCRITURA))):
    """Eliminado lógico: el registro no se borra, su estado pasa a falso."""
    _solo_propia(reserva_id, actual)
    exito = repo.eliminar(reserva_id)
    if not exito:
        raise HTTPException(status_code=404, detail="Reserva no encontrada")
    return {"mensaje": "Reserva eliminada correctamente"}
