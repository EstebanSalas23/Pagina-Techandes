-- Usuario con el que se conecta el portal. Ejecutar como root.
CREATE USER IF NOT EXISTS 'techandes_api'@'localhost' IDENTIFIED BY 'TechAndes2026*';
ALTER USER 'techandes_api'@'localhost' IDENTIFIED BY 'TechAndes2026*';
GRANT SELECT, INSERT, UPDATE, DELETE ON techandes.* TO 'techandes_api'@'localhost';
FLUSH PRIVILEGES;
