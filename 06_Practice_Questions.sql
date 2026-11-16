/* =====================================================================
   06_Practice_Questions.sql
   Course  : SQL and Relational Database Fundamentals (1 day)
   Database: ProductionPractice  |  Server: localhost\SQLEXPRESS
   Practice questions for Modules 3 - 7 (participants)
   HOW TO USE
   - Run 05_Setup_Practice_Data.sql first. Rerun it any time to reset.
   - Write your query under each question.
   - HIGHLIGHT your query, then press F5. Nothing highlighted = every
     query in this tab runs.
   - Compare your result with 'Expected'.
   © 2026 Mufasyah Consultant | mufasyahcons@gmail.com
   ===================================================================== */

/* ---------------------------------------------------------------------
   THE PRACTICE DATABASE: ProductionPractice  (Minuman Segar Sdn Bhd)
   dbo.Machines     (5)  1 row = one filling machine
                         MachineID PK, MachineCode, MachineName, LineName,
                         InstallDate, Status, RatedCapacityPerHour
   dbo.Products     (7)  1 row = one product (SKU)
                         ProductID PK, SKU, ProductName, Category,
                         PackSizeML, UnitPrice (NULL = not set)
   dbo.ShiftOutput  (27) 1 row = one machine, one product, one date, one shift
                         OutputID PK, OutputDate, Shift, MachineID FK,
                         ProductID FK, Supervisor, TargetQty, ActualQty,
                         RejectQty, Remarks (NULL = none)
   dbo.DowntimeLog  (12) 1 row = one machine stoppage
                         DowntimeID PK, MachineID FK, StartTime (DATETIME),
                         EndTime (DATETIME, NULL = still stopped), Reason,
                         Category, ReportedBy
   Machines 1 --< many ShiftOutput >-- 1 Products
   Machines 1 --< many DowntimeLog
   Period: 2 - 13 November 2026 (weekdays only)
   --------------------------------------------------------------------- */

USE ProductionPractice;
GO

SELECT DB_NAME() AS CurrentDatabase;   -- must show: ProductionPractice

/* ====================================================================
   MODULE 3: Basic SQL Queries
   ==================================================================== */

-- Question P3.1
-- Show every column and every row in the Machines table.
-- Expected : 5 rows
-- Hint     : SELECT * FROM ...
-- Your query:




-- Question P3.2
-- List each product's SKU, name and pack size. Use the column headings
-- [SKU], [Product] and [Pack Size (ml)].
-- Expected : 7 rows
-- Hint     : Use AS [heading] for each column
-- Your query:




-- Question P3.3
-- Which products are in the Tea category?
-- Expected : 2 rows: Lemon Tea, Green Tea
-- Hint     : Text values go in single quotes
-- Your query:




-- Question P3.4
-- Which products sell for RM2.50 or more?
-- Expected : 4 rows
-- Hint     : Numbers have no quotes; use >=
-- Your query:




-- Question P3.5
-- Show all shift output recorded on 5 November 2026.
-- Expected : 3 rows
-- Hint     : Dates: 'YYYY-MM-DD'
-- Your query:




-- Question P3.6
-- Show Morning shift output from 9 to 11 November 2026 (both dates
-- included).
-- Expected : 4 rows
-- Hint     : Combine the date range and the shift with AND
-- Your query:




-- Question P3.7
-- Which shifts produced fewer bottles than their target?
-- Expected : 23 rows
-- Hint     : You can compare two columns: ActualQty < TargetQty
-- Your query:




-- Question P3.8
-- Find all juice products by name (any product whose name contains 'Juice').
-- Expected : 3 rows
-- Hint     : LIKE with % on both sides
-- Your query:




-- Question P3.9
-- List the Active machines on Line A or Line B.
-- Expected : 2 rows: FL-01, FL-02
-- Hint     : Put the OR inside brackets
-- Your query:




-- Question P3.10
-- Which products do not have a price yet?
-- Expected : 1 row: Green Tea 450ml
-- Hint     : IS NULL, not = NULL
-- Your query:




-- Question P3.11
-- Which machine stoppages are still ongoing (no end time recorded)?
-- Expected : 1 row: DowntimeID 5
-- Hint     : EndTime IS NULL
-- Your query:




-- Question P3.12
-- [Challenge] Which shifts have a remark AND rejected more than 30 bottles?
-- Expected : 2 rows
-- Hint     : IS NOT NULL combined with >
-- Your query:




/* ====================================================================
   MODULE 4: Working with Related Tables and JOINs
   ==================================================================== */

-- Question P4.1
-- Show the output for 3 November 2026 with the machine code and product name
-- instead of IDs.
-- Expected : 3 rows
-- Hint     : Join ShiftOutput to Machines and to Products
-- Your query:




-- Question P4.2
-- Which machine has not recorded any output yet?
-- Expected : 1 row: FL-05
-- Hint     : LEFT JOIN from Machines, then WHERE s.OutputID IS NULL
-- Your query:




-- Question P4.3
-- Which product has never been produced?
-- Expected : 1 row: Mango Juice 350ml
-- Hint     : Same pattern as P4.2, starting FROM dbo.Products
-- Your query:




-- Question P4.4
-- List all Breakdown stoppages with the machine code and line name.
-- Expected : 5 rows
-- Hint     : Join DowntimeLog to Machines
-- Your query:




-- Question P4.5
-- Show all Juice output on Line A where more than 35 bottles were rejected.
-- Expected : 4 rows
-- Hint     : Three tables; filter on p.Category, m.LineName and s.RejectQty
-- Your query:




-- Question P4.6
-- List EVERY machine with its stoppages, including machines that never
-- stopped.
-- Expected : 13 rows (FL-05 shows NULL)
-- Hint     : LEFT JOIN from Machines to DowntimeLog
-- Your query:




-- Question P4.7
-- [Spot the mistake] A colleague wrote this query to show product names for
-- FL-04 output. Run it, explain why the names are wrong, then fix it.
--     SELECT s.OutputID, p.ProductName
--     FROM dbo.ShiftOutput AS s
--     INNER JOIN dbo.Products AS p ON s.MachineID = p.ProductID
--     WHERE s.MachineID = 4;
-- Expected : Wrong: 4 rows all 'Mineral Water 1.5L'. Correct: Green Tea / Lemon Tea
-- Hint     : The JOIN must use the matching key: s.ProductID = p.ProductID
-- Step 1 - Run the colleague's query, then explain what went wrong:
--

-- Step 2 - Your corrected query:



/* ====================================================================
   MODULE 5: Sorting, Filtering and Summarising Data
   ==================================================================== */

-- Question P5.1
-- List products from the most expensive to the cheapest.
-- Expected : 7 rows; Lemon Tea first, Green Tea (NULL) last
-- Hint     : ORDER BY ... DESC
-- Your query:




-- Question P5.2
-- Which supervisors have recorded output?
-- Expected : 3 rows
-- Hint     : SELECT DISTINCT
-- Your query:




-- Question P5.3
-- For the whole period, show the number of shifts, total target, total
-- actual and total rejects.
-- Expected : 1 row: 27 shifts, 201,000 target, 175,450 actual
-- Hint     : COUNT(*) and SUM() without GROUP BY
-- Your query:




-- Question P5.4
-- Show total actual output and total rejects for each machine, highest
-- output first.
-- Expected : 4 rows; FL-01 first
-- Hint     : GROUP BY machine code after joining Machines
-- Your query:




-- Question P5.5
-- How many shifts were run, and how many bottles produced, in each shift
-- (Morning, Afternoon, Night)?
-- Expected : 3 rows
-- Hint     : GROUP BY Shift
-- Your query:




-- Question P5.6
-- Show the daily output trend for week 1 (2 to 6 November 2026).
-- Expected : 5 rows
-- Hint     : Filter the dates, GROUP BY OutputDate, ORDER BY OutputDate
-- Your query:




-- Question P5.7
-- Show total output by product category.
-- Expected : 3 rows; Juice highest
-- Hint     : Join Products, GROUP BY p.Category
-- Your query:




-- Question P5.8
-- How many stoppages were there in each downtime category?
-- Expected : 4 rows; Breakdown 5
-- Hint     : GROUP BY Category on DowntimeLog
-- Your query:




-- Question P5.9
-- Find the smallest and largest ActualQty for each machine, plus the first
-- and last production date.
-- Expected : 4 rows
-- Hint     : MIN() and MAX() work on numbers and dates
-- Your query:




-- Question P5.10
-- [Challenge] Count the shifts for EVERY machine, including machines with
-- zero shifts.
-- Expected : 5 rows; FL-05 = 0
-- Hint     : LEFT JOIN + COUNT(s.OutputID), not COUNT(*)
-- Your query:




/* ====================================================================
   MODULE 6: Working with SQL Functions and Updating Data
   ==================================================================== */

-- Question P6.1
-- For FL-01 (MachineID 1), show each shift's achievement % (ActualQty /
-- TargetQty x 100), rounded to 1 decimal place, for week 1 (2 to 6 Nov).
-- Expected : 5 rows; 2 Nov = 100.6
-- Hint     : Multiply by 100.0; ROUND then CAST AS DECIMAL(5,1)
-- Your query:




-- Question P6.2
-- Show the reject rate % for each product over the whole period, 2 decimal
-- places, highest first.
-- Expected : 6 rows
-- Hint     : SUM(RejectQty) * 100.0 / (SUM(ActualQty) + SUM(RejectQty))
-- Your query:




-- Question P6.3
-- Create a product label in the form 'SKU - PRODUCT NAME IN CAPITALS', and
-- show the length of each SKU.
-- Expected : 7 rows
-- Hint     : CONCAT(), UPPER(), LEN()
-- Your query:




-- Question P6.4
-- How many minutes did each completed stoppage last?
-- Expected : 11 rows; longest 90 minutes
-- Hint     : DATEDIFF(MINUTE, StartTime, EndTime); exclude EndTime IS NULL
-- Your query:




-- Question P6.5
-- How many years has each machine been installed, as at 16 November 2026?
-- Also show the install date as dd/mm/yyyy.
-- Expected : 5 rows; FL-03 = 8 years
-- Hint     : DATEDIFF(YEAR, InstallDate, '2026-11-16'); CONVERT(VARCHAR(10), InstallDate, 103)
-- Your query:




-- Question P6.6
-- [Date trap] Count the stoppages that started on 13 November 2026. First
-- try StartTime >= '2026-11-13' AND StartTime <= '2026-11-13', then fix it.
-- Expected : Wrong version: 0. Correct version: 2
-- Hint     : StartTime is DATETIME: use >= '2026-11-13' AND < '2026-11-14'
-- Step 1 - Wrong version:


-- Step 2 - Corrected version:



-- Question P6.7
-- For the ongoing stoppage, show the downtime in hours as at 13 Nov 2026
-- 6.00 pm, and replace the missing end time with that cut-off.
-- Expected : 1 row: 164 hours
-- Hint     : ISNULL(EndTime, '2026-11-13T18:00:00') inside DATEDIFF(HOUR, …)
-- Your query:




-- Question P6.8
-- UPDATE one record: Finance has set the price of Green Tea 450ml at RM2.80.
-- Update it using SELECT → UPDATE → SELECT.
-- Expected : (1 row affected); UnitPrice = 2.80
-- Hint     : WHERE SKU = 'TE-GRN-450'
-- Step 1 - SELECT: check the target:


-- Step 2 - UPDATE:


-- Step 3 - SELECT: verify:



-- Question P6.9
-- UPDATE two related records: Filler 3 (FL-03) was repaired on 12 Nov 2026
-- at 4.00 pm. Close its open stoppage and set the machine back to Active.
-- Expected : (1 row affected) twice; FL-03 Active; DowntimeID 5 EndTime 2026-11-12 16:00
-- Hint     : Two UPDATE statements: DowntimeLog first, then Machines
-- Step 1 - SELECT: check both records:


