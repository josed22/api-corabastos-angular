-- Cuenta los registros de cada tabla (PostgreSQL). Meta: 20 en las tablas principales y 10 en las secundarias.
SELECT 'rol' AS tabla, COUNT(*) AS registros FROM rol
UNION ALL SELECT 'modulo', COUNT(*) FROM modulo
UNION ALL SELECT 'modulo_x_rol', COUNT(*) FROM modulo_x_rol
UNION ALL SELECT 'municipio', COUNT(*) FROM municipio
UNION ALL SELECT 'tipo_identificacion', COUNT(*) FROM tipo_identificacion
UNION ALL SELECT 'usuario', COUNT(*) FROM usuario
UNION ALL SELECT 'categoria', COUNT(*) FROM categoria
UNION ALL SELECT 'tipo', COUNT(*) FROM tipo
UNION ALL SELECT 'producto', COUNT(*) FROM producto
UNION ALL SELECT 'pabellon', COUNT(*) FROM pabellon
UNION ALL SELECT 'tienda', COUNT(*) FROM tienda
UNION ALL SELECT 'inventario', COUNT(*) FROM inventario
UNION ALL SELECT 'precio_dia', COUNT(*) FROM precio_dia
UNION ALL SELECT 'estado_reserva', COUNT(*) FROM estado_reserva
UNION ALL SELECT 'reserva', COUNT(*) FROM reserva
UNION ALL SELECT 'detalle_reserva', COUNT(*) FROM detalle_reserva
ORDER BY 1;
