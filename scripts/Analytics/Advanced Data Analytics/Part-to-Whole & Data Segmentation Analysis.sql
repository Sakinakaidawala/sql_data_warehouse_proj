/*
===============================================================================
Section:          Part-to-Whole & Data Segmentation Analysis
===============================================================================
What this section does:
This section analyzes how individual components (like categories or specific 
products) contribute to the overall business, and segments the data into 
distinct, actionable cohorts for targeted business strategies.

Techniques used in this section:
  - Part-to-Whole Calculations: Used Window Functions (SUM(total_sales) OVER()) 
    to calculate the grand total without needing a separate subquery, then 
    dynamically calculated the percentage contribution of each category.
  - String Formatting: Utilized CONCAT() to format the percentage output 
    directly in SQL, making it dashboard-ready.
  - Data Segmentation: Engineered complex Searched CASE statements within CTEs 
    to group products into specific pricing tiers, and categorized customers 
    into 'VIP', 'Regular', and 'New' cohorts based on a combination of tenure 
    (TIMESTAMPDIFF) and lifetime value.
===============================================================================
*/-
- =====================================================================
-- Part to Whole Analysis
-- =====================================================================
-- which category contribute the most to overall sales?
WITH category_sales AS (
	SELECT
	p.category,
	SUM(s.sales) total_sales
	FROM g_fact_sales s
	LEFT JOIN g_dim_product p
		ON s.product_key = p.product_key
	GROUP BY p.category)

SELECT
category,
total_sales,
SUM(total_sales) OVER() overall_sales,
CONCAT(ROUND((total_sales/SUM(total_sales) OVER())*100, 2 ),'%')percentage_of_total
FROM category_sales
ORDER BY total_sales DESC;

-- =====================================================================
-- DATA Segmentation
-- =====================================================================
/* segment products into  cost range and
count how many products fall into each segment */
WITH cte_cost_range AS (
	SELECT
	product_key,
	product_name,
	cost,
	CASE
		WHEN cost < 100 THEN 'Below 100'
		WHEN cost BETWEEN 100 AND 500 THEN '100-500'
		WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
		ELSE 'Above 1000'
	END Cost_range
	FROM g_dim_product)
    
SELECT cost_range, COUNT(cost_range) total_products
FROM cte_cost_range
GROUP BY cost_range
ORDER BY 2 DESC;

/* group customer into 3 segments based on their spending behaviour:
	- VIP: customers with at least 12 month of history and spending more than 5,000
    -- regular: customers with at least 12 month of history and spending 5000 or less
    -- new: customers with lifespan less then 12 month
and find the total number of customer by each group
*/
WITH cte_customer_group AS (
		SELECT
		c.customer_key,
		SUM(s.sales) total_sales,
		MIN(s.order_date) first_order_date,
		MAX(s.order_date) last_order_date,
		TIMESTAMPDIFF(MONTH,MIN(s.order_date),MAX(s.order_date)) order_lifespan,
		CASE
			WHEN TIMESTAMPDIFF(MONTH,MIN(s.order_date),MAX(s.order_date)) >= 12 AND SUM(s.sales) > 5000 THEN 'VIP'
			WHEN TIMESTAMPDIFF(MONTH,MIN(s.order_date),MAX(s.order_date)) >= 12 AND SUM(s.sales) <= 5000 THEN 'Regular'
			ELSE 'New'
		END customer_group
		FROM g_fact_sales s
		LEFT JOIN g_dim_customer c
			ON s.customer_key = c.customer_key
		GROUP BY c.customer_key)
    
SELECT customer_group, COUNT(customer_group) total_customers
FROM cte_customer_group
GROUP BY customer_group;
