-- =====================================================================
-- GOLD LAYER | ANALYTICAL VIEWS AND BUSINESS-READY DATA
-- Script: 05_gold_views.sql
-- Purpose: Create business-ready analytical views from the Silver layer
--          to support reporting, business intelligence, and data analysis.
-- Method: Transform cleaned and standardised Silver data into
--         analytical views using business logic, aggregations, and
--         appropriate joins to prepare data for reporting.
-- =====================================================================

CREATE OR REPLACE PROCEDURE gold.load_gold()
LANGUAGE plpgsql
AS $$
DECLARE
	start_time TIMESTAMPTZ;
	end_time TIMESTAMPTZ;
BEGIN
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';
RAISE NOTICE 'CREATING VIEWS IN GOLD LAYER.......';
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';

-------------------------------------------------------------------------------------------------
-- 1.) Creating gold.customers views

RAISE NOTICE '-----------------------------------------------';
RAISE NOTICE 'Creating gold.customers views.......';
start_time := clock_timestamp();
CREATE OR REPLACE VIEW gold.dim_customers AS 
SELECT 
customer_key,
customer_name AS full_name,
email AS email_id,
customer_segment,
city,
state,
region,
age,
loyalty_tier,
registration_date_text AS registration_date
FROM silver.customers;
RAISE NOTICE 'gold.customers view created';
end_time := clock_timestamp();
RAISE NOTICE 'Load Duration: %', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE '-----------------------------------------------';
-------------------------------------------------------------------------------------------------
-- 2.) Creating gold.products views

RAISE NOTICE '-----------------------------------------------';
RAISE NOTICE 'Creating gold.products views......';
start_time := clock_timestamp();
CREATE OR REPLACE VIEW gold.dim_products AS
SELECT 
product_key,
product_name,
brand AS brand_name,
category AS product_category,
subcategory AS product_subcategory,
product_specs,
warranty_months,
is_active,
list_price AS selling_price,
standard_cost AS product_cost,
(list_price - standard_cost) AS gross_profit,
ROUND((((list_price - standard_cost) :: NUMERIC/NULLIF(list_price,0))*100),2) AS gross_profit_percent
FROM silver.products;
RAISE NOTICE 'gold.products view created';
end_time := clock_timestamp();
RAISE NOTICE 'Load Duration: %', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE '-----------------------------------------------';
-------------------------------------------------------------------------------------------------
-- 3.) Creating gold.stores views

RAISE NOTICE '-----------------------------------------------';
RAISE NOTICE 'Creating gold.stores views.......';
start_time := clock_timestamp();
CREATE OR REPLACE VIEW gold.dim_stores AS
SELECT 
store_key,
store_name,
channel_type,
city,
state,
region,
location_type,
opening_date_text AS opening_date,
store_status
FROM silver.stores;
RAISE NOTICE 'gold.stores view created';
end_time := clock_timestamp();
RAISE NOTICE 'Load Duration: %', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE '-----------------------------------------------';
-------------------------------------------------------------------------------------------------
-- 4.) Creating gold.dates views

RAISE NOTICE '-----------------------------------------------';
RAISE NOTICE 'Creating gold.dates views........';
start_time := clock_timestamp();
CREATE OR REPLACE VIEW gold.dim_dates AS
SELECT 
date_key,
calendar_date_text AS calendar_date,
calendar_year AS year,
month_number,
month_name,
quarter,
day_name,
is_weekend
FROM silver.dates;
RAISE NOTICE 'gold.dates view created';
end_time := clock_timestamp();
RAISE NOTICE 'Load Duration: %', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE '-----------------------------------------------';

-------------------------------------------------------------------------------------------------
-- 5.) Creating gold.sales views

RAISE NOTICE '-----------------------------------------------';
RAISE NOTICE 'Creating gold.sales views.......';
start_time := clock_timestamp();
CREATE OR REPLACE VIEW gold.fact_sales AS
SELECT 
sales_line_id AS sales_key,
order_id, 
customer_key,
product_key,
store_key,
order_date_key AS date_key,
order_date_text AS order_date,
payment_method,
order_status,
return_flag AS return_status,
quantity AS quantity_sold,
unit_selling_price AS selling_price,
discount_rate AS discount_percent,
unit_cost AS product_cost,
shipping_fee AS shipping_cost,
tax_rate AS tax_percent,
sales_amount_incl_tax AS sales_amount,
line_cost_amount AS total_cost,
(sales_amount_incl_tax - line_cost_amount) AS profit_amount,
ROUND((((sales_amount_incl_tax - line_cost_amount) :: NUMERIC/NULLIF(sales_amount_incl_tax, 0))*100), 2)AS profit_percent
FROM silver.sales;
RAISE NOTICE 'gold.sales view created';
end_time := clock_timestamp();
RAISE NOTICE 'Load Duration: %', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE '-----------------------------------------------';
-------------------------------------------------------------------------------------------------
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';
RAISE NOTICE 'CREATED VIEWS IN GOLD LAYER.......';
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';
EXCEPTION 
	WHEN OTHERS THEN
	RAISE NOTICE 'Views Not Created !!: %', SQLERRM;
	RAISE;
END $$;





