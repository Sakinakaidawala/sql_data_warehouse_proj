End-to-End Data Warehouse Construction (MySQL)
Author: Sakina Kaidawala

📝 Project Overview
This project demonstrates the end-to-end design and implementation of a custom Data Warehouse using MySQL. The objective was to ingest raw, messy data from multiple source systems (CRM and ERP), perform extensive data profiling, execute complex transformations, and ultimately model the data into a Star Schema optimized for Business Intelligence reporting.

Notably, this project involved translating and refactoring an architecture originally designed for SQL Server into a fully optimized MySQL environment, requiring deep knowledge of database dialect differences, syntax mapping, and data type handling.

🏗️ Architecture: The Medallion Paradigm
This data warehouse follows a structured three-tier architecture to ensure data quality and traceability:

🥉 Bronze Layer (Raw):

Ingested raw CSV data into unformatted staging tables.

Automated the ingestion and truncation process using MySQL Stored Procedures (load_bronze).

🥈 Silver Layer (Cleansed & Conformed):

Performed rigorous Exploratory Data Analysis (EDA) to identify nulls, duplicates, white spaces, and logic errors.

Executed heavy data transformations: standardized text formatting, handled missing values, derived calculated metrics, and enforced data integrity.

Automated via the load_silver Stored Procedure.

🥇 Gold Layer (Presentation / Star Schema):

Modeled the cleansed data into a robust Star Schema consisting of Dimension tables (Customer, Product) and a Fact table (Sales).

Generated custom Surrogate Keys using Window Functions (ROW_NUMBER()).

Implemented via idempotent CREATE VIEW scripts to serve as the direct semantic layer for reporting tools like Power BI or Tableau.

📊 Data Analysis & Business Intelligence
Beyond data engineering, this project includes a robust analytical suite designed to extract actionable business insights from the Gold layer:

Exploratory Data Analysis (EDA): Calculated high-level KPIs, mapped geographic/demographic distributions, and audited the final Star Schema for reporting readiness.

Time-Series & Cumulative Analysis: Leveraged advanced Window Functions (SUM() OVER(), LAG() OVER()) to calculate running totals, moving averages, and Year-over-Year (YoY) revenue performance.

Data Segmentation: Categorized products into pricing tiers and customers into dynamic cohorts (VIP, Regular, New) using CTEs and complex searched CASE statements based on lifetime value and tenure.

Part-to-Whole & Ranking Analysis: Identified top-performing products and high-value customers using LIMIT, ROW_NUMBER(), and calculated percentage contributions to total revenue.

Comprehensive BI Reporting Views: Engineered 'Customer 360' and 'Product 360' reporting views. Implemented defensive programming (like NULLIF()) to safely calculate Average Order Value (AOV), Average Monthly Spend, and lifecycle metrics without risking divide-by-zero errors.

🛠️ Key Technical Skills Demonstrated
Database Dialect Translation: Successfully refactored SQL Server syntax into MySQL, navigating complex differences in built-in functions (e.g., replacing LEN() with LENGTH(), and ISNULL() with IFNULL()), and adjusting strict date logic parameters (TIMESTAMPDIFF vs DATEDIFF).

Advanced Date Manipulation: Handled strict data type casting and formatting by converting 8-digit integers into standard dates using STR_TO_DATE(). Applied INTERVAL arithmetic and DATE_FORMAT() to group granular timestamps for time-series aggregation.

Data Quality & Profiling: Engineered thorough data quality checks using GROUP BY, HAVING, and conditional logic to identify and resolve duplicate primary keys, referential integrity breaks, and orphan records across systems.

Complex Conditional Logic: Utilized both Simple and Searched CASE statements to clean categorical strings and implemented COALESCE() to seamlessly merge fragmented data points (e.g., customer gender) across different source systems.
