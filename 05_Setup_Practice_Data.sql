/* =====================================================================
   05_Setup_Practice_Data.sql
   Course  : SQL and Relational Database Fundamentals (1 day)
   Purpose : Create and populate the ProductionPractice database used for
             participant practice questions (Modules 3 - 7)
   Company : Minuman Segar Sdn Bhd (fictional beverage bottling plant)
   Platform: Microsoft SQL Server 2025 Express + SSMS
   ---------------------------------------------------------------------
   HOW TO USE
   1. Connect to the training instance (e.g. localhost\SQLEXPRESS).
   2. Open this script and press F5 with NO lines selected.
   3. The Messages tab must end with "Practice setup complete".

   RESET: Rerun this script at any time to restore the original data,
   for example after the UPDATE questions in Module 6.
   This script does NOT touch the ProductionTraining database.
   © 2026 Mufasyah Consultant | mufasyahcons@gmail.com
   ===================================================================== */

SET NOCOUNT ON;
GO

USE master;
GO
IF DB_ID(N'ProductionPractice') IS NULL
BEGIN
    CREATE DATABASE ProductionPractice;
    PRINT N'Database ProductionPractice created.';
END
ELSE
    PRINT N'Database ProductionPractice already exists - tables will be recreated.';
GO

USE ProductionPractice;
GO

DROP TABLE IF EXISTS dbo.DowntimeLog;
DROP TABLE IF EXISTS dbo.ShiftOutput;
DROP TABLE IF EXISTS dbo.Products;
DROP TABLE IF EXISTS dbo.Machines;
GO

-- One row = one filling machine (one machine per production line)
CREATE TABLE dbo.Machines
(
    MachineID            INT           NOT NULL CONSTRAINT PK_Machines PRIMARY KEY,
    MachineCode          VARCHAR(10)   NOT NULL CONSTRAINT UQ_Machines_MachineCode UNIQUE,
    MachineName          NVARCHAR(50)  NOT NULL,
    LineName             NVARCHAR(20)  NOT NULL,
    InstallDate          DATE          NOT NULL,
    Status               VARCHAR(20)   NOT NULL,   -- Active / Under Repair
    RatedCapacityPerHour INT           NOT NULL,   -- bottles per hour
    CONSTRAINT CK_Machines_Status CHECK (Status IN ('Active', 'Under Repair'))
);
GO

-- One row = one product (SKU)
CREATE TABLE dbo.Products
(
    ProductID    INT            NOT NULL CONSTRAINT PK_Products PRIMARY KEY,
    SKU          VARCHAR(20)    NOT NULL CONSTRAINT UQ_Products_SKU UNIQUE,
    ProductName  NVARCHAR(100)  NOT NULL,
    Category     NVARCHAR(20)   NOT NULL,   -- Juice / Water / Tea
    PackSizeML   INT            NOT NULL,
    UnitPrice    DECIMAL(6,2)   NULL        -- RM per bottle; NULL = price not set yet
);
GO

-- One row = output of ONE machine, for ONE product, on ONE date and ONE shift
CREATE TABLE dbo.ShiftOutput
(
    OutputID    INT            NOT NULL CONSTRAINT PK_ShiftOutput PRIMARY KEY,
    OutputDate  DATE           NOT NULL,
    Shift       VARCHAR(10)    NOT NULL,   -- Morning / Afternoon / Night
    MachineID   INT            NOT NULL,
    ProductID   INT            NOT NULL,
    Supervisor  NVARCHAR(50)   NOT NULL,
    TargetQty   INT            NOT NULL,   -- bottles planned for the shift
    ActualQty   INT            NOT NULL,   -- good bottles produced
    RejectQty   INT            NOT NULL,   -- bottles rejected
    Remarks     NVARCHAR(200)  NULL,
    CONSTRAINT FK_ShiftOutput_Machines FOREIGN KEY (MachineID) REFERENCES dbo.Machines (MachineID),
    CONSTRAINT FK_ShiftOutput_Products FOREIGN KEY (ProductID) REFERENCES dbo.Products (ProductID),
    CONSTRAINT CK_ShiftOutput_Shift CHECK (Shift IN ('Morning', 'Afternoon', 'Night'))
);
GO

