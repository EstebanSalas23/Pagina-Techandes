import os

import pymysql
from flask import g


def obtener_conexion():
    """Devuelve la conexión de la petición actual; la crea si no existe."""
    if "db" not in g:
        g.db = pymysql.connect(
            host=os.getenv("DB_HOST", "localhost"),
            port=int(os.getenv("DB_PORT", "3306")),
            user=os.getenv("DB_USER"),
            password=os.getenv("DB_PASSWORD"),
            database=os.getenv("DB_NAME", "techandes"),
            charset="utf8mb4",
            cursorclass=pymysql.cursors.DictCursor,
            autocommit=True,
        )
    return g.db


def cerrar_conexion(error=None):
    """Flask la llama al final de cada petición."""
    conexion = g.pop("db", None)
    if conexion is not None:
        conexion.close()


def consultar(sql, parametros=None, uno=False):
    """SELECT: lista de diccionarios, o uno solo si uno=True."""
    with obtener_conexion().cursor() as cursor:
        cursor.execute(sql, parametros)
        return cursor.fetchone() if uno else cursor.fetchall()


def ejecutar(sql, parametros=None):
    """INSERT, UPDATE o DELETE: devuelve (id_insertado, filas_afectadas)."""
    with obtener_conexion().cursor() as cursor:
        filas = cursor.execute(sql, parametros)
        return cursor.lastrowid, filas


def mensaje_error(error):
    """Traduce los códigos de MySQL que el portal sí puede explicar."""
    codigo = error.args[0] if getattr(error, "args", None) else None
    if codigo == 1062:
        return "Ya existe un registro con ese dato único."
    if codigo == 1451:
        return "El registro está en uso y no se puede eliminar."
    if codigo == 1452:
        return "Hay un dato que no existe en la tabla relacionada."
    if codigo in (3819, 4025):
        return "Los datos no cumplen las reglas de la base de datos."
    return "No se pudo completar la operación en la base de datos."
