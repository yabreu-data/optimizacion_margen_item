USE ventas_costos;

-- ============================================================
-- 04. CÁLCULO DE MARGEN
-- ============================================================
-- Nota conceptual: el margen se calcula con ventas_periodo_analisis + productos,
-- porque costo_unitario ya está fijo por producto. La tabla costos_periodo_analisis
-- se usa aparte, para medir eficiencia operativa de compra (sección 5), no margen.
-- ============================================================


-- ============================================================
-- 1. MARGEN DE CATÁLOGO POR PRODUCTO (teórico, fijo)
-- ============================================================


SELECT
    nombre_producto,
    categoria,
    precio_venta,
    costo_unitario,
    (precio_venta - costo_unitario) AS margen_unitario,
    ROUND((precio_venta - costo_unitario) / precio_venta * 100, 1) AS margen_pct
FROM productos
ORDER BY margen_pct DESC;
-- Resultado real: Mouse y Teclado lideran en % (60%), Laptop es el más bajo en % (33.3%)
-- aunque genera el mayor margen absoluto por unidad ($400).


-- ============================================================
-- 2. MARGEN REALIZADO POR PRODUCTO (agregando ventas del periodo)
-- ============================================================

SELECT
    p.nombre_producto,
    p.categoria,
    SUM(v.cantidad_vendida) AS unidades_vendidas,
    SUM(v.total_venta) AS ingreso_total,
    SUM(v.cantidad_vendida * (p.precio_venta - p.costo_unitario)) AS margen_total,
    ROUND(SUM(v.cantidad_vendida * (p.precio_venta - p.costo_unitario)) / SUM(v.total_venta) * 100, 1) AS margen_pct
FROM ventas_periodo_analisis v
JOIN productos p ON v.id_producto = p.id_producto
GROUP BY p.nombre_producto, p.categoria
ORDER BY margen_total DESC;
-- Resultado real (top): Laptop ($382,800), Smartphone ($220,500), Tablet ($156,600)
-- Laptop lidera en margen absoluto pese a tener el % más bajo -> alto volumen compensa.


-- ============================================================
-- 3. MARGEN REALIZADO POR SUCURSAL
-- ============================================================

SELECT
    s.nombre_sucursal,
    s.ciudad,
    SUM(v.total_venta) AS ingreso_total,
    SUM(v.cantidad_vendida * (p.precio_venta - p.costo_unitario)) AS margen_total,
    ROUND(SUM(v.cantidad_vendida * (p.precio_venta - p.costo_unitario)) / SUM(v.total_venta) * 100, 1) AS margen_pct
FROM ventas_periodo_analisis v
JOIN productos p ON v.id_producto = p.id_producto
JOIN sucursales s ON v.id_sucursal = s.id_sucursal
GROUP BY s.nombre_sucursal, s.ciudad
ORDER BY margen_pct DESC;
-- Resultado real: las 4 sucursales están muy parejas en margen % (36.5%-37.3%).
-- No hay una sucursal claramente "mejor" en rentabilidad de venta -> la diferencia
-- entre sucursales está en la sección 5 (eficiencia de compra), no aquí.


-- ============================================================
-- 4. MARGEN REALIZADO POR CATEGORÍA
-- ============================================================

SELECT
    p.categoria,
    SUM(v.total_venta) AS ingreso_total,
    SUM(v.cantidad_vendida * (p.precio_venta - p.costo_unitario)) AS margen_total,
    ROUND(SUM(v.cantidad_vendida * (p.precio_venta - p.costo_unitario)) / SUM(v.total_venta) * 100, 1) AS margen_pct
FROM ventas_periodo_analisis v
JOIN productos p ON v.id_producto = p.id_producto
GROUP BY p.categoria
ORDER BY margen_total DESC;


-- ============================================================
-- 5. RATIO COSTO/VENTA POR SUCURSAL (eficiencia operativa — distinto de margen)
-- ============================================================

WITH ventas_suc AS (
    SELECT id_sucursal, SUM(total_venta) AS total_ventas
    FROM ventas_periodo_analisis
    GROUP BY id_sucursal
),
costos_suc AS (
    SELECT id_sucursal, SUM(total_costo) AS total_costos
    FROM costos_periodo_analisis
    GROUP BY id_sucursal
)
SELECT
    s.nombre_sucursal,
    vs.total_ventas,
    cs.total_costos,
    ROUND(cs.total_costos / vs.total_ventas, 3) AS ratio_costo_venta
FROM sucursales s
JOIN ventas_suc vs ON vs.id_sucursal = s.id_sucursal
JOIN costos_suc cs ON cs.id_sucursal = s.id_sucursal
ORDER BY ratio_costo_venta DESC;
-- Resultado real (dentro de la ventana correcta de 12 meses):
-- Oeste 0.907 (peor) | Sur 0.897 | Este 0.868 | Norte 0.845 (mejor)
-- A diferencia del cálculo sobre los 7 años completos, aquí H5 SÍ se valida:
-- Oeste tiene el ratio costo/venta más alto dentro del periodo declarado.
-- Esto confirma por qué era crítico fijar la ventana temporal antes de analizar.


-- ============================================================
-- 6. VISTA CONSOLIDADA (para Python / Power BI)
-- ============================================================

DROP VIEW IF EXISTS margen_por_venta;
CREATE VIEW margen_por_venta AS
SELECT
    v.id_venta,
    v.fecha_venta,
    s.nombre_sucursal,
    s.ciudad,
    s.region,
    p.nombre_producto,
    p.categoria,
    v.cantidad_vendida,
    p.precio_venta,
    p.costo_unitario,
    v.total_venta,
    v.cantidad_vendida * (p.precio_venta - p.costo_unitario) AS margen_total,
    ROUND((p.precio_venta - p.costo_unitario) / p.precio_venta * 100, 1) AS margen_pct
FROM ventas_periodo_analisis v
JOIN productos p ON v.id_producto = p.id_producto
JOIN sucursales s ON v.id_sucursal = s.id_sucursal;

SELECT * FROM margen_por_venta LIMIT 5;