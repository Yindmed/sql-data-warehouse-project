# 🏗️ SQL Data Warehouse Project

> An end-to-end data warehousing solution built with SQL Server, following the **Medallion Architecture** (Bronze → Silver → Gold). This project covers ETL pipeline design, data modeling with star schema, and SQL-based analytics — built from the ground up as a personal portfolio project.

---

## 📌 Project Description

This project demonstrates how to design and implement a modern **Data Warehouse from scratch**, applying industry best practices in data engineering. Raw data from ERP and CRM systems is ingested, cleaned, and modeled into a structured, analytics-ready layer.

**What this project covers:**
- End-to-end ETL pipeline from raw CSV files to analytical models
- Medallion Architecture with three clearly defined data layers
- Star schema design for optimized querying and reporting
- SQL-based analytics and business reporting
- Fully documented data flows, architecture, and naming conventions

---

## 🏛️ Data Architecture

This project is structured around the **Medallion Architecture**, dividing the warehouse into three progressive layers:



<img width="500" height="500" alt="dataArchitecture" src="https://github.com/user-attachments/assets/d1df6ef9-2b71-46b3-9beb-5bcaa21fb25c" />


```
[ Source Systems ]
   CSV Files (ERP + CRM)
         │
         ▼
┌─────────────────────┐
│   🥉 BRONZE Layer   │  Raw data ingested as-is — no transformations
└─────────────────────┘
         │
         ▼
┌─────────────────────┐
│   🥈 SILVER Layer   │  Cleaned, standardized, and normalized data
└─────────────────────┘
         │
         ▼
┌─────────────────────┐
│   🥇 GOLD Layer     │  Business-ready star schema for analytics
└─────────────────────┘
         │
         ▼
[ Reports & Dashboards ]
```

| Layer | Purpose | Key Techniques |
|-------|---------|----------------|
| **Bronze** | Preserve raw source data exactly as received | Bulk insert, no transformations |
| **Silver** | Ensure data quality and consistency | Deduplication, type casting, normalization |
| **Gold** | Enable fast, reliable business analysis | Fact & dimension tables, star schema |

---

## 🗂️ Repository Structure

```
sql-data-warehouse-project/
│
├── datasets/                    # Raw source datasets (ERP and CRM CSV files)
│
├── docs/                        # Architecture and design documentation
│   ├── data_architecture.drawio     # High-level data architecture diagram
│   ├── data_catalog.md              # Field descriptions and metadata
│   ├── data_flow.drawio             # End-to-end data flow diagram
│   ├── data_models.drawio           # Star schema data models
│   ├── etl.drawio                   # ETL design and transformation logic
│   └── naming-conventions.md        # Naming guidelines for tables, columns & files
│
├── scripts/                     # SQL scripts organized by layer
│   ├── bronze/                      # Extract and load raw data
│   ├── silver/                      # Clean and transform data
│   └── gold/                        # Build analytical models
│
├── tests/                       # Data quality and validation scripts
│
├── README.md
└── LICENSE
```

---

## 🛠️ Tools & Requirements

All tools used in this project are freely available:

| Tool | Purpose | Link |
|------|---------|------|
| **SQL Server Express** | Local database engine | [Download](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) |
| **SSMS** (SQL Server Management Studio) | Database GUI and query editor | [Download](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms) |
| **Draw.io** | View and edit architecture diagrams | [app.diagrams.net](https://app.diagrams.net/) |
| **Git** | Version control | [git-scm.com](https://git-scm.com/) |

---

## 🎯 What This Project Demonstrates

- End-to-end data pipeline design  
- Data cleaning and transformation  
- Dimensional modeling  
- Writing analytical SQL queries

---

## 📄 License

This project is licensed under the **MIT License** — free to use, modify, and share with attribution.



