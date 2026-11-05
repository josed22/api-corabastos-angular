-- Base de datos auxiliar de Corabastos (MySQL) - 5 tablas normalizadas
-- Informacion de referencia externa a la central: otros mercados, sus precios, proveedores y ofertas.
-- Todas las tablas tienen: llave primaria (id), campos unicos, estado, creado y actualizado.
--   * estado: 1 = activo, 0 = eliminado (DELETE es logico, el registro no se borra)
--   * creado: se llena solo al insertar
--   * actualizado: MySQL lo actualiza solo en cada UPDATE (ON UPDATE CURRENT_TIMESTAMP)

CREATE DATABASE IF NOT EXISTS corabastos_aux CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE corabastos_aux;

DROP TABLE IF EXISTS oferta_proveedor;
DROP TABLE IF EXISTS precio_externo;
DROP TABLE IF EXISTS producto_externo;
DROP TABLE IF EXISTS proveedor_externo;
DROP TABLE IF EXISTS mercado_externo;

CREATE TABLE mercado_externo (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL UNIQUE,
  ciudad VARCHAR(80) NOT NULL,
  tipo VARCHAR(30) NOT NULL DEFAULT 'mayorista',
  estado BOOLEAN NOT NULL DEFAULT TRUE,
  creado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE proveedor_externo (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(120) NOT NULL,
  nit VARCHAR(20) NOT NULL UNIQUE,
  correo VARCHAR(150) NOT NULL UNIQUE,
  telefono VARCHAR(20),
  municipio_origen VARCHAR(80) NOT NULL,
  estado BOOLEAN NOT NULL DEFAULT TRUE,
  creado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE producto_externo (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(80) NOT NULL UNIQUE,
  categoria VARCHAR(40) NOT NULL,
  unidad VARCHAR(20) NOT NULL DEFAULT 'kg',
  estado BOOLEAN NOT NULL DEFAULT TRUE,
  creado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE precio_externo (
  id INT AUTO_INCREMENT PRIMARY KEY,
  mercado_id INT NOT NULL,
  producto_id INT NOT NULL,
  precio DECIMAL(12,2) NOT NULL,
  fecha DATE NOT NULL,
  estado BOOLEAN NOT NULL DEFAULT TRUE,
  creado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_precio_mercado FOREIGN KEY (mercado_id) REFERENCES mercado_externo(id),
  CONSTRAINT fk_precio_producto FOREIGN KEY (producto_id) REFERENCES producto_externo(id),
  CONSTRAINT uq_precio UNIQUE (mercado_id, producto_id, fecha)
) ENGINE=InnoDB;

CREATE TABLE oferta_proveedor (
  id INT AUTO_INCREMENT PRIMARY KEY,
  proveedor_id INT NOT NULL,
  producto_id INT NOT NULL,
  cantidad_kg DECIMAL(12,2) NOT NULL,
  precio_kg DECIMAL(12,2) NOT NULL,
  disponible_hasta DATE NOT NULL,
  estado BOOLEAN NOT NULL DEFAULT TRUE,
  creado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_oferta_proveedor FOREIGN KEY (proveedor_id) REFERENCES proveedor_externo(id),
  CONSTRAINT fk_oferta_producto FOREIGN KEY (producto_id) REFERENCES producto_externo(id),
  CONSTRAINT uq_oferta UNIQUE (proveedor_id, producto_id, disponible_hasta)
) ENGINE=InnoDB;

-- ===================== DATOS DE EJEMPLO =====================
INSERT INTO mercado_externo (nombre, ciudad, tipo) VALUES
('Central Mayorista de Antioquia', 'Medellin', 'mayorista'),
('Cavasa', 'Cali', 'mayorista'),
('Centroabastos', 'Bucaramanga', 'mayorista'),
('Surabastos', 'Bogota', 'mayorista'),
('Plaza de Paloquemao', 'Bogota', 'minorista'),
('Central de Abastos de Villavicencio', 'Villavicencio', 'mayorista');

INSERT INTO producto_externo (nombre, categoria, unidad) VALUES
('Papa pastusa', 'Tuberculos', 'kg'),
('Papa criolla', 'Tuberculos', 'kg'),
('Yuca', 'Tuberculos', 'kg'),
('Tomate chonto', 'Hortalizas', 'kg'),
('Cebolla cabezona blanca', 'Hortalizas', 'kg'),
('Cebolla larga', 'Hortalizas', 'kg'),
('Zanahoria', 'Hortalizas', 'kg'),
('Platano harton', 'Frutas', 'kg'),
('Aguacate Hass', 'Frutas', 'kg'),
('Mango Tommy', 'Frutas', 'kg'),
('Naranja Valencia', 'Frutas', 'kg'),
('Limon Tahiti', 'Frutas', 'kg');

INSERT INTO precio_externo (mercado_id, producto_id, precio, fecha) VALUES
(1, 8, 2600, '2026-11-03'),
(1, 9, 6950, '2026-11-03'),
(1, 12, 2800, '2026-11-03'),
(1, 10, 3750, '2026-11-03'),
(2, 11, 1800, '2026-11-03'),
(2, 10, 3200, '2026-11-03'),
(2, 3, 1700, '2026-11-03'),
(2, 2, 3900, '2026-11-03'),
(3, 11, 2200, '2026-11-03'),
(3, 1, 2200, '2026-11-03'),
(3, 10, 3900, '2026-11-03'),
(3, 7, 1600, '2026-11-03'),
(4, 1, 1800, '2026-11-03'),
(4, 9, 7700, '2026-11-03'),
(4, 2, 3600, '2026-11-03'),
(4, 12, 3800, '2026-11-03'),
(5, 6, 2900, '2026-11-03'),
(5, 8, 2700, '2026-11-03'),
(5, 10, 3750, '2026-11-03'),
(5, 4, 3250, '2026-11-03'),
(6, 8, 3000, '2026-11-03'),
(6, 11, 2200, '2026-11-03'),
(6, 5, 2450, '2026-11-03'),
(6, 7, 2000, '2026-11-03');

INSERT INTO proveedor_externo (nombre, nit, correo, telefono, municipio_origen) VALUES
('Agricola La Esperanza S.A.S.', '900412356-1', 'ventas@laesperanza.com.co', '3105551021', 'Ventaquemada'),
('Cooperativa Agropecuaria del Sumapaz', '860034782-5', 'comercial@coosumapaz.coop', '3115550478', 'Fusagasuga'),
('Hortalizas de la Sabana Ltda.', '800256913-2', 'pedidos@hortasabana.com.co', '3125550933', 'Zipaquira'),
('Frutas del Tolima S.A.S.', '901128745-6', 'contacto@frutastolima.co', '3135550214', 'Ibague'),
('Papas del Altiplano S.A.S.', '900874521-3', 'info@papasaltiplano.com.co', '3145550682', 'Tunja'),
('Finca El Mirador', '1098765432-0', 'elmirador@gmail.com', '3155550356', 'La Union'),
('Agroexportadora Andina S.A.', '830125987-4', 'ventas@agroandina.com.co', '3165550741', 'Cajamarca'),
('Asociacion de Productores de Cubarral', '900365214-8', 'asoprocubarral@gmail.com', '3175550169', 'Cubarral');

INSERT INTO oferta_proveedor (proveedor_id, producto_id, cantidad_kg, precio_kg, disponible_hasta) VALUES
(1, 6, 2000, 2450, '2026-11-10'),
(1, 4, 2000, 3100, '2026-11-30'),
(2, 2, 1500, 2650, '2026-11-10'),
(2, 5, 5000, 2150, '2026-11-15'),
(3, 4, 1500, 2600, '2026-11-30'),
(3, 1, 1500, 1600, '2026-11-15'),
(4, 11, 1000, 1350, '2026-11-20'),
(4, 5, 500, 2450, '2026-11-10'),
(5, 3, 3000, 1250, '2026-11-10'),
(5, 4, 1500, 3150, '2026-11-15'),
(6, 11, 800, 1650, '2026-11-15'),
(6, 9, 3000, 6950, '2026-11-30'),
(7, 11, 500, 1600, '2026-11-15'),
(7, 7, 500, 1500, '2026-11-20'),
(8, 1, 800, 1850, '2026-11-10'),
(8, 4, 500, 3400, '2026-11-15');
