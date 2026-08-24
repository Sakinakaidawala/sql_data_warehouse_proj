/*
===============================================================================
Script:           Exploratory Data Analysis (EDA) & Key Metrics
Author:           Sakina Kaidawala
===========================================================================
What this script does:      
This script explores the final Gold layer of the data warehouse. It calculates 
the high-level business Key Performance Indicators (KPIs), analyzes customer 
demographics, and audits the database structure to ensure everything is ready 
for reporting dashboards.

Things I did in this code:
  - Database Auditing: Queried the 'information_schema' to verify table 
    structures and column metadata.
  - Dimension Profiling: Used DISTINCT to map out geographic regions and 
    product hierarchies (categories/subcategories).
  - Date Math & Age Calculation: Used MySQL's TIMESTAMPDIFF() and CURDATE() to 
    find the exact lifespan of our sales data and the ages of our customers.
  - Core Business Aggregations: Calculated Total Revenue, Total Orders, Average 
    Price, and Unique Customers using SUM(), AVG(), and COUNT(DISTINCT).
  - Executive Summary: Combined all the individual KPI queries into a single, 
    clean summary table using UNION ALL for easy dashboard integration.
===============================================================================
*/
-- ============================================
-- Database exploration
-- ============================================
SELECT table_name, table_type, table_rows
FROM information_schema.tables
WHERE table_schema = 'datawarehouse';

SELECT *
FROM information_schema.columns
WHERE table_schema = 'datawarehouse' AND table_name = 'g_dim_customer';

-- ============================================
-- Dimension exploration
-- ============================================ 
SELECT * FROM g_dim_customer;
SELECT * FROM g_dim_products;
SELECT * FROM g_fact_sales;
-- Exploring all country our customers are from 
SELECT DISTINCT country
FROM g_dim_customer;

-- Exploring all category (major division)
SELECT DISTINCT category, subcategory,product_name
FROM g_dim_products;

-- ============================================
-- Date exploration
-- ============================================ 
SELECT 
MIN(order_date) AS first_order_date,
MAX(order_date) AS last_order_date
FROM g_sales;

-- find how many year of sale are available
SELECT
MIN(order_date) AS first_order_date,
MAX(order_date) AS last_order_date,
TIMESTAMPDIFF(MONTH,MIN(order_date),MAX(order_date)) order_date_range
FROM g_sales;

-- Find the are of customers
SELECT
MIN(birthdate) oldest_birthdate,
TIMESTAMPDIFF (YEAR, MIN(birthdate), CURDATE()) oldest,
MAX(birthdate) youngest_birthdate,
TIMESTAMPDIFF (YEAR, MAX(birthdate), CURDATE()) youngest
FROM g_dim_customer;

-- ============================================
-- measure exploration
-- ============================================ 
-- find the total sale
SELECT SUM(sales) AS total_sales
FROM g_sales;

-- Show how many items are sold
SELECT SUM(quantity) total_quantity_sold
FROM g_sales;

-- Find the avg selling price
SELECT AVG(price) avg_price
FROM g_sales;

-- Fiend the total number of order
SELECT COUNT(DISTINCT order_number) total_order
from g_fact_sales;

-- Fiend the total number of Product
SELECT COUNT(DISTINCT product_id) total_products
FROM g_dim_products;

-- Find the total number of customers
SELECT COUNT(DISTINCT customer_id) total_customers
FROM g_dim_customer;

-- Find the total number of customers who place order
SELECT COUNT(DISTINCT customer_key) total_customers
FROM g_fact_sales;

-- generate the report of all key metrix
SELECT 'total_sales' AS measure_name, SUM(sales) AS measure_value FROM g_fact_sales
UNION ALL 
SELECT 'total_quantities' AS measure_name, SUM(quantity)FROM g_fact_sales
UNION ALL 
SELECT 'avg_price' AS measure_name, AVG(price)FROM g_fact_sales
UNION ALL
SELECT 'total_no_orders' AS measure_name, COUNT(DISTINCT order_number) FROM g_fact_sales
UNION ALL
SELECT 'total_no_products' AS measure_name, COUNT(DISTINCT product_id) FROM g_dim_product
UNION ALL
SELECT 'total_no_customers' AS measure_name, COUNT(DISTINCT customer_id) FROM g_dim_customer;
