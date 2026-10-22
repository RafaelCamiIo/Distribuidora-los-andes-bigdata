/* ============================================================
   PROYECTO DE BASE DE DATOS
   EMPRESA: DISTRIBUIDORA LOS ANDES S.A.C.
   MOTOR: MICROSOFT SQL SERVER

   CANTIDAD DE REGISTROS:

   CATEGORIA        = 15
   PROVEEDOR        = 30
   PRODUCTO         = 200
   CLIENTE          = 200
   EMPLEADO         = 20
   PEDIDO           = 1000
   DETALLE_PEDIDO   = 2500
   PAGO             = 1000
   ============================================================ */


/* ============================================================
   1. ELIMINAR BASE DE DATOS SI YA EXISTE
   ============================================================ */

USE master;
GO

IF DB_ID('DistribuidoraLosAndes') IS NOT NULL
BEGIN
    ALTER DATABASE DistribuidoraLosAndes
    SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

    DROP DATABASE DistribuidoraLosAndes;
END
GO


/* ============================================================
   2. CREAR BASE DE DATOS
   ============================================================ */

CREATE DATABASE DistribuidoraLosAndes;
GO

USE DistribuidoraLosAndes;
GO


/* ============================================================
   3. TABLA CATEGORIA
   ============================================================ */

CREATE TABLE CATEGORIA
(
    IdCategoria INT IDENTITY(1,1) NOT NULL,
    NombreCategoria VARCHAR(100) NOT NULL,
    Descripcion VARCHAR(200),

    CONSTRAINT PK_CATEGORIA
        PRIMARY KEY (IdCategoria),

    CONSTRAINT UQ_CATEGORIA_NOMBRE
        UNIQUE (NombreCategoria)
);
GO


/* ============================================================
   4. TABLA PROVEEDOR
   ============================================================ */

CREATE TABLE PROVEEDOR
(
    IdProveedor INT IDENTITY(1,1) NOT NULL,
    RazonSocial VARCHAR(150) NOT NULL,
    RUC CHAR(11) NOT NULL,
    Telefono VARCHAR(20),
    Correo VARCHAR(100),
    Direccion VARCHAR(200),

    CONSTRAINT PK_PROVEEDOR
        PRIMARY KEY (IdProveedor),

    CONSTRAINT UQ_PROVEEDOR_RUC
        UNIQUE (RUC)
);
GO


/* ============================================================
   5. TABLA PRODUCTO
   ============================================================ */

CREATE TABLE PRODUCTO
(
    IdProducto INT IDENTITY(1,1) NOT NULL,
    NombreProducto VARCHAR(150) NOT NULL,
    Precio DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL,
    IdCategoria INT NOT NULL,
    IdProveedor INT NOT NULL,

    CONSTRAINT PK_PRODUCTO
        PRIMARY KEY (IdProducto),

    CONSTRAINT FK_PRODUCTO_CATEGORIA
        FOREIGN KEY (IdCategoria)
        REFERENCES CATEGORIA(IdCategoria),

    CONSTRAINT FK_PRODUCTO_PROVEEDOR
        FOREIGN KEY (IdProveedor)
        REFERENCES PROVEEDOR(IdProveedor),

    CONSTRAINT CK_PRODUCTO_PRECIO
        CHECK (Precio > 0),

    CONSTRAINT CK_PRODUCTO_STOCK
        CHECK (Stock >= 0)
);
GO


/* ============================================================
   6. TABLA CLIENTE
   ============================================================ */

CREATE TABLE CLIENTE
(
    IdCliente INT IDENTITY(1,1) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    DNI CHAR(8) NOT NULL,
    Telefono VARCHAR(20),
    Correo VARCHAR(100),
    Direccion VARCHAR(200),

    CONSTRAINT PK_CLIENTE
        PRIMARY KEY (IdCliente),

    CONSTRAINT UQ_CLIENTE_DNI
        UNIQUE (DNI)
);
GO


/* ============================================================
   7. TABLA EMPLEADO
   ============================================================ */

