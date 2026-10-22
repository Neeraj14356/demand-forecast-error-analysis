
-- ============================================================
-- Project: Demand Forecasting Analysis
-- Brand: R&D | RetailPulse
-- File: 01_create_tables.sql
-- Purpose: Rename raw tables, standardize column names,
--          define primary and foreign key constraints,
--          and verify database relationships.
--
-- IMPORTANT:
-- This is a one-time setup/migration script.
-- Do not rerun blindly after successful execution.
-- ============================================================


-- ============================================================
-- 01. DATABASE SETUP
-- ============================================================

CREATE DATABASE IF NOT EXISTS demand_forecasting;

USE demand_forecasting;


-- ============================================================
-- 02. RENAME RAW TABLES
-- ============================================================

RENAME TABLE
    raw_train          TO fact_sales,
    raw_stores         TO dim_stores,
    raw_oil            TO dim_oil_prices,
    raw_holidays_events TO dim_holidays_events,
    raw_transactions   TO fact_transactions;


-- ============================================================
-- 03. REMOVE UNNECESSARY TABLES
-- ============================================================

-- WARNING: These tables will be permanently dropped.
-- Confirm that they are no longer required before execution.

DROP TABLE demand_forecasting.raw_sample_submission;
DROP TABLE demand_forecasting.raw_test;


-- ============================================================
-- 04. STANDARDIZE COLUMN NAMES
-- ============================================================

-- 04.1 Fact Sales

ALTER TABLE fact_sales
    RENAME COLUMN id TO sales_id,
    RENAME COLUMN date TO sales_date,
    RENAME COLUMN store_nbr TO store_id,
    RENAME COLUMN family TO product_family,
    RENAME COLUMN sales TO total_sales,
    RENAME COLUMN onpromotion TO on_promotion;


-- 04.2 Store Dimension

ALTER TABLE dim_stores
    RENAME COLUMN store_nbr TO store_id,
    RENAME COLUMN city TO city_name,
    RENAME COLUMN state TO state_name,
    RENAME COLUMN type TO store_type;


-- 04.3 Oil Price Dimension

ALTER TABLE dim_oil_prices
    RENAME COLUMN date TO oil_date,
    RENAME COLUMN dcoilwtico TO oil_price;


-- 04.4 Holiday and Events Dimension

ALTER TABLE dim_holidays_events
    RENAME COLUMN type TO event_type,
    RENAME COLUMN locale TO event_locale,
    RENAME COLUMN description TO event_description,
    RENAME COLUMN transferred TO is_transferred;


-- 04.5 Transactions Fact Table

ALTER TABLE fact_transactions
    RENAME COLUMN store_nbr TO store_id,
    RENAME COLUMN transactions TO transactions_count;


-- ============================================================
-- 05. VALIDATE SALES ID UNIQUENESS
-- ============================================================

-- Check that sales_id values are non-NULL and unique
-- before adding the primary key.

SELECT
    COUNT(*) AS total_rows,
    COUNT(sales_id) AS non_null_ids,
    COUNT(DISTINCT sales_id) AS unique_ids
FROM fact_sales;


-- ============================================================
-- 06. DEFINE PRIMARY KEYS
-- ============================================================

-- 06.1 Store Dimension Primary Key

ALTER TABLE dim_stores
    ADD CONSTRAINT pk_dim_stores
    PRIMARY KEY (store_id);


-- 06.2 Sales Fact Primary Key

-- Execute only after confirming sales_id is unique
-- and contains no NULL values.

ALTER TABLE fact_sales
    ADD CONSTRAINT pk_fact_sales
    PRIMARY KEY (sales_id);


-- ============================================================
-- 07. VALIDATE STORE REFERENCES
-- ============================================================

-- Identify sales records without a matching store.
-- Expected result: zero rows.

SELECT DISTINCT
    f.store_id
FROM fact_sales AS f
LEFT JOIN dim_stores AS s
    ON f.store_id = s.store_id
WHERE s.store_id IS NULL;


-- ============================================================
-- 08. DEFINE FOREIGN KEY
-- ============================================================

-- Execute only after verifying that all sales store_id
-- values match dim_stores.store_id.

ALTER TABLE fact_sales
    ADD CONSTRAINT fk_fact_sales_store
    FOREIGN KEY (store_id)
    REFERENCES dim_stores (store_id);


-- ============================================================
-- 09. VERIFY PRIMARY KEYS
-- ============================================================

SHOW KEYS FROM dim_stores
WHERE Key_name = 'PRIMARY';

SHOW KEYS FROM fact_sales
WHERE Key_name = 'PRIMARY';


-- ============================================================
-- 10. VERIFY FOREIGN KEY CONSTRAINTS
-- ============================================================

SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'demand_forecasting'
  AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME, CONSTRAINT_NAME;


-- ============================================================
-- END OF DATABASE SETUP AND SCHEMA VALIDATION
-- ============================================================
