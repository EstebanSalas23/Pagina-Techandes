from flask import Blueprint, render_template, session

from db import consultar
from seguridad import login_requerido

bp = Blueprint("inicio", __name__)


@bp.route("/")
@login_requerido
def inicio():
    indicadores = consultar(
        """SELECT
             (SELECT COALESCE(SUM(d.cantidad * d.precio_unitario), 0)
              FROM detalle_pedido d
              JOIN pedidos p ON p.id_pedido = d.id_pedido
              WHERE p.estado <> 'CANCELADO') AS ventas_totales,
             (SELECT COUNT(*) FROM pedidos WHERE estado = 'PENDIENTE') AS pendientes,
             (SELECT COUNT(*) FROM clientes) AS clientes,
             (SELECT COUNT(*) FROM productos WHERE activo = 1 AND stock < 10) AS stock_bajo""",
        uno=True,
    )

    mis_ventas = consultar(
        """SELECT COUNT(DISTINCT p.id_pedido) AS pedidos,
                  COALESCE(SUM(d.cantidad * d.precio_unitario), 0) AS total
           FROM pedidos p
           JOIN detalle_pedido d ON d.id_pedido = p.id_pedido
           WHERE p.id_empleado = %s AND p.estado <> 'CANCELADO'""",
        (session["usuario"]["id_empleado"],),
        uno=True,
    )

    ultimos = consultar(
        """SELECT p.id_pedido, p.fecha_pedido, p.estado,
                  CONCAT(c.nombres, ' ', c.apellidos) AS cliente,
                  COALESCE(SUM(d.cantidad * d.precio_unitario), 0) AS total
           FROM pedidos p
           JOIN clientes c ON c.id_cliente = p.id_cliente
           LEFT JOIN detalle_pedido d ON d.id_pedido = p.id_pedido
           GROUP BY p.id_pedido, p.fecha_pedido, p.estado, c.nombres, c.apellidos
           ORDER BY p.fecha_pedido DESC
           LIMIT 5"""
    )

    bajo_stock = consultar(
        """SELECT id_producto, nombre, stock
           FROM productos
           WHERE activo = 1 AND stock < 10
           ORDER BY stock, nombre"""
    )

    return render_template(
        "inicio.html",
        indicadores=indicadores,
        mis_ventas=mis_ventas,
        ultimos=ultimos,
        bajo_stock=bajo_stock,
    )
