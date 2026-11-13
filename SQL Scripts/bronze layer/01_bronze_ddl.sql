-- =====================================================================
-- BRONZE LAYER | TABLE DEFINITIONS
-- Script: 01_bronze_ddl.sql
-- Purpose: Create tables for ingesting raw source data.
-- Design: All columns are defined as VARCHAR to preserve source values
--         and defer data type conversion and validation to the Silver layer.
-- =====================================================================

DO $$
DECLARE 	
	start_time TIMESTAMPTZ;
	end_time TIMESTAMPTZ;
BEGIN
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';
RAISE NOTICE 'CREATING BRONZE LAYER TABLES';
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';
-----------------------------------------------------------------------------------------------------------------------------------
--1.) Creating sales table

RAISE NOTICE '-------------------------------------------';
RAISE NOTICE 'Creating bronze(sales) table...............';
start_time := clock_timestamp();
DROP TABLE IF EXISTS bronze.sales;
CREATE TABLE bronze.sales(
sales_line_id VARCHAR(100),
order_id VARCHAR(100),
customer_key VARCHAR(100),
product_key VARCHAR(100),
store_key VARCHAR(100),
order_date_key VARCHAR(100),
order_date_text VARCHAR(100),
quantity VARCHAR(100),
unit_selling_price VARCHAR(100),
discount_rate VARCHAR(100),
unit_cost VARCHAR(100),
shipping_fee VARCHAR(100),
tax_rate VARCHAR(100),
payment_method VARCHAR(100),
order_status VARCHAR(100),
return_flag VARCHAR(100),
sales_amount_incl_tax VARCHAR(100),
line_cost_amount VARCHAR(100),
invoice_number VARCHAR(100)
);
RAISE NOTICE 'Bronze(sales) table created !!';
end_time := clock_timestamp();
RAISE NOTICE 'Build Duration: % seconds', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE '-------------------------------------------';

-----------------------------------------------------------------------------------------------------------------------------------
--2.) Creating customers table
RAISE NOTICE '-------------------------------------------';
RAISE NOTICE 'Creating bronze(customers) table...............';
start_time := clock_timestamp();
DROP TABLE IF EXISTS bronze.customers;
CREATE TABLE bronze.customers(
customer_key VARCHAR(100),
customer_id VARCHAR(100),
customer_name VARCHAR(100),
email VARCHAR(100),
customer_segment VARCHAR(100),
city VARCHAR(100),
state VARCHAR(100),
region VARCHAR(100),
registration_date_text VARCHAR(100),
age VARCHAR(100),
loyalty_tier VARCHAR(100)
);
RAISE NOTICE 'Bronze(customers) table created !!';
end_time := clock_timestamp();
RAISE NOTICE 'Build Duration: % seconds', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE '-------------------------------------------';

-----------------------------------------------------------------------------------------------------------------------------------
--3.) Creating products table
RAISE NOTICE '-------------------------------------------';
RAISE NOTICE 'Creating bronze(products) table...............';
start_time := clock_timestamp();
DROP TABLE IF EXISTS bronze.products;
CREATE TABLE bronze.products(
product_key VARCHAR(100),
sku VARCHAR(100),
product_name VARCHAR(100),
brand VARCHAR(100),
category VARCHAR(100),
subcategory VARCHAR(100),
product_specs VARCHAR(100),
list_price VARCHAR(100),
standard_cost VARCHAR(100),
warranty_months VARCHAR(100),
is_active VARCHAR(100)
);
RAISE NOTICE 'Bronze(products) table created !!';
end_time := clock_timestamp();
RAISE NOTICE 'Build Duration: % seconds', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE '-------------------------------------------';

-----------------------------------------------------------------------------------------------------------------------------------
--4.) Creating stores table
RAISE NOTICE '-------------------------------------------';
RAISE NOTICE 'Creating bronze(stores) table...............';
start_time := clock_timestamp();
DROP TABLE IF EXISTS bronze.stores;
CREATE TABLE bronze.stores(
store_key VARCHAR(100),
store_code VARCHAR(100),
store_name VARCHAR(100),
channel_type VARCHAR(100),
city VARCHAR(100),
state VARCHAR(100),
region VARCHAR(100),
location_type VARCHAR(100),
opening_date_text VARCHAR(100),
store_status VARCHAR(100)
);
RAISE NOTICE 'Bronze(stores) table created !!';
end_time := clock_timestamp();
RAISE NOTICE 'Build Duration: % seconds', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE '-------------------------------------------';

-----------------------------------------------------------------------------------------------------------------------------------
--5.) Creating dates table
RAISE NOTICE '-------------------------------------------';
RAISE NOTICE 'Creating bronze(dates) table...............';
start_time := clock_timestamp();
DROP TABLE IF EXISTS bronze.dates;
CREATE TABLE bronze.dates(
date_key VARCHAR(100),
calendar_date_text VARCHAR(100),
calendar_year VARCHAR(100),
month_number VARCHAR(100),
month_name VARCHAR(100),
quarter VARCHAR(100),
day_name VARCHAR(100),
is_weekend VARCHAR(100),
holiday_label VARCHAR(100)
);
RAISE NOTICE 'Bronze(dates) table created !!';
end_time := clock_timestamp();
RAISE NOTICE 'Build Duration: % seconds', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE '-------------------------------------------';

-----------------------------------------------------------------------------------------------------------------------------------
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';
RAISE NOTICE 'ALL BRONZE LAYER TABLES CREATED !!';
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';

EXCEPTION 
	WHEN OTHERS THEN 
	RAISE NOTICE 'Bronze table creation failed: %', SQLERRM;
	RAISE;
END $$;