-- One row = one machine stoppage. EndTime NULL = still stopped
-- DATETIME values are inserted as 'YYYY-MM-DDThh:mm:ss' (ISO 8601), which
-- SQL Server reads the same way whatever the login language is.
CREATE TABLE dbo.DowntimeLog
(
    DowntimeID  INT            NOT NULL CONSTRAINT PK_DowntimeLog PRIMARY KEY,
    MachineID   INT            NOT NULL,
    StartTime   DATETIME       NOT NULL,
    EndTime     DATETIME       NULL,
    Reason      NVARCHAR(100)  NOT NULL,
    Category    VARCHAR(20)    NOT NULL,   -- Breakdown / Changeover / Maintenance / Material Shortage
    ReportedBy  NVARCHAR(50)   NOT NULL,
    CONSTRAINT FK_DowntimeLog_Machines FOREIGN KEY (MachineID) REFERENCES dbo.Machines (MachineID)
);
GO

INSERT INTO dbo.Machines
    (MachineID, MachineCode, MachineName, LineName, InstallDate, Status, RatedCapacityPerHour)
VALUES
    (1, 'FL-01', N'Filler 1', N'Line A', '2019-03-15', 'Active', 1200),
    (2, 'FL-02', N'Filler 2', N'Line B', '2020-07-01', 'Active', 1000),
    (3, 'FL-03', N'Filler 3', N'Line C', '2018-11-20', 'Under Repair', 900),
    (4, 'FL-04', N'Filler 4', N'Line D', '2022-05-09', 'Active', 1100),
    (5, 'FL-05', N'Filler 5', N'Line E', '2026-11-10', 'Active', 1300);
GO

INSERT INTO dbo.Products
    (ProductID, SKU, ProductName, Category, PackSizeML, UnitPrice)
VALUES
    (1, 'JC-ORG-350', N'Orange Juice 350ml', N'Juice', 350, 2.50),
    (2, 'JC-APL-350', N'Apple Juice 350ml', N'Juice', 350, 2.50),
    (3, 'WT-MIN-500', N'Mineral Water 500ml', N'Water', 500, 1.20),
    (4, 'WT-MIN-1500', N'Mineral Water 1.5L', N'Water', 1500, 2.20),
    (5, 'TE-LMN-450', N'Lemon Tea 450ml', N'Tea', 450, 2.80),
    (6, 'TE-GRN-450', N'Green Tea 450ml', N'Tea', 450, NULL),
    (7, 'JC-MNG-350', N'Mango Juice 350ml', N'Juice', 350, 2.70);
GO

INSERT INTO dbo.ShiftOutput
    (OutputID, OutputDate, Shift, MachineID, ProductID, Supervisor, TargetQty, ActualQty, RejectQty, Remarks)
VALUES
    ( 1, '2026-11-02', 'Morning'  , 1, 1, N'Hafiz', 9000, 9050, 19, N'Startup delay'),
    ( 2, '2026-11-02', 'Afternoon', 2, 3, N'Mei Ling', 8000, 5900, 40, NULL),
    ( 3, '2026-11-02', 'Night'    , 3, 5, N'Ravi', 6000, 5200, 42, NULL),
    ( 4, '2026-11-03', 'Morning'  , 1, 2, N'Hafiz', 9000, 8900, 44, NULL),
    ( 5, '2026-11-03', 'Morning'  , 4, 6, N'Hafiz', 7000, 6200, 25, NULL),
    ( 6, '2026-11-03', 'Afternoon', 2, 4, N'Mei Ling', 5000, 5150, 11, NULL),
    ( 7, '2026-11-04', 'Morning'  , 1, 1, N'Hafiz', 9000, 8500, 27, NULL),
    ( 8, '2026-11-04', 'Afternoon', 2, 3, N'Mei Ling', 8000, 6300, 29, N'Label jam'),
    ( 9, '2026-11-04', 'Night'    , 3, 5, N'Ravi', 6000, 4000, 45, NULL),
    (10, '2026-11-05', 'Morning'  , 1, 2, N'Hafiz', 9000, 9150, 10, NULL),
    (11, '2026-11-05', 'Morning'  , 4, 5, N'Hafiz', 7000, 6500, 6, NULL),
    (12, '2026-11-05', 'Afternoon', 2, 4, N'Mei Ling', 5000, 4500, 23, NULL),
    (13, '2026-11-06', 'Morning'  , 1, 1, N'Hafiz', 9000, 7300, 28, NULL),
    (14, '2026-11-06', 'Afternoon', 2, 3, N'Mei Ling', 8000, 7800, 30, NULL),
    (15, '2026-11-06', 'Night'    , 3, 5, N'Ravi', 6000, 4000, 36, NULL),
    (16, '2026-11-09', 'Morning'  , 1, 2, N'Hafiz', 9000, 7200, 37, N'Short of caps'),
    (17, '2026-11-09', 'Afternoon', 2, 4, N'Mei Ling', 5000, 2500, 43, N'Feeder breakdown'),
    (18, '2026-11-10', 'Morning'  , 1, 1, N'Hafiz', 9000, 7200, 38, NULL),
    (19, '2026-11-10', 'Morning'  , 4, 6, N'Hafiz', 7000, 5100, 37, NULL),
    (20, '2026-11-10', 'Afternoon', 2, 3, N'Mei Ling', 8000, 7300, 41, NULL),
    (21, '2026-11-11', 'Morning'  , 1, 2, N'Hafiz', 9000, 8900, 41, NULL),
    (22, '2026-11-11', 'Afternoon', 2, 4, N'Mei Ling', 5000, 4700, 8, NULL),
    (23, '2026-11-12', 'Morning'  , 1, 1, N'Hafiz', 9000, 7000, 11, N'Low syrup stock'),
    (24, '2026-11-12', 'Morning'  , 4, 5, N'Hafiz', 7000, 7100, 12, NULL),
    (25, '2026-11-12', 'Afternoon', 2, 3, N'Mei Ling', 8000, 7300, 35, NULL),
    (26, '2026-11-13', 'Morning'  , 1, 2, N'Hafiz', 9000, 8200, 35, NULL),
    (27, '2026-11-13', 'Afternoon', 2, 4, N'Mei Ling', 5000, 4500, 40, NULL);
