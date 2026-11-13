-- =====================================================================
-- SILVER LAYER | DATA LOADING AND TRANSFORMATION
-- Script: 04_load_silver.sql
-- Purpose: Load cleaned, standardised, and validated data from the
--          Bronze layer into the Silver layer.
-- Method: Transform raw Bronze data through data cleansing, type
--         conversion, standardisation, and deduplication before
--         inserting the processed data into Silver tables.
-- =====================================================================

CREATE OR REPLACE PROCEDURE silver.load_silver()
LANGUAGE plpgsql
AS $$
DECLARE
	start_time TIMESTAMPTZ;
	end_time TIMESTAMPTZ;
BEGIN
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';
RAISE NOTICE 'INSERTING DATA IN THE SILVER LAYER.......';
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';
-------------------------------------------------------------------------------------------------
-- 1.) Inserting data in the silver.customers table

RAISE NOTICE '-----------------------------------------------';
RAISE NOTICE 'Inserting Data In The silver.customers table....';
start_time := clock_timestamp();
TRUNCATE TABLE silver.customers;
INSERT INTO silver.customers (
    customer_key,
    customer_id,
    customer_name,
    email,
    customer_segment,
    city,
    state,
    region,
    registration_date_text,
    age,
    loyalty_tier
)
SELECT
    customer_key,

    (CASE
        WHEN customer_id IS NULL
          OR UPPER(TRIM(customer_id)) IN ('-', '?', 'NULL', 'N/A', 'NA', 'UNKNOWN', '')
        THEN 'N/A'
        ELSE TRIM(customer_id)
    END) AS customer_id,

    COALESCE(INITCAP(TRIM(customer_name)), 'N/A') AS customer_name,

    COALESCE(LOWER(TRIM(email)), 'N/A') AS email,

    COALESCE(
        (CASE
            WHEN customer_segment IS NULL
              OR UPPER(TRIM(customer_segment)) IN ('NULL', '[NULL]', 'NA', 'N/A', 'UNKNOWN', '?', '-')
            THEN 'N/A'

            WHEN UPPER(TRIM(customer_segment)) IN ('SMALL-BUSINESS', 'BUSINESS - SMALL', 'SMB')
            THEN 'Small Business'

            WHEN UPPER(TRIM(customer_segment)) IN ('B2B ENTERPRISE', 'ENT')
            THEN 'Enterprise'

            WHEN UPPER(TRIM(customer_segment)) IN ('CREATOR', 'INFLUENCER')
            THEN 'Content Creator'

            WHEN UPPER(TRIM(customer_segment)) = 'COLLEGE STUDENT'
            THEN 'Student'

            WHEN UPPER(TRIM(customer_segment)) IN ('B2C', 'RETAIL CUSTOMER')
            THEN 'Consumer'

            ELSE INITCAP(TRIM(customer_segment))
        END),
        'N/A'
    ) AS customer_segment,

    (CASE
        WHEN city IS NULL
          OR UPPER(TRIM(city)) IN ('-', '?', 'NA', 'N/A', 'NULL', 'UNKNOWN')
        THEN 'N/A'

        WHEN UPPER(TRIM(city)) = 'DELHI'
        THEN 'New Delhi'

        ELSE INITCAP(TRIM(city))
    END) AS city,

    (CASE
        WHEN state IS NULL
          OR UPPER(TRIM(state)) IN ('-', '?', 'NA', 'N/A', 'NULL', 'UNKNOWN')
        THEN 'N/A'

        WHEN UPPER(TRIM(state)) IN ('UP', 'U.P.', 'UTTAR PRADESH')
        THEN 'Uttar Pradesh'

        WHEN UPPER(TRIM(state)) IN ('KA', 'KARNATKA', 'KARNATAKA')
        THEN 'Karnataka'

        WHEN UPPER(TRIM(state)) IN ('MH', 'MAHA.', 'MAHARASHTRA')
        THEN 'Maharashtra'

        ELSE INITCAP(TRIM(state))
    END) AS state,

    (CASE
        WHEN region IS NULL
          OR UPPER(TRIM(region)) IN ('-', '?', 'N', 'NA', 'N/A', 'NULL', 'UNKNOWN')
        THEN 'N/A'

        WHEN UPPER(TRIM(region)) IN ('NORTH', 'NORTH ZONE', 'N')
        THEN 'North'

        WHEN UPPER(TRIM(region)) IN ('SOUTH', 'SOUTH ZONE', 'S')
        THEN 'South'

        WHEN UPPER(TRIM(region)) IN ('EAST', 'E')
        THEN 'East'

        WHEN UPPER(TRIM(region)) IN ('WEST', 'W')
        THEN 'West'

        WHEN UPPER(TRIM(region)) IN ('CENTRAL', 'CENTRAL REGION')
        THEN 'Central'

        ELSE INITCAP(TRIM(region))
    END) AS region,

    registration_date_text,
    age,
    loyalty_tier

