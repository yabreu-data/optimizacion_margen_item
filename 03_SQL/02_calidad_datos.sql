USE ventas_costos;

-- ============================================================
-- 02. CALIDAD DE DATOS
-- ============================================================

-- ============================================================
-- 1. VALORES NULOS EN CAMPOS CLAVE
-- ============================================================

SELECT
    SUM(CASE WHEN id_sucursal IS NULL THEN 1 ELSE 0 END) AS nulos_sucursal,
    SUM(CASE WHEN id_producto IS NULL THEN 1 ELSE 0 END) AS nulos_producto,
    SUM(CASE WHEN fecha_venta IS NULL THEN 1 ELSE 0 END) AS nulos_fecha,
    SUM(CASE WHEN cantidad_vendida IS NULL THEN 1 ELSE 0 END) AS nulos_cantidad,
    SUM(CASE WHEN total_venta IS NULL THEN 1 ELSE 0 END) AS nulos_total
FROM ventas;
-- Resultado real: 0 nulos (constraints NOT NULL del esquema se respetan)

SELECT
    SUM(CASE WHEN id_sucursal IS NULL THEN 1 ELSE 0 END) AS nulos_sucursal,
    SUM(CASE WHEN id_producto IS NULL THEN 1 ELSE 0 END) AS nulos_producto,
    SUM(CASE WHEN total_costo IS NULL THEN 1 ELSE 0 END) AS nulos_total
FROM costos;
-- Resultado real: 0 nulos


-- ============================================================
-- 2. DUPLICADOS EXACTOS (mismo evento de negocio repetido)
-- ============================================================

SELECT id_sucursal, id_producto, fecha_venta, cantidad_vendida, total_venta,
       COUNT(*) AS repeticiones
FROM ventas
GROUP BY id_sucursal, id_producto, fecha_venta, cantidad_vendida, total_venta
HAVING COUNT(*) > 1;
-- Resultado real: 5 combinaciones repetidas (10 de 5,382 filas, ~0.2%).
-- Cada fila conserva su propio id_venta -> son transacciones distintas que coinciden
-- por azar (baja cardinalidad: 4 sucursales x 8 productos x 7 años). No se considera error.

SELECT id_sucursal, id_producto, fecha_costo, cantidad_comprada, total_costo,
       COUNT(*) AS repeticiones
FROM costos
GROUP BY id_sucursal, id_producto, fecha_costo, cantidad_comprada, total_costo
HAVING COUNT(*) > 1;
-- Resultado real: 24 combinaciones repetidas (~0.4%), misma interpretación que arriba.


-- ============================================================
-- 3. INTEGRIDAD REFERENCIAL (registros huérfanos)
-- ============================================================

SELECT v.id_venta, v.id_producto
FROM ventas v
LEFT JOIN productos p ON v.id_producto = p.id_producto
WHERE p.id_producto IS NULL;
-- Resultado real: 0 filas -> integridad correcta

SELECT v.id_venta, v.id_sucursal
FROM ventas v
LEFT JOIN sucursales s ON v.id_sucursal = s.id_sucursal
WHERE s.id_sucursal IS NULL;
-- Resultado real: 0 filas -> integridad correcta

-- (misma lógica aplicada a costos: 0 huérfanos en ambas FK)


-- ============================================================
-- 4. CONSISTENCIA MATEMÁTICA (total = cantidad × precio/costo)
-- ============================================================

SELECT v.id_venta, v.cantidad_vendida, p.precio_venta, v.total_venta
FROM ventas v
JOIN productos p ON v.id_producto = p.id_producto
WHERE v.total_venta <> ROUND(v.cantidad_vendida * p.precio_venta, 2);
-- Resultado real: 0 filas -> el 100% de las ventas cuadra matemáticamente

SELECT c.id_costo, c.cantidad_comprada, p.costo_unitario, c.total_costo
FROM costos c
JOIN productos p ON c.id_producto = p.id_producto
WHERE c.total_costo <> ROUND(c.cantidad_comprada * p.costo_unitario, 2);
-- Resultado real: 0 filas -> el 100% de los costos cuadra matemáticamente


-- ============================================================
-- 5. VALORES FUERA DE RANGO
-- ============================================================

SELECT COUNT(*) AS invalidos
FROM ventas
WHERE cantidad_vendida <= 0 OR total_venta < 0;
-- Resultado real: 0 -> sin cantidades o montos inválidos


-- ============================================================
-- 6. CONSISTENCIA DE VALORES CATEGÓRICOS
-- ============================================================
SELECT DISTINCT categoria FROM productos;
-- Resultado real: 'Electrónica', 'Accesorios' -> sin duplicados por formato

SELECT DISTINCT ciudad, region FROM sucursales;
-- Resultado real: 4 combinaciones únicas, sin inconsistencias de mayúsculas/espacios


-- ============================================================
-- 7. COBERTURA TEMPORAL VS. ALCANCE DECLARADO
-- ============================================================

SELECT
    SUM(CASE WHEN fecha_venta BETWEEN '2024-03-01' AND '2025-02-28' THEN 1 ELSE 0 END) AS dentro_ventana,
    SUM(CASE WHEN fecha_venta NOT BETWEEN '2024-03-01' AND '2025-02-28' THEN 1 ELSE 0 END) AS fuera_ventana
FROM ventas;
-- Resultado real: ~1,108 dentro / ~4,274 fuera. Solo 20% de las filas cae en la ventana
-- de 12 meses declarada en 01_Documentacion/definicion_proyecto.md.
-- PENDIENTE: decidir si se filtra con vista (ventas_periodo_analisis) o se amplía
-- el alcance documentado a 2024-2030. Se resuelve en 03_vistas_periodo.sql.



-- ============================================================
-- CONCLUSIÓN
-- ============================================================
-- El dataset está estructuralmente limpio: sin nulos, sin huérfanos, sin inconsistencias matemáticas ni categóricas. No se requiere un script de limpieza/transformación de datos.
-- El único punto pendiente es de ALCANCE (ventana temporal), no de calidad, y se resuelve con una vista filtrada antes de calcular el margen.