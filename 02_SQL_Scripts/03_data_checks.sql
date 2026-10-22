USE demand_forecasting;

-- =========================================================
-- 03_DATA_CHECKS.SQL
-- Project: R&D | RetailPulse
-- Purpose: Validate data quality before analysis
-- IMPORTANT: Execute each section separately.
-- =========================================================

-- 01. CHECK NULL VALUES
-- Check for missing values in fact_sales.
SELECT 
      COUNT(*) AS total_rows,
      SUM(sales_id IS NULL) AS null_sales_id,
      SUM(sales_date IS NULL) AS null_sales_data,
      SUM(store_id IS NULL) AS null_store_id,
      SUM(product_family IS NULL) AS null_product_family,
      SUM(total_sales IS NULL) AS null_total_sales,
      SUM(on_promotion IS NULL) AS null_on_promotion
FROM demand_forecasting.fact_sales;

-- Check NULL values in dimension and transaction tables.
SELECT 
      COUNT(*) AS total_rows,
      SUM(store_id IS NULL) AS null_store_id,
      SUM(state_name IS NULL) AS null_state_name,
      SUM(store_type IS NULL) AS null_store_type,
      SUM(cluster IS NULL) AS null_cluster
FROM demand_forecasting.dim_stores;

SELECT 
      COUNT(*) AS total_rows,
      SUM(oil_date IS NULL) AS null_oil_date,
      SUM(oil_price IS NULL) AS null_oil_price
FROM demand_forecasting.dim_oil_prices;

SELECT 
	  COUNT(*) AS total_rows,
      SUM(event_type IS NULL) AS null_event_type,
      SUM(event_locale IS NULL) AS null_event_locale,
      SUM(locale_name IS NULL) AS null_locale_name,
      SUM(event_description IS NULL) AS null_event_description,
      SUM(is_transferred IS NULL) AS null_is_transferred
FROM demand_forecasting.dim_holidays_events;

SELECT 
     COUNT(*) AS total_rows,
     SUM(date IS NULL) AS null_date,
     SUM(store_id IS NULL) AS null_store_id,
     SUM(transactions_count IS NULL) AS null_transactions_count
FROM demand_forecasting.fact_transactions;

-- =========================================================
-- 02. CHECK DUPLICATE RECORDS
-- =========================================================

-- Check duplicate business keys in fact_sales.
-- Expected: no duplicate combinations.
-- This query may take time on the 3-million-row table.

SELECT 
sales_date,
store_id,
product_family,
COUNT(*) AS duplicate_count
FROM demand_forecasting.fact_sales
GROUP BY  
        sales_date,
        store_id,
        product_family
HAVING  COUNT(*) >1;


-- Check duplicate store IDs.

SELECT 
      store_id, 
      COUNT(*) AS duplicate_count
FROM demand_forecasting.dim_stores
GROUP BY store_id
HAVING COUNT(*) >1;

-- Check duplicate oil dates.

SELECT 
      oil_date,
       oil_price,
       COUNT(*) AS duplicate_count
FROM demand_forecasting.dim_oil_prices
GROUP BY oil_date , oil_price
HAVING COUNT(*) > 1;

-- Check duplicate transaction keys.

SELECT
    date,
    store_id,
    COUNT(*) AS duplicate_count
FROM demand_forecasting.fact_transactions
GROUP BY
    date,
    store_id
HAVING COUNT(*) > 1;

-- Check exact duplicate holiday/event rows.
-- Multiple different events on one date are valid.

SELECT
    date,
    event_type,
    event_locale,
    locale_name,
    event_description,
    is_transferred,
    COUNT(*) AS duplicate_count
FROM demand_forecasting.dim_holidays_events
GROUP BY
    date,
    event_type,
    event_locale,
    locale_name,
    event_description,
    is_transferred
HAVING COUNT(*) > 1;

-- =====================================================
-- 03. EXPLORE DATASET STRUCTURE
-- Purpose: Understand date range and available categories
-- =====================================================

-- 1. CHECK SALES DATE RANGE
-- Identify the first and last dates in the dataset.

SELECT
    MIN(sales_date) AS first_sales_date,
    MAX(sales_date) AS last_sales_date
FROM fact_sales;

-- 2. IDENTIFY PRODUCT FAMILIES
-- List all unique product families in the sales data.

SELECT DISTINCT
    product_family
FROM fact_sales
ORDER BY product_family ASC;

-- 3. IDENTIFY STORE TYPES
-- List all unique store types.

SELECT DISTINCT
    store_type
FROM dim_stores
ORDER BY store_type ASC;

-- 4. IDENTIFY CITIES
-- List all unique cities where stores are located.

