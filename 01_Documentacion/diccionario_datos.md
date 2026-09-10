### 🏢 Tabla: `sucursales`
*Contiene la información de ubicación y administración de las sucursales de la empresa.*

| Columna | Tipo de Datos | Descripción | Ejemplo |
| :--- | :--- | :--- | :--- |
| **`id_sucursal`** | `INT` <br> 🔑 *PK, AI* | Identificador único de sucursal. | `1` |
| **`nombre_sucursal`** | `VARCHAR(100)` | Nombre comercial de la sucursal. | `Sucursal Norte` |
| **`ciudad`** | `VARCHAR(100)` | Ciudad donde opera. | `Santiago` |
| **`region`** | `VARCHAR(100)` | Región geográfica asignada. | `Centro` |
| **`gerente`** | `VARCHAR(100)` | Nombre del gerente a cargo. | `Juan Pérez` |

---
<br>

### 📦 Tabla: `productos`
*Catálogo maestro de los productos disponibles para la venta y sus costos bases.*

| Columna | Tipo de Datos | Descripción | Ejemplo |
| :--- | :--- | :--- | :--- |
| **`id_producto`** | `INT` <br> 🔑 *PK, AI* | Identificador único de producto. | `1` |
| **`nombre_producto`** | `VARCHAR(100)` | Nombre del producto. | `Laptop` |
| **`categoria`** | `VARCHAR(100)` | Categoría comercial. | `Electrónica` |
| **`precio_venta`** | `DECIMAL(10,2)` | Precio unitario de venta al público. | `1200.00` |
| **`costo_unitario`** | `DECIMAL(10,2)` | Costo unitario de adquisición. | `800.00` |

---
<br>

### 💰 Tabla: `ventas`
*Registro histórico de transacciones comerciales realizadas en cada sucursal.*

| Columna | Tipo de Datos | Descripción | Ejemplo |
| :--- | :--- | :--- | :--- |
| **`id_venta`** | `INT` <br> 🔑 *PK, AI* | Identificador único de la transacción. | `101` |
| **`id_sucursal`** | `INT` <br> 🔗 *FK → sucursales* | Sucursal donde ocurrió la venta. | `3` |
| **`id_producto`** | `INT` <br> 🔗 *FK → productos* | Producto vendido. | `1` |
| **`fecha_venta`** | `DATE` | Fecha de la transacción. | `2024-09-25` |
| **`cantidad_vendida`** | `INT` | Unidades vendidas en la transacción. | `2` |
| **`total_venta`** | `DECIMAL(10,2)` | Monto total de la venta *(cantidad × precio)*. | `2400.00` |

---
<br>

### 📉 Tabla: `costos`
*Registro de egresos por concepto de compras y reposición de inventario por sucursal.*

| Columna | Tipo de Datos | Descripción | Ejemplo |
| :--- | :--- | :--- | :--- |
| **`id_costo`** | `INT` <br> 🔑 *PK, AI* | Identificador único del registro de costo. | `87` |
| **`id_sucursal`** | `INT` <br> 🔗 *FK → sucursales* | Sucursal que incurrió en el costo. | `3` |
| **`id_producto`** | `INT` <br> 🔗 *FK → productos* | Producto asociado al costo *(compra/reposición)*. | `1` |
| **`fecha_costo`** | `DATE` | Fecha en que se registró el costo. | `2024-09-13` |
| **`cantidad_comprada`** | `INT` | Unidades compradas o repuestas. | `4` |
| **`total_costo`** | `DECIMAL(10,2)` | Monto total del costo *(cantidad × costo unitario)*. | `3200.00` |

<br>
<br>

> **Nota sobre relación entre `ventas` y `costos`:**  
> Estas dos tablas registran eventos independientes (una venta vs. una compra/reposición de inventario) y **no comparten llave directa**. `id_venta` e `id_costo` son identificadores autónomos sin relación semántica entre sí — nunca deben unirse con un `JOIN ventas.id_venta = costos.id_costo`.
>
> Ambas tablas comparten únicamente las dimensiones `id_sucursal` e `id_producto`. Por eso, para calcular métricas de margen, cada tabla se agrega **por separado** (por sucursal, producto o periodo) y luego se combinan los totales agregados — no se cruzan fila a fila.
