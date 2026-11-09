import pymysql
from flask import Blueprint, flash, redirect, render_template, request, session, url_for

from db import consultar, mensaje_error, obtener_conexion
from seguridad import login_requerido

bp = Blueprint("ventas", __name__, url_prefix="/ventas")

METODOS = ("EFECTIVO", "TARJETA", "TRANSFERENCIA", "PSE")
FILAS = 5


class ErrorVenta(Exception):
    """Error de negocio: aborta la transacción con un mensaje claro."""


def catalogo():
    return consultar(
        """SELECT id_producto, nombre, precio, stock
           FROM productos
           WHERE activo = 1
           ORDER BY nombre"""
    )


def clientes():
    return consultar(
        """SELECT id_cliente, CONCAT(nombres, ' ', apellidos) AS nombre, documento
           FROM clientes
           ORDER BY apellidos, nombres"""
    )


def lineas_vacias():
    return [{"id_producto": "", "cantidad": ""} for _ in range(FILAS)]


def leer_lineas():
    """Junta las filas del formulario. El mismo producto se suma."""
    items = {}
    lineas = []
    errores = []
    for i in range(1, FILAS + 1):
        id_producto = request.form.get(f"producto_{i}", "").strip()
        cantidad = request.form.get(f"cantidad_{i}", "").strip()
        lineas.append({"id_producto": id_producto, "cantidad": cantidad})
        if not id_producto and not cantidad:
            continue
        if not id_producto.isdigit():
            errores.append(f"Seleccione el producto de la fila {i}.")
            continue
        if not cantidad.isdigit() or int(cantidad) <= 0:
            errores.append(f"La cantidad de la fila {i} debe ser un entero mayor que 0.")
            continue
        pid = int(id_producto)
        items[pid] = items.get(pid, 0) + int(cantidad)
    if not items and not errores:
        errores.append("Agregue al menos un producto.")
    return items, lineas, errores


def registrar_pedido(id_cliente, metodo_pago, items):
    """Inserta pedido + detalle y descuenta stock. Todo o nada."""
    conexion = obtener_conexion()
    conexion.begin()
    try:
        with conexion.cursor() as cursor:
            cursor.execute(
                """INSERT INTO pedidos (id_cliente, id_empleado, estado, metodo_pago)
                   VALUES (%s, %s, 'PENDIENTE', %s)""",
                (id_cliente, session["usuario"]["id_empleado"], metodo_pago),
            )
            id_pedido = cursor.lastrowid

            for id_producto, cantidad in items.items():
                cursor.execute(
                    """SELECT nombre, precio, stock, activo
                       FROM productos
                       WHERE id_producto = %s
                       FOR UPDATE""",
                    (id_producto,),
                )
                producto = cursor.fetchone()
                if producto is None or not producto["activo"]:
                    raise ErrorVenta(f"El producto {id_producto} no está disponible.")
                if producto["stock"] < cantidad:
                    raise ErrorVenta(
                        f"Stock insuficiente de {producto['nombre']}: "
                        f"hay {producto['stock']}, se piden {cantidad}."
                    )
                cursor.execute(
                    """INSERT INTO detalle_pedido
                       (id_pedido, id_producto, cantidad, precio_unitario)
                       VALUES (%s, %s, %s, %s)""",
                    (id_pedido, id_producto, cantidad, producto["precio"]),
                )
                cursor.execute(
                    "UPDATE productos SET stock = stock - %s WHERE id_producto = %s",
                    (cantidad, id_producto),
                )
        conexion.commit()
        return id_pedido
    except Exception:
        conexion.rollback()
        raise


@bp.route("/nueva", methods=["GET", "POST"])
@login_requerido
def nueva():
    id_cliente = ""
    metodo_pago = ""
    lineas = lineas_vacias()

    if request.method == "POST":
        id_cliente = request.form.get("id_cliente", "").strip()
        metodo_pago = request.form.get("metodo_pago", "")
        items, lineas, errores = leer_lineas()

        if not id_cliente.isdigit():
            errores.append("Seleccione un cliente.")
        elif consultar(
            "SELECT id_cliente FROM clientes WHERE id_cliente = %s",
            (id_cliente,),
            uno=True,
        ) is None:
            errores.append("El cliente no existe.")
        if metodo_pago not in METODOS:
            errores.append("Seleccione un método de pago.")

        if not errores:
            try:
                id_pedido = registrar_pedido(int(id_cliente), metodo_pago, items)
            except ErrorVenta as error:
                flash(str(error), "error")
            except pymysql.MySQLError as error:
                flash(mensaje_error(error), "error")
            else:
                flash(f"Venta registrada: pedido #{id_pedido}.", "exito")
                return redirect(url_for("pedidos.detalle", id_pedido=id_pedido))
        for error in errores:
            flash(error, "error")

    return render_template(
        "ventas/nueva.html",
        productos=catalogo(),
        clientes=clientes(),
        metodos=METODOS,
        id_cliente=id_cliente,
        metodo_pago=metodo_pago,
        lineas=lineas,
    )
