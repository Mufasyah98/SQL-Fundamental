# SQL and Relational Database Fundamentals

Hands-on training material for a **one-day SQL Fundamentals course for complete beginners**, built around a fictional plastics manufacturer, **Kilang Plastik Maju Sdn Bhd**. Every example and exercise uses production data: products, production orders, output quantities, rejects, shifts and dates.

| | |
|---|---|
| **Audience** | Production, manufacturing, operations and administrative staff with no SQL experience |
| **Duration** | 1 day (8.30 am – 5.00 pm) |
| **Platform** | Microsoft SQL Server 2025 Express + SQL Server Management Studio (SSMS) |
| **Training database** | `ProductionTraining` |
| **Demo connection** | `localhost\SQLEXPRESS` with Windows Authentication |

---

## Repository contents

| File | Purpose |
|---|---|
| `01_Setup_ProductionTraining.sql` | Creates and populates the `ProductionTraining` database. Safe to rerun: it drops and recreates the training tables, so sample data is never duplicated. |
| `README.md` | This guide |

The full training pack also includes participant notes (`.docx`), an exercise script (`02_Latihan_Peserta.sql`), a trainer answer script (`03_Jawapan_Trainer.sql`) and a reset script for the UPDATE exercises (`04_Reset_Latihan_Update.sql`). These are distributed by the trainer.

---

## Quick start

