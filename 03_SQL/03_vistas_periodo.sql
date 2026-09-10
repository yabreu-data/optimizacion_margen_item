USE ventas_costos;

-- ============================================================
-- 03. VISTAS DE PERIODO DE ANÁLISIS
-- ============================================================
-- Objetivo: fijar en un solo lugar la ventana temporal declarada en 01_Documentacion/definicion_proyecto.md (2024-03-01 a 2025-02-28), sin modificar las tablas raw.
-- Todos los scripts posteriores (04_calculo_margen.sql en adelante) consultan estas vistas, no las tablas ventas/costos directamente.
-- ============================================================

DROP VIEW IF EXISTS ventas_periodo_analisis;
CREATE VIEW ventas_periodo_analisis AS
SELECT *
FROM ventas
WHERE fecha_venta BETWEEN '2024-03-01' AND '2025-02-28';

DROP VIEW IF EXISTS costos_periodo_analisis;
CREATE VIEW costos_periodo_analisis AS
SELECT *
FROM costos
WHERE fecha_costo BETWEEN '2024-03-01' AND '2025-02-28';


-- ============================================================
-- VERIFICACIÓN
-- ============================================================

SELECT COUNT(*) AS filas_ventas_periodo FROM ventas_periodo_analisis;
-- Resultado esperado: ~1,108 filas (verificado en 02_calidad_datos.sql)

SELECT COUNT(*) AS filas_costos_periodo FROM costos_periodo_analisis;
-- Resultado esperado: filas equivalentes dentro de la misma ventana

SELECT MIN(fecha_venta) AS primera_fecha, MAX(fecha_venta) AS ultima_fecha
FROM ventas_periodo_analisis;
-- Confirma que el rango efectivo no sale de 2024-03-01 a 2025-02-28