CREATE TABLE EMPLEADO
(
    IdEmpleado INT IDENTITY(1,1) NOT NULL,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    DNI CHAR(8) NOT NULL,
    Cargo VARCHAR(50) NOT NULL,
    Sueldo DECIMAL(10,2) NOT NULL,
    FechaIngreso DATE NOT NULL,

    CONSTRAINT PK_EMPLEADO
        PRIMARY KEY (IdEmpleado),

    CONSTRAINT UQ_EMPLEADO_DNI
        UNIQUE (DNI),

    CONSTRAINT CK_EMPLEADO_SUELDO
        CHECK (Sueldo > 0)
);
GO


/* ============================================================
   8. TABLA PEDIDO
   ============================================================ */

CREATE TABLE PEDIDO
(
    IdPedido INT IDENTITY(1,1) NOT NULL,
    FechaPedido DATE NOT NULL,
    IdCliente INT NOT NULL,
    IdEmpleado INT NOT NULL,
    Estado VARCHAR(30) NOT NULL,

    CONSTRAINT PK_PEDIDO
        PRIMARY KEY (IdPedido),

    CONSTRAINT FK_PEDIDO_CLIENTE
        FOREIGN KEY (IdCliente)
        REFERENCES CLIENTE(IdCliente),

    CONSTRAINT FK_PEDIDO_EMPLEADO
        FOREIGN KEY (IdEmpleado)
        REFERENCES EMPLEADO(IdEmpleado),

    CONSTRAINT CK_PEDIDO_ESTADO
        CHECK (Estado IN ('Completado','Pendiente','Cancelado'))
);
GO


/* ============================================================
   9. TABLA DETALLE_PEDIDO
   ============================================================ */

CREATE TABLE DETALLE_PEDIDO
(
    IdPedido INT NOT NULL,
    IdProducto INT NOT NULL,
    Cantidad INT NOT NULL,
    PrecioUnitario DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_DETALLE_PEDIDO
        PRIMARY KEY (IdPedido, IdProducto),

    CONSTRAINT FK_DETALLE_PEDIDO
        FOREIGN KEY (IdPedido)
        REFERENCES PEDIDO(IdPedido),

    CONSTRAINT FK_DETALLE_PRODUCTO
        FOREIGN KEY (IdProducto)
        REFERENCES PRODUCTO(IdProducto),

    CONSTRAINT CK_DETALLE_CANTIDAD
        CHECK (Cantidad > 0),

    CONSTRAINT CK_DETALLE_PRECIO
        CHECK (PrecioUnitario > 0)
);
GO


/* ============================================================
   10. TABLA PAGO
   ============================================================ */

CREATE TABLE PAGO
(
    IdPago INT IDENTITY(1,1) NOT NULL,
    IdPedido INT NOT NULL,
    FechaPago DATE NOT NULL,
    Monto DECIMAL(10,2) NOT NULL,
    TipoPago VARCHAR(30) NOT NULL,

    CONSTRAINT PK_PAGO
        PRIMARY KEY (IdPago),

    CONSTRAINT FK_PAGO_PEDIDO
        FOREIGN KEY (IdPedido)
        REFERENCES PEDIDO(IdPedido),

    CONSTRAINT UQ_PAGO_PEDIDO
        UNIQUE (IdPedido),

    CONSTRAINT CK_PAGO_MONTO
        CHECK (Monto > 0),

    CONSTRAINT CK_PAGO_TIPO
        CHECK (TipoPago IN
        ('Efectivo','Tarjeta','Yape','Plin'))
);
GO


/* ============================================================
   11. INSERTAR CATEGORIAS
   EXACTAMENTE 15
   ============================================================ */