### 1. Install the software
- **SQL Server 2025 Express** (free) – [SQL Server downloads](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
- **SQL Server Management Studio 22** – [Install SSMS](https://learn.microsoft.com/en-us/ssms/install/install)

### 2. Connect in SSMS
1. Open SSMS. The **Connect to Server** window appears.
2. **Server type:** Database Engine
3. **Server name:** `localhost\SQLEXPRESS`
4. **Authentication:** Windows Authentication
5. If you see a certificate error, tick **Trust server certificate** (local training instance only).
6. Click **Connect**.

> `localhost` means *your own computer*. The real server name depends on the training setup; use the name your trainer gives you.

### 3. Run the setup script
1. **File → Open → File...** and select `01_Setup_ProductionTraining.sql`.
2. Make sure **no text is highlighted**, then press **F5**.
3. Check the **Messages** tab ends with *Setup complete*.
4. The last result grid should show:

| TableName | TotalRows |
|---|---|
| Products | 8 |
| ProductionOrders | 12 |
| ProductionRecords | 16 |

### 4. Confirm you are in the right database
```sql
SELECT DB_NAME() AS CurrentDatabase;   -- expect: ProductionTraining
```

---

## The training database

```
dbo.Products  1 ──< many  dbo.ProductionOrders  1 ──< many  dbo.ProductionRecords
 (ProductID)                (OrderID, ProductID)              (RecordID, OrderID)
```

| Table | Rows | One row means | Primary key | Foreign key |
|---|---|---|---|---|
| `dbo.Products` | 8 | One product | `ProductID` | – |
| `dbo.ProductionOrders` | 12 | One production order for one product | `OrderID` | `ProductID` → `Products` |
| `dbo.ProductionRecords` | 16 | Output for one order, on one date, in one shift | `RecordID` | `OrderID` → `ProductionOrders` |

**Built-in scenarios for practice**
- Products with no orders: P007, P008 (to practise `LEFT JOIN`)
- Orders with no output yet: PO-2026-006, -008, -009, -010, -012
- Orders with several output records (to see repeated rows after a `JOIN`)
- Realistic `NULL` values in `StandardCost`, `CompletedDate`, `Remarks` and `DowntimeMinutes`
- Fixed dates (30 Sep – 16 Oct 2026), so every participant gets identical results

---

## Course outline

| Time | Module | Topics |
|---|---|---|
| 8.30 – 9.00 am | – | Participant attendance; check SSMS and run the setup script |
| 9.00 – 10.30 am | **1. Introduction to Databases and SQL** | Databases, relational databases, tables, rows, columns, records and fields; primary and foreign keys; types of table relationships; what SQL is used for; database → table → query → result |
| | **2. Getting Started with SSMS** | SQL Server and SSMS; connecting; Object Explorer; table structures, columns and data types; query window; running a simple statement |
| 10.30 – 10.45 am | | Morning break |
| 10.45 am – 12.30 pm | **3. Basic SQL Queries** | `SELECT`, specific vs all columns, SQL syntax, aliases, `WHERE`, comparison operators, filtering text, numbers and dates, `AND` / `OR`, `NULL` |
| 12.30 – 1.30 pm | | Lunch |
| 1.30 – 3.30 pm | **4. Working with Related Tables and JOINs** | Why databases use multiple tables, `INNER JOIN`, `LEFT JOIN`, matching records, common JOIN mistakes |
| | **5. Sorting, Filtering and Summarising Data** | `ORDER BY`, `DISTINCT`, `COUNT`, `SUM`, `AVG`, `MIN`, `MAX`, `GROUP BY`, trends and totals |
| 3.30 – 3.45 pm | | Afternoon break |
| 3.45 – 5.00 pm | **6. Working with SQL Functions** | Number, text and date functions; combining functions for reporting; date and number pitfalls; `UPDATE`, batch updates, transactions and best practices |
| | **7. Exporting Query Results & Practical Mini-Project / Q&A** | Validating and preparing results, export formats, CSV to Excel, guided mini project, review of key concepts |

---

## Sample queries

**Open orders, earliest due date first**
```sql
SELECT OrderNo, LineName, DueDate, PlannedQty
FROM dbo.ProductionOrders
WHERE Status = 'Open'
ORDER BY DueDate ASC;
```

**Total output by product**
```sql
SELECT p.ProductCode,
       p.ProductName,
       SUM(r.GoodQty)   AS TotalGoodQty,
       SUM(r.RejectQty) AS TotalRejectQty
FROM dbo.ProductionRecords AS r
INNER JOIN dbo.ProductionOrders AS o ON r.OrderID   = o.OrderID
INNER JOIN dbo.Products         AS p ON o.ProductID = p.ProductID
GROUP BY p.ProductCode, p.ProductName
ORDER BY TotalGoodQty DESC;
```

**Safe batch update inside a transaction**
```sql
BEGIN TRANSACTION;

UPDATE dbo.ProductionOrders
SET    Status = 'On Hold'
WHERE  Status = 'Open'
  AND  DueDate <= '2026-10-24';     -- (3 rows affected)

SELECT OrderNo, Status FROM dbo.ProductionOrders WHERE Status = 'On Hold';

ROLLBACK TRANSACTION;               -- undo; use COMMIT TRANSACTION to keep
```

---

## Common issues

| Problem | Fix |
|---|---|
| `Invalid object name 'dbo.Products'` | The query tab is using `master`. Pick **ProductionTraining** in the database dropdown or run `USE ProductionTraining;` |
| `ProductionTraining` not in Object Explorer | Check the instance with `SELECT @@SERVERNAME;`, reconnect to `localhost\SQLEXPRESS`, then right-click **Databases → Refresh** |
| *The certificate chain was issued by an authority that is not trusted* | Tick **Trust server certificate** in the Connect to Server window (local training instance only) |
| CSV export has no column headers | **Tools → Options → Query Results → SQL Server → Results to Grid →** tick *Include column headers when copying or saving the results*, then open a new query tab |
| Data changed by mistake | Rerun `01_Setup_ProductionTraining.sql` to rebuild the database |

---

## Official references (Microsoft Learn)

**Software and setup**
- [SQL Server downloads (including 2025 Express)](https://www.microsoft.com/en-us/sql-server/sql-server-downloads)
- [Editions and supported features of SQL Server 2025](https://learn.microsoft.com/en-us/sql/sql-server/editions-and-components-of-sql-server-2025)
- [What is SQL Server Management Studio (SSMS)?](https://learn.microsoft.com/en-us/ssms/sql-server-management-studio-ssms)
- [Install SQL Server Management Studio](https://learn.microsoft.com/en-us/ssms/install/install)
- [Connect and query with SSMS](https://learn.microsoft.com/en-us/ssms/quickstarts/ssms-connect)
- [Troubleshoot "The certificate chain was issued by an authority that is not trusted"](https://learn.microsoft.com/en-us/troubleshoot/sql/database-engine/connect/certificate-chain-not-trusted)

**T-SQL by module**
| Module | Reference |
|---|---|
| 3 | [SELECT](https://learn.microsoft.com/en-us/sql/t-sql/queries/select-transact-sql) · [SELECT clause](https://learn.microsoft.com/en-us/sql/t-sql/queries/select-clause-transact-sql) |
| 4 | [FROM clause plus JOIN](https://learn.microsoft.com/en-us/sql/t-sql/queries/from-transact-sql) · [Joins (SQL Server)](https://learn.microsoft.com/en-us/sql/relational-databases/performance/joins) |
| 5 | [GROUP BY](https://learn.microsoft.com/en-us/sql/t-sql/queries/select-group-by-transact-sql) · [Aggregate functions](https://learn.microsoft.com/en-us/sql/t-sql/functions/aggregate-functions-transact-sql) · [SUM](https://learn.microsoft.com/en-us/sql/t-sql/functions/sum-transact-sql) |
| 6 | [SQL database functions](https://learn.microsoft.com/en-us/sql/t-sql/functions/functions) · [Date and time functions](https://learn.microsoft.com/en-us/sql/t-sql/functions/date-and-time-data-types-and-functions-transact-sql) · [CAST and CONVERT](https://learn.microsoft.com/en-us/sql/t-sql/functions/cast-and-convert-transact-sql) · [date data type](https://learn.microsoft.com/en-us/sql/t-sql/data-types/date-transact-sql) · [UPDATE](https://learn.microsoft.com/en-us/sql/t-sql/queries/update-transact-sql) · [BEGIN TRANSACTION](https://learn.microsoft.com/en-us/sql/t-sql/language-elements/begin-transaction-transact-sql) |

---

## Trainer

**Fakhrul Syahmi** – Data Consultant & HRD Corp Certified Trainer
Mufasyah Consultant · mufasyahcons@gmail.com

© 2026 Mufasyah Consultant. Training data is fictional; any resemblance to real companies or people is coincidental.
