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

🛠️ Key Technical Skills Demonstrated
Database Dialect Translation: Successfully refactored SQL Server syntax into MySQL, navigating complex differences in built-in functions (e.g., replacing LEN() with LENGTH(), and ISNULL() with IFNULL()).

Advanced Date Manipulation: Handled strict data type casting and formatting by converting 8-digit integers into standard dates using STR_TO_DATE(). Applied INTERVAL arithmetic within Window Functions to calculate product expiration dates.

Data Quality & Profiling: Engineered thorough data quality checks using GROUP BY, HAVING, and conditional logic to identify and resolve duplicate primary keys, referential integrity breaks, and orphan records across systems.

Complex Conditional Logic: Utilized both Simple and Searched CASE statements to clean categorical strings and implemented COALESCE() to seamlessly merge fragmented data points (e.g., customer gender) across different source systems
