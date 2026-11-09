# Cómo ejecutar el portal TechAndes

Hay dos partes: primero la base de datos en MySQL Workbench y después el portal en Python. Si omites la base, la pantalla de ingreso abre, pero al escribir usuario y contraseña sale un error de conexión.

La carpeta del proyecto es:

```text
C:\Users\johan\techandes-portal
```

## 1. Encender MySQL

1. Pulsa la tecla Windows y escribe **Servicios**.
2. Busca **MySQL267** (MySQL Server 26.7).
3. Si el estado no es **En ejecución**, clic derecho y **Iniciar**.

MySQL80 puede quedar detenido. El que usa este proyecto es el que está escuchando en el puerto **3306**, que en este equipo es MySQL267.

## 2. Cargar la base en Workbench

Abre **MySQL Workbench** y entra a la conexión local con el usuario **root** (la misma con la que ya trabajas).

Ejecuta estos tres archivos, en este orden, uno por uno. En cada uno: **File → Open SQL Script**, elige el archivo y pulsa el rayo (**Execute**). Espera a que termine antes de abrir el siguiente.

| Orden | Archivo | Qué hace |
| --- | --- | --- |
| 1 | `sql\00_techandes_db.sql` | Crea la base `techandes` y carga categorías, empleados, clientes, productos y los 50 pedidos. |
| 2 | `sql\01_usuarios.sql` | Crea la tabla `usuarios` y los 8 accesos del portal. Al final muestra la lista de usuarios. |
| 3 | `sql\02_permisos.sql` | Crea el usuario `techandes_api` con clave `TechAndes2026*` y le da permiso de consultar y modificar esa base. |

El portal no entra como `root`. Entra como `techandes_api`. Por eso el tercer script es obligatorio.

Comprueba que quedó bien. En una pestaña de consulta:

```sql
USE techandes;
SHOW TABLES;
SELECT usuario, rol FROM usuarios;
```

Deben aparecer las tablas `categorias`, `clientes`, `detalle_pedido`, `empleados`, `pedidos`, `productos` y `usuarios`, y estos 8 usuarios: `mprieto`, `hbustos`, `crobayo`, `klozada`, `ytafur`, `boviedo`, `lmurcia`, `fcuellar`.

Si más adelante vuelves a ejecutar el script 1, ejecuta otra vez el 2. El volcado de tablas no trae `usuarios`.

## 3. Abrir la terminal del proyecto

En Cursor, abre una terminal en la carpeta del proyecto. Si PowerShell dice que la ejecución de scripts está deshabilitada, corre esto una sola vez y vuelve a abrir la terminal:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

Activa el entorno virtual. Hay que hacerlo cada vez que abras una terminal nueva:

```powershell
cd C:\Users\johan\techandes-portal
.\.venv\Scripts\activate
```

Cuando está activo, la línea empieza con `(.venv)`.

La primera vez en otro computador también haría falta instalar las librerías. En este equipo ya están instaladas. Si en una máquina nueva falta Flask, ejecuta:

```powershell
pip install -r requirements.txt
```

El archivo `.env` ya existe y apunta a `localhost`, base `techandes`, usuario `techandes_api` y clave `TechAndes2026*`. No lo subas a GitHub.

## 4. Arrancar el portal

Con `(.venv)` visible:

```powershell
python app.py
```

La terminal debe decir:

```text
Running on http://127.0.0.1:5000
```

Deja esa terminal abierta. Si la cierras o pulsas Ctrl + C, el portal se apaga.

Abre el navegador en:

http://127.0.0.1:5000

Te lleva a la pantalla de ingreso.

## 5. Entrar

