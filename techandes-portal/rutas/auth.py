from flask import Blueprint, flash, redirect, render_template, request, session, url_for
from werkzeug.security import check_password_hash

from db import consultar, ejecutar

bp = Blueprint("auth", __name__)


@bp.route("/login", methods=["GET", "POST"])
def login():
    if "usuario" in session:
        return redirect(url_for("inicio.inicio"))

    if request.method == "POST":
        usuario = request.form.get("usuario", "").strip().lower()
        clave = request.form.get("clave", "")

        fila = consultar(
            """SELECT u.id_usuario, u.usuario, u.clave_hash, u.rol, u.activo,
                      e.id_empleado, CONCAT(e.nombres, ' ', e.apellidos) AS nombre, e.cargo
               FROM usuarios u
               JOIN empleados e ON e.id_empleado = u.id_empleado
               WHERE u.usuario = %s""",
            (usuario,),
            uno=True,
        )

        if fila is None or not check_password_hash(fila["clave_hash"], clave):
            flash("Usuario o contraseña incorrectos.", "error")
        elif not fila["activo"]:
            flash("Su usuario está desactivado. Contacte al administrador.", "error")
        else:
            session.clear()
            session["usuario"] = {
                "id_usuario": fila["id_usuario"],
                "usuario": fila["usuario"],
                "rol": fila["rol"],
                "id_empleado": fila["id_empleado"],
                "nombre": fila["nombre"],
                "cargo": fila["cargo"],
            }
            ejecutar(
                "UPDATE usuarios SET ultimo_acceso = NOW() WHERE id_usuario = %s",
                (fila["id_usuario"],),
            )

            siguiente = request.args.get("siguiente", "")
            if not siguiente.startswith("/") or siguiente.startswith("//"):
                siguiente = url_for("inicio.inicio")
            return redirect(siguiente)

    return render_template("login.html")


@bp.route("/logout")
def logout():
    session.clear()
    flash("Sesión cerrada correctamente.", "exito")
    return redirect(url_for("auth.login"))
