/* =====================================================================
   01_Setup_ProductionTraining.sql
   Course: SQL and Relational Database Fundamentals (1 day)
   Trainer: Fakhrul Syahmi | Data Consultant & Certified Trainer
   Platform: SQL Server 2025 Express (localhost\SQLEXPRESS), SSMS, T-SQL
   ---------------------------------------------------------------------
   What this script does
     1. Creates the ProductionTraining database if it does not exist.
     2. Recreates dbo.Products, dbo.ProductionOrders, and
        dbo.ProductionRecords with the same schema.
     3. Creates dbo.usp_ResetTrainingData and loads fictional sample data.
     4. Displays row counts for verification.

   Rerunning this script recreates the three training tables and reloads
   the original sample data. Changes made to those tables will be lost.

   How to run: Open this file in SSMS, clear any text selection, and
   press F5 or click Execute. Check the Messages tab for errors and
   verify the row counts in the Results tab. The final message is
   "ProductionTraining setup complete."

   The optional dbo.ProductionRecordsLarge table from script 04 is
   excluded from this setup.
   ===================================================================== */

SET NOCOUNT ON;
GO

USE master;
GO

IF DB_ID(N'ProductionTraining') IS NULL
BEGIN
    CREATE DATABASE ProductionTraining;
    PRINT 'ProductionTraining database created.';
END
ELSE
    PRINT 'ProductionTraining already exists. The training tables will be recreated.';
GO

USE ProductionTraining;
GO

/* ---------- 1. Remove existing demo objects, if present ---------- */

DROP VIEW      IF EXISTS dbo.vw_ProductionDetail;
DROP PROCEDURE IF EXISTS dbo.usp_ProductOutputByPeriod;
DROP PROCEDURE IF EXISTS dbo.usp_ResetTrainingData;
DROP TABLE     IF EXISTS dbo.ProductionRecords;   -- Drop child tables first because of foreign keys.
DROP TABLE     IF EXISTS dbo.ProductionOrders;
DROP TABLE     IF EXISTS dbo.Products;

IF USER_ID(N'TrainingReader') IS NOT NULL
    DROP USER TrainingReader;                     -- Used in the access permissions demo (Section D).
GO

/* ---------- 2. Product master table ---------- */

CREATE TABLE dbo.Products
(
    ProductID    INT            NOT NULL,
    ProductCode  VARCHAR(10)    NOT NULL,
    ProductName  NVARCHAR(100)  NOT NULL,
    Category     NVARCHAR(50)   NULL,
    UnitPrice    DECIMAL(10,2)  NOT NULL,
    IsActive     BIT            NOT NULL CONSTRAINT DF_Products_IsActive DEFAULT (1),
    CONSTRAINT PK_Products PRIMARY KEY CLUSTERED (ProductID),
    CONSTRAINT UQ_Products_ProductCode UNIQUE (ProductCode),
    CONSTRAINT CK_Products_UnitPrice CHECK (UnitPrice >= 0)
);
GO

/* ---------- 3. Production work orders ---------- */

CREATE TABLE dbo.ProductionOrders
(
    OrderID         INT            NOT NULL,
    OrderNo         VARCHAR(15)    NOT NULL,
    ProductID       INT            NOT NULL,
    ProductionLine  NVARCHAR(20)   NOT NULL,
    OrderDate       DATE           NOT NULL,
    DueDate         DATE           NOT NULL,
    PlannedQty      INT            NOT NULL,
    Status          NVARCHAR(20)   NOT NULL,
    CompletedDate   DATE           NULL,
    Remarks         NVARCHAR(200)  NULL,
    CONSTRAINT PK_ProductionOrders PRIMARY KEY CLUSTERED (OrderID),
    CONSTRAINT UQ_ProductionOrders_OrderNo UNIQUE (OrderNo),
    CONSTRAINT FK_ProductionOrders_Products
        FOREIGN KEY (ProductID) REFERENCES dbo.Products (ProductID),
    CONSTRAINT CK_ProductionOrders_PlannedQty CHECK (PlannedQty > 0),
    CONSTRAINT CK_ProductionOrders_Status
        CHECK (Status IN (N'Planned', N'In Progress', N'On Hold', N'Completed', N'Cancelled')),
    CONSTRAINT CK_ProductionOrders_Dates CHECK (DueDate >= OrderDate)
);
GO