FROM (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_key
            ORDER BY registration_date_text NULLS LAST
        ) AS rnk_id

    FROM (
        SELECT
            customer_key,
            customer_id,
            customer_name,
            email,
            customer_segment,
            city,
            state,
            region,

            silver.parse_date(registration_date_text) AS registration_date_text,

            (CASE
                WHEN UPPER(TRIM(age)) = 'TWENTY SIX'
                THEN 26::NUMERIC

                WHEN UPPER(TRIM(age)) IN ('N/A', 'UNKNOWN', 'NULL', '?', '-')
                  OR age IS NULL
                  OR TRIM(age) = ''
                THEN NULL

                WHEN TRIM(age) !~ '^-?\d+(\.\d+)?$'
                THEN NULL

                WHEN TRIM(age)::NUMERIC <= 0
                THEN NULL

                ELSE TRIM(age)::NUMERIC
            END) AS age,

            (CASE
                WHEN UPPER(TRIM(loyalty_tier)) IN ('N/A', 'UNKNOWN', 'NULL', '?', '-', 'NA')
                  OR loyalty_tier IS NULL
                  OR TRIM(loyalty_tier) = ''
                THEN NULL

                WHEN UPPER(TRIM(loyalty_tier)) = 'VIP'
                THEN 'VIP'

                ELSE INITCAP(TRIM(loyalty_tier))
            END) AS loyalty_tier

        FROM bronze.customers
    ) a
) b

WHERE rnk_id = 1;

RAISE NOTICE 'Inserted Data in the silver.customers table....';
end_time := clock_timestamp();
RAISE NOTICE 'Load Duration: %', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE 'Total Rows: %', (SELECT COUNT(*) FROM silver.customers);
RAISE NOTICE '-----------------------------------------------';
-------------------------------------------------------------------------------------------------
-- 2.) Inserting data in the silver.products table

RAISE NOTICE '-----------------------------------------------';
RAISE NOTICE 'Inserting Data In The silver.products table....';
start_time := clock_timestamp();
TRUNCATE TABLE silver.products;
INSERT INTO silver.products(
product_key, 
sku,
product_name,
brand,
category,
subcategory,
product_specs,
list_price,
standard_cost,
warranty_months,
is_active
)
SELECT 
COALESCE(TRIM(product_key), 'N/A') AS product_key,
COALESCE((CASE
	WHEN UPPER(TRIM(sku)) IN ('-', '?', 'NULL', 'N/A', 'NA', 'UNKNOWN', '') THEN 'N/A'
	ELSE UPPER(TRIM(sku))
	END), 'N/A') AS sku,
COALESCE((CASE
	WHEN UPPER(TRIM(product_name)) IN ('-', '?', 'NULL', 'N/A', 'NA', 'UNKNOWN', '') THEN 'N/A'
	ELSE INITCAP(TRIM(product_name)) 
	END), 'N/A') AS product_name,
COALESCE((CASE 
	WHEN INITCAP(TRIM(brand)) = 'Dell Inc.' THEN 'Dell'
	WHEN INITCAP(TRIM(brand)) = 'Sony Corporation' THEN 'Sony'
	WHEN INITCAP(TRIM(brand)) = 'Sam Sung' THEN 'Samsung'
	WHEN INITCAP(TRIM(brand)) = 'Mi' THEN 'Xiaomi'
	WHEN INITCAP(TRIM(brand)) IN ('-', '?', 'NULL', 'N/A', 'NA', 'UNKNOWN', '') THEN 'N/A'
	ELSE INITCAP(TRIM(brand)) 
	END), 'N/A') AS brand,
