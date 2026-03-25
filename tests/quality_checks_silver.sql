/*
===============================================================================
QUALITY CHECKS - SILVER LAYER
===============================================================================
Script Purpose:
    This script performs data quality validations to ensure consistency,
    accuracy and standardization across the Silver layer.

    It validates:
    - Primary key integrity (NULLs / duplicates)
    - Unwanted spaces in text fields
    - Data standardization (categorical values)
    - Date format and logical consistency
    - Numerical consistency across related fields

    It also includes raw date validations from Bronze layer to ensure
    correct transformation into DATE format.

Usage Notes:
    - Run after loading Silver layer
    - Any returned result indicates a data issue to investigate
===============================================================================
*/

-- ====================================================================
-- CHECKING: silver.crm_cust_info
-- ====================================================================

-- Primary Key Check (NULLs / duplicates)
SELECT cst_id, COUNT(*) 
FROM silver.crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1 OR cst_id IS NULL;

-- Unwanted spaces
SELECT cst_key 
FROM silver.crm_cust_info
WHERE cst_key <> TRIM(cst_key);

-- Domain check
SELECT DISTINCT cst_marital_status 
FROM silver.crm_cust_info;

-- ====================================================================
-- CHECKING: silver.crm_prd_info
-- ====================================================================

-- Primary Key Check
SELECT prd_id, COUNT(*) 
FROM silver.crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- Unwanted spaces
SELECT prd_nm 
FROM silver.crm_prd_info
WHERE prd_nm <> TRIM(prd_nm);

-- Cost validation
SELECT prd_cost 
FROM silver.crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

-- Domain check
SELECT DISTINCT prd_line 
FROM silver.crm_prd_info;

-- Date consistency (start must be before end)
SELECT *
FROM silver.crm_prd_info
WHERE prd_end_dt < prd_start_dt;

-- ====================================================================
-- CHECKING: silver.crm_sales_details
-- ====================================================================

-- Date logical order
-- Expectation: order_date <= ship_date <= due_date
SELECT *
FROM silver.crm_sales_details
WHERE sls_order_dt > sls_ship_dt 
   OR sls_order_dt > sls_due_dt;

-- Numerical consistency: sales = quantity * price
SELECT DISTINCT 
    sls_sales,
    sls_quantity,
    sls_price 
FROM silver.crm_sales_details
WHERE sls_sales <> sls_quantity * sls_price
   OR sls_sales IS NULL 
   OR sls_quantity IS NULL 
   OR sls_price IS NULL
   OR sls_sales <= 0 
   OR sls_quantity <= 0 
   OR sls_price <= 0
ORDER BY sls_sales, sls_quantity, sls_price;

-- ====================================================================
-- CHECKING: silver.erp_cust_az12
-- ====================================================================

-- Birthdate validation
SELECT DISTINCT bdate 
FROM silver.erp_cust_az12
WHERE bdate < '1924-01-01' 
   OR bdate > GETDATE();

-- Domain check
SELECT DISTINCT gen 
FROM silver.erp_cust_az12;

-- ====================================================================
-- CHECKING: silver.erp_loc_a101
-- ====================================================================

-- Domain check
SELECT DISTINCT cntry 
FROM silver.erp_loc_a101
ORDER BY cntry;

-- ====================================================================
-- CHECKING: silver.erp_px_cat_g1v2
-- ====================================================================

-- Unwanted spaces
SELECT *
FROM silver.erp_px_cat_g1v2
WHERE cat <> TRIM(cat) 
   OR subcat <> TRIM(subcat) 
   OR maintence <> TRIM(maintence);

-- Domain check
SELECT DISTINCT maintence 
FROM silver.erp_px_cat_g1v2;



/* ====================================================================
   EXTRA CHECKS: RAW DATE VALIDATION (BRONZE LAYER)
   ==================================================================== */

-- Validate raw date format before transformation (YYYYMMDD)
-- Detect invalid structure or out-of-range values

SELECT sls_ship_date
FROM bronze.crm_sales_details
WHERE sls_ship_date IS NULL
   OR sls_ship_date = 0
   OR LEN(CAST(sls_ship_date AS VARCHAR)) <> 8
   OR CAST(sls_ship_date AS VARCHAR) NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'
   OR CAST(sls_ship_date AS VARCHAR) < '19000101'
   OR CAST(sls_ship_date AS VARCHAR) > '20500101';
