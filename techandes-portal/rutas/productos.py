import pymysql
from flask import Blueprint, abort, flash, redirect, render_template, request, url_for

from db import consultar, ejecutar, mensaje_error
from seguridad import login_requerido, rol_requerido

bp = Blueprint("productos", __name__, url_prefix="/productos")


def categorias():
    return consultar("SELECT id_categoria, nombre FROM categorias ORDER BY nombre")


def leer_formulario():
    """Lee y valida el formulario. Devuelve (datos, lista_de_errores)."""
    datos = {
        "nombre": request.form.get("nombre", "").strip(),
        "id_categoria": request.form.get("id_categoria", ""),
        "precio": request.form.get("precio", "").strip(),
        "stock": request.form.get("stock", "0").strip(),
        "activo": 1 if request.form.get("activo") else 0,
    }
    errores = []
    if not datos["nombre"]:
        errores.append("El nombre es obligatorio.")
    elif len(datos["nombre"]) > 100:
        errores.append("El nombre no puede superar 100 caracteres.")
    if not datos["id_categoria"].isdigit():
        errores.append("Seleccione una categoría.")
    try:
        if float(datos["precio"]) <= 0:
            errores.append("El precio debe ser mayor que 0.")
    except ValueError:
        errores.append("El precio debe ser un número.")
    if not datos["stock"].isdigit():
        errores.append("El stock debe ser un número entero mayor o igual a 0.")
    return datos, errores


@bp.route("/")
@login_requerido
def lista():
    buscar = request.args.get("buscar", "").strip()
    categoria = request.args.get("categoria", "")

    sql = """SELECT p.id_producto, p.nombre, p.precio, p.stock, p.activo,
                    c.nombre AS categoria
             FROM productos p
             JOIN categorias c ON c.id_categoria = p.id_categoria
             WHERE 1 = 1"""
    parametros = []
    if buscar:
        sql += " AND p.nombre LIKE %s"
        parametros.append(f"%{buscar}%")
    if categoria.isdigit():
        sql += " AND p.id_categoria = %s"
        parametros.append(int(categoria))
    sql += " ORDER BY c.nombre, p.nombre"

    productos = consultar(sql, parametros)
    return render_template(
        "productos/lista.html",
        productos=productos,
        categorias=categorias(),
        buscar=buscar,
        categoria=categoria,
    )


@bp.route("/nuevo", methods=["GET", "POST"])
@rol_requerido("ADMIN")
def nuevo():
    datos = {"nombre": "", "id_categoria": "", "precio": "", "stock": "0", "activo": 1}
    if request.method == "POST":
        datos, errores = leer_formulario()
        if not errores:
            try:
                ejecutar(
                    """INSERT INTO productos (nombre, id_categoria, precio, stock, activo)
                       VALUES (%s, %s, %s, %s, %s)""",
                    (
                        datos["nombre"],
                        datos["id_categoria"],
                        datos["precio"],
                        datos["stock"],
                        datos["activo"],
                    ),
                )
                flash(f"Producto «{datos['nombre']}» creado.", "exito")
                return redirect(url_for("productos.lista"))
            except pymysql.MySQLError as error:
                errores.append(mensaje_error(error))
        for error in errores:
            flash(error, "error")
    return render_template(
        "productos/formulario.html",
        datos=datos,
        categorias=categorias(),
        titulo="Nuevo producto",
    )


@bp.route("/<int:id_producto>/editar", methods=["GET", "POST"])
@rol_requerido("ADMIN")
def editar(id_producto):
    fila = consultar(
        "SELECT * FROM productos WHERE id_producto = %s",
        (id_producto,),
        uno=True,
    )
    if fila is None:
        abort(404)

    datos = {
        "nombre": fila["nombre"],
        "id_categoria": str(fila["id_categoria"]),
        "precio": str(fila["precio"]),
        "stock": str(fila["stock"]),
        "activo": fila["activo"],
    }
    if request.method == "POST":
        datos, errores = leer_formulario()
        if not errores:
            try:
                ejecutar(
                    """UPDATE productos
                       SET nombre = %s, id_categoria = %s, precio = %s, stock = %s, activo = %s
                       WHERE id_producto = %s""",
                    (
                        datos["nombre"],
                        datos["id_categoria"],
                        datos["precio"],
                        datos["stock"],
                        datos["activo"],
                        id_producto,
                    ),
                )
                flash(f"Producto «{datos['nombre']}» actualizado.", "exito")
                return redirect(url_for("productos.lista"))
            except pymysql.MySQLError as error:
                errores.append(mensaje_error(error))
        for error in errores:
            flash(error, "error")
    return render_template(
        "productos/formulario.html",
        datos=datos,
        categorias=categorias(),
        titulo="Editar producto",
    )


@bp.route("/<int:id_producto>/eliminar", methods=["POST"])
@rol_requerido("ADMIN")
def eliminar(id_producto):
    try:
        _, filas = ejecutar("DELETE FROM productos WHERE id_producto = %s", (id_producto,))
        if filas == 0:
            abort(404)
        flash("Producto eliminado.", "exito")
    except pymysql.MySQLError as error:
        if error.args and error.args[0] == 1451:
            flash(
                "Este producto ya tiene ventas y no se puede eliminar. "
                "Desmarque «Activo» para retirarlo del catálogo.",
                "error",
            )
        else:
            flash(mensaje_error(error), "error")
    return redirect(url_for("productos.lista"))