COALESCE((CASE
	WHEN INITCAP(TRIM(category)) IN ('Tab', 'Tablet', 'Tablets') THEN 'Tablet'
	WHEN INITCAP(TRIM(category)) IN ('Laptops', 'Laptop', 'Lap Top', 'Notebook') THEN 'Laptop'
	WHEN INITCAP(TRIM(category)) IN ('Headphone', 'Head Phones', 'Headphones', 'Audio') THEN 'Audio'
	WHEN INITCAP(TRIM(category)) IN	('Accessories', 'Accessory') THEN 'Accessories'
	WHEN INITCAP(TRIM(category)) IN	('Smartwatches', 'Smart Watch') THEN 'Smartwatch'
	WHEN INITCAP(TRIM(category)) IN	('Smartphone', 'Smartphones', 'Smart Phones', 'Mobile', 'Mobiles') THEN 'Smartphone'
	WHEN INITCAP(TRIM(category)) IN ('Screen', 'Monitors') THEN 'Monitors'
	WHEN INITCAP(TRIM(category)) IN ('-', '?', 'NULL', 'N/A', 'NA', 'UNKNOWN', '') THEN 'N/A'
	WHEN INITCAP(TRIM(category)) IN ('Gaming', 'Gaming Devices', 'Games') THEN 'Gaming'
	ELSE INITCAP(TRIM(category))
	END), 'N/A') AS category,
(CASE
    WHEN subcategory IS NULL
    OR UPPER(TRIM(subcategory)) IN ('', 'NA', 'N/A', 'NULL', 'UNKNOWN', '?', '-')
    THEN 'N/A'
    ELSE INITCAP(TRIM(subcategory))
	END) AS subcategory,
COALESCE((CASE
	WHEN UPPER(TRIM(product_specs)) IN ('', 'NA', 'N/A', 'NULL', 'UNKNOWN', '?', '-') THEN 'N/A'
	ELSE UPPER(TRIM(product_specs))
	END), 'N/A') AS product_specs,
(CASE
    WHEN list_price IS NULL
    OR UPPER(TRIM(list_price)) IN ('', '-', '?', 'N/A', 'NA', 'NULL', 'UNKNOWN', 'TBD') THEN NULL  
    WHEN REGEXP_REPLACE(
        UPPER(TRIM(list_price)),
        '(RS\.?|INR|₹|,|/|-|\s)',
        '',
        'g'
    ) ~ '^\d+(\.\d+)?$'
        THEN REGEXP_REPLACE(
        UPPER(TRIM(list_price)),
            '(RS\.?|INR|₹|,|/|-|\s)',
            '',
            'g'
        )::NUMERIC
    ELSE NULL
	END) AS list_price,
(CASE
    WHEN standard_cost IS NULL
    OR UPPER(TRIM(standard_cost)) IN ('', '-', '?', 'N/A', 'NA', 'NULL', 'UNKNOWN', 'TBD') THEN NULL  
    WHEN REGEXP_REPLACE(
        UPPER(TRIM(standard_cost)),
        '(RS\.?|INR|₹|,|/|-|\s)',
        '',
        'g'
    ) ~ '^\d+(\.\d+)?$'
        THEN REGEXP_REPLACE(
        UPPER(TRIM(standard_cost)),
            '(RS\.?|INR|₹|,|/|-|\s)',
            '',
            'g'
        )::NUMERIC
    ELSE NULL
	END) AS standard_cost,
(CASE
    WHEN warranty_months IS NULL OR LOWER(TRIM(warranty_months)) IN ('', '-', 'na', 'n/a', 'null', 'unknown', '?')
    THEN NULL
    WHEN LOWER(TRIM(warranty_months)) IN ('1 year(s)', '12 months', '12m')
    THEN 12::NUMERIC
    WHEN LOWER(TRIM(warranty_months)) IN ('2 year(s)', '24 months', '24m')
    THEN 24::NUMERIC
    WHEN LOWER(TRIM(warranty_months)) IN ('3 year(s)', '36 months', '36m')
    THEN 36::NUMERIC
    WHEN LOWER(TRIM(warranty_months)) ~ '^\d+(\.\d+)?$'
    THEN TRIM(warranty_months)::NUMERIC
    WHEN LOWER(TRIM(warranty_months)) ~ '^\d+(\.\d+)?\s*months?$'
    THEN REGEXP_REPLACE(LOWER(TRIM(warranty_months)), '\s*months?$', '')::NUMERIC
    WHEN LOWER(TRIM(warranty_months)) ~ '^\d+(\.\d+)?\s*m$'
    THEN REGEXP_REPLACE(LOWER(TRIM(warranty_months)), '\s*m$', '')::NUMERIC
    WHEN LOWER(TRIM(warranty_months)) ~ '^\d+(\.\d+)?\s*year\(s\)$'
    THEN REGEXP_REPLACE(LOWER(TRIM(warranty_months)), '\s*year\(s\)$', '')::NUMERIC * 12
    ELSE NULL
	END) AS warranty_months,
