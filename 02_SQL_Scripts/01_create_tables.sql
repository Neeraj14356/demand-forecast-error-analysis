CREATE DATABASE IF NOT EXISTS demand_forecasting;


USE demand_forecasting;

-- Change table name
RENAME TABLE 
    raw_train TO fact_sales,
    raw_stores TO dim_stores,
    raw_oil TO dim_oil_prices,
    raw_holidays_events TO dim_holidays_events,
    raw_transactions TO fact_transactions;
    
-- Drop unwanted dataset
DROP TABLE demand_forecasting.raw_sample_submission;
DROP TABLE demand_forecasting.raw_test;

-- Rename columns name of table fact_sales.
ALTER TABLE demand_forecasting.fact_sales
   RENAME COLUMN id TO sales_id,	
   RENAME COLUMN date TO sales_date,	
   RENAME COLUMN store_nbr TO store_id,	
   RENAME COLUMN family TO product_family,	
   RENAME COLUMN sales TO total_sales,	
   RENAME COLUMN onpromotion TO on_promotion;
   
-- Rename columns name of table dim_stores
ALTER TABLE demand_forecasting.dim_stores
   RENAME COLUMN store_nbr TO store_id,
   RENAME COLUMN city TO city_name,	
   RENAME COLUMN state TO state_name,	
   RENAME COLUMN type TO store_type;
   
-- Rename columns name of table dim_oil_price
ALTER TABLE demand_forecasting.dim_oil_prices
   RENAME COLUMN date TO oil_date, 
   RENAME COLUMN dcoilwtico TO oil_price;
   
-- Rename columns name of table dim_holiday_events
ALTER TABLE demand_forecasting.dim_holidays_events
   RENAME COLUMN type TO event_type,	
   RENAME COLUMN locale TO event_locale,	
   RENAME COLUMN description TO event_description,	
   RENAME COLUMN transferred TO is_transferred;
   
-- Rename columns name of table fact_transactions
ALTER TABLE demand_forecasting.fact_transactions
RENAME COLUMN store_nbr TO store_id,	
RENAME COLUMN transactions TO transactions_count;

-- Add primary key in dim_stores
ALTER TABLE demand_forecasting.dim_stores
ADD PRIMARY KEY (store_id);

-- Add primary key & foreign key in fact_sales
-- sales_id unique aur non-NULL
SELECT
    COUNT(*) AS total_rows,
    COUNT(sales_id) AS non_null_ids,
    COUNT(DISTINCT sales_id) AS unique_ids
FROM fact_sales;

-- Primary Key
ALTER TABLE demand_forecasting.fact_sales
ADD CONSTRAINT pk_fact_sales
PRIMARY KEY (sales_id);

-- Verify store_id is present in dim_store
SELECT DISTINCT f.store_id
FROM fact_sales AS f
LEFT JOIN dim_stores AS s
    ON f.store_id = s.store_id
WHERE s.store_id IS NULL;

-- Foreign Key
ALTER TABLE demand_forecasting.fact_sales
ADD CONSTRAINT fk_fact_sales
FOREIGN KEY (store_id) 
REFERENCES demand_forecasting.dim_stores(store_id);

-- Verify Primary key & Foreign Key

-- Primary keys
SHOW KEYS FROM dim_stores WHERE Key_name = 'PRIMARY';
SHOW KEYS FROM fact_sales WHERE Key_name = 'PRIMARY';

-- Foreign keys
SELECT
    TABLE_NAME,
    CONSTRAINT_NAME,
    COLUMN_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM information_schema.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'demand_forecasting'
  AND REFERENCED_TABLE_NAME IS NOT NULL;








