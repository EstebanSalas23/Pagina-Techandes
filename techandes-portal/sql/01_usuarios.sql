-- Tabla de acceso del portal. Ejecutar en Workbench como root,
-- después de sql/00_techandes_db.sql.
USE techandes;

DROP TABLE IF EXISTS usuarios;

CREATE TABLE usuarios (
  id_usuario     INT          NOT NULL AUTO_INCREMENT,
  usuario        VARCHAR(30)  NOT NULL,
  clave_hash     VARCHAR(255) NOT NULL,
  rol            VARCHAR(15)  NOT NULL DEFAULT 'VENDEDOR',
  id_empleado    INT          NOT NULL,
  activo         TINYINT      NOT NULL DEFAULT 1,
  ultimo_acceso  DATETIME     NULL,
  CONSTRAINT pk_usuarios PRIMARY KEY (id_usuario),
  CONSTRAINT uq_usuarios_usuario  UNIQUE (usuario),
  CONSTRAINT uq_usuarios_empleado UNIQUE (id_empleado),
  CONSTRAINT fk_usuarios_empleados FOREIGN KEY (id_empleado)
      REFERENCES empleados (id_empleado)
      ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_usuarios_rol    CHECK (rol IN ('ADMIN', 'VENDEDOR')),
  CONSTRAINT ck_usuarios_activo CHECK (activo IN (0, 1))
) ENGINE = InnoDB;

-- ADMIN: Admin2026*    VENDEDOR: Ventas2026*
-- Cada hash incluye una sal distinta, aunque la clave sea la misma.
INSERT INTO usuarios (usuario, clave_hash, rol, id_empleado) VALUES
  ('mprieto',  'scrypt:32768:8:1$RvWeaHGEseGIO5CH$868d4f4f9f6250f1bc1b965e1fddbddb4e700219faed3a1f1447a0c1b8e63b97198e1eb130ae774dd0346224644f961ff71a96e35b67bea3729d4ca1546f8217', 'ADMIN', 1),
  ('hbustos',  'scrypt:32768:8:1$GllLqjM6QQXoSMgP$038d0cd6e2cc357c13ea7f68264286ff1a194998e9bfb4b8789dfc2076d0bb626011b343148df50477f10d887c04553c3039f905e6bf39a07f044d43d47807bf', 'ADMIN', 2),
  ('crobayo',  'scrypt:32768:8:1$hPmvmehYoq8bD2b2$c2f8fbf148bd6807d570c30c97432c3d83ee134cfd69e82354173d178a9f45be3a51b7becb491a98972dfe4fdfb454ecfd1f3da8c9fd31873e62532c86e13fac', 'ADMIN', 3),
  ('klozada',  'scrypt:32768:8:1$CEuPbth8N13FYAmr$2e8a896d22aef9a42c3ece492f3c4c9c51fbcf6a5771ec0f145edb792518fcdc117f6748ba6940a25ea8acec1b1c917da17968b30ca1e8011888ead8e58d8b9e', 'VENDEDOR', 4),
  ('ytafur',   'scrypt:32768:8:1$R48kBIifDzqcfXdT$cb56738c831d30923b1791607d90065983367383206ed4c2c09c41000d3d6a84ca69893021e72edccc9eaf568b61f505b84e7c34e99478d03638c14bf9e413b1', 'VENDEDOR', 5),
  ('boviedo',  'scrypt:32768:8:1$2W9n3EsyCMCQzMcH$1db5df31e2b7c1d559687d7934d98731b12465a71aaccf458471ab8f0d900d8ec2ea5813d428bbd75a12891d8c05a983d62f05bca48e561289aeed140fac7c9c', 'VENDEDOR', 6),
  ('lmurcia',  'scrypt:32768:8:1$rTkx3lpoUjbDOYDS$25e93f1b3a58d1c26c922bf6e6e6598439be7f1f5c94b40c460a8c1bcdbea1f118593a1d8fef5ad485d69be89f7b3c511b471fb0fd4aa0cdc2f87469e702b97b', 'VENDEDOR', 7),
  ('fcuellar', 'scrypt:32768:8:1$6cYfETwOxNe3Igia$6ca8fc4031a21e1431f71052ff208060cc7bc42b3cf3c3bff79cb7f68075660eabe227e1a20956c6ff1e5e02e31f8ea7082ec5a2878d2a935bea88e05b1d1fb9', 'VENDEDOR', 8);

SELECT u.usuario, u.rol, CONCAT(e.nombres, ' ', e.apellidos) AS empleado, e.cargo
FROM usuarios u
JOIN empleados e ON e.id_empleado = u.id_empleado
ORDER BY u.id_usuario;