(CASE	
	WHEN UPPER(TRIM(is_active)) IN('0','INACTIVE', 'N', 'NO') THEN 'No'
	WHEN UPPER(TRIM(is_active)) IN('1', 'ACTIVE', 'TRUE', 'Y','YES') THEN 'Yes'
	ELSE 'N/A'
	END) AS is_active
FROM bronze.products;
RAISE NOTICE 'Inserted Data in the silver.products table....';
end_time := clock_timestamp();
RAISE NOTICE 'Load Duration: %', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE 'Total Rows: %', (SELECT COUNT(*) FROM silver.products);
RAISE NOTICE '-----------------------------------------------';

-------------------------------------------------------------------------------------------------
-- 3.) Inserting data into the silver.stores table

RAISE NOTICE '-----------------------------------------------';
RAISE NOTICE 'Inserting Data In The silver.stores table....';
start_time := clock_timestamp();
TRUNCATE TABLE silver.stores;
INSERT INTO silver.stores(
store_key,
store_code, 
store_name,
channel_type,
city,
state,
region,
location_type,
opening_date_text,
store_status
)
SELECT store_key,
store_code,
COALESCE(INITCAP(TRIM(store_name)), 'N/A') AS store_name,
COALESCE((CASE
	WHEN UPPER(TRIM(channel_type))  IN ('', '-', 'na', 'n/a', 'null', 'unknown', '?') THEN 'N/A'
	WHEN INITCAP(TRIM(channel_type)) IN ('Retail', 'Retail Outlet') THEN 'Retail'
	ELSE INITCAP(TRIM(channel_type)) 
	END), 'N/A') AS channel_type,
COALESCE(INITCAP(TRIM(city)),'N/A') AS city,
COALESCE((CASE
	WHEN UPPER(TRIM(state)) IN ('', '-', 'na', 'n/a', 'null', 'unknown', '?')
	THEN 'N/A'
	ELSE INITCAP(TRIM(state))
	END), 'N/A') AS state,
COALESCE((CASE 
	WHEN UPPER(TRIM(region)) IN ('', '-', 'na', 'n/a', 'null', 'unknown', '?')
	THEN 'N/A'
	WHEN INITCAP(TRIM(region)) IN ('South Zone', 'South', 'S') THEN 'South'
	WHEN INITCAP(TRIM(region)) IN ('West', 'West Zone') THEN 'West'
	ELSE INITCAP(TRIM(region))
	END), 'N/A') AS region,
COALESCE(INITCAP(TRIM(location_type)), 'N/A') AS location_type,
silver.parse_date(opening_date_text) AS opening_date_text,
COALESCE((CASE	
	WHEN INITCAP(TRIM(store_status)) IN ('Y', 'True', 'Yes', 'Active', '1') THEN 'Open'
	WHEN INITCAP(TRIM(store_status)) IN ('N', 'False', 'No', 'Inactive', '0') THEN 'Close'
	ELSE 'N/A'
	END), 'N/A') AS store_status
FROM bronze.stores;
RAISE NOTICE 'Inserted Data in the silver.stores table....';
end_time := clock_timestamp();
RAISE NOTICE 'Load Duration: %', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE 'Total Rows: %', (SELECT COUNT(*) FROM silver.stores);
RAISE NOTICE '-----------------------------------------------';

-------------------------------------------------------------------------------------------------
-- 4.) Inserting data into the silver.dates table