/* ---------- 4. Production output records (one row per output entry) ---------- */

CREATE TABLE dbo.ProductionRecords
(
    RecordID            INT            NOT NULL,
    OrderID             INT            NOT NULL,
    ProductionDateTime  DATETIME2(0)   NOT NULL,
    Shift               CHAR(1)        NOT NULL,
    OutputQty           INT            NOT NULL,
    ScrapQty            INT            NULL,
    OperatorName        NVARCHAR(50)   NOT NULL,
    CONSTRAINT PK_ProductionRecords PRIMARY KEY CLUSTERED (RecordID),
    CONSTRAINT FK_ProductionRecords_ProductionOrders
        FOREIGN KEY (OrderID) REFERENCES dbo.ProductionOrders (OrderID),
    CONSTRAINT CK_ProductionRecords_Shift CHECK (Shift IN ('A', 'B')),
    CONSTRAINT CK_ProductionRecords_OutputQty CHECK (OutputQty >= 0),
    CONSTRAINT CK_ProductionRecords_ScrapQty CHECK (ScrapQty >= 0)
);
GO

/* ---------- 5. Reset procedure: restore the original training data ----------
   Run this after an UPDATE demo or participant exercise:
       EXEC dbo.usp_ResetTrainingData;
   ------------------------------------------------------------------------- */

