/* =====================================================================
   01_Setup_ProductionTraining.sql
   Course  : SQL and Relational Database Fundamentals (1 day)
   Purpose : Create and populate the ProductionTraining training database
   Platform: Microsoft SQL Server 2025 Express + SSMS
   Server  : localhost\SQLEXPRESS (Windows Authentication)
   ---------------------------------------------------------------------
   HOW TO USE
   1. Open SSMS and connect to the training instance (e.g. localhost\SQLEXPRESS).
   2. Go to File > Open > File... and select this script.
   3. Press F5 (Execute) with no lines selected.
   4. Check the Messages tab for "Setup complete" at the end.

   RERUN BEHAVIOR: The script drops the training tables if they exist
   and recreates them. Rerunning it will not duplicate the sample data.
   WARNING: Any participant changes to these training tables will be lost.
   © 2026 Mufasyah Consultant | mufasyahcons@gmail.com
   ===================================================================== */

SET NOCOUNT ON;
GO

/* ---------- Step 1: Create the database if it does not exist ---------- */
USE master;
GO

IF DB_ID(N'ProductionTraining') IS NULL
BEGIN
    CREATE DATABASE ProductionTraining;
    PRINT N'The ProductionTraining database was created.';
END
ELSE
    PRINT N'The ProductionTraining database already exists. The training tables will be recreated.';
GO

USE ProductionTraining;
GO

/* ---------- Step 2: Drop existing tables (child tables first) ---------- */
DROP TABLE IF EXISTS dbo.ProductionRecords;
DROP TABLE IF EXISTS dbo.ProductionOrders;
DROP TABLE IF EXISTS dbo.Products;
GO

/* ---------- Step 3: Create the tables ---------- */

-- Each row represents one product manufactured by the factory.
CREATE TABLE dbo.Products
(
    ProductID      INT            NOT NULL CONSTRAINT PK_Products PRIMARY KEY,
    ProductCode    VARCHAR(10)    NOT NULL CONSTRAINT UQ_Products_ProductCode UNIQUE,
    ProductName    NVARCHAR(100)  NOT NULL,
    Category       NVARCHAR(50)   NOT NULL,
    UnitOfMeasure  NVARCHAR(10)   NOT NULL,
    StandardCost   DECIMAL(10,2)  NULL,      -- Standard cost per unit (RM). NULL means it has not been set.
    IsActive       BIT            NOT NULL CONSTRAINT DF_Products_IsActive DEFAULT (1)
);
GO

-- Each row represents one production order for a single product.
CREATE TABLE dbo.ProductionOrders
(
    OrderID        INT            NOT NULL CONSTRAINT PK_ProductionOrders PRIMARY KEY,
    OrderNo        VARCHAR(20)    NOT NULL CONSTRAINT UQ_ProductionOrders_OrderNo UNIQUE,
    ProductID      INT            NOT NULL,
    LineName       NVARCHAR(20)   NOT NULL,  -- Production line
    OrderDate      DATE           NOT NULL,
    DueDate        DATE           NOT NULL,
    PlannedQty     INT            NOT NULL,  -- Planned quantity in units
    Status         VARCHAR(20)    NOT NULL,  -- Open / In Progress / Completed / Cancelled / On Hold
    CompletedDate  DATE           NULL,      -- NULL means the order has not been completed.
    Remarks        NVARCHAR(200)  NULL,      -- NULL means no remarks were entered.
    CONSTRAINT FK_ProductionOrders_Products
        FOREIGN KEY (ProductID) REFERENCES dbo.Products (ProductID),
    CONSTRAINT CK_ProductionOrders_Status
        CHECK (Status IN ('Open', 'In Progress', 'Completed', 'Cancelled', 'On Hold')),
    CONSTRAINT CK_ProductionOrders_PlannedQty CHECK (PlannedQty > 0)
);
GO

-- Each row records output for one order, on one date, during one shift.
CREATE TABLE dbo.ProductionRecords
(
    RecordID         INT           NOT NULL CONSTRAINT PK_ProductionRecords PRIMARY KEY,
    OrderID          INT           NOT NULL,
    ProductionDate   DATE          NOT NULL,
    Shift            NVARCHAR(10)  NOT NULL,  -- Morning / Afternoon / Night
    GoodQty          INT           NOT NULL,  -- Units that passed quality inspection
    RejectQty        INT           NOT NULL,  -- Rejected units
    OperatorName     NVARCHAR(50)  NOT NULL,
    DowntimeMinutes  INT           NULL,      -- NULL means downtime was not recorded.
    CONSTRAINT FK_ProductionRecords_ProductionOrders
        FOREIGN KEY (OrderID) REFERENCES dbo.ProductionOrders (OrderID),
    CONSTRAINT CK_ProductionRecords_Qty CHECK (GoodQty >= 0 AND RejectQty >= 0)
);
GO

/* ---------- Step 4: Insert sample data with fixed dates ---------- */

INSERT INTO dbo.Products
    (ProductID, ProductCode, ProductName, Category, UnitOfMeasure, StandardCost, IsActive)