RAISE NOTICE '-----------------------------------------------';
RAISE NOTICE 'Inserting Data In The silver.dates table....';
start_time := clock_timestamp();
TRUNCATE TABLE silver.dates;
INSERT INTO silver.dates(
date_key,
calendar_date_text,
calendar_year,
month_number,
month_name,
quarter,
day_name,
is_weekend,
holiday_label
)
SELECT 
date_key,
silver.parse_date(calendar_date_text) AS calendar_date_text,
TO_CHAR(
    silver.parse_date(calendar_date_text),
    'YYYY'
) AS calendar_year,
EXTRACT(
    MONTH FROM silver.parse_date(calendar_date_text)
)::INT::TEXT AS month_number,
TO_CHAR(
    silver.parse_date(calendar_date_text),
    'FMMonth'
) AS month_name,
EXTRACT(QUARTER FROM silver.parse_date(calendar_date_text))::INT AS quarter,
TO_CHAR(silver.parse_date(calendar_date_text), 'FMDay') AS day_name,
COALESCE((CASE
	WHEN EXTRACT(DOW FROM silver.parse_date(calendar_date_text)) IN(0,6)
	THEN 'YES'
	ELSE 'NO'
	END),'N/A') AS is_weekend,
(CASE
    WHEN UPPER(TRIM(holiday_label)) IN ('', '-', 'NA', 'N/A', 'NULL', 'UNKNOWN', '?')
    THEN 'N/A'
    ELSE INITCAP(TRIM(holiday_label))	
	END) AS holiday_label
FROM bronze.dates;
RAISE NOTICE 'Inserted Data in the silver.dates table....';
end_time := clock_timestamp();
RAISE NOTICE 'Load Duration: %', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE 'Total Rows: %', (SELECT COUNT(*) FROM silver.dates);
RAISE NOTICE '-----------------------------------------------';

-------------------------------------------------------------------------------------------------
-- 5.) Inserting data in the silver.sales table

RAISE NOTICE '-----------------------------------------------';
RAISE NOTICE 'Inserting Data In The silver.sales table....';
start_time := clock_timestamp();
TRUNCATE TABLE silver.sales;
INSERT INTO silver.sales(
sales_line_id,
order_id,
customer_key,
product_key,
store_key,
order_date_key,
order_date_text,
quantity,
unit_selling_price,
discount_rate,
unit_cost,
shipping_fee,
tax_rate,
payment_method,
order_status,
return_flag,
sales_amount_incl_tax,
line_cost_amount,
invoice_number
)
SELECT
COALESCE(sales_line_id, 'N/A') AS sales_line_id,
COALESCE(order_id, 'N/A') AS order_id,
COALESCE(customer_key, 'N/A') AS customer_key,
COALESCE(product_key, 'N/A') AS product_key,
COALESCE(store_key, 'N/A') AS store_key,
COALESCE(order_date_key, 'N/A') AS order_date_key,
silver.parse_date(order_date_text) AS order_date_text,
(CASE
    WHEN quantity IS NULL
    OR UPPER(TRIM(quantity)) IN ('', 'NULL', 'N/A', 'NA', 'UNKNOWN', '?')
    THEN NULL
    WHEN TRIM(quantity) ~ '^-\d+(\.\d+)?$'THEN 0::INTEGER
    WHEN LOWER(TRIM(quantity)) = 'one'   THEN 1
    WHEN LOWER(TRIM(quantity)) = 'two'   THEN 2
    WHEN LOWER(TRIM(quantity)) = 'three' THEN 3
    WHEN LOWER(TRIM(quantity)) = 'four'  THEN 4
	WHEN LOWER(TRIM(quantity)) = '1,0' THEN 1
    WHEN REGEXP_REPLACE(LOWER(TRIM(quantity)), '\s*pcs$', '') ~ '^\d+(\.\d+)?$'
    THEN GREATEST(REGEXP_REPLACE(LOWER(TRIM(quantity)), '\s*pcs$', '')::NUMERIC,0)::INTEGER
    ELSE NULL
	END) AS quantity,
(CASE
    WHEN unit_selling_price IS NULL
    OR UPPER(TRIM(unit_selling_price)) IN ('', '-', '?', 'N/A', 'NA', 'NULL', 'UNKNOWN', 'TBD')
    THEN NULL
    WHEN LOWER(TRIM(unit_selling_price)) = 'free'THEN 0::NUMERIC
    WHEN REGEXP_REPLACE(UPPER(TRIM(unit_selling_price)),'^(RS\.?|INR|₹)\s*|(/-?)\s*$|[,[:space:]]','','g') ~ '^-?\d+(\.\d+)?$'
    THEN ABS(REGEXP_REPLACE(UPPER(TRIM(unit_selling_price)),'^(RS\.?|INR|₹)\s*|(/-?)\s*$|[,[:space:]]','','g')::NUMERIC)
    ELSE NULL
	END) AS unit_selling_price,