INSERT INTO CATEGORIA
(
    NombreCategoria,
    Descripcion
)
VALUES
('Abarrotes','Productos basicos de consumo'),
('Bebidas','Gaseosas, aguas y otras bebidas'),
('Lacteos','Leches y productos derivados'),
('Limpieza','Productos para limpieza del hogar'),
('Cuidado Personal','Productos de higiene personal'),
('Snacks','Galletas, chocolates y piqueos'),
('Conservas','Productos enlatados y conservas'),
('Granos y Cereales','Arroz, avena y cereales'),
('Aceites y Salsas','Aceites y diferentes salsas'),
('Panificacion','Pan y productos de panaderia'),
('Congelados','Productos congelados'),
('Mascotas','Alimentos para mascotas'),
('Bebes','Productos para bebes'),
('Papeleria','Articulos escolares y de oficina'),
('Hogar','Articulos para el hogar');
GO


/* ============================================================
   12. INSERTAR PROVEEDORES
   EXACTAMENTE 30
   ============================================================ */

INSERT INTO PROVEEDOR
(
    RazonSocial,
    RUC,
    Telefono,
    Correo,
    Direccion
)
VALUES
('Distribuciones Lima SAC','20100000001','987654301','ventas01@empresa.com','Av. Argentina 1010, Lima'),
('Comercial San Martin SAC','20100000002','987654302','ventas02@empresa.com','Av. San Martin 1250, Lima'),
('Alimentos del Pacifico SAC','20100000003','987654303','ventas03@empresa.com','Av. Colonial 850, Callao'),
('Corporacion Andina SAC','20100000004','987654304','ventas04@empresa.com','Av. Universitaria 450, Lima'),
('Importaciones del Norte SAC','20100000005','987654305','ventas05@empresa.com','Av. Tupac Amaru 800, Lima'),
('Productos Nacionales SAC','20100000006','987654306','ventas06@empresa.com','Av. Mexico 650, Lima'),
('Comercializadora Central SAC','20100000007','987654307','ventas07@empresa.com','Av. Grau 740, Lima'),
('Inversiones Pacifico SAC','20100000008','987654308','ventas08@empresa.com','Av. Brasil 900, Lima'),
('Distribuidora Santa Rosa SAC','20100000009','987654309','ventas09@empresa.com','Av. Peru 1250, Lima'),
('Comercial Los Olivos SAC','20100000010','987654310','ventas10@empresa.com','Av. Carlos Izaguirre 540, Lima'),
('Mercantil San Juan SAC','20100000011','987654311','ventas11@empresa.com','Av. Los Heroes 720, Lima'),
('Distribuciones del Sur SAC','20100000012','987654312','ventas12@empresa.com','Av. Pedro Miotta 650, Lima'),
('Alimentos del Peru SAC','20100000013','987654313','ventas13@empresa.com','Av. Arequipa 1050, Lima'),
('Comercial El Sol SAC','20100000014','987654314','ventas14@empresa.com','Av. Canada 950, Lima'),
('Productos La Hacienda SAC','20100000015','987654315','ventas15@empresa.com','Av. Circunvalacion 400, Lima'),
('Distribuidora Moderna SAC','20100000016','987654316','ventas16@empresa.com','Av. Faucett 1200, Callao'),
('Comercial Santa Anita SAC','20100000017','987654317','ventas17@empresa.com','Av. Metropolitana 600, Lima'),
('Corporacion del Valle SAC','20100000018','987654318','ventas18@empresa.com','Av. Separadora Industrial 500, Lima'),
('Distribuidora San Miguel SAC','20100000019','987654319','ventas19@empresa.com','Av. La Marina 900, Lima'),
('Comercial La Victoria SAC','20100000020','987654320','ventas20@empresa.com','Av. Manco Capac 780, Lima'),
('Importadora Pacifico SAC','20100000021','987654321','ventas21@empresa.com','Av. Venezuela 950, Lima'),
('Mercados Unidos SAC','20100000022','987654322','ventas22@empresa.com','Av. Alfonso Ugarte 820, Lima'),
('Distribuciones Santa Anita SAC','20100000023','987654323','ventas23@empresa.com','Av. Ruiseñores 450, Lima'),
('Comercial Primavera SAC','20100000024','987654324','ventas24@empresa.com','Av. Primavera 780, Lima'),
('Productos del Centro SAC','20100000025','987654325','ventas25@empresa.com','Av. Colonial 1100, Lima'),
('Distribuidora El Progreso SAC','20100000026','987654326','ventas26@empresa.com','Av. Progreso 620, Lima'),
('Comercial Santa Clara SAC','20100000027','987654327','ventas27@empresa.com','Av. Central 730, Lima'),
('Distribuidora San Juan SAC','20100000028','987654328','ventas28@empresa.com','Av. Canto Grande 850, Lima'),
('Comercial Metropolitana SAC','20100000029','987654329','ventas29@empresa.com','Av. Metropolitana 920, Lima'),
('Corporacion Los Andes SAC','20100000030','987654330','ventas30@empresa.com','Av. Aviacion 870, Lima');
GO


