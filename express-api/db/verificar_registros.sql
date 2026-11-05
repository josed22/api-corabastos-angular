-- Cuenta los registros de cada tabla (MySQL). Meta: 20 en las tablas principales y 10 en las secundarias.
USE corabastos_aux;
SELECT 'favorito' AS tabla, COUNT(*) AS registros FROM favorito
UNION ALL SELECT 'alerta_precio', COUNT(*) FROM alerta_precio
UNION ALL SELECT 'canal_notificacion', COUNT(*) FROM canal_notificacion
UNION ALL SELECT 'preferencia_notificacion', COUNT(*) FROM preferencia_notificacion
UNION ALL SELECT 'notificacion', COUNT(*) FROM notificacion;
