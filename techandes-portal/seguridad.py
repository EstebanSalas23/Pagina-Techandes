from functools import wraps

from flask import abort, flash, redirect, request, session, url_for


def login_requerido(vista):
    """Solo deja pasar a usuarios que iniciaron sesión."""
    @wraps(vista)
    def envoltura(*args, **kwargs):
        if "usuario" not in session:
            flash("Inicie sesión para continuar.", "aviso")
            return redirect(url_for("auth.login", siguiente=request.path))
        return vista(*args, **kwargs)
    return envoltura


def rol_requerido(*roles):
    """Solo deja pasar a usuarios con alguno de los roles indicados."""
    def decorador(vista):
        @wraps(vista)
        @login_requerido
        def envoltura(*args, **kwargs):
            if session["usuario"]["rol"] not in roles:
                abort(403)
            return vista(*args, **kwargs)
        return envoltura
    return decorador
