/*
===============================================================================
Customer Report
===============================================================================
Purpose:
    This view consolidates core customer metrics and profile attributes into a 
    single, comprehensive dataset. It is designed to act as the primary semantic 
    layer for BI dashboards, enabling customer success and marketing teams to 
    analyze demographics, purchasing behavior, and customer lifetime value (CLV).

Techniques Utilized:
    - Modular CTE Architecture: Used layered Common Table Expressions (CTEs) 
      to clearly separate the raw data extraction (`base_query`) from the 
      mathematical aggregations (`customers_aggregation`), ensuring the code is 
      readable and maintainable.
    - Defensive Programming: Implemented CASE statements to gracefully handle 
      potential divide-by-zero errors when calculating Average Order Value (AOV) 
      and Average Monthly Spend.
    - Dynamic Segmentation: Engineered rule-based logic to categorize customers 
      into age brackets and value tiers (VIP, Regular, New) dynamically based 
      on their real-time transaction history.
===============================================================================
*/

DROP VIEW IF EXISTS g_report_customers;
CREATE VIEW g_report_customers AS 
	WITH base_query AS (
	/*---------------------------------------------------------------------------
	1) Base Query: Retrieves core columns from tables
	---------------------------------------------------------------------------*/
		SELECT
		s.order_number,
		s.product_key,
		s.order_date,
		s.sales,
		s.quantity,
		c.customer_key,
		c.customer_number,
		CONCAT(c.first_name,' ',c.last_name) customer_name,
		TIMESTAMPDIFF(YEAR, c.birthdate,CURDATE()) age
		FROM g_fact_sales s
		LEFT JOIN g_dim_customer c
			ON s.customer_key = c.customer_key
		WHERE s.order_date IS NOT NULL),
		
	customers_aggregation AS (
	/*---------------------------------------------------------------------------
	2) Customer Aggregations: Summarizes key metrics at the customer level
	---------------------------------------------------------------------------*/
		SELECT
		customer_key,
		customer_number,
		customer_name,
		age,
		COUNT(DISTINCT order_number) total_order,
		SUM(sales) total_sales,
		SUM(quantity) total_quantity,
		COUNT(DISTINCT product_key) total_products,
		MAX(order_date) last_order_date,
		TIMESTAMPDIFF(MONTH,MIN(order_date),MAX(order_date)) order_lifespan
		FROM base_query
		GROUP BY 
			customer_key,
			customer_number,
			customer_name,
			age)

	SELECT
	customer_key,
	customer_number,
	customer_name,
	age,
	CASE
		WHEN age < 20 THEN 'Under 20'
		WHEN age BETWEEN 20 AND 29 THEN '20-29'
		WHEN age BETWEEN 30 AND 39 THEN '30-39'
		WHEN age BETWEEN 40 and 49 THEN '40-49'
		ELSE '50 and above'
	END age_group,
	CASE
		WHEN order_lifespan >= 12 AND total_sales > 5000 THEN 'VIP'
		WHEN order_lifespan >= 12 AND total_sales <= 5000 THEN 'Regular'
		ELSE 'New'
	END customer_segment,
	last_order_date,
	TIMESTAMPDIFF(Month, last_order_date, CURDATE()) recency,
	total_order,
	total_sales,
	total_quantity,
	total_products,
	order_lifespan,
	-- compute average order value(AOV)
	CASE 
		WHEN total_order = 0 THEN 0
		ELSE ROUND(total_sales/total_order,2)
	END avg_order_value,
	-- compute avearge monthly sales
	CASE
		WHEN order_lifespan = 0 THEN total_sales
		ELSE ROUND(total_sales/order_lifespan,2)
	END avg_monthly_spend
	FROM customers_aggregation;
    
SELECT * FROM g_report_customers;
