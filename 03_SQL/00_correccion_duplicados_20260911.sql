USE ventas_costos;

-- ============================================================
-- 00. CORRECCIÓN DE INCIDENTE: DUPLICACIÓN DE DATOS EN VENTAS
-- ============================================================
-- Fecha: 2026-09-11
-- Hallazgo: al recalcular estacionalidad en Python, los montos de margen
-- aparecieron exactamente 2x los valores esperados (confirmados previamente
-- en 05_analisis_rentabilidad.sql). Se diagnosticó reinserción accidental
-- del script de carga original sobre la tabla ventas (10,764 filas en vez
-- de las 5,382 esperadas). La tabla costos no se vio afectada (5,358 filas,
-- consistente con el dato original menos coincidencias legítimas ya conocidas).
-- Resolución: eliminación de duplicados exactos vía ROW_NUMBER(), conservando
-- el id_venta más bajo de cada grupo.
-- Resultado final verificado: ventas=5,377 | ventas_periodo_analisis=1,105
-- (la diferencia frente a 5,382/1,108 corresponde a las 5 coincidencias
-- legítimas detectadas en 02_calidad_datos.sql, que este método también
-- colapsa a una sola fila; se acepta como trade-off, impacto <0.1%).
--
-- NOTA: este script es un registro histórico de la corrección aplicada el
-- 2026-09-11. NO debe volverse a ejecutar completo: las tablas de backup
-- ya existen y los DELETE ya se aplicaron sobre los datos reales. Se
-- conserva en el repositorio solo por trazabilidad.
-- ============================================================

-- ---- Diagnóstico ----
SELECT COUNT(*) AS total_filas, COUNT(DISTINCT id_venta) AS ids_unicos FROM ventas;
-- Resultado real obtenido: 10,764 / 10,764 -> confirma duplicación total (2x lo esperado)

SELECT COUNT(*) AS total_filas, COUNT(DISTINCT id_costo) AS ids_unicos FROM costos;
-- Resultado real obtenido: 5,358 / 5,358 -> costos NO estaba duplicada

-- ---- Respaldo previo a cualquier eliminación ----
CREATE TABLE ventas_backup_20260911 AS SELECT * FROM ventas;
CREATE TABLE costos_backup_20260911 AS SELECT * FROM costos;

-- ---- Eliminación de duplicados en ventas ----
WITH duplicados AS (
    SELECT id_venta,
           ROW_NUMBER() OVER (
               PARTITION BY id_sucursal, id_producto, fecha_venta, cantidad_vendida, total_venta
               ORDER BY id_venta ASC
           ) AS rn
    FROM ventas
)
DELETE v FROM ventas v
JOIN duplicados d ON v.id_venta = d.id_venta
WHERE d.rn > 1;

-- ---- Verificación de duplicados en costos (no requirió DELETE) ----
SELECT id_sucursal, id_producto, fecha_costo, cantidad_comprada, total_costo,
       COUNT(*) AS repeticiones
FROM costos
GROUP BY id_sucursal, id_producto, fecha_costo, cantidad_comprada, total_costo
HAVING COUNT(*) > 1;
-- Resultado real: 0 filas -> costos ya estaba correcta, no se aplicó DELETE

-- ---- Verificación final ----
SELECT COUNT(*) FROM ventas;                    -- resultado real: 5,377
SELECT COUNT(*) FROM costos;                    -- resultado real: 5,358 (sin cambios)
SELECT COUNT(*) FROM ventas_periodo_analisis;   -- resultado real: 1,105
SELECT COUNT(*) FROM costos_periodo_analisis;   -- verificar y anotar aquí