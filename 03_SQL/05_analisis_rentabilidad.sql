USE ventas_costos;

-- ============================================================
-- 05. ANÁLISIS DE RENTABILIDAD
-- ============================================================
-- Responde a las preguntas de negocio 1 (Rentabilidad por Producto)
-- y 3 (Tendencias Estacionales) del doc de definición del proyecto.
-- ============================================================


-- ============================================================
-- 1. CUADRANTE VOLUMEN VS. MARGEN % (candidatos a impulsar o renegociar)
-- ============================================================
WITH volumen_producto AS (
    SELECT
        p.nombre_producto,
        SUM(v.cantidad_vendida) AS volumen,
        ROUND((p.precio_venta - p.costo_unitario) / p.precio_venta * 100, 1) AS margen_pct
    FROM ventas_periodo_analisis v
    JOIN productos p ON v.id_producto = p.id_producto
    GROUP BY p.nombre_producto, p.precio_venta, p.costo_unitario
),
promedios AS (
    SELECT
        AVG(volumen) AS volumen_promedio,
        AVG(margen_pct) AS margen_pct_promedio
    FROM volumen_producto
)
SELECT
    vp.nombre_producto,
    vp.volumen,
    vp.margen_pct,
    CASE
        WHEN vp.volumen >= pr.volumen_promedio AND vp.margen_pct < pr.margen_pct_promedio
        THEN 'Alto volumen / bajo margen % -> revisar costo o precio'
        ELSE 'Otro cuadrante'
    END AS diagnostico
FROM volumen_producto vp
CROSS JOIN promedios pr
ORDER BY vp.volumen DESC;
-- Resultado real: Laptop es el producto de MAYOR volumen (957 unidades) y el de
-- MENOR margen % (33.3%) de todo el catálogo -> candidato directo a revisar costo
-- de adquisición o evaluar un ligero ajuste de precio, ya que su alto volumen
-- amplifica el impacto de cualquier punto porcentual de margen que se gane o pierda.


-- ============================================================
-- 2. TOP Y BOTTOM PRODUCTOS POR MARGEN TOTAL GENERADO
-- ============================================================

SELECT
    p.nombre_producto,
    SUM(v.cantidad_vendida * (p.precio_venta - p.costo_unitario)) AS margen_total
FROM ventas_periodo_analisis v
JOIN productos p ON v.id_producto = p.id_producto
GROUP BY p.nombre_producto
ORDER BY margen_total DESC
LIMIT 5;
-- Top real: Laptop, Smartphone, Tablet (ver 04_calculo_margen.sql sección 2)

SELECT
    p.nombre_producto,
    SUM(v.cantidad_vendida * (p.precio_venta - p.costo_unitario)) AS margen_total
FROM ventas_periodo_analisis v
JOIN productos p ON v.id_producto = p.id_producto
GROUP BY p.nombre_producto
ORDER BY margen_total ASC
LIMIT 3;


-- ============================================================
-- 3. TENDENCIA MENSUAL DE MARGEN (estacionalidad)
-- ============================================================

SELECT
    YEAR(v.fecha_venta) AS anio,
    MONTH(v.fecha_venta) AS mes,
    SUM(v.cantidad_vendida * (p.precio_venta - p.costo_unitario)) AS margen_mensual
FROM ventas_periodo_analisis v
JOIN productos p ON v.id_producto = p.id_producto
GROUP BY YEAR(v.fecha_venta), MONTH(v.fecha_venta)
ORDER BY anio, mes;
-- Resultado real: pico claro en enero 2025 ($137,475, casi el doble del promedio
-- mensual de ~$79,700), y el valle más bajo en mayo 2024 ($45,125).
-- Vale la pena explorar en Python si el pico de enero coincide con algún producto
-- o sucursal específica, o es un alza generalizada.


-- ============================================================
-- 4. MARGEN PROMEDIO POR TRANSACCIÓN POR SUCURSAL (eficiencia por venta)
-- ============================================================

SELECT
    s.nombre_sucursal,
    COUNT(*) AS num_transacciones,
    ROUND(SUM(v.cantidad_vendida * (p.precio_venta - p.costo_unitario)) / COUNT(*), 2) AS margen_promedio_transaccion
FROM ventas_periodo_analisis v
JOIN productos p ON v.id_producto = p.id_producto
JOIN sucursales s ON v.id_sucursal = s.id_sucursal
GROUP BY s.nombre_sucursal
ORDER BY margen_promedio_transaccion DESC;
-- Resultado real: Este lidera ($890.58/transacción), Oeste queda último ($809.45).
-- Cruzado con 04 (sección 5, ratio costo/venta), Oeste queda mal posicionada en
-- AMBAS métricas: menor margen por transacción y mayor costo relativo de compra.
-- Es la sucursal más clara para priorizar en las recomendaciones finales.