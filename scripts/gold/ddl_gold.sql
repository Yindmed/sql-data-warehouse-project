   /*
============================================================ 
  DDL Script: Gold Views
============================================================
Script Purpose:

  This Script creates views for the Gold layer in the data wareohuse.
  The Gold layer represents the final dimension and fact tables (Star schema)

  Each view performs transformations and combines data from the Silver layer
  to produce a clean, enriched, and business-ready dataset.

Usage:
  - These views can be quiered directly for analytics and reporting

*/

/* ============================================================
   VIEW: gold.dim_customer
   Source:
   silver.crm_cust_info
   silver.erp_cust_az12
   silver.erp_loc_a101

   Objective:
   Create the customer dimension by combining customer master data
   from CRM with additional demographic and location data from ERP.
   ============================================================ */
IF OBJECT_ID('gold.dim_customers', 'V') IS NOT NULL
    DROP VIEW gold.dim_customers;
GO
CREATE VIEW gold.dim_customers AS 
SELECT
	ROW_NUMBER() OVER (ORDER BY cst_id) AS customer_key, -- Created a FK with WF 
	ci.cst_id AS customer_id,
	ci.cst_key AS customer_number,
	ci.cst_firstname AS first_name,
	ci.cst_lastname AS last_name,
	la.cntry AS country,
	ci.cst_marital_status AS marital_satus,
	CASE WHEN ci.cst_gndr <> 'n/a' THEN ci.cst_gndr -- CRM is the Master for gender info
		ELSE COALESCE(ca.gen, 'n/a')
	END AS new_gen,
	ca.bdate AS birthdate,
	ci.cst_create_date AS create_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 ca 
ON   ci.cst_key = ca.cid 
LEFT JOIN silver.erp_loc_a101 la 
ON  ci.cst_key = la.cid
;


/* ============================================================
   VIEW: gold.dim_products
   Source:
   silver.crm_prd_info
   silver.erp_px_cat_g1v2

   Objective:
   Create the product dimension by combining product master data
   with category information.

   Note:
   Only current products are included. Historical records are excluded.
   ============================================================ */
IF OBJECT_ID('gold.dim_products', 'V') IS NOT NULL
    DROP VIEW gold.dim_products;
GO
CREATE VIEW gold.dim_products AS 
SELECT 
	ROW_NUMBER() OVER (ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key -- Surrogate Key,
	pn.prd_id AS product_id,
	pn.prd_key AS product_number,
	pn.prd_nm AS product_name,
	pn.cat_id AS category_id,
	pc.cat AS category,
	pc.subcat AS subcategory,
	pc.maintence,
	pn.prd_cost AS cost,
	pn.prd_line AS product_line,
	pn.prd_start_dt AS start_date
FROM silver.crm_prd_info pn
LEFT JOIN silver.erp_px_cat_g1v2 pc 
ON pn.cat_id = pc.id
WHERE prd_end_dt IS NULL -- Keep only the latest active product records


/* ============================================================
   VIEW: gold.fact_sales
   Source:
   silver.crm_sales_details
   gold.dim_products
   gold.dim_customer

   Objective:
   Create the sales fact table by linking transactional sales data
   with customer and product dimensions.
   ============================================================ */
IF OBJECT_ID('gold.fact_sales', 'V') IS NOT NULL
    DROP VIEW gold.fact_sales;
GO
CREATE VIEW gold.fact_sales AS 
SELECT
	sd.sls_ord_num AS order_number,
	pr.product_key,
	cm.customer_key,
	sd.sls_order_dt AS order_date,
	sd.sls_ship_dt AS shipping_date,
	sd.sls_due_dt AS due_date,
	sd.sls_sales AS sales_amount,
	sd.sls_quantity AS quantity,
	sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products pr
ON sd.sls_prd_key = pr.product_number
LEFT JOIN gold.dim_customer cm
ON sd.sls_cust_id = cm.customer_id
