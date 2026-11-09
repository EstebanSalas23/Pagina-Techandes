# Cómo se creó el portal TechAndes

Este documento explica qué se armó y por qué el portal se ve en el navegador y trabaja con MySQL. La forma de encenderlo está en `ejecutar.md`.

## Qué quedó construido

Es el portal interno de ventas del taller: una aplicación en Python con Flask. El navegador no habla con MySQL. Pide una página a Flask, Flask consulta la base `techandes` y devuelve HTML ya armado. No hay JavaScript de aplicación: los formularios se envían al servidor y el servidor responde con otra página.

El aspecto (banner, barra de bienvenida, menú y contenido) sale de una sola plantilla. Cada sección del menú es un módulo aparte.

## Paso 1. La base que ya existía

El archivo `Tablas techandes.sql` es el volcado de la tienda. Se copió a `sql/00_techandes_db.sql` y se le agregó `DROP TABLE IF EXISTS usuarios` para poder volver a importarlo sin que choque con la tabla de accesos.

Ese script crea la base y estas tablas:

| Tabla | Para qué sirve en el portal |
| --- | --- |
| `categorias` | Agrupa el catálogo. |
| `productos` | Nombre, precio, stock, categoría y si sigue activo. |
| `clientes` | Documento, nombre, correo, teléfono y ciudad. El correo está en la columna `email`. |
| `empleados` | Quien vende. El portal muestra nombres y cargo. |
| `pedidos` | Cliente, empleado, fecha, estado y método de pago. |
| `detalle_pedido` | Productos de cada pedido, con la cantidad y el precio del momento de la venta. |

Los estados permitidos son `PENDIENTE`, `ENVIADO`, `ENTREGADO` y `CANCELADO`. Los pagos permitidos son `EFECTIVO`, `TARJETA`, `TRANSFERENCIA` y `PSE`. Esas listas están como `CHECK` en MySQL: si el formulario manda otro valor, la base lo rechaza.

Con esos datos, antes de registrar ventas nuevas, el inicio muestra $ 66.538.300 en ventas efectivas, 2 pedidos pendientes y 8 productos con stock menor a 10.

## Paso 2. Usuarios y permisos

La base original no tenía forma de iniciar sesión. Se agregó `sql/01_usuarios.sql`.

La tabla `usuarios` guarda el nombre de usuario, el hash de la contraseña, el rol (`ADMIN` o `VENDEDOR`), el empleado al que pertenece, si está activo y la fecha del último ingreso. `id_empleado` es único: un empleado tiene un solo usuario.

La contraseña no se guarda en texto. Werkzeug genera un hash `scrypt` con una sal distinta para cada fila. Al entrar, el portal vuelve a calcular el hash de lo que escribió la persona y lo compara. Los tres administradores usan `Admin2026*` y los cinco asesores usan `Ventas2026*`.

| Usuario | Empleado | Rol |
| --- | --- | --- |
| mprieto | Martha Lucía Prieto Gaitán | ADMIN |
| hbustos | Hernán Bustos Arango | ADMIN |
| crobayo | Claudia Robayo Méndez | ADMIN |
| klozada | Kevin Lozada Perdomo | VENDEDOR |
| ytafur | Yesica Tafur Bonilla | VENDEDOR |
| boviedo | Brayan Oviedo Calderón | VENDEDOR |
| lmurcia | Lorena Murcia Vanegas | VENDEDOR |
| fcuellar | Fabián Cuéllar Yepes | VENDEDOR |

`sql/02_permisos.sql` crea el usuario de MySQL `techandes_api`, con clave `TechAndes2026*`, y le da `SELECT`, `INSERT`, `UPDATE` y `DELETE` solo sobre `techandes`. El portal se conecta con ese usuario, no con `root`.

## Paso 3. Configuración y conexión

`requirements.txt` pide Flask, PyMySQL, python-dotenv y cryptography. Cryptography hace falta porque MySQL 8 autentica con `caching_sha2_password`.

`.env` guarda lo que no debe quedar en el código: la clave que firma la cookie de sesión y los datos de conexión (`DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`). `.env.example` es la misma lista, sin la clave real. `.gitignore` deja fuera `.env` y la carpeta `.venv`.