(CASE
    WHEN discount_rate IS NULL
    OR UPPER(TRIM(discount_rate)) IN ('', '-', '?', 'N/A', 'NA', 'NULL', 'UNKNOWN')
    THEN NULL
    WHEN REGEXP_REPLACE(TRIM(discount_rate), '[%[:space:],]', '', 'g')
    !~ '^-?\d+(\.\d+)?$'
    THEN NULL
    WHEN REGEXP_REPLACE(TRIM(discount_rate), '[%[:space:],]', '', 'g')::NUMERIC < 0
    THEN 0::NUMERIC
    WHEN ABS(REGEXP_REPLACE(TRIM(discount_rate), '[%[:space:],]', '', 'g')::NUMERIC) < 1
    AND POSITION('%' IN discount_rate) = 0
    THEN ROUND(REGEXP_REPLACE(TRIM(discount_rate), '[%[:space:],]', '', 'g')::NUMERIC * 100,2)
    ELSE ROUND(REGEXP_REPLACE(TRIM(discount_rate), '[%[:space:],]', '', 'g')::NUMERIC,2)
	END) AS discount_rate,
(CASE
    WHEN unit_cost IS NULL
    OR UPPER(TRIM(unit_cost)) IN ('', '-', '?', 'N/A', 'NA', 'NULL', 'UNKNOWN', 'TBD')
    THEN NULL
    WHEN LOWER(TRIM(unit_cost)) = 'free'THEN 0::NUMERIC
    WHEN REGEXP_REPLACE(UPPER(TRIM(unit_cost)),'^(RS\.?|INR|₹)\s*|(/-?)\s*$|[,[:space:]]','','g') ~ '^-?\d+(\.\d+)?$'
    THEN ABS(REGEXP_REPLACE(UPPER(TRIM(unit_cost)),'^(RS\.?|INR|₹)\s*|(/-?)\s*$|[,[:space:]]','','g')::NUMERIC)
    ELSE NULL
	END) AS unit_cost,
(CASE
    WHEN shipping_fee IS NULL
    OR UPPER(TRIM(shipping_fee)) IN ('', '-', '?', 'N/A', 'NA', 'NULL', 'UNKNOWN', 'TBD')
    THEN NULL
    WHEN LOWER(TRIM(shipping_fee)) = 'free'THEN 0::NUMERIC
    WHEN REGEXP_REPLACE(UPPER(TRIM(shipping_fee)),'^(RS\.?|INR|₹)\s*|(/-?)\s*$|[,[:space:]]','','g') ~ '^-?\d+(\.\d+)?$'
    THEN ABS(REGEXP_REPLACE(UPPER(TRIM(shipping_fee)),'^(RS\.?|INR|₹)\s*|(/-?)\s*$|[,[:space:]]','','g')::NUMERIC)
    ELSE NULL
	END) AS shipping_fee,
(CASE
    WHEN tax_rate IS NULL
    OR UPPER(TRIM(tax_rate)) IN ('', '-', '?', 'N/A', 'NA', 'NULL', 'UNKNOWN')
    THEN NULL
    WHEN REGEXP_REPLACE(TRIM(tax_rate), '[%[:space:],]', '', 'g')
    !~ '^-?\d+(\.\d+)?$'
    THEN NULL
    WHEN REGEXP_REPLACE(TRIM(tax_rate), '[%[:space:],]', '', 'g')::NUMERIC < 0
    THEN 0::NUMERIC
    WHEN ABS(REGEXP_REPLACE(TRIM(tax_rate), '[%[:space:],]', '', 'g')::NUMERIC) < 1
    AND POSITION('%' IN tax_rate) = 0
    THEN ROUND(REGEXP_REPLACE(TRIM(tax_rate), '[%[:space:],]', '', 'g')::NUMERIC * 100,2)
    ELSE ROUND(REGEXP_REPLACE(TRIM(tax_rate), '[%[:space:],]', '', 'g')::NUMERIC,2)
	END) AS tax_rate,
