# Reporte Ejecutivo — Optimización de Margen por Ítem (i-tem)

**Periodo analizado:** 2024-03-01 a 2025-02-28
**Fuente:** SQL (MySQL) + Python (validación cruzada) sobre datos ficticios de ventas y costos

---

## Resumen Ejecutivo

i-tem cuenta con un margen promedio saludable (~37%) y consistente entre sus 4 sucursales, pero presenta tres áreas de oportunidad concretas: **Laptop** concentra el mayor volumen de ventas con el menor margen porcentual del catálogo; **Sucursal Oeste** queda rezagada tanto en eficiencia de compra como en margen por transacción; y existe un **alza estacional generalizada en enero** que no está siendo aprovechada de forma planificada.

---

## 1. Rentabilidad por Producto

| Producto | Margen total (periodo) | Margen % (catálogo) | Volumen |
|---|---|---|---|
| Laptop | $382,800 | 33.3% (el más bajo) | 957 uds. (el más alto) |
| Smartphone | $220,500 | 37.5% | 735 uds. |
| Tablet | $156,600 | 40.0% | 783 uds. |
| Monitor | $86,400 | 40.0% | 720 uds. |
| Mouse / Teclado | ~$11,600 / $25,000 | 60.0% (los más altos) | Volumen bajo |

**Hallazgo clave:** Laptop es simultáneamente el producto de mayor volumen y el de menor margen porcentual de todo el catálogo. Su alto volumen amplifica el impacto de cada punto porcentual de margen ganado o perdido — es el candidato más directo para revisar costo de adquisición o evaluar un ajuste de precio.

Mouse y Teclado tienen el margen % más alto (60%), pero su bajo volumen limita su impacto absoluto — son candidatos a impulso comercial, no a revisión de costos.

---

## 2. Desempeño por Sucursal

| Sucursal | Margen % ventas | Ratio costo/venta | Margen promedio/transacción |
|---|---|---|---|
| Este | 37.3% | 0.868 | **$890.58** (el mejor) |
| Sur | 37.1% | 0.897 | $881.12 |
| Norte | 36.8% | 0.845 (el mejor) | $871.51 |
| **Oeste** | 36.5% | **0.907 (el peor)** | **$809.45 (el peor)** |

**Hallazgo clave:** las 4 sucursales están muy parejas en margen % de venta (36.5%–37.3%), pero **Sucursal Oeste** queda última en las dos métricas de eficiencia operativa: mayor ratio costo/venta (gasta más en reposición de inventario por cada dólar vendido) y menor margen promedio por transacción. Es la sucursal más clara para priorizar en un plan de mejora.

---

## 3. Tendencias Estacionales

El margen mensual osciló entre un valle de **$45,125 (mayo 2024)** y un pico de **$137,475 (enero 2025)** — casi el triple.

**El pico de enero es generalizado, no aislado:** los 8 productos del catálogo muestran margen por encima de su propio promedio mensual ese mes, liderado por Smartphone (+115.8% sobre su promedio) y Laptop en términos absolutos ($52,000, el mayor aporte). Esto sugiere una oportunidad de planificación de inventario y personal anticipada para ese periodo, más que un evento ligado a un solo producto.

---

## 4. Síntesis y Recomendaciones

1. **Revisar costo de adquisición o precio de Laptop.** Es el producto de mayor volumen con el margen % más bajo; una mejora de solo 2-3 puntos porcentuales tendría el mayor impacto absoluto de todo el catálogo.
2. **Priorizar Laptop, Smartphone y Tablet en pauta comercial** — son los tres productos que más margen total generan.
3. **Auditar la operación de Sucursal Oeste.** Queda última tanto en eficiencia de compra (ratio costo/venta) como en margen por transacción — ambas métricas apuntan en la misma dirección, lo que descarta que sea una coincidencia estadística.
4. **Planificar inventario y personal con anticipación para enero**, dado el patrón de alza generalizada observado en el periodo analizado.

---

## Notas Metodológicas y Alcance

- El análisis se limita a la ventana **2024-03-01 a 2025-02-28** (12 meses), aunque la base de datos contiene registros hasta 2030; esta decisión de alcance se documenta en `01_Documentacion/definicion_proyecto.md`.
- Durante el desarrollo se detectó y corrigió un incidente de duplicación de registros en la tabla `ventas` (documentado en `03_SQL/00_correccion_duplicados_20260911.sql`); todos los resultados de este reporte están calculados **después** de esa corrección.
- Todos los cálculos de margen fueron validados de forma cruzada entre SQL y Python, obteniendo resultados idénticos.
- Los datos utilizados son ficticios; los hallazgos ilustran la metodología de análisis, no representan una empresa real.

---

*Próximo paso: dashboard interactivo en Power BI (`05_PowerBI/`) para exploración visual de estos hallazgos.*