/* ============================================================
   13. INSERTAR CLIENTES
   EXACTAMENTE 200
   ============================================================ */

;WITH Numeros AS
(
    SELECT TOP (200)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
    FROM sys.all_objects A
    CROSS JOIN sys.all_objects B
)
INSERT INTO CLIENTE
(
    Nombre,
    Apellido,
    DNI,
    Telefono,
    Correo,
    Direccion
)
SELECT

    CASE N % 20
        WHEN 0 THEN 'Carlos'
        WHEN 1 THEN 'Luis'
        WHEN 2 THEN 'Pedro'
        WHEN 3 THEN 'Jose'
        WHEN 4 THEN 'Miguel'
        WHEN 5 THEN 'Juan'
        WHEN 6 THEN 'Daniel'
        WHEN 7 THEN 'Fernando'
        WHEN 8 THEN 'Jorge'
        WHEN 9 THEN 'Ricardo'
        WHEN 10 THEN 'Andrea'
        WHEN 11 THEN 'Maria'
        WHEN 12 THEN 'Lucia'
        WHEN 13 THEN 'Patricia'
        WHEN 14 THEN 'Sofia'
        WHEN 15 THEN 'Valeria'
        WHEN 16 THEN 'Camila'
        WHEN 17 THEN 'Rosa'
        WHEN 18 THEN 'Ana'
        ELSE 'Gabriela'
    END,

    CASE N % 20
        WHEN 0 THEN 'Garcia'
        WHEN 1 THEN 'Rodriguez'
        WHEN 2 THEN 'Hernandez'
        WHEN 3 THEN 'Flores'
        WHEN 4 THEN 'Torres'
        WHEN 5 THEN 'Ramirez'
        WHEN 6 THEN 'Castillo'
        WHEN 7 THEN 'Vargas'
        WHEN 8 THEN 'Sanchez'
        WHEN 9 THEN 'Mendoza'
        WHEN 10 THEN 'Quispe'
        WHEN 11 THEN 'Rojas'
        WHEN 12 THEN 'Chavez'
        WHEN 13 THEN 'Fernandez'
        WHEN 14 THEN 'Diaz'
        WHEN 15 THEN 'Huaman'
        WHEN 16 THEN 'Cruz'
        WHEN 17 THEN 'Morales'
        WHEN 18 THEN 'Paredes'
        ELSE 'Salazar'
    END,

    RIGHT('00000000' + CAST(70000000 + N AS VARCHAR(8)),8),

    '9' + RIGHT('00000000' + CAST(10000000 + N AS VARCHAR(8)),8),

    'cliente' + CAST(N AS VARCHAR(3)) + '@correo.com',

    CASE N % 8
        WHEN 0 THEN 'Comas'
        WHEN 1 THEN 'Los Olivos'
        WHEN 2 THEN 'San Martin de Porres'
        WHEN 3 THEN 'Independencia'
        WHEN 4 THEN 'Carabayllo'
        WHEN 5 THEN 'Lima'
        WHEN 6 THEN 'Rimac'
        ELSE 'San Juan de Lurigancho'
    END

FROM Numeros;
GO