-- Step 2 - UPDATE the stoppage:


-- Step 3 - UPDATE the machine:


-- Step 4 - SELECT: verify both:



-- Question P6.10
-- BATCH UPDATE: Add the remark 'Below 90% target' to every shift that
-- produced less than 90% of its target and has no remark yet. Check first,
-- update, then confirm the row count with @@ROWCOUNT.
-- Expected : Step 1: 8 rows; (8 rows affected); RowsUpdated = 8
-- Hint     : WHERE ActualQty < TargetQty * 0.9 AND Remarks IS NULL
-- Step 1 - SELECT: check the targets (note the row count):


-- Step 2 - UPDATE and confirm with @@ROWCOUNT:


-- Step 3 - SELECT: verify:



-- Question P6.11
-- BATCH UPDATE in a transaction: Management is considering raising all Juice
-- prices by RM0.20. Apply the change inside a transaction, check the new
-- prices, then ROLLBACK.
-- Expected : (3 rows affected); after ROLLBACK prices return to 2.50 / 2.50 / 2.70
-- Hint     : BEGIN TRANSACTION ... ROLLBACK TRANSACTION; finish with SELECT @@TRANCOUNT
-- Step 1 - BEGIN TRANSACTION + UPDATE:


-- Step 2 - SELECT: check inside the transaction:


-- Step 3 - ROLLBACK:


-- Step 4 - SELECT: prices back to original:



-- >>> Before Module 7: rerun 05_Setup_Practice_Data.sql to restore the original data. <<<
--     (P6.8 - P6.10 changed prices, FL-03 status, stoppage 5 and shift remarks.)

/* ====================================================================
   MODULE 7: Exporting Query Results and Practical Application
   ==================================================================== */

-- Question P7.1
-- [Validate] Before reporting week 2 (9 to 13 Nov), cross-check: how many
-- shifts were run and how many bottles were produced?
-- Expected : 1 row: 12 shifts, 77,000 bottles
-- Hint     : Use >= '2026-11-09' AND < '2026-11-14'
-- Your query:




-- Question P7.2
-- [Prepare & export] Build a report-ready daily output list for week 2: date
-- as dd/mm/yyyy, machine code, product, target, actual and achievement %.
-- Sort by date and machine. Save it as Week2_Output.csv and open it in
-- Excel.
-- Expected : 12 rows + header row in the CSV
-- Hint     : Clear aliases, CONVERT(…, 103) for display, ORDER BY the real date column
-- Your query:




-- Question P7.3
-- [Mini project A] Machine performance report, 2 to 13 Nov 2026. One row per
-- machine: MachineCode, LineName, Shifts, TotalTarget, TotalActual,
-- AchievementPct (1 dp), RejectRatePct (2 dp). Highest achievement first.
-- Export to Machine_Performance.csv.
-- Expected : 4 rows; FL-01 first (90.4%); total TotalActual = 175,450
-- Hint     : JOIN + date filter + GROUP BY + aggregates + ROUND/CAST + ORDER BY
-- Your query:




-- Question P7.4
-- [Mini project B] Downtime summary per machine for completed stoppages:
-- MachineCode, number of stoppages, total minutes. Most minutes first. Keep
-- this as a SEPARATE query from Mini project A.
-- Expected : 4 rows; FL-02 first (165 min)
-- Hint     : DATEDIFF(MINUTE, …) inside SUM(); WHERE EndTime IS NOT NULL
-- Your query:




-- Question P7.5
-- [Discussion] For each situation, choose: Save Results As CSV, Copy with
-- Headers into Excel, or connect Excel/Power BI directly to the database.
-- (a) Send this week's machine report to the plant manager once. (b) The
-- same report is needed every Monday. (c) Quickly paste 12 rows into an
-- email table.
-- Expected : Written answer
-- Hint     : Think about how often the report is needed
-- Your answer:
--  (a)
--  (b)
--  (c)