CREATE OR ALTER PROCEDURE dbo.usp_ResetTrainingData
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

        DELETE FROM dbo.ProductionRecords;
        DELETE FROM dbo.ProductionOrders;
        DELETE FROM dbo.Products;

        INSERT INTO dbo.Products
            (ProductID, ProductCode, ProductName, Category, UnitPrice, IsActive)
        VALUES
            (1, 'P001', N'Brake Pad Set BP-100', N'Brake', 45.00, 1),
            (2, 'P002', N'Brake Disc BD-280', N'Brake', 120.00, 1),
            (3, 'P003', N'Oil Filter OF-10', N'Filter', 18.50, 1),
            (4, 'P004', N'Air Filter AF-22', N'Filter', 25.00, 1),
            (5, 'P005', N'Wiper Blade WB-22', N'Accessories', 32.00, 1),
            (6, 'P006', N'Radiator Hose RH-05', N'Cooling', 28.00, 1),
            (7, 'P007', N'Cabin Filter CF-03', N'Filter', 22.00, 1),
            (8, 'P008', N'Door Seal DS-01', NULL, 15.00, 0);

        INSERT INTO dbo.ProductionOrders
            (OrderID, OrderNo, ProductID, ProductionLine, OrderDate, DueDate,
             PlannedQty, Status, CompletedDate, Remarks)
        VALUES
            (1, 'WO-2603-001', 1, N'Line A', '2026-03-02', '2026-03-06', 500, N'Completed', '2026-03-05', NULL),
            (2, 'WO-2603-002', 2, N'Line B', '2026-03-02', '2026-03-08', 300, N'Completed', '2026-03-09', N'One day late due to a press breakdown'),
            (3, 'WO-2603-003', 3, N'Line A', '2026-03-05', '2026-03-12', 1000, N'Completed', '2026-03-12', NULL),
            (4, 'WO-2603-004', 1, N'Line A', '2026-03-10', '2026-03-16', 400, N'Completed', '2026-03-14', NULL),
            (5, 'WO-2603-005', 4, N'Line C', '2026-03-11', '2026-03-20', 600, N'In Progress', NULL, NULL),
            (6, 'WO-2603-006', 5, N'Line C', '2026-03-16', '2026-03-23', 250, N'On Hold', NULL, N'Awaiting rubber supplies'),
            (7, 'WO-2603-007', 2, N'Line B', '2026-03-23', '2026-04-02', 350, N'In Progress', NULL, NULL),
            (8, 'WO-2603-008', 6, N'Line B', '2026-03-25', '2026-04-03', 200, N'Planned', NULL, NULL),
            (9, 'WO-2603-009', 3, N'Line A', '2026-03-27', '2026-04-06', 800, N'In Progress', NULL, NULL),
            (10, 'WO-2604-010', 4, N'Line C', '2026-04-01', '2026-04-08', 500, N'Planned', NULL, NULL),
            (11, 'WO-2602-011', 1, N'Line A', '2026-02-23', '2026-02-27', 450, N'Completed', '2026-02-26', NULL),
            (12, 'WO-2603-012', 5, N'Line C', '2026-03-18', '2026-03-25', 300, N'Cancelled', NULL, N'Cancelled by the customer');

        INSERT INTO dbo.ProductionRecords
            (RecordID, OrderID, ProductionDateTime, Shift, OutputQty, ScrapQty, OperatorName)
        VALUES
            (1, 1, '2026-03-03T08:00:00', 'A', 180, 4, N'Aziz'),
            (2, 1, '2026-03-04T08:00:00', 'A', 170, 6, N'Aziz'),
            (3, 1, '2026-03-05T20:00:00', 'B', 160, 5, N'Mei Ling'),
            (4, 2, '2026-03-04T08:00:00', 'A', 100, 2, N'Ravi'),
            (5, 2, '2026-03-06T20:00:00', 'B', 110, 3, N'Ravi'),
            (6, 2, '2026-03-09T08:00:00', 'A', 95, NULL, N'Siti'),
            (7, 3, '2026-03-06T08:00:00', 'A', 350, 10, N'Aziz'),
            (8, 3, '2026-03-09T08:00:00', 'A', 340, 8, N'Aziz'),
            (9, 3, '2026-03-11T20:00:00', 'B', 320, 12, N'Mei Ling'),
            (10, 4, '2026-03-11T08:00:00', 'A', 210, 3, N'Siti'),
            (11, 4, '2026-03-14T08:00:00', 'A', 195, 5, N'Siti'),
            (12, 5, '2026-03-12T08:00:00', 'A', 200, 6, N'Kumar'),
            (13, 5, '2026-03-17T20:00:00', 'B', 180, NULL, N'Kumar'),
            (14, 6, '2026-03-17T08:00:00', 'A', 60, 1, N'Farah'),
            (15, 7, '2026-03-24T08:00:00', 'A', 120, 2, N'Ravi'),
            (16, 7, '2026-03-30T20:00:00', 'B', 115, 4, N'Ravi'),
            (17, 9, '2026-03-31T22:00:00', 'B', 260, 7, N'Mei Ling'),
            (18, 9, '2026-04-01T00:00:00', 'B', 240, 6, N'Mei Ling'),
            (19, 9, '2026-04-02T08:00:00', 'A', 250, 5, N'Aziz'),
            (20, 11, '2026-02-24T08:00:00', 'A', 220, 5, N'Aziz'),
            (21, 11, '2026-02-26T08:00:00', 'A', 230, 4, N'Aziz');

    COMMIT TRANSACTION;

    PRINT 'Training data restored: 8 products, 12 work orders, and 21 output records.';
END;
GO

EXEC dbo.usp_ResetTrainingData;
GO

/* ---------- 6. Verify the setup ----------
   Expected results:
     TableName           RowCnt
     Products            8
     ProductionOrders    12
     ProductionRecords   21
   ----------------------------------------- */

SELECT N'Products' AS TableName, COUNT(*) AS RowCnt FROM dbo.Products
UNION ALL
SELECT N'ProductionOrders', COUNT(*) FROM dbo.ProductionOrders
UNION ALL
SELECT N'ProductionRecords', COUNT(*) FROM dbo.ProductionRecords;

/* Cross-check. Expected result: 21 | 4105 | 98 */
SELECT COUNT(*)        AS TotalRecords,
       SUM(OutputQty)  AS TotalOutput,
       SUM(ScrapQty)   AS TotalScrap
FROM dbo.ProductionRecords;

PRINT 'ProductionTraining setup complete.';
GO