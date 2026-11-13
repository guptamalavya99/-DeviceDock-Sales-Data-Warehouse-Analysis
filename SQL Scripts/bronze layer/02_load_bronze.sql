-- =====================================================================
-- BRONZE LAYER | BULK DATA LOADING
-- Script: 02_load_bronze.sql
-- Purpose: Bulk import raw source data from CSV files into Bronze tables.
-- Method: Load source data without applying transformations or cleansing
--         to preserve the original values for subsequent processing.
-- =====================================================================

CREATE OR REPLACE PROCEDURE bronze.load_bronze()
LANGUAGE plpgsql 
AS $$
DECLARE
	start_time TIMESTAMPTZ;
	end_time TIMESTAMPTZ;
BEGIN
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';
RAISE NOTICE 'INSERTING DATA IN BRONZE TABLES:';
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';
--------------------------------------------------------------------------------------------------------------------------------------
-- 1.) Inserting data in the sales table
RAISE NOTICE '------------------------------------------';
RAISE NOTICE 'Inserting Data Inside: bronze.sales........';
start_time := clock_timestamp();
TRUNCATE TABLE bronze.sales;
COPY bronze.sales
FROM 'C:\Users\Ranu Gupta\OneDrive\Desktop\DeviceDock_Project\Dataset\sales.csv'
WITH(
FORMAT csv,
HEADER true
);

RAISE NOTICE 'bronze.sales Data Loading Completed !!';
end_time := clock_timestamp();
RAISE NOTICE 'Load Duration : % seconds', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE 'Total Rows: %', (SELECT COUNT(*) FROM bronze.sales);
RAISE NOTICE '------------------------------------------';

--------------------------------------------------------------------------------------------------------------------------------------
-- 2.) Inserting data in the customers table
RAISE NOTICE '------------------------------------------';
RAISE NOTICE 'Inserting Data Inside: bronze.customers........';
start_time := clock_timestamp();
TRUNCATE TABLE bronze.customers;
COPY bronze.customers
FROM 'C:\Users\Ranu Gupta\OneDrive\Desktop\DeviceDock_Project\Dataset\customers.csv'
WITH(
FORMAT csv,
HEADER true
);

RAISE NOTICE 'bronze.customers Data Loading Completed !!';
end_time := clock_timestamp();
RAISE NOTICE 'Load Duration : % seconds', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE 'Total Rows: %', (SELECT COUNT(*) FROM bronze.customers);
RAISE NOTICE '------------------------------------------';

--------------------------------------------------------------------------------------------------------------------------------------
-- 3.) Inserting data in the products table
RAISE NOTICE '------------------------------------------';
RAISE NOTICE 'Inserting Data Inside: bronze.products........';
start_time := clock_timestamp();
TRUNCATE TABLE bronze.products;
COPY bronze.products
FROM 'C:\Users\Ranu Gupta\OneDrive\Desktop\DeviceDock_Project\Dataset\products.csv'
WITH(
FORMAT csv,
HEADER true
);

RAISE NOTICE 'bronze.products Data Loading Completed !!';
end_time := clock_timestamp();
RAISE NOTICE 'Load Duration : % seconds', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE 'Total Rows: %', (SELECT COUNT(*) FROM bronze.products);
RAISE NOTICE '------------------------------------------';

--------------------------------------------------------------------------------------------------------------------------------------
-- 4.) Inserting data in the stores table
RAISE NOTICE '------------------------------------------';
RAISE NOTICE 'Inserting Data Inside: bronze.stores........';
start_time := clock_timestamp();
TRUNCATE TABLE bronze.stores;
COPY bronze.stores
FROM 'C:\Users\Ranu Gupta\OneDrive\Desktop\DeviceDock_Project\Dataset\stores.csv'
WITH (
FORMAT csv,
HEADER true
);

RAISE NOTICE 'bronze.stores Data Loading Completed !!';
end_time := clock_timestamp();
RAISE NOTICE 'Load Duration : % seconds', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE 'Total Rows: %', (SELECT COUNT(*) FROM bronze.stores);
RAISE NOTICE '------------------------------------------';

--------------------------------------------------------------------------------------------------------------------------------------
-- 5.) Inserting data in the dates table
RAISE NOTICE '------------------------------------------';
RAISE NOTICE 'Inserting Data Inside: bronze.dates........';
start_time := clock_timestamp();
TRUNCATE TABLE bronze.dates;
COPY bronze.dates
FROM 'C:\Users\Ranu Gupta\OneDrive\Desktop\DeviceDock_Project\Dataset\dates.csv'
WITH(
FORMAT csv,
HEADER true
);

RAISE NOTICE 'bronze.dates Data Loading Completed !!';
end_time := clock_timestamp();
RAISE NOTICE 'Load Duration : % seconds', ROUND(EXTRACT(EPOCH FROM(end_time - start_time)) :: NUMERIC,3);
RAISE NOTICE 'Total Rows: %', (SELECT COUNT(*) FROM bronze.dates);
RAISE NOTICE '------------------------------------------';

--------------------------------------------------------------------------------------------------------------------------------------
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';
RAISE NOTICE 'ALL DATA INSERTED IN THE BRONZE TABLES !!';
RAISE NOTICE '\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\';

EXCEPTION
	WHEN OTHERS THEN 
	RAISE NOTICE 'Data Inserting Failed: %', SQLERRM;
	RAISE;
END;
$$;


