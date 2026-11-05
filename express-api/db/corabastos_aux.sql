-- Base de datos auxiliar de Corabastos (MySQL) - 5 tablas normalizadas
-- Guarda lo personal de cada usuario de la web: sus favoritos, sus alertas de precio y las notificaciones.
-- id_usuario e id_producto apuntan a la base principal (PostgreSQL): son referencias entre bases, no llaves foraneas.
-- Todas las tablas tienen: llave primaria (id), campos unicos, estado, creado y actualizado.
--   * estado: 1 = activo, 0 = eliminado (DELETE es logico, el registro no se borra)
--   * creado: se llena solo al insertar
--   * actualizado: MySQL lo actualiza solo en cada UPDATE (ON UPDATE CURRENT_TIMESTAMP)
-- Los datos (20 registros en las tablas principales y 10 en las secundarias) los registra el equipo;
-- este script solo crea las tablas y los 4 canales de notificacion que la aplicacion necesita para funcionar.

CREATE DATABASE IF NOT EXISTS corabastos_aux CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE corabastos_aux;

DROP TABLE IF EXISTS notificacion;
DROP TABLE IF EXISTS preferencia_notificacion;
DROP TABLE IF EXISTS alerta_precio;
DROP TABLE IF EXISTS favorito;
DROP TABLE IF EXISTS canal_notificacion;

CREATE TABLE canal_notificacion (
  id INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(40) NOT NULL UNIQUE,
  estado BOOLEAN NOT NULL DEFAULT TRUE,
  creado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE favorito (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  id_producto INT NOT NULL,
  estado BOOLEAN NOT NULL DEFAULT TRUE,
  creado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT uq_favorito UNIQUE (id_usuario, id_producto)
) ENGINE=InnoDB;

CREATE TABLE alerta_precio (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  id_producto INT NOT NULL,
  tipo ENUM('sube','baja') NOT NULL,
  umbral DECIMAL(6,2) NOT NULL,            -- variacion porcentual que activa la alerta
  estado BOOLEAN NOT NULL DEFAULT TRUE,
  creado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT uq_alerta UNIQUE (id_usuario, id_producto, tipo),
  CONSTRAINT ck_alerta_umbral CHECK (umbral > 0)
) ENGINE=InnoDB;

CREATE TABLE preferencia_notificacion (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  id_canal INT NOT NULL,
  estado BOOLEAN NOT NULL DEFAULT TRUE,
  creado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_pref_canal FOREIGN KEY (id_canal) REFERENCES canal_notificacion(id),
  CONSTRAINT uq_pref UNIQUE (id_usuario, id_canal)
) ENGINE=InnoDB;

CREATE TABLE notificacion (
  id INT AUTO_INCREMENT PRIMARY KEY,
  id_usuario INT NOT NULL,
  id_alerta INT NOT NULL,
  id_canal INT NOT NULL,
  mensaje VARCHAR(255) NOT NULL,
  leida BOOLEAN NOT NULL DEFAULT FALSE,
  estado BOOLEAN NOT NULL DEFAULT TRUE,
  creado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  actualizado TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_notif_alerta FOREIGN KEY (id_alerta) REFERENCES alerta_precio(id),
  CONSTRAINT fk_notif_canal FOREIGN KEY (id_canal) REFERENCES canal_notificacion(id)
) ENGINE=InnoDB;

-- Catalogo minimo para que la aplicacion funcione
INSERT INTO canal_notificacion (nombre) VALUES ('Aplicacion'), ('Correo electronico'), ('WhatsApp'), ('Telegram');
