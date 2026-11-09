CREATE DATABASE  IF NOT EXISTS `techandes` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;
USE `techandes`;
-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: 127.0.0.1    Database: techandes
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `categorias`
--

DROP TABLE IF EXISTS `categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categorias` (
  `id_categoria` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id_categoria`),
  UNIQUE KEY `uq_categorias_nombre` (`nombre`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias`
--

LOCK TABLES `categorias` WRITE;
/*!40000 ALTER TABLE `categorias` DISABLE KEYS */;
INSERT INTO `categorias` VALUES (1,'Portátiles','Computadores portátiles para hogar, oficina y gaming'),(2,'Celulares','Teléfonos inteligentes de gama media y alta'),(3,'Tablets','Tabletas y lectores electrónicos'),(4,'Monitores','Pantallas para computador de 22 a 34 pulgadas'),(5,'Periféricos','Teclados, mouse, cámaras web y accesorios'),(6,'Audio','Audífonos, parlantes y micrófonos'),(7,'Almacenamiento','Discos SSD, discos externos y memorias USB'),(8,'Redes','Routers, repetidores y adaptadores de red');
/*!40000 ALTER TABLE `categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `clientes`
--

DROP TABLE IF EXISTS `clientes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `clientes` (
  `id_cliente` int NOT NULL AUTO_INCREMENT,
  `documento` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  `nombres` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellidos` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `telefono` varchar(15) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ciudad` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `fecha_registro` date NOT NULL DEFAULT (curdate()),
  PRIMARY KEY (`id_cliente`),
  UNIQUE KEY `uq_clientes_documento` (`documento`),
  UNIQUE KEY `uq_clientes_email` (`email`),
  KEY `idx_clientes_ciudad` (`ciudad`)
) ENGINE=InnoDB AUTO_INCREMENT=42 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `clientes`
--

LOCK TABLES `clientes` WRITE;
/*!40000 ALTER TABLE `clientes` DISABLE KEYS */;
INSERT INTO `clientes` VALUES (1,'1064708126','Andrés','Gómez Rojas','andres.gomez1@correo.com','3126376341','Cali','2025-04-17'),(2,'1094047344','Valentina','Rodríguez Peña','valentina.rodriguez2@correo.com','3573002611','Ibagué','2025-02-09'),(3,'1073233523','Santiago','Martínez Cruz','santiago.martinez3@correo.com','3285134554','Bucaramanga','2024-12-23'),(4,'1089892850','Camila','López Vargas','camila.lopez4@correo.com','3283571250','Bogotá','2025-07-15'),(5,'1086820486','Juan David','García Mora','juan.garcia5@correo.com','3563948553','Ibagué','2025-01-08'),(6,'1027183296','Daniela','Hernández Ríos','daniela.hernandez6@correo.com','3246109392','Ibagué','2024-06-05'),(7,'1004443850','Sebastián','Ramírez Ortiz','sebastian.ramirez7@correo.com','3197998874','Ibagué','2025-04-02'),(8,'1061502247','Laura','Torres Castro','laura.torres8@correo.com',NULL,'Bogotá','2025-07-17'),(9,'1070180947','Felipe','Díaz Molina','felipe.diaz9@correo.com','3558309773','Barranquilla','2024-09-11'),(10,'1034911442','María José','Moreno Suárez','maria.moreno10@correo.com','3572633522','Medellín','2025-02-17'),(11,'1102905180','Carlos','Jiménez Ruiz','carlos.jimenez11@correo.com','3568281295','Pereira','2025-03-13'),(12,'1089106819','Natalia','Álvarez Parra','natalia.alvarez12@correo.com','3048932423','Ibagué','2024-11-10'),(13,'1061425491','Julián','Romero Silva','julian.romero13@correo.com','3068847902','Medellín','2025-01-28'),(14,'1096169478','Paula','Castillo León','paula.castillo14@correo.com','3270789987','Bogotá','2024-09-02'),(15,'1057146759','Mateo','Herrera Rincón','mateo.herrera15@correo.com','3518629549','Cali','2025-02-01'),(16,'1035764479','Sara','Medina Duarte','sara.medina16@correo.com','3559677843','Medellín','2024-07-20'),(17,'1026116972','Diego','Aguirre Pinto','diego.aguirre17@correo.com','3529643929','Barranquilla','2025-01-17'),(18,'1001883416','Isabella','Cárdenas Gil','isabella.cardenas18@correo.com','3010028718','Ibagué','2025-01-18'),(19,'1077932180','Alejandro','Osorio Lozano','alejandro.osorio19@correo.com','3091890761','Medellín','2025-07-12'),(20,'1026681370','Mariana','Quintero Mejía','mariana.quintero20@correo.com','3126216039','Cali','2025-04-14'),(21,'1005994039','Jorge','Valencia Ospina','jorge.valencia21@correo.com','3299721481','Cali','2025-06-23'),(22,'1085283083','Catalina','Arias Bernal','catalina.arias22@correo.com','3230771657','Bucaramanga','2024-06-03'),(23,'1042069571','Esteban','Patiño Rueda','esteban.patino23@correo.com','3528101218','Bogotá','2025-03-07'),(24,'1029920845','Luisa','Restrepo Cano','luisa.restrepo24@correo.com',NULL,'Barranquilla','2024-12-21'),(25,'1078911235','Nicolás','Salazar Niño','nicolas.salazar25@correo.com','3190280510','Ibagué','2025-05-21'),(26,'1067742558','Ana María','Vélez Pardo','ana.velez26@correo.com','3221332433','Bogotá','2024-12-31'),(27,'1089731916','Cristian','Zapata Acosta','cristian.zapata27@correo.com','3128165850','Bogotá','2025-07-07'),(28,'1105013444','Juliana','Montoya Rivas','juliana.montoya28@correo.com','3278142594','Manizales','2024-12-28'),(29,'1052399581','Miguel','Guerrero Luna','miguel.guerrero29@correo.com','3179797368','Bogotá','2025-07-19'),(30,'1026400239','Gabriela','Cifuentes Mora','gabriela.cifuentes30@correo.com','3511896747','Ibagué','2024-07-25'),(31,'1052257400','Óscar','Bermúdez Tovar','oscar.bermudez31@correo.com','3016895485','Bogotá','2024-11-25'),(32,'1086741219','Carolina','Sánchez Prada','carolina.sanchez32@correo.com','3213461507','Manizales','2024-06-14'),(33,'1068503096','Tomás','Ortega Beltrán','tomas.ortega33@correo.com','3553991209','Bucaramanga','2025-05-16'),(34,'1040758128','Manuela','Rivera Galvis','manuela.rivera34@correo.com','3553760716','Medellín','2024-08-02'),(35,'1066782671','David','Campos Ayala','david.campos35@correo.com','3586721298','Ibagué','2025-04-13'),(36,'1108037032','Verónica','Pineda Soto','veronica.pineda36@correo.com','3130654844','Medellín','2025-03-30'),(37,'1069741374','Samuel','Navarro Toro','samuel.navarro37@correo.com',NULL,'Pereira','2024-09-14'),(38,'1058197822','Lina','Ibarra Franco','lina.ibarra38@correo.com','3271581409','Ibagué','2025-04-03'),(39,'1031316553','Ricardo','Cortés Daza','ricardo.cortes39@correo.com','3083464604','Cali','2024-12-22'),(40,'1004583896','Diana','Barrera Lugo','diana.barrera40@correo.com','3196869801','Bogotá','2024-08-28'),(41,'1130504126','Esteban','Salas Posada','esteban.salas.4126@miremington.edu.co','3026755355','Ibagué','2026-11-06');
/*!40000 ALTER TABLE `clientes` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalle_pedido`
--

DROP TABLE IF EXISTS `detalle_pedido`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalle_pedido` (
  `id_pedido` int NOT NULL,
  `id_producto` int NOT NULL,
  `cantidad` int NOT NULL,
  `precio_unitario` decimal(12,2) NOT NULL,
  PRIMARY KEY (`id_pedido`,`id_producto`),
  KEY `fk_detalle_productos` (`id_producto`),
  CONSTRAINT `fk_detalle_pedidos` FOREIGN KEY (`id_pedido`) REFERENCES `pedidos` (`id_pedido`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_detalle_productos` FOREIGN KEY (`id_producto`) REFERENCES `productos` (`id_producto`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `ck_detalle_cantidad` CHECK ((`cantidad` > 0)),
  CONSTRAINT `ck_detalle_precio` CHECK ((`precio_unitario` > 0))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalle_pedido`
--

LOCK TABLES `detalle_pedido` WRITE;
/*!40000 ALTER TABLE `detalle_pedido` DISABLE KEYS */;
INSERT INTO `detalle_pedido` VALUES (1,19,1,249000.00),(2,18,2,89000.00),(3,20,1,229000.00),(4,2,1,3199000.00),(4,8,1,4299000.00),(5,16,2,69000.00),(6,1,1,2499000.00),(7,5,1,1699000.00),(7,29,3,71100.00),(8,19,1,249000.00),(9,23,2,289000.00),(10,9,1,899000.00),(11,20,1,229000.00),(12,12,2,649000.00),(13,6,1,999000.00),(14,16,1,69000.00),(14,27,1,219000.00),(15,7,1,1899000.00),(16,29,1,71100.00),(17,14,1,1799000.00),(18,25,3,59000.00),(19,6,1,999000.00),(20,24,1,349000.00),(21,6,1,999000.00),(22,17,3,329000.00),(22,21,1,589000.00),(23,6,1,999000.00),(23,26,4,799000.00),(24,1,1,2499000.00),(25,3,1,4899000.00),(26,15,2,189000.00),(27,6,2,999000.00),(28,1,1,2499000.00),(28,4,1,2659000.00),(29,19,1,249000.00),(30,25,2,56000.00),(31,4,1,2799000.00),(32,16,4,69000.00),(32,25,1,59000.00),(33,6,1,999000.00),(34,10,1,1099000.00),(34,29,1,71100.00),(35,1,1,2499000.00),(35,21,1,559600.00),(36,15,2,189000.00),(37,15,1,189000.00),(38,6,1,999000.00),(39,23,2,289000.00),(40,5,1,1699000.00),(41,10,1,1099000.00),(41,16,3,69000.00),(42,24,2,314100.00),(43,13,1,854000.00),(43,14,1,1799000.00),(44,3,1,4899000.00),(44,12,1,649000.00),(45,8,1,4299000.00),(46,28,1,159000.00),(47,5,1,1614000.00),(48,23,1,289000.00),(48,26,1,759000.00),(49,18,2,89000.00),(50,10,1,1099000.00),(50,17,1,329000.00);
/*!40000 ALTER TABLE `detalle_pedido` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `empleados`
--

DROP TABLE IF EXISTS `empleados`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `empleados` (
  `id_empleado` int NOT NULL AUTO_INCREMENT,
  `nombres` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellidos` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `cargo` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `salario` decimal(12,2) NOT NULL,
  `fecha_ingreso` date NOT NULL,
  `id_jefe` int DEFAULT NULL,
  PRIMARY KEY (`id_empleado`),
  KEY `fk_empleados_jefe` (`id_jefe`),
  CONSTRAINT `fk_empleados_jefe` FOREIGN KEY (`id_jefe`) REFERENCES `empleados` (`id_empleado`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `ck_empleados_salario` CHECK ((`salario` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `empleados`
--

LOCK TABLES `empleados` WRITE;
/*!40000 ALTER TABLE `empleados` DISABLE KEYS */;
INSERT INTO `empleados` VALUES (1,'Martha Lucía','Prieto Gaitán','Gerente comercial',9500000.00,'2019-03-01',NULL),(2,'Hernán','Bustos Arango','Supervisor de ventas',5200000.00,'2020-07-15',1),(3,'Claudia','Robayo Méndez','Supervisor de ventas',5200000.00,'2021-02-01',1),(4,'Kevin','Lozada Perdomo','Asesor comercial',2600000.00,'2022-05-09',2),(5,'Yesica','Tafur Bonilla','Asesor comercial',2600000.00,'2022-11-21',2),(6,'Brayan','Oviedo Calderón','Asesor comercial',2450000.00,'2023-08-14',3),(7,'Lorena','Murcia Vanegas','Asesor comercial',2450000.00,'2024-01-22',3),(8,'Fabián','Cuéllar Yepes','Asesor comercial',2300000.00,'2025-02-03',3);
/*!40000 ALTER TABLE `empleados` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedidos`
--

DROP TABLE IF EXISTS `pedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedidos` (
  `id_pedido` int NOT NULL AUTO_INCREMENT,
  `id_cliente` int NOT NULL,
  `id_empleado` int NOT NULL,
  `fecha_pedido` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `estado` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'PENDIENTE',
  `metodo_pago` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id_pedido`),
  KEY `fk_pedidos_clientes` (`id_cliente`),
  KEY `fk_pedidos_empleados` (`id_empleado`),
  KEY `idx_pedidos_fecha` (`fecha_pedido`),
  CONSTRAINT `fk_pedidos_clientes` FOREIGN KEY (`id_cliente`) REFERENCES `clientes` (`id_cliente`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `fk_pedidos_empleados` FOREIGN KEY (`id_empleado`) REFERENCES `empleados` (`id_empleado`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `ck_pedidos_estado` CHECK ((`estado` in (_utf8mb4'PENDIENTE',_utf8mb4'ENVIADO',_utf8mb4'ENTREGADO',_utf8mb4'CANCELADO'))),
  CONSTRAINT `ck_pedidos_metodo` CHECK ((`metodo_pago` in (_utf8mb4'EFECTIVO',_utf8mb4'TARJETA',_utf8mb4'TRANSFERENCIA',_utf8mb4'PSE')))
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedidos`
--

LOCK TABLES `pedidos` WRITE;
/*!40000 ALTER TABLE `pedidos` DISABLE KEYS */;
INSERT INTO `pedidos` VALUES (1,6,7,'2025-01-16 13:25:00','ENTREGADO','PSE'),(2,24,6,'2025-01-17 15:45:00','ENTREGADO','EFECTIVO'),(3,9,6,'2025-01-23 18:50:00','ENTREGADO','TARJETA'),(4,6,4,'2025-02-17 19:45:00','ENTREGADO','TRANSFERENCIA'),(5,13,7,'2025-02-19 08:30:00','ENTREGADO','PSE'),(6,6,5,'2025-02-21 13:45:00','ENTREGADO','PSE'),(7,22,5,'2025-02-21 11:45:00','ENTREGADO','PSE'),(8,5,5,'2025-03-15 15:30:00','ENTREGADO','TRANSFERENCIA'),(9,2,8,'2025-03-17 18:05:00','ENTREGADO','EFECTIVO'),(10,15,4,'2025-03-17 18:25:00','ENTREGADO','TRANSFERENCIA'),(11,3,4,'2025-03-21 16:50:00','ENTREGADO','TRANSFERENCIA'),(12,10,6,'2025-03-24 12:30:00','ENVIADO','TRANSFERENCIA'),(13,22,4,'2025-03-24 12:25:00','ENTREGADO','TARJETA'),(14,9,5,'2025-04-05 08:55:00','ENTREGADO','EFECTIVO'),(15,16,8,'2025-04-12 19:30:00','ENTREGADO','TRANSFERENCIA'),(16,24,7,'2025-05-03 08:20:00','ENTREGADO','TARJETA'),(17,3,5,'2025-05-11 19:25:00','ENTREGADO','TRANSFERENCIA'),(18,26,7,'2025-05-21 12:55:00','ENVIADO','EFECTIVO'),(19,6,4,'2025-06-26 09:20:00','ENVIADO','TARJETA'),(20,9,6,'2025-07-11 14:25:00','ENTREGADO','TARJETA'),(21,14,6,'2025-07-12 17:00:00','ENTREGADO','TARJETA'),(22,11,5,'2025-07-15 16:25:00','CANCELADO','TARJETA'),(23,16,5,'2025-07-17 11:40:00','ENTREGADO','PSE'),(24,15,8,'2025-07-26 08:55:00','ENTREGADO','EFECTIVO'),(25,3,5,'2025-08-06 09:10:00','CANCELADO','PSE'),(26,1,8,'2025-08-20 17:05:00','ENTREGADO','TRANSFERENCIA'),(27,1,4,'2025-08-22 09:00:00','ENTREGADO','TARJETA'),(28,7,4,'2025-08-23 10:40:00','ENTREGADO','TARJETA'),(29,28,7,'2025-09-22 13:45:00','ENTREGADO','PSE'),(30,4,4,'2025-11-02 18:50:00','ENTREGADO','TARJETA'),(31,2,6,'2025-11-04 12:00:00','ENTREGADO','TARJETA'),(32,18,5,'2025-11-19 14:45:00','ENTREGADO','TARJETA'),(33,8,4,'2026-01-10 10:25:00','ENTREGADO','TARJETA'),(34,29,4,'2026-02-15 14:30:00','ENTREGADO','TRANSFERENCIA'),(35,31,6,'2026-02-18 14:15:00','ENTREGADO','TARJETA'),(36,9,7,'2026-03-02 14:50:00','ENTREGADO','PSE'),(37,21,4,'2026-03-10 11:10:00','ENTREGADO','PSE'),(38,30,7,'2026-04-10 10:40:00','ENTREGADO','TARJETA'),(39,18,4,'2026-04-21 08:50:00','ENTREGADO','TRANSFERENCIA'),(40,19,5,'2026-05-09 19:40:00','ENTREGADO','PSE'),(41,27,6,'2026-05-19 18:40:00','ENTREGADO','TARJETA'),(42,32,5,'2026-05-20 14:20:00','ENTREGADO','PSE'),(43,30,7,'2026-06-16 10:15:00','CANCELADO','TRANSFERENCIA'),(44,17,6,'2026-07-13 08:00:00','ENTREGADO','TARJETA'),(45,22,6,'2026-07-25 12:40:00','ENTREGADO','EFECTIVO'),(46,23,5,'2026-07-29 15:30:00','ENTREGADO','TARJETA'),(47,12,8,'2026-08-13 12:25:00','ENTREGADO','TARJETA'),(48,20,5,'2026-09-08 10:50:00','ENVIADO','TARJETA'),(49,25,7,'2026-09-22 17:05:00','PENDIENTE','TARJETA'),(50,6,6,'2026-09-29 10:40:00','PENDIENTE','TRANSFERENCIA');
/*!40000 ALTER TABLE `pedidos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `productos`
--

DROP TABLE IF EXISTS `productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productos` (
  `id_producto` int NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `id_categoria` int NOT NULL,
  `precio` decimal(12,2) NOT NULL,
  `stock` int NOT NULL DEFAULT '0',
  `fecha_registro` date NOT NULL DEFAULT (curdate()),
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id_producto`),
  KEY `fk_productos_categorias` (`id_categoria`),
  KEY `idx_productos_nombre` (`nombre`),
  CONSTRAINT `fk_productos_categorias` FOREIGN KEY (`id_categoria`) REFERENCES `categorias` (`id_categoria`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `ck_productos_activo` CHECK ((`activo` in (0,1))),
  CONSTRAINT `ck_productos_precio` CHECK ((`precio` > 0)),
  CONSTRAINT `ck_productos_stock` CHECK ((`stock` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productos`
--

LOCK TABLES `productos` WRITE;
/*!40000 ALTER TABLE `productos` DISABLE KEYS */;
INSERT INTO `productos` VALUES (1,'Portátil Lenovo IdeaPad 3 14\"',1,2499000.00,12,'2024-05-15',1),(2,'Portátil HP Pavilion 15\"',1,3199000.00,8,'2024-12-07',1),(3,'Portátil ASUS TUF Gaming F15',1,4899000.00,5,'2025-06-12',1),(4,'Portátil Acer Aspire 5',1,2799000.00,0,'2025-06-22',0),(5,'Celular Samsung Galaxy A55',2,1699000.00,25,'2024-04-29',1),(6,'Celular Xiaomi Redmi Note 13',2,999000.00,40,'2024-08-30',1),(7,'Celular Motorola Edge 50',2,1899000.00,15,'2025-03-20',1),(8,'Celular iPhone 15 128GB',2,4299000.00,6,'2025-05-31',1),(9,'Tablet Samsung Galaxy Tab A9',3,899000.00,18,'2025-04-10',1),(10,'Tablet Lenovo Tab M11',3,1099000.00,10,'2024-09-16',1),(11,'Lector Kindle Paperwhite',3,749000.00,0,'2024-01-17',1),(12,'Monitor LG 24\" IPS',4,649000.00,20,'2024-04-06',1),(13,'Monitor Samsung 27\" Curvo',4,899000.00,14,'2024-05-07',1),(14,'Monitor AOC 34\" Ultrawide',4,1799000.00,4,'2024-11-04',1),(15,'Teclado mecánico Redragon Kumara',5,189000.00,35,'2024-04-24',1),(16,'Mouse Logitech M280 inalámbrico',5,69000.00,60,'2025-04-19',1),(17,'Cámara web Logitech C920',5,329000.00,22,'2024-01-26',1),(18,'Combo teclado y mouse Genius',5,89000.00,30,'2025-05-31',1),(19,'Audífonos Sony WH-CH520',6,249000.00,28,'2024-12-01',1),(20,'Audífonos JBL Tune 520BT',6,229000.00,0,'2024-08-17',0),(21,'Parlante JBL Flip 6',6,589000.00,16,'2025-02-24',1),(22,'Micrófono HyperX SoloCast',6,279000.00,9,'2024-09-28',1),(23,'SSD Kingston NV2 1TB',7,289000.00,45,'2025-01-05',1),(24,'Disco externo Seagate 2TB',7,349000.00,24,'2025-01-14',1),(25,'Memoria USB SanDisk 128GB',7,59000.00,80,'2025-02-03',1),(26,'SSD Samsung 990 EVO 2TB',7,799000.00,7,'2025-06-23',1),(27,'Router TP-Link Archer C6',8,219000.00,19,'2024-04-02',1),(28,'Repetidor TP-Link RE315',8,159000.00,13,'2024-12-28',1),(29,'Adaptador USB WiFi TP-Link',8,79000.00,26,'2024-04-15',1),(30,'Router Mesh Deco X20 (2 und)',8,899000.00,3,'2024-11-09',1);
/*!40000 ALTER TABLE `productos` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-06 19:01:43