`db.py` abre una conexión por petición y la cierra al terminar, aunque haya un error. Cada fila llega como diccionario (`nombre`, `precio`, …) gracias a `DictCursor`. Las consultas usan `%s` y una tupla de valores. Así un texto escrito en un buscador no se pega dentro del SQL.

Hay dos funciones:

- `consultar` ejecuta un `SELECT` y devuelve la lista, o una sola fila si se pide `uno=True`.
- `ejecutar` hace `INSERT`, `UPDATE` o `DELETE` y devuelve el id nuevo y cuántas filas cambiaron.

`mensaje_error` traduce los códigos que el usuario sí puede entender: 1062 (dato único repetido), 1451 (no se puede borrar porque otra tabla lo usa), 1452 (la llave foránea no existe) y 3819 (no cumple un `CHECK`).

## Paso 4. La aplicación

`app.py` crea la aplicación. Lee `.env`, firma la sesión con `SECRET_KEY` y registra el cierre de la conexión. También deja listas dos herramientas para todas las páginas:

- El filtro `pesos` convierte `1499000` en `$ 1.499.000`.
- El filtro `fecha` convierte una fecha de MySQL en `29/09/2026` o, si se pide, con hora.

Cada sección del menú es un blueprint en `rutas/`. `app.py` los registra. Si una ruta no existe, responde 404. Si el rol no alcanza, responde 403. Esas dos páginas usan `templates/errores/error.html`.

| Archivo | Rutas | Quién entra |
| --- | --- | --- |
| `rutas/auth.py` | `/login`, `/logout` | Cualquiera |
| `rutas/inicio.py` | `/` | Con sesión |
| `rutas/productos.py` | `/productos/` | Ver: con sesión. Crear, editar y eliminar: solo ADMIN |
| `rutas/clientes.py` | `/clientes/` | Con sesión |
| `rutas/ventas.py` | `/ventas/nueva` | Con sesión |
| `rutas/pedidos.py` | `/pedidos/` | Con sesión |
| `rutas/informes.py` | `/informes/` | Solo ADMIN |

`rutas/__init__.py` está vacío. Sirve para que Python trate la carpeta `rutas` como un paquete.

## Paso 5. Lo que se ve en el navegador

Flask busca el HTML en `templates/` y las imágenes y estilos en `static/`. Esos nombres no se pueden cambiar.

`templates/base.html` se escribe una vez y lo heredan las páginas de adentro. Tiene cinco franjas:

1. El banner `static/img/banner.svg` (logo, nombre TECHANDES y la cordillera).
2. La barra de bienvenida con el nombre, el cargo, el rol y Cerrar sesión. Esos datos salen de la sesión, no de un texto fijo.
3. El menú. La pestaña activa se marca porque Flask sabe en qué módulo está la página. Informes solo se dibuja si el rol es `ADMIN`.
4. El contenido, que cada página llena con su propio bloque.
5. El pie con el año actual.

Los avisos de una sola vez (producto creado, stock insuficiente, sesión cerrada) se envían con `flash` y la plantilla los pinta de verde, rojo o ámbar.

`templates/login.html` no hereda esa base, porque todavía no hay un empleado que mostrar. Es una tarjeta centrada con el mismo banner y el formulario de usuario y contraseña.

`static/css/estilos.css` define la paleta en variables al inicio del archivo. El fondo, el recuadro, el menú, las tarjetas y los botones usan esas variables. La paleta actual es verde bosque y cobre, en lugar del azul del taller. El banner se pintó con los mismos tonos para que no se vea de otro sitio.

## Paso 6. Inicio de sesión y permisos

`seguridad.py` tiene dos decoradores. Se ponen encima de la función de la ruta, debajo de `@bp.route`:

- `login_requerido` mira si hay un usuario en la sesión. Si no, manda a `/login` y guarda la página que se había pedido, para volver a ella después de entrar.
- `rol_requerido("ADMIN")` exige sesión y, además, ese rol. Si un vendedor abre `/informes/` a mano, recibe 403. Ocultar el enlace del menú no basta.

En `rutas/auth.py` el ingreso funciona así:

1. Lee usuario y contraseña del formulario. El usuario se pasa a minúsculas.
2. Busca esa fila uniendo `usuarios` con `empleados`.
3. Compara la contraseña con el hash. Si el usuario no existe o la clave no coincide, el mensaje es el mismo: no se dice cuál de los dos falló.
4. Si el usuario está desactivado, no entra.
5. Si todo coincide, limpia la sesión anterior y guarda solo lo necesario: id, usuario, rol, id del empleado, nombre y cargo. No guarda la contraseña ni el hash.
6. Actualiza `ultimo_acceso`.
7. Redirige a la página pedida, o al inicio. Después de un POST correcto se responde con una redirección, no con la misma página, para que recargar no vuelva a enviar el formulario.

Cerrar sesión borra la cookie de sesión y regresa al ingreso.

## Paso 7. Cómo una página muestra datos

El inicio es el ejemplo completo. `rutas/inicio.py` hace cuatro consultas y se las pasa a `templates/inicio.html`:

- Ventas efectivas (suma de detalle de pedidos que no están cancelados), pedidos pendientes, cantidad de clientes y productos activos con stock menor a 10.
- Las ventas del empleado que inició sesión. Por eso Kevin Lozada ve 12 pedidos y $ 20.828.100, y la gerente ve accesos rápidos en lugar de ese bloque.
- Los 5 pedidos más recientes, con cliente y total.
- Los productos activos con menos de 10 unidades.

La plantilla recorre esas listas con `{% for %}`. `{{ total | pesos }}` y `{{ fecha_pedido | fecha }}` usan los filtros de `app.py`. El estado lleva una clase CSS (`PENDIENTE`, `ENVIADO`, `ENTREGADO`, `CANCELADO`) y cada una tiene su color.

El mismo patrón se repite en el resto:

- **Productos.** La lista filtra por nombre y categoría con `WHERE 1 = 1` y un `AND` por cada filtro. Los valores van en `%s`. Crear y editar comparten `templates/productos/formulario.html`. El formulario se valida en Python aunque el HTML ya pida los campos: el navegador se puede saltar. Eliminar es un POST. Si el producto ya está en un pedido, MySQL responde 1451 y la página dice que no se borre, que se desmarque Activo.
- **Clientes.** La lista busca por nombre, apellido o documento y filtra por ciudad. Un `LEFT JOIN` cuenta los pedidos, también los de quien tiene cero. Al registrar se valida documento numérico, correo y ciudad. Si el documento o el correo ya existen, el error 1062 se muestra como «Ya existe un cliente con ese documento o correo». El detalle muestra lo comprado, sin contar cancelados, y el historial.
- **Pedidos.** La lista filtra por estado. El detalle muestra cliente, vendedor, líneas y total. Cambiar el estado va en una transacción: se lee el estado actual con `FOR UPDATE` para que dos personas no lo cancelen a la vez. Si ya está cancelado, no se toca. Si el nuevo estado es `CANCELADO`, primero se devuelve el stock de cada línea y después se actualiza el pedido.

## Paso 8. La venta, que es todo o nada

Registrar una venta toca tres tablas: inserta el pedido, inserta cada línea del detalle y resta el stock. Si algo falla a la mitad, no puede quedar un pedido sin sus productos o un stock descontado sin venta.

`rutas/ventas.py` lo hace en una transacción:

1. El formulario manda cliente, método de pago y hasta 5 filas de producto y cantidad. Las filas vacías se ignoran. Si el mismo producto aparece dos veces, las cantidades se suman, porque la llave de `detalle_pedido` no permite repetirlo en el mismo pedido.
2. El vendedor es el de la sesión. No se elige en el formulario.
3. `BEGIN` abre la transacción. Nada se guarda hasta el `COMMIT`.
4. Se inserta el pedido en estado `PENDIENTE`.
5. Por cada producto se lee la fila con `FOR UPDATE` (la bloquea mientras dura la venta), se comprueba que esté activo y que el stock alcance, se inserta el detalle con el precio que está en la base en ese momento y se resta el stock.
6. Si todo sale bien, `COMMIT`. La ruta redirige al detalle del pedido nuevo.
7. Si falta stock o el producto no existe, se lanza `ErrorVenta`, se hace `ROLLBACK` y no queda nada de esa venta. El mensaje dice cuántas unidades hay y cuántas se pidieron.

