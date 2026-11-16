/* =====================================================================
   02_Participant_Exercises.sql
   Course : SQL and Relational Database Fundamentals (1 day)
   Database: ProductionTraining  |  Training server: localhost\SQLEXPRESS

   HOW TO USE
   - Run 01_Setup_ProductionTraining.sql first (once).
   - Write your query below each task.
   - Highlight only your query, then press F5.
     If no text is selected, SSMS runs all queries in the tab.
   - Compare your results with the expected output.
   © 2026 Mufasyah Consultant | mufasyahcons@gmail.com
   ===================================================================== */

USE ProductionTraining;
GO

-- Check that the active database is ProductionTraining.
SELECT DB_NAME() AS CurrentDatabase;

/* ===================================================================
   MODULE 1: Introduction to Databases and SQL
   =================================================================== */
-- Exercise 1: Identify the table structure

-- Task 1.1
-- Identify the primary key and foreign key in dbo.ProductionOrders.
-- Which table does the foreign key reference?
-- Expected output: Two column names and one table name
-- Your answer:
--
--

-- Task 1.2
-- How many output records can one order have? How many orders can a
-- single output record belong to?
-- Expected output: "Many" and "one"
-- Your answer:
--
--

-- Task 1.3
-- Products P007 and P008 have never been ordered. Which table can you
-- check to confirm this?
-- Expected output: One table name
-- Your answer:
--
--

-- Task 1.4
-- Why does ProductionRecords store the numeric OrderID instead of the
-- product name or the full OrderNo?
-- Expected output: One reason
-- Your answer:
--
--

/* ===================================================================
   MODULE 2: Getting Started with SSMS
   =================================================================== */
-- Exercise 2: Connect, select a database, and run queries

-- Task 2.1
-- Connect to the training instance, open New Query, select
-- ProductionTraining from the database dropdown, and run
-- SELECT DB_NAME() AS CurrentDatabase;
-- Expected output: One row showing ProductionTraining
-- Hint: If the result is master, select ProductionTraining from the dropdown.
-- Write your query below:



-- Task 2.2
-- Display all columns and rows in dbo.Products. How many rows does
-- the status bar show?
-- Expected output: 8 rows
-- Hint: Use SELECT * FROM ...
-- Write your query below:



-- Task 2.3
-- Display all output records for OrderID 1.
-- Expected output: 3 rows
-- Hint: Add WHERE OrderID = 1
-- Write your query below:



-- Task 2.4
-- Use INFORMATION_SCHEMA.COLUMNS to display the structure of
-- dbo.ProductionRecords, including each column's name, data type,
-- maximum length, and whether it allows NULL.
-- Expected output: 8 rows, with only DowntimeMinutes allowing NULL
-- Hint: WHERE TABLE_NAME = 'ProductionRecords'
-- Write your query below: