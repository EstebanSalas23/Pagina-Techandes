from flask import Blueprint, render_template

from db import consultar
from seguridad import rol_requerido

bp = Blueprint("informes", __name__, url_prefix="/informes")


@bp.route("/")
@rol_requerido("ADMIN")
def index():
    categorias = consultar(
        """SELECT c.nombre AS categoria,
                  COALESCE(SUM(CASE
                      WHEN pe.estado <> 'CANCELADO'
                      THEN d.cantidad * d.precio_unitario
                  END), 0) AS total
           FROM categorias c
           LEFT JOIN productos p ON p.id_categoria = c.id_categoria
           LEFT JOIN detalle_pedido d ON d.id_producto = p.id_producto
           LEFT JOIN pedidos pe ON pe.id_pedido = d.id_pedido
           GROUP BY c.id_categoria, c.nombre
           ORDER BY total DESC, c.nombre"""
    )
    gran_total = sum((float(fila["total"]) for fila in categorias), 0.0) or 1.0
    for fila in categorias:
        fila["porcentaje"] = round(float(fila["total"]) / gran_total * 100, 1)

    vendedores = consultar(
        """SELECT RANK() OVER (
                      ORDER BY SUM(d.cantidad * d.precio_unitario) DESC
                  ) AS puesto,
                  CONCAT(e.nombres, ' ', e.apellidos) AS vendedor,
                  e.cargo,
                  COUNT(DISTINCT p.id_pedido) AS pedidos,
                  SUM(d.cantidad * d.precio_unitario) AS total
           FROM empleados e
           JOIN pedidos p ON p.id_empleado = e.id_empleado
           JOIN detalle_pedido d ON d.id_pedido = p.id_pedido
           WHERE p.estado <> 'CANCELADO'
           GROUP BY e.id_empleado, e.nombres, e.apellidos, e.cargo
           ORDER BY puesto, vendedor"""
    )

    top_productos = consultar(
        """SELECT pr.nombre,
                  SUM(d.cantidad) AS unidades,
                  SUM(d.cantidad * d.precio_unitario) AS total
           FROM detalle_pedido d
           JOIN productos pr ON pr.id_producto = d.id_producto
           JOIN pedidos pe ON pe.id_pedido = d.id_pedido
           WHERE pe.estado <> 'CANCELADO'
           GROUP BY pr.id_producto, pr.nombre
           ORDER BY unidades DESC, pr.nombre
           LIMIT 5"""
    )

    sin_compras = consultar(
        """SELECT c.id_cliente, c.documento,
                  CONCAT(c.nombres, ' ', c.apellidos) AS nombre,
                  c.ciudad, c.email
           FROM clientes c
           WHERE NOT EXISTS (
               SELECT 1 FROM pedidos p WHERE p.id_cliente = c.id_cliente
           )
           ORDER BY c.apellidos, c.nombres"""
    )

    return render_template(
        "informes/index.html",
        categorias=categorias,
        vendedores=vendedores,
        top_productos=top_productos,
        sin_compras=sin_compras,
    )