COALESCE((CASE
	WHEN UPPER(TRIM(payment_method)) IN ('', '-', '?', 'N/A', 'NA', 'NULL', 'UNKNOWN') THEN 'N/A'
 	WHEN UPPER(TRIM(payment_method)) IN ('CREDIT CARD', 'CREDIT_CARD') THEN 'Credit Card'
	WHEN UPPER(TRIM(payment_method)) = 'EMI' THEN 'EMI'
	WHEN UPPER(TRIM(payment_method)) = 'UPI' THEN 'UPI'
	WHEN UPPER(TRIM(payment_method)) IN ('NET BANKING', 'NETBANKING') THEN 'Net Banking'
	WHEN UPPER(TRIM(payment_method)) IN ('COD', 'CASH ON DELIVERY') THEN 'Cash On Delivery'
	ELSE INITCAP(TRIM(payment_method))
	END),'N/A') AS payment_method,
COALESCE((CASE	
	WHEN UPPER(TRIM(order_status)) IN ('', '-', '?', 'N/A', 'NA', 'NULL', 'UNKNOWN') THEN 'N/A'
	WHEN UPPER(TRIM(order_status)) IN ('SHIPPED', 'IN TRANSIT') THEN 'Shipped'
	WHEN UPPER(TRIM(order_status)) IN ('COMPLETED', 'COMPLETE') THEN 'Completed'
	WHEN UPPER(TRIM(order_status)) IN ('RETURN', 'RETURNED') THEN 'Returned'
	ELSE INITCAP(TRIM(order_status))
	END), 'N/A') AS order_status,
COALESCE((CASE
	WHEN UPPER(return_flag) IN ('TRUE', 'YES', 'Y', '1', 'RETURNED', 'REFUNDED') THEN 'Returned'
	WHEN UPPER(return_flag) IN ('FALSE', 'NO','N', '0', 'NOT RETURNED', 'NO RETURN') THEN 'Not Returned'
	WHEN UPPER(TRIM(return_flag)) IN ('', '-', '?', 'N/A', 'NA', 'NULL', 'UNKNOWN') THEN 'N/A'
	ELSE INITCAP(TRIM(return_flag))
	END), 'N/A') AS return_flag,
(CASE
    WHEN sales_amount_incl_tax IS NULL
    OR UPPER(TRIM(sales_amount_incl_tax)) IN ('', '-', '?', 'N/A', 'NA', 'NULL', 'UNKNOWN', 'TBD')
    THEN NULL
    WHEN LOWER(TRIM(sales_amount_incl_tax)) = 'free'THEN 0::NUMERIC
    WHEN REGEXP_REPLACE(UPPER(TRIM(sales_amount_incl_tax)),'^(RS\.?|INR|₹)\s*|(/-?)\s*$|[,[:space:]]','','g') ~ '^-?\d+(\.\d+)?$'
    THEN ABS(REGEXP_REPLACE(UPPER(TRIM(sales_amount_incl_tax)),'^(RS\.?|INR|₹)\s*|(/-?)\s*$|[,[:space:]]','','g')::NUMERIC)
    ELSE NULL
	END) AS sales_amount_incl_tax, 
(CASE
    WHEN line_cost_amount IS NULL
    OR UPPER(TRIM(line_cost_amount)) IN ('', '-', '?', 'N/A', 'NA', 'NULL', 'UNKNOWN', 'TBD')
    THEN NULL
    WHEN LOWER(TRIM(line_cost_amount)) = 'free'THEN 0::NUMERIC
    WHEN REGEXP_REPLACE(UPPER(TRIM(line_cost_amount)),'^(RS\.?|INR|₹)\s*|(/-?)\s*$|[,[:space:]]','','g') ~ '^-?\d+(\.\d+)?$'
    THEN ABS(REGEXP_REPLACE(UPPER(TRIM(line_cost_amount)),'^(RS\.?|INR|₹)\s*|(/-?)\s*$|[,[:space:]]','','g')::NUMERIC)
    ELSE NULL
	END) AS line_cost_amount,
COALESCE(invoice_number, 'N/A') AS invoice_number
FROM bronze.sales;
RAISE NOTICE 'Inserted Data in the silver.sales table....';
end_time := clock_timestamp();
RAISE NOTICE 'Load Duration: %', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE 'Total Rows: %', (SELECT COUNT(*) FROM silver.sales);
RAISE NOTICE '-----------------------------------------------';
-------------------------------------------------------------------------------------------------
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';
RAISE NOTICE 'INSERTED DATA IN THE SILVER LAYER.......';
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';

EXCEPTION
    WHEN OTHERS THEN
    RAISE NOTICE 'Data Not Loaded !!: %', SQLERRM;
    RAISE;

END;
$$;



