-- =====================================================================
-- SILVER LAYER | TABLE DEFINITIONS
-- Script: 03_silver_ddl.sql
-- Purpose: Create tables to store cleaned, standardised, and validated
--          data processed from the Bronze layer.
-- Method: Define the Silver layer table structures to support data
--         cleansing, standardisation, and data quality improvements.
-- =====================================================================

DO $$
DECLARE 	
	start_time TIMESTAMPTZ;
	end_time TIMESTAMPTZ;
BEGIN
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';
RAISE NOTICE 'CREATING SILVER LAYER TABLES';
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';
-----------------------------------------------------------------------------------------------------------------------------------
--1.) Creating sales table

RAISE NOTICE '-------------------------------------------';
RAISE NOTICE 'Creating silver(sales) table...............';
start_time := clock_timestamp();
DROP TABLE IF EXISTS silver.sales;
CREATE TABLE silver.sales(
sales_line_id VARCHAR(100),
order_id VARCHAR(100),
customer_key VARCHAR(100),
product_key VARCHAR(100),
store_key VARCHAR(100),
order_date_key VARCHAR(100),
order_date_text DATE,
quantity NUMERIC,
unit_selling_price NUMERIC,
discount_rate NUMERIC,
unit_cost NUMERIC,
shipping_fee NUMERIC,
tax_rate NUMERIC,
payment_method VARCHAR(100),
order_status VARCHAR(100),
return_flag VARCHAR(100),
sales_amount_incl_tax NUMERIC,
line_cost_amount NUMERIC,
invoice_number VARCHAR(100)
);
RAISE NOTICE 'silver(sales) table created !!';
end_time := clock_timestamp();
RAISE NOTICE 'Build Duration: % seconds', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE '-------------------------------------------';

-----------------------------------------------------------------------------------------------------------------------------------
--2.) Creating customers table
RAISE NOTICE '-------------------------------------------';
RAISE NOTICE 'Creating silver(customers) table...............';
start_time := clock_timestamp();
DROP TABLE IF EXISTS silver.customers;
CREATE TABLE silver.customers(
customer_key VARCHAR(100),
customer_id VARCHAR(100),
customer_name VARCHAR(100),
email VARCHAR(100),
customer_segment VARCHAR(100),
city VARCHAR(100),
state VARCHAR(100),
region VARCHAR(100),
registration_date_text DATE,
age NUMERIC,
loyalty_tier VARCHAR(100)
);
RAISE NOTICE 'silver(customers) table created !!';
end_time := clock_timestamp();
RAISE NOTICE 'Build Duration: % seconds', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE '-------------------------------------------';

-----------------------------------------------------------------------------------------------------------------------------------
--3.) Creating products table
RAISE NOTICE '-------------------------------------------';
RAISE NOTICE 'Creating silver(products) table...............';
start_time := clock_timestamp();
DROP TABLE IF EXISTS silver.products;
CREATE TABLE silver.products(
product_key VARCHAR(100),
sku VARCHAR(100),
product_name VARCHAR(100),
brand VARCHAR(100),
category VARCHAR(100),
subcategory VARCHAR(100),
product_specs VARCHAR(100),
list_price NUMERIC,
standard_cost NUMERIC,
warranty_months NUMERIC,
is_active VARCHAR(100)
);
RAISE NOTICE 'silver(products) table created !!';
end_time := clock_timestamp();
RAISE NOTICE 'Build Duration: % seconds', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE '-------------------------------------------';

-----------------------------------------------------------------------------------------------------------------------------------
--4.) Creating stores table
RAISE NOTICE '-------------------------------------------';
RAISE NOTICE 'Creating silver(stores) table...............';
start_time := clock_timestamp();
DROP TABLE IF EXISTS silver.stores;
CREATE TABLE silver.stores(
store_key VARCHAR(100),
store_code VARCHAR(100),
store_name VARCHAR(100),
channel_type VARCHAR(100),
city VARCHAR(100),
state VARCHAR(100),
region VARCHAR(100),
location_type VARCHAR(100),
opening_date_text DATE,
store_status VARCHAR(100)
);
RAISE NOTICE 'silver(stores) table created !!';
end_time := clock_timestamp();
RAISE NOTICE 'Build Duration: % seconds', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE '-------------------------------------------';

-----------------------------------------------------------------------------------------------------------------------------------
--5.) Creating dates table
RAISE NOTICE '-------------------------------------------';
RAISE NOTICE 'Creating silver(dates) table...............';
start_time := clock_timestamp();
DROP TABLE IF EXISTS silver.dates;
CREATE TABLE silver.dates(
date_key VARCHAR(100),
calendar_date_text DATE,
calendar_year VARCHAR(100),
month_number VARCHAR(100),
month_name VARCHAR(100),
quarter VARCHAR(100),
day_name VARCHAR(100),
is_weekend VARCHAR(100),
holiday_label VARCHAR(100)
);
RAISE NOTICE 'silver(dates) table created !!';
end_time := clock_timestamp();
RAISE NOTICE 'Build Duration: % seconds', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE '-------------------------------------------';

-----------------------------------------------------------------------------------------------------------------------------------
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';
RAISE NOTICE 'ALL SILVER LAYER TABLES CREATED !!';
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';

EXCEPTION 
	WHEN OTHERS THEN 
	RAISE NOTICE 'silver table creation failed: %', SQLERRM;
	RAISE;
END $$;