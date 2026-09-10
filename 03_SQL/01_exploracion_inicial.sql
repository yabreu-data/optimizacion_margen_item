USE ventas_costos;

-- ============================================================
-- 01. EXPLORACIÓN INICIAL
-- ============================================================


-- ============================================================
-- 1. ESTRUCTURA DE LA BASE DE DATOS
-- ============================================================

-- 1.1. Ver las tablas disponibles
SHOW TABLES;


-- 1.2. Ver la estructura de cada tabla
DESCRIBE sucursales;
DESCRIBE productos;
DESCRIBE ventas;
DESCRIBE costos;


-- ============================================================
-- 2. VISTA PRELIMINAR DE LOS DATOS
-- ============================================================

-- 2.1. Primeros registros de cada tabla
SELECT *
FROM sucursales
LIMIT 5;

SELECT *
FROM productos
LIMIT 5;

SELECT *
FROM ventas
LIMIT 5;

SELECT *
FROM costos
LIMIT 5;


-- ============================================================
-- 3. VOLUMEN DE DATOS
-- ============================================================

-- 3.1. Cantidad de registros por tabla
SELECT 'Sucursales' AS tabla, COUNT(*) AS filas
FROM sucursales

UNION ALL

SELECT 'Productos', COUNT(*)
FROM productos

UNION ALL

SELECT 'Ventas', COUNT(*)
FROM ventas

UNION ALL

SELECT 'Costos', COUNT(*)
FROM costos;


-- ============================================================
-- 4. DIMENSIONES Y ENTIDADES DISPONIBLES
-- ============================================================

-- 4.1. Cantidad de sucursales y su distribución geográfica
SELECT
    COUNT(*) AS total_sucursales,
    COUNT(DISTINCT ciudad) AS ciudades,
    COUNT(DISTINCT region) AS regiones
FROM sucursales;


-- 4.2. Ver sucursales y sus ubicaciones
SELECT
    nombre_sucursal,
    ciudad,
    region,
    gerente
FROM sucursales
ORDER BY region, ciudad;


-- 4.3. Cantidad de productos y categorías
SELECT
    COUNT(*) AS total_productos,
    COUNT(DISTINCT categoria) AS categorias
FROM productos;


-- 4.4. Distribución de productos por categoría
SELECT
    categoria,
    COUNT(*) AS total_productos
FROM productos
GROUP BY categoria
ORDER BY total_productos DESC;


-- ============================================================
-- 5. COBERTURA Y DISTRIBUCIÓN TEMPORAL
-- ============================================================

-- 5.1. Cobertura temporal de las ventas
SELECT
    COUNT(*) AS filas,
    COUNT(DISTINCT id_producto) AS productos,
    COUNT(DISTINCT id_sucursal) AS sucursales,
    MIN(fecha_venta) AS primera_fecha,
    MAX(fecha_venta) AS ultima_fecha
FROM ventas;


-- 5.2. Cobertura temporal de los costos
SELECT
    COUNT(*) AS filas,
    COUNT(DISTINCT id_producto) AS productos,
    COUNT(DISTINCT id_sucursal) AS sucursales,
    MIN(fecha_costo) AS primera_fecha,
    MAX(fecha_costo) AS ultima_fecha
FROM costos;


-- ============================================================
-- 6. DISTRIBUCIÓN DE REGISTROS EN EL TIEMPO
-- ============================================================

-- 6.1. Cantidad de ventas por mes
SELECT
    YEAR(fecha_venta) AS anio,
    MONTH(fecha_venta) AS mes,
    COUNT(*) AS registros
FROM ventas
GROUP BY
    YEAR(fecha_venta),
    MONTH(fecha_venta)
ORDER BY
    anio,
    mes;


-- 6.2. Cantidad de registros de costos por mes
SELECT
    YEAR(fecha_costo) AS anio,
    MONTH(fecha_costo) AS mes,
    COUNT(*) AS registros
FROM costos
GROUP BY
    YEAR(fecha_costo),
    MONTH(fecha_costo)
ORDER BY
    anio,
    mes;


-- ============================================================
-- 7. COBERTURA DE PRODUCTOS Y SUCURSALES EN LAS TRANSACCIONES
-- ============================================================

-- 7.1. Productos presentes en las ventas
SELECT
    COUNT(DISTINCT id_producto) AS productos_en_ventas
FROM ventas;


-- 7.2. Sucursales presentes en las ventas
SELECT
    COUNT(DISTINCT id_sucursal) AS sucursales_en_ventas
FROM ventas;


-- 7.3. Productos presentes en los costos
SELECT
    COUNT(DISTINCT id_producto) AS productos_en_costos
FROM costos;


-- 7.4. Sucursales presentes en los costos
SELECT
    COUNT(DISTINCT id_sucursal) AS sucursales_en_costos
FROM costos;