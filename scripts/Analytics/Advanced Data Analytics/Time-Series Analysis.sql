/*
===============================================================================
Section:          Time-Series Analysis
===============================================================================
What this section does:
This section analyzes sales performance over time to identify historical trends, 
seasonality, and overall business growth. 

Techniques used in this section:
  - Date Extraction: Utilizing YEAR() and MONTH() functions to aggregate 
    granular transaction dates into high-level yearly and monthly cohorts.
  - Date Formatting: Demonstrating an alternative, cleaner approach to monthly 
    grouping using MySQL's DATE_FORMAT() function ('%Y-%m') for continuous 
    time-series charting.
  - Data Quality Filtering: Applying 'WHERE order_date IS NOT NULL' to ensure 
    incomplete or corrupted records do not skew the timeline analysis.
===============================================================================
*/
-- sales performance over time
-- year
SELECT YEAR(order_date) order_year,
SUM(sales) total_sales,
COUNT(DISTINCT customer_key) total_customers,
SUM(quantity) total_quantities
FROM g_fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date)
ORDER BY YEAR(order_date);
-- month
SELECT YEAR(order_date) order_year,
MONTH(order_date) order_month,
SUM(sales) total_sales,
COUNT(DISTINCT customer_key) total_customers,
SUM(quantity) total_quantities
FROM g_fact_sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date);
-- OR
SELECT DATE_FORMAT(order_date, '%Y-%m') AS order_month,
SUM(sales) total_sales,
COUNT(DISTINCT customer_key) total_customers,
SUM(quantity) total_quantities
FROM g_fact_sales
WHERE order_date IS NOT NULL
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY DATE_FORMAT(order_date, '%Y-%m');
