# Portal TechAndes

Portal interno de ventas de TechAndes. Está hecho con Flask y se conecta a la base MySQL `techandes`.

## Requisitos

- Python 3.10 o superior
- MySQL 8 en ejecución (en este equipo, el servicio MySQL 26.7)

## Base de datos

En MySQL Workbench, conectado como `root`, ejecute los scripts en este orden:

1. `sql/00_techandes_db.sql` — crea la base y carga categorías, empleados, clientes, productos y pedidos.
2. `sql/01_usuarios.sql` — crea la tabla `usuarios` y los 8 accesos del portal.
3. `sql/02_permisos.sql` — crea el usuario `techandes_api` con permiso de leer y modificar `techandes`.

El archivo `Tablas techandes.sql` es el volcado original. La copia de trabajo es `sql/00_techandes_db.sql` (además borra `usuarios` si vuelve a importar la base).

Si reimporta el paso 1, vuelva a ejecutar el paso 2: el volcado no trae la tabla de usuarios.

## Instalación del portal

```powershell
cd techandes-portal
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
copy .env.example .env
```

En este proyecto el entorno y el archivo `.env` ya están creados. La clave de MySQL del portal es la del taller: `TechAndes2026*`.

## Ejecutar

```powershell
.venv\Scripts\activate
python app.py
```

Abra http://127.0.0.1:5000 . Sin sesión, cualquier página lleva a `/login`.

## Usuarios de prueba

| Usuario | Empleado | Rol | Contraseña |
| --- | --- | --- | --- |
| mprieto | Martha Lucía Prieto Gaitán, gerente | ADMIN | Admin2026* |
| hbustos | Hernán Bustos Arango, supervisor | ADMIN | Admin2026* |
| crobayo | Claudia Robayo Méndez, supervisor | ADMIN | Admin2026* |
| klozada | Kevin Lozada Perdomo, asesor | VENDEDOR | Ventas2026* |
| ytafur | Yesica Tafur Bonilla, asesor | VENDEDOR | Ventas2026* |
| boviedo | Brayan Oviedo Calderón, asesor | VENDEDOR | Ventas2026* |
| lmurcia | Lorena Murcia Vanegas, asesor | VENDEDOR | Ventas2026* |
| fcuellar | Fabián Cuéllar Yepes, asesor | VENDEDOR | Ventas2026* |

## Módulos

- **Inicio:** ventas efectivas, pedidos pendientes, clientes, stock bajo, últimos pedidos y productos por reabastecer. El vendedor ve sus propias ventas; el administrador ve accesos rápidos.
- **Productos:** catálogo con búsqueda. Solo el administrador crea, edita y elimina.
- **Clientes:** búsqueda, registro e historial. El correo del taller `andres.gomez1@correo.com` ya existe.
- **Nueva venta:** pedido en una transacción. Descuenta stock y guarda el precio del momento.
- **Pedidos:** consulta y cambio de estado. Al cancelar, las unidades vuelven al inventario.
- **Informes:** solo administrador. Ventas por categoría, ranking de vendedores, top 5 y clientes sin compras.

## Cifras del volcado

Con los datos cargados, antes de registrar ventas nuevas:

- Ventas efectivas: $ 66.538.300
- Pedidos pendientes: 2
- Productos con stock menor a 10: 8
- Kevin Lozada (`klozada`): 12 pedidos por $ 20.828.100
- Primer puesto del ranking: Brayan Oviedo Calderón, $ 21.491.600

El volcado incluye un cliente extra, Esteban Salas Posada (Ibagué, documento 1130504126). Por eso el inicio muestra **41 clientes** y el filtro Ibagué devuelve **11**, no los 40 y 10 del guion original. Ese cliente no tiene pedidos, así que las ventas no cambian. Si el profesor pide las cifras exactas del taller, borre esa fila en Workbench y vuelva a abrir Inicio.

## Prueba de una venta

Cliente Tomás Ortega Beltrán, 2 unidades del Mouse Logitech M280 (id 16, $ 69.000) y 1 SSD Kingston NV2 1TB (id 23, $ 289.000). El pedido queda en $ 427.000. Una venta con 50 portátiles ASUS TUF Gaming F15 (id 3, stock 5) se rechaza y no crea el pedido.
