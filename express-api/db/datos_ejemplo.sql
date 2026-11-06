-- Registros de ejemplo para corabastos_aux (MySQL)
-- Ejecutar DESPUES de corabastos_aux.sql:  mysql -u root -p corabastos_aux < db/datos_ejemplo.sql
-- Se puede ejecutar varias veces: vacia las tablas y las vuelve a llenar.
--
-- Cantidades (taller: 20 en tablas principales, 10 en secundarias):
--   favorito 20 | alerta_precio 20 | canal_notificacion 10 | preferencia_notificacion 10 | notificacion 10
--
-- id_usuario e id_producto salen de la base PostgreSQL (db/corabastos_completo.sql):
--   usuarios 10 a 14 = los 5 compradores; productos 1 a 30 = los primeros del catalogo.
--   Si tu base PostgreSQL tiene otros ids, cambia estos numeros.

USE corabastos_aux;

SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE notificacion;
TRUNCATE TABLE preferencia_notificacion;
TRUNCATE TABLE alerta_precio;
TRUNCATE TABLE favorito;
TRUNCATE TABLE canal_notificacion;
SET FOREIGN_KEY_CHECKS = 1;

-- 10 canales (ids 1 a 10)
INSERT INTO canal_notificacion (nombre) VALUES
('Aplicacion'), ('Correo electronico'), ('WhatsApp'), ('Telegram'), ('SMS'),
('Notificacion push'), ('Messenger'), ('Instagram'), ('Llamada telefonica'), ('Correo corporativo');

-- 20 favoritos: 4 por comprador
INSERT INTO favorito (id_usuario, id_producto) VALUES
(10, 1), (10, 5), (10, 12), (10, 20),
(11, 3), (11, 8), (11, 15), (11, 22),
(12, 2), (12, 9), (12, 17), (12, 25),
(13, 4), (13, 11), (13, 18), (13, 27),
(14, 6), (14, 13), (14, 21), (14, 30);

-- 20 alertas: 4 por comprador (ids 1 a 20, en este orden)
INSERT INTO alerta_precio (id_usuario, id_producto, tipo, umbral) VALUES
(10, 1,  'baja', 5.00),  (10, 5,  'sube', 10.00), (10, 12, 'baja', 8.00),  (10, 20, 'sube', 12.50),
(11, 3,  'sube', 7.50),  (11, 8,  'baja', 6.00),  (11, 15, 'sube', 15.00), (11, 22, 'baja', 10.00),
(12, 2,  'baja', 4.00),  (12, 9,  'sube', 9.00),  (12, 17, 'baja', 5.50),  (12, 25, 'sube', 20.00),
(13, 4,  'sube', 6.50),  (13, 11, 'baja', 7.00),  (13, 18, 'sube', 11.00), (13, 27, 'baja', 9.50),
(14, 6,  'baja', 3.50),  (14, 13, 'sube', 8.50),  (14, 21, 'baja', 12.00), (14, 30, 'sube', 14.00);

-- 10 preferencias: 2 canales por comprador
INSERT INTO preferencia_notificacion (id_usuario, id_canal) VALUES
(10, 1), (10, 2),
(11, 1), (11, 3),
(12, 2), (12, 4),
(13, 1), (13, 5),
(14, 3), (14, 6);

-- 10 notificaciones: 2 por comprador, ligadas a sus alertas (id_alerta) y a un canal que ellos prefieren
INSERT INTO notificacion (id_usuario, id_alerta, id_canal, mensaje, leida) VALUES
(10, 1,  1, 'El precio del producto 1 bajo mas del 5%',         TRUE),
(10, 2,  2, 'El precio del producto 5 subio mas del 10%',       FALSE),
(11, 5,  1, 'El precio del producto 3 subio mas del 7.5%',      TRUE),
(11, 6,  3, 'El precio del producto 8 bajo mas del 6%',         FALSE),
(12, 9,  2, 'El precio del producto 2 bajo mas del 4%',         TRUE),
(12, 10, 4, 'El precio del producto 9 subio mas del 9%',        FALSE),
(13, 13, 1, 'El precio del producto 4 subio mas del 6.5%',      FALSE),
(13, 14, 5, 'El precio del producto 11 bajo mas del 7%',        TRUE),
(14, 17, 3, 'El precio del producto 6 bajo mas del 3.5%',       FALSE),
(14, 18, 6, 'El precio del producto 13 subio mas del 8.5%',     TRUE);
