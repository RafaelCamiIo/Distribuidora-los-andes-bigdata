/* ============================================================
   SCRIPT 2: ETL DEL DATAMART
   Distribuidora Los Andes

   REQUISITOS:
   - Haber ejecutado antes el script 1 (crear entorno).
   - La base DistribuidoraLosAndes debe existir en este servidor.
   - Copiar los txt a la carpeta C:\txt\
        stg_venta.txt      (separador |, con encabezado)
        stg_empleado.txt   (separador coma, sin encabezado)
        stg_proveedor.txt  (separador coma, sin encabezado)
   ============================================================ */

use datamartdistribuidora
go

--Paso 1: Limpiamos tablas
delete from fac_ventas
if @@ROWCOUNT <> 0
	DBCC CHECKIDENT ( 'fac_ventas', RESEED, 0 )
go
delete from dim_producto
if @@ROWCOUNT <> 0
	DBCC CHECKIDENT ( 'dim_producto', RESEED, 0 )
go
delete from dim_cliente
if @@ROWCOUNT <> 0
	DBCC CHECKIDENT ( 'dim_cliente', RESEED, 0 )
go
delete from dim_empleado
if @@ROWCOUNT <> 0
	DBCC CHECKIDENT ( 'dim_empleado', RESEED, 0 )
go
delete from dim_proveedor
if @@ROWCOUNT <> 0
	DBCC CHECKIDENT ( 'dim_proveedor', RESEED, 0 )
go
delete from dim_metodoPago
if @@ROWCOUNT <> 0
	DBCC CHECKIDENT ( 'dim_metodoPago', RESEED, 0 )
go
delete from dim_tiempo
go
truncate table stg_venta
go
truncate table stg_empleado
go
truncate table stg_proveedor
go


--Paso 2: Cargamos dimensiones desde la base transaccional
use DistribuidoraLosAndes
go

--Cargamos la dimension cliente
insert into datamartdistribuidora.dbo.dim_cliente (pk_cliente, nombre, dni, direccion)
select IdCliente as pk_cliente, Nombre + ' ' + Apellido as nombre, DNI, Direccion
from CLIENTE
go

select * from datamartdistribuidora.dbo.dim_cliente
go

--Cargamos la dimension producto
insert into datamartdistribuidora.dbo.dim_producto (pk_producto, nombre, categoria)
select P.IdProducto pk_producto, P.NombreProducto nombre, C.NombreCategoria categoria
from CATEGORIA C
join PRODUCTO P on C.IdCategoria = P.IdCategoria
go

select * from datamartdistribuidora.dbo.dim_producto
go

--Cargamos la dimension tiempo (un registro por cada dia entre el primer y el ultimo pedido)
Declare @inicio date, @fin date
select @inicio = Min(FechaPedido), @fin = Max(FechaPedido) from PEDIDO

WHILE (@inicio <= @fin)
	BEGIN

		INSERT INTO datamartdistribuidora.dbo.dim_tiempo
		SELECT @inicio fecha, DATEPART(yyyy, @inicio) anio, DATEPART(m, @inicio) mes, DATEPART(d, @inicio) diaMes,
			-- formula independiente del idioma / DATEFIRST del servidor
			CASE (DATEPART(dw, @inicio) + @@DATEFIRST - 2) % 7 + 1
					WHEN 1 THEN 'Lunes'
					WHEN 2 THEN 'Martes'
					WHEN 3 THEN 'Miercoles'
					WHEN 4 THEN 'Jueves'
					WHEN 5 THEN 'Viernes'
					WHEN 6 THEN 'Sabado'
					WHEN 7 THEN 'Domingo'
				END AS diaSemana,
				DATEPART(q, @inicio) AS trimestre

		SET @inicio = DATEADD(d, 1, @inicio);
	end
go

select * from datamartdistribuidora.dbo.dim_tiempo
go


--Paso 3: Cargamos el staging desde los txt
--cargamos staging venta
Bulk insert datamartdistribuidora.dbo.stg_venta
	  from 'C:\txt\stg_venta.txt'
	  WITH
	  (FIRSTROW = 2,
	  FIELDTERMINATOR='|', ROWTERMINATOR = '\n')
go

select * from datamartdistribuidora.dbo.stg_venta
go

--cargamos staging empleado
Bulk insert datamartdistribuidora.dbo.stg_empleado
	  from 'C:\txt\stg_empleado.txt'
	  WITH
	  (FIRSTROW = 1,
	  FIELDTERMINATOR=',', ROWTERMINATOR = '\n')
go

--cargamos staging proveedor
Bulk insert datamartdistribuidora.dbo.stg_proveedor
	  from 'C:\txt\stg_proveedor.txt'
	  WITH
	  (FIRSTROW = 1,
	  FIELDTERMINATOR=',', ROWTERMINATOR = '\n')
go


--Paso 4: Cargamos las dimensiones que vienen del staging
--Cargar DIM_EMPLEADO
Insert into datamartdistribuidora.dbo.dim_empleado (pk_empleado, nombre, cargo)
select pk_empleado, nombre + ' ' + apellido, cargo
from datamartdistribuidora.dbo.stg_empleado
go

select * from datamartdistribuidora.dbo.dim_empleado
go

--Cargar DIM_PROVEEDOR
Insert into datamartdistribuidora.dbo.dim_proveedor (pk_proveedor, razonSocial, ruc)
select pk_proveedor, razonSocial, ruc
from datamartdistribuidora.dbo.stg_proveedor
go

select * from datamartdistribuidora.dbo.dim_proveedor
go

--Cargar DIM_METODOPAGO (los metodos distintos que aparecen en las ventas)
Insert into datamartdistribuidora.dbo.dim_metodoPago (nombreMetodo)
select distinct tipoPago
from datamartdistribuidora.dbo.stg_venta
go

select * from datamartdistribuidora.dbo.dim_metodoPago
go


--Paso 5: Cargamos la FAC Ventas (tabla de hechos)
--Se buscan los id sustitutos de cada dimension con JOIN por la pk_ original
insert into datamartdistribuidora.dbo.fac_ventas
(idPedido, id_cliente, id_producto, id_empleado, id_proveedor, id_metodoP, fecha,
 cantidad, precioUnitario, importeTotal, stockDisponible)
select S.idPedido, D_CL.id_cliente, D_PR.id_producto, D_EM.id_empleado, D_PV.id_proveedor, D_MP.id_metodoP,
       S.fechaPedido, S.cantidad, S.precioUnitario, S.cantidad * S.precioUnitario, S.stock
from datamartdistribuidora.dbo.stg_venta S
join datamartdistribuidora.dbo.dim_cliente    D_CL on D_CL.pk_cliente   = S.idCliente
join datamartdistribuidora.dbo.dim_producto   D_PR on D_PR.pk_producto  = S.idProducto
join datamartdistribuidora.dbo.dim_empleado   D_EM on D_EM.pk_empleado  = S.idEmpleado
join datamartdistribuidora.dbo.dim_proveedor  D_PV on D_PV.pk_proveedor = S.idProveedor
join datamartdistribuidora.dbo.dim_metodoPago D_MP on D_MP.nombreMetodo = S.tipoPago
go

select * from datamartdistribuidora.dbo.fac_ventas
go


--Paso 6: Verificacion
/* Esperado: stg_venta 2500 | stg_empleado 20 | stg_proveedor 30
             dim_cliente 200 | dim_producto 200 | dim_empleado 20
             dim_proveedor 30 | dim_metodoPago 4 | dim_tiempo 1000
             fac_ventas 2500 | importe total 105595.75 */
use datamartdistribuidora
go

select 'stg_venta' as tabla, count(*) as filas from stg_venta
union all select 'stg_empleado',   count(*) from stg_empleado
union all select 'stg_proveedor',  count(*) from stg_proveedor
union all select 'dim_cliente',    count(*) from dim_cliente
union all select 'dim_producto',   count(*) from dim_producto
union all select 'dim_empleado',   count(*) from dim_empleado
union all select 'dim_proveedor',  count(*) from dim_proveedor
union all select 'dim_metodoPago', count(*) from dim_metodoPago
union all select 'dim_tiempo',     count(*) from dim_tiempo
union all select 'fac_ventas',     count(*) from fac_ventas
go

-- Los dos importes deben ser iguales
select sum(importeTotal) as importe_fact from fac_ventas
go
select sum(Monto) as monto_pagos_origen from DistribuidoraLosAndes.dbo.PAGO
go