Por eso una venta de 1 memoria USB y 50 portátiles ASUS (el ASUS tiene 5) no crea el pedido y la memoria sigue en 80. Y 2 mouse Logitech M280 más 1 SSD Kingston NV2 quedan en $ 427.000, porque 69.000 × 2 + 289.000 = 427.000.

## Paso 9. Informes

`rutas/informes.py` solo la abre un administrador. Reúne cuatro consultas sobre las ventas que no están canceladas:

- Total por categoría. El porcentaje se calcula en Python (total de la categoría dividido entre el gran total) y la plantilla lo usa como ancho de una barra hecha con CSS.
- Ranking de vendedores con `RANK() OVER`. El primero es Brayan Oviedo Calderón.
- Los 5 productos con más unidades vendidas.
- Clientes que no tienen ningún pedido, con `NOT EXISTS`.

## El error de PyMySQL al iniciar sesión

Al enviar el formulario de ingreso, Flask respondía 500 y la terminal mostraba:

```text
pymysql.err.OperationalError: (1045, "Access denied for user 'techandes_api'@'localhost' (using password: YES)")
```

La traza salía de `rutas/auth.py`, en la consulta del login, y de ahí a `db.py`, en `pymysql.connect`. El fallo ocurría dentro de la autenticación `caching_sha2_password` de MySQL 8. No era una consulta mal escrita ni un fallo de la librería: MySQL rechazaba la cuenta con la que el `.env` intenta entrar.

Se revisó la base entrando como `root` (la misma cuenta de Workbench). Esto es lo que había:

- La base `techandes` sí existía, con `categorias`, `clientes`, `detalle_pedido`, `empleados`, `pedidos`, `productos` y `usuarios`.
- La tabla `usuarios` tenía la estructura correcta, pero **cero filas**. El script `01_usuarios.sql` no se había cargado.
- La cuenta de MySQL `techandes_api` **no existía**. Por eso el error 1045, aunque la contraseña del `.env` fuera `TechAndes2026*`.

Se aplicó entonces lo que faltaba, sin volver a importar `00_techandes_db.sql` para no borrar los datos de la tienda:

1. `sql/02_permisos.sql`: se creó `techandes_api`@`localhost`, se le asignó la clave `TechAndes2026*` y se le dio `SELECT`, `INSERT`, `UPDATE` y `DELETE` sobre `techandes`.
2. El `INSERT` de `sql/01_usuarios.sql`: se cargaron los 8 usuarios con sus hashes. Se comprobó cada hash con Werkzeug: los ADMIN aceptan `Admin2026*` y los VENDEDOR aceptan `Ventas2026*`.

Después se probó el portal con la cookie de sesión. `klozada` / `Ventas2026*` entra al inicio, la barra muestra a Kevin Lozada Perdomo y las ventas efectivas aparecen en $ 66.538.300. PyMySQL conecta bien; el ingreso ya no devuelve 1045.

## Cómo se recorre una visita

1. La persona abre http://127.0.0.1:5000/productos/ sin haber entrado.
2. `login_requerido` no encuentra sesión y redirige a `/login?siguiente=/productos/`.
3. Envía el formulario. Flask compara el hash y, si coincide, guarda al empleado en la sesión.
4. El navegador vuelve a `/productos/`. Ahora sí hay sesión.
5. La ruta arma el SQL, `db.py` lo ejecuta en MySQL y devuelve diccionarios.
6. Jinja mete esos diccionarios en la plantilla, que hereda el banner y el menú de `base.html`.
7. El navegador pide también `static/css/estilos.css` y `static/img/banner.svg`. Flask se los entrega y la página se ve con la paleta verde y cobre.
8. Al terminar la petición, `db.py` cierra la conexión.

Ese recorrido ya funciona en este equipo: `techandes_api` existe y `usuarios` tiene las 8 filas. Si se vuelve a importar `00_techandes_db.sql`, hay que ejecutar otra vez `01_usuarios.sql`, porque ese volcado deja la tabla de accesos vacía o la elimina. Si el ingreso vuelve a mostrar el 1045, falta volver a ejecutar `02_permisos.sql`.