SELECT DISTINCT
    city_name
FROM dim_stores
ORDER BY city_name ASC;

-- 5. IDENTIFY STATES
-- List all unique states where stores are located.

SELECT DISTINCT
    state_name
FROM dim_stores
ORDER BY state_name ASC;

-- =====================================================
-- END OF DATASET EXPLORATION
-- =====================================================

-- =========================================================
-- 04. IDENTIFY MISSING DATES
-- =========================================================

-- Known fact_sales date range:
-- 2013-01-01 to 2017-08-15.
-- Expected missing date: December 25 each year.
-- Raise recursion limit for this session only.

 SET SESSION cte_max_recursion_depth = 3000;
 
 -- Identify Missing Dates
 WITH RECURSIVE calendar AS (
    SELECT DATE('2013-01-01') AS calendar_date

    UNION ALL

    SELECT DATE_ADD(calendar_date, INTERVAL 1 DAY)
    FROM calendar
    WHERE calendar_date < '2017-08-15'
)
SELECT c.calendar_date AS missing_date
FROM calendar c
LEFT JOIN (
    SELECT DISTINCT sales_date
    FROM demand_forecasting.fact_sales
) f
    ON c.calendar_date = f.sales_date
WHERE f.sales_date IS NULL
ORDER BY c.calendar_date;

-- Confirmed result so far:
-- 2013-12-25
-- 2014-12-25
-- 2015-12-25
-- 2016-12-25
-- These four missing dates are expected.

-- =========================================================
-- 05. VALIDATE INVALID OR OUT-OF-RANGE VALUES
-- =========================================================

-- Check negative sales.
-- Zero sales are not automatically invalid.

SELECT COUNT(*) AS negative_sales_rows
FROM fact_sales
WHERE total_sales < 0;

-- Check invalid promotion counts.

SELECT COUNT(*) AS negative_promotion_rows
FROM fact_sales
WHERE on_promotion < 0;

-- Check negative transaction counts.

SELECT COUNT(*) AS negative_transaction_rows
FROM fact_transactions
WHERE transactions_count < 0;

-- Check negative oil prices.
-- Investigate results before deciding how to treat them.

SELECT COUNT(*) AS negative_oil_price_rows
FROM dim_oil_prices
WHERE oil_price < 0;

-- Inspect unexpected transferred flag values.

SELECT DISTINCT is_transferred
FROM dim_holidays_events
ORDER BY is_transferred;

-- =========================================================
-- 06. VALIDATE FOREIGN KEY RELATIONSHIPS
-- =========================================================

-- Sales rows with no matching store.

SELECT COUNT(*) AS sales_without_store
FROM fact_sales AS f
LEFT JOIN dim_stores AS s
    ON f.store_id = s.store_id
WHERE s.store_id IS NULL;

-- Transactions with no matching store.

SELECT COUNT(*) AS transactions_without_store
FROM fact_transactions AS t
LEFT JOIN dim_stores AS s
    ON t.store_id = s.store_id
WHERE s.store_id IS NULL;

-- =====================================================
-- 07. CREATE STORE START DATE TABLE
-- Purpose: Identify each store's first positive-sales date
-- =====================================================

CREATE TABLE demand_forecasting.store_start AS
SELECT
    f.store_id,
    MIN(f.sales_date) AS first_sale_date
FROM demand_forecasting.fact_sales AS f
WHERE f.total_sales > 0
GROUP BY
    f.store_id;

-- Verify the created table

SELECT *
FROM demand_forecasting.store_start
ORDER BY store_id;
 
-- =========================================================
-- 06. ANALYZE ZERO-SALES PRODUCT FAMILIES
-- =========================================================

-- Count zero-sales rows and calculate their percentage
-- within each product family.

WITH family_sales AS (
    SELECT
        product_family,
        COUNT(*) AS total_rows,
        SUM(
            CASE
                WHEN total_sales = 0 THEN 1
                ELSE 0
            END
        ) AS zero_sales_count
    FROM fact_sales
    GROUP BY product_family
)
SELECT
    product_family,
    total_rows,
    zero_sales_count,
    ROUND(
        zero_sales_count * 100.0 / total_rows,
        2
    ) AS zero_sales_percentage
FROM family_sales
WHERE zero_sales_count > 0
ORDER BY zero_sales_percentage DESC;


-- =========================================================
-- END OF DATA QUALITY CHECKS
-- =========================================================

-- Do not delete records automatically.
-- Investigate results and document the decision in
-- 00_Project_Documents/data_issues.md.
-- For slow queries, run sections separately and use EXPLAIN.

