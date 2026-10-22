/* ============================================================
   SCRIPT 1: CREAR ENTORNO DEL DATAMART
   Distribuidora Los Andes
   Crea la base, las dimensiones, el staging y la tabla de hechos.
   (Los datos se cargan con el script 2: ETL)
   ============================================================ */

use master
go
if db_id('datamartdistribuidora') is not null
begin
    alter database datamartdistribuidora set single_user with rollback immediate
    drop database datamartdistribuidora
end
go
create database datamartdistribuidora
go

use datamartdistribuidora
go

-- ---------- DIMENSIONES ----------
create table dim_cliente
(id_cliente int primary key identity,
pk_cliente int,
nombre varchar(200),
dni char(8),
direccion varchar(200)
)
go

create table dim_producto
(id_producto int primary key identity,
pk_producto int,
nombre varchar(150),
categoria varchar(100)
)
go

create table dim_tiempo
(fecha date primary key,
anio smallint,
mes smallint,
diaMes smallint,
diaSemana varchar(15),
trimestre smallint
)
go

create table dim_empleado
(id_empleado int primary key identity,
pk_empleado int,
nombre varchar(200),
cargo varchar(50)
)
go

create table dim_proveedor
(id_proveedor int primary key identity,
pk_proveedor int,
razonSocial varchar(150),
ruc char(11)
)
go

create table dim_metodoPago
(id_metodoP int primary key identity,
nombreMetodo varchar(30)
)
go

-- ---------- STAGING (se cargan desde txt) ----------
create table stg_venta
(idPedido int,
idProducto int,
fechaPedido date,
idCliente int,
idEmpleado int,
idProveedor int,
tipoPago varchar(30),
cantidad int,
precioUnitario decimal(10,2),
stock int
)
go

create table stg_empleado
(pk_empleado int,
nombre varchar(100),
apellido varchar(100),
cargo varchar(50)
)
go

create table stg_proveedor
(pk_proveedor int,
razonSocial varchar(150),
ruc char(11)
)
go

-- ---------- TABLA DE HECHOS ----------
--drop table fac_ventas
create table fac_ventas
(
id_venta int primary key identity,
idPedido int,                                   -- dimension degenerada
id_cliente int references dim_cliente,
id_producto int references dim_producto,
id_empleado int references dim_empleado,
id_proveedor int references dim_proveedor,
id_metodoP int references dim_metodoPago,
fecha date references dim_tiempo,
cantidad int,
precioUnitario money,
importeTotal money,
stockDisponible int
)
go