| Usuario | Quién es | Rol | Contraseña |
| --- | --- | --- | --- |
| mprieto | Martha Lucía Prieto Gaitán, gerente | ADMIN | Admin2026* |
| hbustos | Hernán Bustos Arango, supervisor | ADMIN | Admin2026* |
| crobayo | Claudia Robayo Méndez, supervisor | ADMIN | Admin2026* |
| klozada | Kevin Lozada Perdomo, asesor | VENDEDOR | Ventas2026* |
| ytafur | Yesica Tafur Bonilla, asesor | VENDEDOR | Ventas2026* |
| boviedo | Brayan Oviedo Calderón, asesor | VENDEDOR | Ventas2026* |
| lmurcia | Lorena Murcia Vanegas, asesor | VENDEDOR | Ventas2026* |
| fcuellar | Fabián Cuéllar Yepes, asesor | VENDEDOR | Ventas2026* |

Para probar los dos roles:

1. Entra como `klozada` / `Ventas2026*`. Ves Inicio, Productos, Clientes, Nueva venta y Pedidos. No aparece Informes. Si escribes a mano http://127.0.0.1:5000/informes/ sale el error 403.
2. En Inicio, las ventas efectivas son **$ 66.538.300** y **Mis ventas** dice 12 pedidos por **$ 20.828.100**.
3. Cierra sesión.
4. Entra como `mprieto` / `Admin2026*`. Aparecen Informes y los botones de crear, editar y eliminar productos.

El volcado trae un cliente extra (Esteban Salas Posada, Ibagué). Por eso el inicio muestra **41** clientes y el filtro Ibagué devuelve **11**, no los 40 y 10 del PDF. Las ventas no cambian.

## 6. Probar una venta y una cancelación

Con `klozada` todavía dentro:

1. Abre **Nueva venta**.
2. Cliente: **Tomás Ortega Beltrán**.
3. Método de pago: el que quieras (EFECTIVO, TARJETA, TRANSFERENCIA o PSE).
4. Fila 1: **Mouse Logitech M280**, cantidad **2**.
5. Fila 2: **SSD Kingston NV2 1TB**, cantidad **1**.
6. Registrar. Debe crearse el pedido **#51** por **$ 427.000**. El precio lo pone la base, no el formulario.

Prueba que la venta se deshace si no hay stock:

1. Otra venta nueva.
2. Fila 1: **Memoria USB SanDisk 128GB**, cantidad **1**.
3. Fila 2: **Portátil ASUS TUF Gaming F15**, cantidad **50**.
4. Debe decir que el stock es insuficiente (hay 5) y no debe crearse ningún pedido. La memoria USB sigue con 80 unidades.

Luego abre el pedido **#51**, cambia el estado a **CANCELADO** y actualiza. El mensaje dice que las unidades volvieron al inventario. El mouse queda otra vez en 60. Si intentas pasarlo a ENVIADO, el portal responde que un pedido cancelado no se puede modificar.

## 7. Parar el servidor

En la terminal donde corre `python app.py`, pulsa **Ctrl + C**.

Para volver a usarlo otro día: enciende MySQL, activa `.venv` y ejecuta otra vez `python app.py`. No hace falta repetir los scripts SQL, salvo que quieras borrar lo que hayas vendido y regresar a los 50 pedidos originales. En ese caso vuelve a ejecutar, en orden, `00_techandes_db.sql` y `01_usuarios.sql`.

## Si algo falla

| Qué ves | Qué hacer |
| --- | --- |
| `Access denied` o usuario o contraseña incorrectos en el portal, con la clave bien escrita | No corriste `02_permisos.sql`, o el `.env` no coincide. Revisa que `DB_USER` sea `techandes_api` y `DB_PASSWORD` sea `TechAndes2026*`. |
| `Can't connect` | MySQL está apagado o no está en el puerto 3306. |
| `Table 'techandes.usuarios' doesn't exist` | Falta ejecutar `sql\01_usuarios.sql`. |
| Usuario o contraseña incorrectos con `klozada` y `Ventas2026*` | Los administradores usan `Admin2026*`. Los asesores usan `Ventas2026*`. Si sigue fallando, vuelve a ejecutar `01_usuarios.sql`. |
| `Address already in use` o el puerto 5000 ocupado | Ya hay un `python app.py` abierto. Ciérralo con Ctrl + C en esa terminal, o entra directo a http://127.0.0.1:5000. |
| La página se ve sin estilos | Recarga con Ctrl + F5. |