VALUES
    (1, 'P001', N'500 mL Food Container',     N'Packaging',       N'pcs',     0.35, 1),
    (2, 'P002', N'750 mL Food Container',     N'Packaging',       N'pcs',     0.48, 1),
    (3, 'P003', N'A4 Plastic Tray',           N'Accessories',     N'pcs',     1.20, 1),
    (4, 'P004', N'20 mm PVC Pipe (3 m)',      N'Pipes & Fittings',N'lengths', 4.50, 1),
    (5, 'P005', N'20 mm Tee Fitting',         N'Pipes & Fittings',N'pcs',     0.65, 1),
    (6, 'P006', N'200 mm Cable Tie',          N'Accessories',     N'pcs',     0.04, 1),
    (7, 'P007', N'28 mm Bottle Cap',          N'Packaging',       N'pcs',     0.05, 0),  -- Inactive product with no orders
    (8, 'P008', N'ABS Door Handle',           N'Accessories',     N'pcs',     NULL, 1);  -- New product with no orders or standard cost
GO

INSERT INTO dbo.ProductionOrders
    (OrderID, OrderNo, ProductID, LineName, OrderDate, DueDate, PlannedQty, Status, CompletedDate, Remarks)
VALUES
    ( 1, 'PO-2026-001', 1, N'Line A', '2026-09-28', '2026-10-05',  5000, 'Completed',   '2026-10-02', NULL),
    ( 2, 'PO-2026-002', 2, N'Line B', '2026-09-29', '2026-10-06',  3000, 'Completed',   '2026-10-03', NULL),
    ( 3, 'PO-2026-003', 3, N'Line A', '2026-10-01', '2026-10-10',  2000, 'Completed',   '2026-10-07', NULL),
    ( 4, 'PO-2026-004', 4, N'Line C', '2026-10-02', '2026-10-12',  4000, 'In Progress', NULL,         N'Machine M3 stops frequently'),
    ( 5, 'PO-2026-005', 1, N'Line A', '2026-10-05', '2026-10-14',  6000, 'In Progress', NULL,         NULL),
    ( 6, 'PO-2026-006', 5, N'Line C', '2026-10-06', '2026-10-16',  2500, 'Open',        NULL,         NULL),
    ( 7, 'PO-2026-007', 2, N'Line B', '2026-10-08', '2026-10-18',  3500, 'In Progress', NULL,         NULL),
    ( 8, 'PO-2026-008', 6, N'Line B', '2026-10-09', '2026-10-20', 10000, 'Open',        NULL,         NULL),
    ( 9, 'PO-2026-009', 3, N'Line A', '2026-10-12', '2026-10-22',  1500, 'Cancelled',   NULL,         N'Customer cancelled the order'),
    (10, 'PO-2026-010', 4, N'Line C', '2026-10-14', '2026-10-24',  3000, 'Open',        NULL,         NULL),
    (11, 'PO-2026-011', 5, N'Line C', '2026-10-15', '2026-10-25',  2000, 'In Progress', NULL,         NULL),
    (12, 'PO-2026-012', 1, N'Line A', '2026-10-16', '2026-10-28',  4000, 'Open',        NULL,         NULL);
GO

INSERT INTO dbo.ProductionRecords
    (RecordID, OrderID, ProductionDate, Shift, GoodQty, RejectQty, OperatorName, DowntimeMinutes)
VALUES
    ( 1,  1, '2026-09-30', N'Morning',   1800, 25, N'Aminah', 15),
    ( 2,  1, '2026-10-01', N'Morning',   1700, 30, N'Aminah', NULL),
    ( 3,  1, '2026-10-02', N'Afternoon', 1550, 20, N'Rajesh', 30),
    ( 4,  2, '2026-10-01', N'Morning',   1500, 40, N'Siti',   0),
    ( 5,  2, '2026-10-03', N'Afternoon', 1520, 35, N'Lim',    20),
    ( 6,  3, '2026-10-06', N'Morning',   1000, 15, N'Aminah', 10),
    ( 7,  3, '2026-10-07', N'Night',     1010, 12, N'Kumar',  NULL),
    ( 8,  4, '2026-10-05', N'Morning',    900, 18, N'Farid',  45),
    ( 9,  4, '2026-10-06', N'Afternoon',  850, 22, N'Farid',  60),
    (10,  4, '2026-10-08', N'Morning',    950, 10, N'Wong',   0),
    (11,  5, '2026-10-08', N'Afternoon', 2000, 28, N'Rajesh', 0),
    (12,  5, '2026-10-10', N'Morning',   1900, 32, N'Aminah', 25),
    (13,  7, '2026-10-12', N'Morning',   1200, 20, N'Siti',   0),
    (14,  7, '2026-10-13', N'Night',     1150, 25, N'Lim',    NULL),
    (15, 11, '2026-10-16', N'Morning',    800,  8, N'Wong',   5),
    (16,  5, '2026-10-15', N'Morning',   1000, 15, N'Aminah', 10);
GO

/* ---------- Step 5: Verify the row counts ---------- */
SELECT 'Products'          AS TableName, COUNT(*) AS TotalRows FROM dbo.Products
UNION ALL
SELECT 'ProductionOrders',               COUNT(*)             FROM dbo.ProductionOrders
UNION ALL
SELECT 'ProductionRecords',              COUNT(*)             FROM dbo.ProductionRecords;
-- Expected row counts: Products = 8, ProductionOrders = 12, ProductionRecords = 16

PRINT N'Setup complete. The ProductionTraining database is ready to use.';
GO