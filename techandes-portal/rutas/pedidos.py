from flask import Blueprint, abort, flash, redirect, render_template, request, url_for
from werkzeug.exceptions import HTTPException

from db import consultar, obtener_conexion
from seguridad import login_requerido

bp = Blueprint("pedidos", __name__, url_prefix="/pedidos")

ESTADOS = ("PENDIENTE", "ENVIADO", "ENTREGADO", "CANCELADO")


def cargar_pedido(id_pedido):
    pedido = consultar(
        """SELECT p.id_pedido, p.fecha_pedido, p.estado, p.metodo_pago,
                  CONCAT(c.nombres, ' ', c.apellidos) AS cliente,
                  c.id_cliente, c.documento, c.ciudad,
                  CONCAT(e.nombres, ' ', e.apellidos) AS vendedor
           FROM pedidos p
           JOIN clientes c ON c.id_cliente = p.id_cliente
           JOIN empleados e ON e.id_empleado = p.id_empleado
           WHERE p.id_pedido = %s""",
        (id_pedido,),
        uno=True,
    )
    if pedido is None:
        abort(404)
    lineas = consultar(
        """SELECT d.id_producto, pr.nombre, d.cantidad, d.precio_unitario,
                  d.cantidad * d.precio_unitario AS subtotal
           FROM detalle_pedido d
           JOIN productos pr ON pr.id_producto = d.id_producto
           WHERE d.id_pedido = %s
           ORDER BY pr.nombre""",
        (id_pedido,),
    )
    total = sum((linea["subtotal"] for linea in lineas), 0)
    return pedido, lineas, total


@bp.route("/")
@login_requerido
def lista():
    estado = request.args.get("estado", "")
    sql = """SELECT p.id_pedido, p.fecha_pedido, p.estado,
                    CONCAT(c.nombres, ' ', c.apellidos) AS cliente,
                    CONCAT(e.nombres, ' ', e.apellidos) AS vendedor,
                    COALESCE(SUM(d.cantidad * d.precio_unitario), 0) AS total
             FROM pedidos p
             JOIN clientes c ON c.id_cliente = p.id_cliente
             JOIN empleados e ON e.id_empleado = p.id_empleado
             LEFT JOIN detalle_pedido d ON d.id_pedido = p.id_pedido
             WHERE 1 = 1"""
    parametros = []
    if estado in ESTADOS:
        sql += " AND p.estado = %s"
        parametros.append(estado)
    else:
        estado = ""
    sql += """ GROUP BY p.id_pedido, p.fecha_pedido, p.estado,
                        c.nombres, c.apellidos, e.nombres, e.apellidos
               ORDER BY p.fecha_pedido DESC"""
    return render_template(
        "pedidos/lista.html",
        pedidos=consultar(sql, parametros),
        estados=ESTADOS,
        estado=estado,
    )


@bp.route("/<int:id_pedido>")
@login_requerido
def detalle(id_pedido):
    pedido, lineas, total = cargar_pedido(id_pedido)
    return render_template(
        "pedidos/detalle.html",
        pedido=pedido,
        lineas=lineas,
        total=total,
        estados=ESTADOS,
    )


@bp.route("/<int:id_pedido>/estado", methods=["POST"])
@login_requerido
def cambiar_estado(id_pedido):
    nuevo = request.form.get("estado", "")
    if nuevo not in ESTADOS:
        flash("Estado no válido.", "error")
        return redirect(url_for("pedidos.detalle", id_pedido=id_pedido))

    conexion = obtener_conexion()
    conexion.begin()
    mensaje = None
    try:
        with conexion.cursor() as cursor:
            cursor.execute(
                "SELECT estado FROM pedidos WHERE id_pedido = %s FOR UPDATE",
                (id_pedido,),
            )
            fila = cursor.fetchone()
            if fila is None:
                conexion.rollback()
                abort(404)
            actual = fila["estado"]
            if actual == nuevo:
                conexion.rollback()
                mensaje = ("El pedido ya tiene ese estado.", "aviso")
            elif actual == "CANCELADO":
                conexion.rollback()
                mensaje = ("Un pedido cancelado no se puede modificar.", "error")
            else:
                if nuevo == "CANCELADO":
                    cursor.execute(
                        "SELECT id_producto, cantidad FROM detalle_pedido WHERE id_pedido = %s",
                        (id_pedido,),
                    )
                    for linea in cursor.fetchall():
                        cursor.execute(
                            "UPDATE productos SET stock = stock + %s WHERE id_producto = %s",
                            (linea["cantidad"], linea["id_producto"]),
                        )
                    mensaje = (
                        "Pedido cancelado. Las unidades volvieron al inventario.",
                        "exito",
                    )
                else:
                    mensaje = (f"Estado actualizado a {nuevo}.", "exito")
                cursor.execute(
                    "UPDATE pedidos SET estado = %s WHERE id_pedido = %s",
                    (nuevo, id_pedido),
                )
                conexion.commit()
    except HTTPException:
        raise
    except Exception:
        conexion.rollback()
        raise

    if mensaje:
        flash(*mensaje)
    return redirect(url_for("pedidos.detalle", id_pedido=id_pedido))