/* ============================================================
   14. INSERTAR EMPLEADOS
   EXACTAMENTE 20
   ============================================================ */

INSERT INTO EMPLEADO
(
    Nombre,
    Apellido,
    DNI,
    Cargo,
    Sueldo,
    FechaIngreso
)
VALUES
('Pedro','Ramirez','60000001','Vendedor',1600,'2022-01-15'),
('Luis','Garcia','60000002','Vendedor',1650,'2021-03-10'),
('Carlos','Torres','60000003','Vendedor',1700,'2023-05-20'),
('Miguel','Flores','60000004','Vendedor',1600,'2022-08-12'),
('Juan','Castillo','60000005','Vendedor',1750,'2020-11-05'),
('Daniel','Vargas','60000006','Vendedor',1650,'2023-01-18'),
('Jorge','Sanchez','60000007','Vendedor',1800,'2019-07-22'),
('Ricardo','Mendoza','60000008','Vendedor',1700,'2021-09-14'),
('Fernando','Rojas','60000009','Vendedor',1650,'2022-06-30'),
('Jose','Chavez','60000010','Vendedor',1600,'2024-02-01'),
('Andrea','Quispe','60000011','Vendedor',1700,'2021-12-10'),
('Maria','Huaman','60000012','Vendedor',1750,'2020-04-17'),
('Lucia','Morales','60000013','Vendedor',1650,'2023-09-25'),
('Patricia','Cruz','60000014','Vendedor',1800,'2019-10-08'),
('Sofia','Paredes','60000015','Vendedor',1700,'2022-03-19'),
('Valeria','Salazar','60000016','Administrador',2500,'2018-06-11'),
('Camila','Fernandez','60000017','Administrador',2600,'2019-02-20'),
('Rosa','Diaz','60000018','Almacenero',1900,'2021-05-05'),
('Ana','Vega','60000019','Almacenero',1850,'2022-07-12'),
('Gabriela','Mendoza','60000020','Supervisora',2800,'2017-01-10');
GO


/* ============================================================
   15. INSERTAR PRODUCTOS
   EXACTAMENTE 200
   ============================================================ */

;WITH Numeros AS
(
    SELECT TOP (200)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
    FROM sys.all_objects A
    CROSS JOIN sys.all_objects B
)
INSERT INTO PRODUCTO
(
    NombreProducto,
    Precio,
    Stock,
    IdCategoria,
    IdProveedor
)
SELECT

    CASE N % 20
        WHEN 0 THEN 'Arroz Extra'
        WHEN 1 THEN 'Azucar Rubia'
        WHEN 2 THEN 'Gaseosa Cola'
        WHEN 3 THEN 'Agua Mineral'
        WHEN 4 THEN 'Leche Evaporada'
        WHEN 5 THEN 'Yogurt Natural'
        WHEN 6 THEN 'Detergente'
        WHEN 7 THEN 'Jabon de Tocador'
        WHEN 8 THEN 'Galletas'
        WHEN 9 THEN 'Chocolate'
        WHEN 10 THEN 'Atun en Conserva'
        WHEN 11 THEN 'Avena'
        WHEN 12 THEN 'Aceite Vegetal'
        WHEN 13 THEN 'Pan de Molde'
        WHEN 14 THEN 'Pollo Congelado'
        WHEN 15 THEN 'Alimento para Perro'
        WHEN 16 THEN 'Panales'
        WHEN 17 THEN 'Cuaderno'
        WHEN 18 THEN 'Mayonesa'
        ELSE 'Escoba'
    END
    + ' ' + CAST(N AS VARCHAR(3)),

    CAST
    (
        CASE N % 20
            WHEN 0 THEN 4.50
            WHEN 1 THEN 4.20
            WHEN 2 THEN 3.50
            WHEN 3 THEN 2.50
            WHEN 4 THEN 4.80
            WHEN 5 THEN 5.50
            WHEN 6 THEN 9.90
            WHEN 7 THEN 3.80
            WHEN 8 THEN 2.50
            WHEN 9 THEN 4.90
            WHEN 10 THEN 6.50
            WHEN 11 THEN 5.20
            WHEN 12 THEN 8.50
            WHEN 13 THEN 9.50
            WHEN 14 THEN 15.90
            WHEN 15 THEN 18.50
            WHEN 16 THEN 25.90
            WHEN 17 THEN 6.90
            WHEN 18 THEN 7.90
            ELSE 12.50
        END
        + ((N % 7) * 0.75)
    AS DECIMAL(10,2)),

    50 + ((N * 17) % 251),

    ((N - 1) % 15) + 1,

    ((N - 1) % 30) + 1

