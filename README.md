# 🏗️ SQL Data Warehouse Project

> Una solución completa de Data Warehouse construida con SQL Server, siguiendo la Arquitectura Medallion (Bronze → Silver → Gold). Este proyecto cubre el diseño de pipelines ETL, modelado de datos con esquema estrella y analítica basada en SQL — desarrollado desde cero como proyecto personal de portfolio.

> An end-to-end data warehousing solution built with SQL Server, following the **Medallion Architecture** (Bronze → Silver → Gold). This project covers ETL pipeline design, data modeling with star schema, and SQL-based analytics — built from the ground up as a personal portfolio project.

> Proyecto inspirado en el enfoque y buenas prácticas de Data With Baraa | Project inspired by the approach and best practices of Data With Baraa
> www.youtube.com/@DataWithBaraa

---

## 📌 Project Description

> ES: Este proyecto demuestra cómo diseñar e implementar un Data Warehouse moderno desde cero, aplicando buenas prácticas de la industria en ingeniería de datos. Los datos en bruto provenientes de sistemas ERP y CRM son ingeridos, limpiados y modelados en una capa estructurada lista para análisis.

> This project demonstrates how to design and implement a modern **Data Warehouse from scratch**, applying industry best practices in data engineering. Raw data from ERP and CRM systems is ingested, cleaned, and modeled into a structured, analytics-ready layer.

**What this project covers:**
- Pipeline ETL completo desde archivos CSV hasta modelos analíticos | End-to-end ETL pipeline from raw CSV files to analytical models
- Arquitectura Medallion con tres capas de datos claramente definidas | Medallion Architecture with three clearly defined data layers
- Diseño de esquema estrella para consultas y reporting optimizados | Star schema design for optimized querying and reporting
- Analítica basada en SQL y reporting de negocio | SQL-based analytics and business reporting
- Flujos de datos, arquitectura y convenciones de nomenclatura completamente documentados | Fully documented data flows, architecture, and naming conventions

---

## 🏛️ Data Architecture

ES: Este proyecto está estructurado siguiendo la Arquitectura Medallion, dividiendo el Data Warehouse en tres capas progresivas:

EN: This project is structured around the **Medallion Architecture**, dividing the warehouse into three progressive layers:



<img width="1000" height="600" alt="dataArchitecture" src="https://github.com/user-attachments/assets/d1df6ef9-2b71-46b3-9beb-5bcaa21fb25c" />

---

````
[ Sistemas Fuente ]
   Archivos CSV (ERP + CRM)
         │
         ▼
┌─────────────────────┐
│   🥉 CAPA BRONZE    │  Datos en bruto ingeridos tal cual — sin transformaciones
└─────────────────────┘
         │
         ▼
┌─────────────────────┐
│   🥈 CAPA SILVER    │  Datos limpios, estandarizados y normalizados
└─────────────────────┘
         │
         ▼
┌─────────────────────┐
│   🥇 CAPA GOLD      │  Esquema estrella listo para análisis de negocio
└─────────────────────┘
         │
         ▼
[ Informes y Dashboards ]

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


| Layer | Purpose | Key Techniques |
|-------|---------|----------------|
| **Bronze** | Preserve raw source data exactly as received | Bulk insert, no transformations |
| **Silver** | Ensure data quality and consistency | Deduplication, type casting, normalization |
| **Gold** | Enable fast, reliable business analysis | Fact & dimension tables, star schema |

---

````
## 🗂️Estuctura / Repository Structure

````
sql-data-warehouse-project/
│
├── datasets/                    # Raw source datasets (ERP and CRM CSV files)
│
├── docs/                        # Architecture and design documentation
│   ├── data_architecture.drawio     # High-level data architecture diagram
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

````
---

## 🛠️ Tools & Requirements

ES: Todas las herramientas utilizadas en este proyecto son gratuitas:
EN: All tools used in this project are freely available:

| Tool | Purpose | Link |
|------|---------|------|
| **SQL Server Express** | Local database engine | [Download](https://www.microsoft.com/en-us/sql-server/sql-server-downloads) |
| **SSMS** (SQL Server Management Studio) | Database GUI and query editor | [Download](https://learn.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms) |
| **Draw.io** | View and edit architecture diagrams | [app.diagrams.net](https://app.diagrams.net/) |
| **Git** | Version control | [git-scm.com](https://git-scm.com/) |

---

## 🎯 What This Project Demonstrates / ¿Que demuestra este proyecto?

- Diseño completo de pipelines de datos | End-to-end data pipeline design  
- Limpieza y transformación de datos| Data cleaning and transformation
- Modelado dimensional | Dimensional modeling
- Escritura de consultas analíticas en SQL | Writing analytical SQL queries
---

## 📄 License

This project is licensed under the **MIT License** — free to use, modify, and share with attribution.



