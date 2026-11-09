import os
from datetime import date, datetime

from dotenv import load_dotenv
from flask import Flask, render_template

load_dotenv()

from db import cerrar_conexion


def crear_app():
    app = Flask(__name__)
    app.config["SECRET_KEY"] = os.getenv("SECRET_KEY", "clave-solo-para-desarrollo")
    app.teardown_appcontext(cerrar_conexion)

    @app.template_filter("pesos")
    def pesos(valor):
        """1499000 -> '$ 1.499.000'"""
        return "$ " + f"{float(valor or 0):,.0f}".replace(",", ".")

    @app.template_filter("fecha")
    def fecha(valor, con_hora=False):
        if valor is None:
            return ""
        if isinstance(valor, str):
            valor = datetime.fromisoformat(valor)
        formato = "%d/%m/%Y %H:%M" if con_hora and isinstance(valor, datetime) else "%d/%m/%Y"
        return valor.strftime(formato)

    @app.context_processor
    def variables_globales():
        return {"anio_actual": date.today().year}

    from rutas.auth import bp as auth_bp
    from rutas.inicio import bp as inicio_bp
    from rutas.productos import bp as productos_bp
    from rutas.clientes import bp as clientes_bp
    from rutas.ventas import bp as ventas_bp
    from rutas.pedidos import bp as pedidos_bp
    from rutas.informes import bp as informes_bp

    for blueprint in (
        auth_bp,
        inicio_bp,
        productos_bp,
        clientes_bp,
        ventas_bp,
        pedidos_bp,
        informes_bp,
    ):
        app.register_blueprint(blueprint)

    @app.errorhandler(403)
    def prohibido(error):
        return render_template(
            "errores/error.html",
            codigo=403,
            mensaje="No tiene permisos para ver esta página.",
        ), 403

    @app.errorhandler(404)
    def no_encontrado(error):
        return render_template(
            "errores/error.html",
            codigo=404,
            mensaje="La página que busca no existe.",
        ), 404

    return app


app = crear_app()

if __name__ == "__main__":
    app.run(debug=True)