GO

INSERT INTO dbo.DowntimeLog
    (DowntimeID, MachineID, StartTime, EndTime, Reason, Category, ReportedBy)
VALUES
    ( 1, 1, '2026-11-02T08:10:00', '2026-11-02T08:40:00', N'Startup checks overran', 'Changeover', N'Hafiz'),
    ( 2, 2, '2026-11-03T15:20:00', '2026-11-03T16:05:00', N'Bottle feeder jam', 'Breakdown', N'Mei Ling'),
    ( 3, 3, '2026-11-04T23:00:00', '2026-11-04T23:50:00', N'Cap supply ran out', 'Material Shortage', N'Ravi'),
    ( 4, 1, '2026-11-05T10:00:00', '2026-11-05T10:25:00', N'Flavour changeover', 'Changeover', N'Hafiz'),
    ( 5, 3, '2026-11-06T22:30:00', NULL, N'Main pump failure', 'Breakdown', N'Ravi'),
    ( 6, 4, '2026-11-10T09:15:00', '2026-11-10T10:45:00', N'Planned lubrication', 'Maintenance', N'Hafiz'),
    ( 7, 2, '2026-11-10T14:00:00', '2026-11-10T14:20:00', N'Label roll change', 'Changeover', N'Mei Ling'),
    ( 8, 1, '2026-11-11T07:45:00', '2026-11-11T09:05:00', N'Conveyor belt slip', 'Breakdown', N'Hafiz'),
    ( 9, 2, '2026-11-12T16:30:00', '2026-11-12T17:10:00', N'Shrink-wrap film shortage', 'Material Shortage', N'Mei Ling'),
    (10, 4, '2026-11-12T11:00:00', '2026-11-12T11:35:00', N'Sensor fault', 'Breakdown', N'Hafiz'),
    (11, 1, '2026-11-13T09:30:00', '2026-11-13T09:50:00', N'Filler nozzle cleaning', 'Maintenance', N'Hafiz'),
    (12, 2, '2026-11-13T14:30:00', '2026-11-13T15:30:00', N'Carton erector jam', 'Breakdown', N'Mei Ling');
GO

SELECT 'Machines'    AS TableName, COUNT(*) AS TotalRows FROM dbo.Machines
UNION ALL
SELECT 'Products',                COUNT(*)             FROM dbo.Products
UNION ALL
SELECT 'ShiftOutput',             COUNT(*)             FROM dbo.ShiftOutput
UNION ALL
SELECT 'DowntimeLog',             COUNT(*)             FROM dbo.DowntimeLog;
-- Expected: Machines 5, Products 7, ShiftOutput 27, DowntimeLog 12

PRINT N'Practice setup complete. The ProductionPractice database is ready to use.';
GO
