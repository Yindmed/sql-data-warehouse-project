/* ============================================================
   STORED PROCEDURE: Load Silver Layer
   ============================================================

   DESCRIPTION:
   This stored procedure loads and transforms data from the 
   Bronze layer into the Silver layer.

   It performs:
   - Data cleansing (TRIM, NULL handling)
   - Data standardization (CASE, mappings)
   - Deduplication (ROW_NUMBER)
   - Data type conversions (e.g. DATE)
   - Basic business rules (sales and price corrections)

   Tables are truncated before loading to ensure a full refresh.

   USAGE:
   EXEC silver.load_silver;
   ============================================================ */


CREATE OR ALTER PROCEDURE silver.load_silver AS
BEGIN
	-- Variables para medir tiempo por tabla y del proceso completo
    DECLARE @start_time DATETIME, 
            @end_time DATETIME, 
            @batch_start_time DATETIME, 
            @batch_end_time DATETIME;

	BEGIN TRY
        -- Inicio de la carga completa de la capa Bronze
        SET @batch_start_time = GETDATE();

        PRINT '==========================================';
        PRINT 'Loading Silver Layer';
        PRINT '==========================================';

        PRINT '------------------------------------------';
        PRINT 'Loading CRM Tables';
        PRINT '------------------------------------------';

        SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_info'
		TRUNCATE TABLE silver.crm_cust_info 
		PRINT '>> Inserting Data Into: silver.crm_info'
		INSERT INTO silver.crm_cust_info (
			cst_id,
			cst_key,
			cst_firstname,
			cst_lastname,
			cst_marital_status,
			cst_gndr,
			cst_create_date
		)
		SELECT 
			cst_id,
			cst_key,
			TRIM(cst_firstname) AS cst_firstname, -- Remove unwanted spaces
			TRIM(cst_lastname) AS cst_lastname,   -- Remove unwanted spaces
			CASE 
				WHEN TRIM(cst_marital_status) = 'S' THEN 'Single'
				WHEN TRIM(cst_marital_status) = 'M' THEN 'Married'
				ELSE 'n/a'
			END AS cst_marital_status, -- Standardize marital status values
			CASE 
				WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
				WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
				ELSE 'n/a'
			END AS cst_gndr, -- Standardize gender values
			cst_create_date
		FROM (
			SELECT 
				*,
				ROW_NUMBER() OVER (
					PARTITION BY cst_id           -- Group records by customer ID
					ORDER BY cst_create_date DESC -- Keep the most recent record first
				) AS flag_last
			FROM bronze.crm_cust_info
			WHERE cst_id IS NOT NULL -- Exclude records with NULL primary key
		) t WHERE flag_last = 1; -- Keep only the latest record per customer

		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ---------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_prd_info'
		TRUNCATE TABLE silver.crm_prd_info 
		PRINT '>> Inserting Data Into: silver.crm_prd_info'
		INSERT INTO silver.crm_prd_info(
			prd_id,
			cat_id,
			prd_key,
			prd_nm,
			prd_cost,
			prd_line,
			prd_start_dt,
			prd_end_dt
		)
		SELECT 
			prd_id,
			REPLACE(SUBSTRING(prd_key, 1, 5),'-', '_') AS cat_id, -- Extract category ID from prd_key (first 5 characters)
			SUBSTRING(prd_key, 7, LEN(prd_key)) AS prd_key, -- Extract product key (removing category prefix)
			prd_nm,
			ISNULL(prd_cost, 0) AS prd_cost, -- Replace NULL costs with 0 (business decision)
			CASE UPPER(TRIM(prd_line))  -- Standardize product line values
				WHEN 'M' THEN 'Mountain'
				WHEN 'R' THEN 'Road'
				WHEN 'S' THEN 'Other Sales'
				WHEN 'T' THEN 'Touring'
				ELSE 'n/a'
			END AS prd_line,
	
			CAST (prd_start_dt AS DATE) AS prd_start_dt,
			CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key ORDER BY prd_start_dt)-1 AS DATE) AS prd_end_dt   -- Get the next start date for the same product
		FROM bronze.crm_prd_info;

		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ---------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.crm_sales_details'
		TRUNCATE TABLE silver.crm_sales_details
		PRINT '>> Inserting Data Into: silver.crm_sales_details'
		INSERT INTO silver.crm_sales_details(
			sls_ord_num,
			sls_prd_key,
			sls_cust_id,
			sls_order_dt,
			sls_ship_dt,
			sls_due_dt,
			sls_sales,
			sls_quantity,
			sls_price
		)
		SELECT 
			sls_ord_num,  
			sls_prd_key,  -- Product key, related to prd_key in crm_prd_info
			sls_cust_id,  -- Customer ID, related to cst_id in crm_cust_info
			CASE  -- Convert raw order date to DATE
				WHEN sls_order_dt = 0 OR LEN(sls_order_dt) <> 8 THEN NULL
				ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
			END AS sls_order_dt,

			CASE -- Convert raw ship date to DATE
				WHEN sls_ship_date = 0 OR LEN(sls_ship_date) <> 8 THEN NULL
				ELSE CAST(CAST(sls_ship_date AS VARCHAR) AS DATE)
			END AS sls_ship_dt,

			-- Convert raw due date to DATE
			-- Invalid values are replaced with NULL
			CASE
				WHEN sls_due_dt = 0 OR LEN(sls_due_dt) <> 8 THEN NULL
				ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
			END AS sls_due_dt,
    
			CASE 
				WHEN sls_sales IS NULL 
					 OR sls_sales <= 0 
					 OR sls_sales <> sls_quantity * ABS(sls_price)
				THEN sls_quantity * ABS(sls_price)
				ELSE sls_sales
			END AS sls_sales, -- recalculate sales if original value is missing or incorrect 
			sls_quantity, 
			CASE 
				WHEN sls_price IS NULL OR sls_price <= 0
				THEN sls_sales / NULLIF(sls_quantity, 0)
				ELSE sls_price -- Derive price if original value is invalid
			END AS sls_price
		FROM bronze.crm_sales_details;
		
		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ---------------------------------------';


		PRINT '------------------------------------------';
        PRINT 'Loading ERP Tables';
        PRINT '------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_cust_az12'
		TRUNCATE TABLE silver.erp_cust_az12
		PRINT '>>Inserting Data Into: silver.erp_cust_az12'
		INSERT INTO silver.erp_cust_az12(cid,bdate,gen)
		SELECT 
			CASE -- Standardize customer ID
				WHEN cid IS NULL THEN NULL
				WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4, LEN(cid) - 3)
				ELSE cid
			END AS cid,
			CASE -- Validate birthdate
				WHEN bdate > GETDATE() OR bdate < '1900-01-01' THEN NULL
				ELSE bdate
			END AS bdate,
			CASE -- Normalize gender values
				WHEN gen IS NULL OR TRIM(gen) = '' THEN 'n/a'
				WHEN UPPER(TRIM(gen)) IN ('F', 'FEMALE') THEN 'Female'
				WHEN UPPER(TRIM(gen)) IN ('M', 'MALE') THEN 'Male'
				ELSE 'n/a'
			END AS gen
		FROM bronze.erp_cust_az12;

		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ---------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_loc_a101'
		TRUNCATE TABLE silver.erp_loc_a101
		PRINT '>> Inserting Data Into: silver.erp_loc_a101'
		INSERT INTO silver.erp_loc_a101(cid, cntry)
		SELECT 
			-- Clean customer ID:
			-- Remove '-' characters to standardize format
			REPLACE(cid, '-', '') AS cid,
			-- Normalize country values:
			-- Handle nulls and empty strings
			CASE
				WHEN cntry IS NULL OR TRIM(cntry) = '' THEN 'n/a'
				WHEN UPPER(TRIM(cntry)) = 'DE' THEN 'Germany'
				WHEN UPPER(TRIM(cntry)) IN ('US','USA') THEN 'United States'
				ELSE TRIM(cntry) -- Keep cleaned original value
			END AS cntry
		FROM bronze.erp_loc_a101;

		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ---------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>> Truncating Table: silver.erp_px_cat_g1v2'
		TRUNCATE TABLE silver.erp_px_cat_g1v2
		PRINT '>> Inserting Data Into: silver.erp_px_cat_g1v2'
		INSERT INTO silver.erp_px_cat_g1v2(id, cat, subcat, maintence)
		SELECT 
			id,
			cat,
			subcat,
			maintence
		FROM bronze.erp_px_cat_g1v2

		SET @end_time = GETDATE();
        PRINT '>> Load Duration: ' + CAST(DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
        PRINT '>> ---------------------------------------';
		END TRY

		BEGIN CATCH
        -- Captura y muestra información básica del error
        PRINT '=========================================';
        PRINT 'ERROR OCCURED DURING LOADING BRONZE LAYER';
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        PRINT 'Error State: ' + CAST(ERROR_STATE() AS NVARCHAR);
        PRINT '=========================================';
    END CATCH
END

EXEC silver.load_silver
