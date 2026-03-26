# Data Catalog - Gold Layer

## Overview
The Gold Layer represents the final business-ready data model, designed for analysis and reporting.

It follows a Star Schema:
- FACT → transactional data
- DIM → descriptive data

---

## 1. gold.dim_customer
- Purpose: Stores customer details enriched with demographic and geographic data.

| Column Name      | Data Type     | Description |
|------------------|---------------|------------|
| customer_key     | INT           | Surrogate key generated using a window function. |
| customer_id      | INT           | Unique identifier for each customer. |
| customer_number  | NVARCHAR(50)  | Business key used to identify the customer. |
| first_name       | NVARCHAR(50)  | Customer first name. |
| last_name        | NVARCHAR(50)  | Customer last name. |
| country          | NVARCHAR(50)  | Country of residence. |
| marital_status   | NVARCHAR(50)  | Standardized marital status. |
| gender           | NVARCHAR(50)  | Gender (CRM prioritized, ERP as fallback). |
| birthdate        | DATE          | Customer birth date. |
| create_date      | DATE          | Record creation date. |

---

## 2. gold.dim_products
- Purpose: Provides product information and categorization.

| Column Name         | Data Type     | Description |
|---------------------|---------------|------------|
| product_key         | INT           | Surrogate key generated for the product dimension. |
| product_id          | INT           | Internal product identifier. |
| product_number      | NVARCHAR(50)  | Business product key. |
| product_name        | NVARCHAR(50)  | Product name. |
| category_id         | NVARCHAR(50)  | Category identifier. |
| category            | NVARCHAR(50)  | Product category. |
| subcategory         | NVARCHAR(50)  | Product subcategory. |
| maintenance_required| NVARCHAR(50)  | Indicates if maintenance is required. |
| cost                | INT           | Product cost. |
| product_line        | NVARCHAR(50)  | Product line classification. |
| start_date          | DATE          | Product availability date. |

Note:
Only current records are used (`prd_end_dt IS NULL`).

---

## 3. gold.fact_sales
- Purpose: Stores transactional sales data for analysis.

| Column Name     | Data Type     | Description |
|-----------------|---------------|------------|
| order_number    | NVARCHAR(50)  | Unique order identifier. |
| product_key     | INT           | FK (foreign key → clave foránea) to product dimension. |
| customer_key    | INT           | FK (foreign key → clave foránea) to customer dimension. |
| order_date      | DATE          | Order date. |
| shipping_date   | DATE          | Shipping date. |
| due_date        | DATE          | Due date. |
| sales_amount    | INT           | Total sales value. |
| quantity        | INT           | Units sold. |
| price           | INT           | Unit price. |

---

## Final Notes
The goal of this layer is to provide clean, consistent and well-related data ready for BI tools.

Focus:
- clear relationships (FKs)
- consistent business logic
- easy analytical queries
