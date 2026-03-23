/* ============================================================
   PURPOSE
   ============================================================
   This script creates the BRONZE layer tables for the Data Warehouse.

   The Bronze layer is responsible for storing raw data ingested 
   from source systems (CRM and ERP) with minimal or no transformations.

   Key characteristics:
   - Data is loaded "as-is" from source files (CSV)
   - No business logic is applied at this stage
   - Used as the foundation for further transformations (Silver layer)
   - Tables are recreated to ensure a clean load environment

   Source Systems:
   - CRM: Customer, Product, Sales data
   - ERP: Location, Customer, Product Category data

   Notes:
   - Tables are dropped and recreated on each execution
   - Designed for full reload (not incremental)
   - Data types reflect source structure (raw ingestion)
   ============================================================ */

-- ============================================
-- CRM CUSTOMER INFO
-- ============================================
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info(
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE
);
GO

-- ============================================
-- CRM PRODUCT INFO
-- ============================================
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info(
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATETIME,
    prd_end_dt DATETIME
);
GO

-- ============================================
-- CRM SALES DETAILS
-- ============================================
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details(
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_date INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);
GO

-- ============================================
-- ERP LOCATION
-- ============================================
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;

CREATE TABLE bronze.erp_loc_a101(
    cid NVARCHAR(50),
    cntry NVARCHAR(50)
);
GO

-- ============================================
-- ERP CUSTOMER
-- ============================================
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12(
    cid NVARCHAR(50),
    bdate DATE,
    gen NVARCHAR(50) 
);
GO

-- ============================================
-- ERP PRODUCT CATEGORY
-- ============================================
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze.erp_px_cat_g1v2;

CREATE TABLE bronze.erp_px_cat_g1v2(
    id NVARCHAR(50),
    cat NVARCHAR(50),
    subcat NVARCHAR(50),
    maintence NVARCHAR(50) 
);
GO