FROM Numeros;
GO


/* ============================================================
   16. INSERTAR PEDIDOS
   EXACTAMENTE 1000
   ============================================================ */

;WITH Numeros AS
(
    SELECT TOP (1000)
        ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS N
    FROM sys.all_objects A
    CROSS JOIN sys.all_objects B
)
INSERT INTO PEDIDO
(
    FechaPedido,
    IdCliente,
    IdEmpleado,
    Estado
)
SELECT

    DATEADD
    (
        DAY,
        N - 1,
        CAST('2024-01-01' AS DATE)
    ),

    ((N - 1) % 200) + 1,

    ((N - 1) % 15) + 1,

    'Completado'

FROM Numeros;
GO


/* ============================================================
   17. INSERTAR DETALLES
   EXACTAMENTE 2500

   PEDIDOS 1 - 500:
       2 productos cada uno
       500 x 2 = 1000

   PEDIDOS 501 - 1000:
       3 productos cada uno
       500 x 3 = 1500

   TOTAL:
       1000 + 1500 = 2500
   ============================================================ */

;WITH Detalles AS
(
    /* Producto 1 */
    SELECT
        P.IdPedido,
        ((P.IdPedido - 1) % 200) + 1 AS IdProducto
    FROM PEDIDO P

    UNION ALL

    /* Producto 2 */
    SELECT
        P.IdPedido,
        ((P.IdPedido + 49) % 200) + 1
    FROM PEDIDO P

    UNION ALL

    /* Producto 3 solamente para los pedidos 501-1000 */
    SELECT
        P.IdPedido,
        ((P.IdPedido + 99) % 200) + 1
    FROM PEDIDO P
    WHERE P.IdPedido >= 501
)
INSERT INTO DETALLE_PEDIDO
(
    IdPedido,
    IdProducto,
    Cantidad,
    PrecioUnitario
)
SELECT

    D.IdPedido,

    D.IdProducto,

    1 + ((D.IdPedido + D.IdProducto) % 8),

    PR.Precio

FROM Detalles D

INNER JOIN PRODUCTO PR
    ON D.IdProducto = PR.IdProducto;
GO


/* ============================================================
   18. INSERTAR PAGOS
   EXACTAMENTE 1000

   El monto se calcula automáticamente:
   Cantidad x PrecioUnitario
   ============================================================ */

INSERT INTO PAGO
(
    IdPedido,
    FechaPago,
    Monto,
    TipoPago
)
SELECT

    P.IdPedido,

    P.FechaPedido,

    CAST
    (
        SUM(D.Cantidad * D.PrecioUnitario)
        AS DECIMAL(10,2)
    ),

    CASE P.IdPedido % 4
        WHEN 0 THEN 'Efectivo'
        WHEN 1 THEN 'Tarjeta'
        WHEN 2 THEN 'Yape'
        ELSE 'Plin'
    END

FROM PEDIDO P

INNER JOIN DETALLE_PEDIDO D
    ON P.IdPedido = D.IdPedido

GROUP BY
    P.IdPedido,
    P.FechaPedido;
GO


/* ============================================================
   19. VERIFICAR CANTIDAD DE REGISTROS
   ============================================================ */

SELECT
    'CATEGORIA' AS Tabla,
    COUNT(*) AS Cantidad
FROM CATEGORIA

UNION ALL

SELECT
    'PROVEEDOR',
    COUNT(*)
FROM PROVEEDOR

UNION ALL

SELECT
    'PRODUCTO',
    COUNT(*)
FROM PRODUCTO

UNION ALL

SELECT
    'CLIENTE',
    COUNT(*)
FROM CLIENTE

UNION ALL

SELECT
    'EMPLEADO',
    COUNT(*)
FROM EMPLEADO

UNION ALL

SELECT
    'PEDIDO',
    COUNT(*)
FROM PEDIDO

UNION ALL

SELECT
    'DETALLE_PEDIDO',
    COUNT(*)
FROM DETALLE_PEDIDO

UNION ALL

SELECT
    'PAGO',
    COUNT(*)
FROM PAGO;
GO


/* ============================================================
   20. VERIFICAR QUE NO EXISTAN DETALLES DUPLICADOS
   ============================================================ */

SELECT
    IdPedido,
    IdProducto,
    COUNT(*) AS Veces
FROM DETALLE_PEDIDO
GROUP BY
    IdPedido,
    IdProducto
HAVING COUNT(*) > 1;
GO


/* ============================================================
   21. VERIFICAR PEDIDOS SIN DETALLES
   ============================================================ */

SELECT
    P.IdPedido
FROM PEDIDO P
LEFT JOIN DETALLE_PEDIDO D
    ON P.IdPedido = D.IdPedido
WHERE D.IdPedido IS NULL;
GO


/* ============================================================
   22. VERIFICAR PEDIDOS SIN PAGO
   ============================================================ */

SELECT
    P.IdPedido
FROM PEDIDO P
LEFT JOIN PAGO PA
    ON P.IdPedido = PA.IdPedido
WHERE PA.IdPedido IS NULL;
GO


/* ============================================================
   23. VERIFICAR QUE EL PAGO COINCIDA CON EL TOTAL DEL PEDIDO
   ============================================================ */

SELECT
    P.IdPedido,

    CAST
    (
        SUM(D.Cantidad * D.PrecioUnitario)
        AS DECIMAL(10,2)
    ) AS TotalPedido,

    PA.Monto AS MontoPagado

FROM PEDIDO P

INNER JOIN DETALLE_PEDIDO D
    ON P.IdPedido = D.IdPedido

INNER JOIN PAGO PA
    ON P.IdPedido = PA.IdPedido

GROUP BY
    P.IdPedido,
    PA.Monto

HAVING
    CAST
    (
        SUM(D.Cantidad * D.PrecioUnitario)
        AS DECIMAL(10,2)
    ) <> PA.Monto;
GO


/* ============================================================
   24. MOSTRAR PEDIDOS CON INFORMACIÓN COMPLETA
   ============================================================ */

SELECT TOP 20

    P.IdPedido,
    P.FechaPedido,

    C.Nombre + ' ' + C.Apellido AS Cliente,

    E.Nombre + ' ' + E.Apellido AS Empleado,

    P.Estado,

    COUNT(D.IdProducto) AS ProductosDiferentes,

    SUM(D.Cantidad) AS UnidadesVendidas,

    CAST
    (
        SUM(D.Cantidad * D.PrecioUnitario)
        AS DECIMAL(10,2)
    ) AS TotalPedido,

    PA.TipoPago

FROM PEDIDO P

INNER JOIN CLIENTE C
    ON P.IdCliente = C.IdCliente

INNER JOIN EMPLEADO E
    ON P.IdEmpleado = E.IdEmpleado

INNER JOIN DETALLE_PEDIDO D
    ON P.IdPedido = D.IdPedido

INNER JOIN PAGO PA
    ON P.IdPedido = PA.IdPedido

GROUP BY
    P.IdPedido,
    P.FechaPedido,
    C.Nombre,
    C.Apellido,
    E.Nombre,
    E.Apellido,
    P.Estado,
    PA.TipoPago

ORDER BY P.IdPedido;
GO


/* ============================================================
   FIN DEL SCRIPT
   ============================================================ */