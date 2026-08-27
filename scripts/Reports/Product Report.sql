/*
===============================================================================
Product Report
===============================================================================
Purpose:
    This view consolidates core product metrics and performance attributes into 
    a single, comprehensive dataset. It acts as the semantic layer for product 
    performance dashboards, enabling inventory and sales teams to track lifecycle, 
    profitability, and volume at the SKU level.

Techniques Utilized:
    - Modular CTE Architecture: Segregated the raw fact-to-dimension join 
      (`base_query`) from the heavy mathematical calculations 
      (`products_aggregation`) to optimize query readability and execution.
    - Defensive Programming (NULLIF): Implemented `NULLIF()` during the average 
      selling price calculation to completely eliminate the risk of divide-by-zero 
      errors when calculating item-level metrics.
    - Tiered Categorization: Built dynamic `CASE` statements to categorize 
      inventory into actionable segments ('High-Performer', 'Mid-Range', 
      'Low-Performer') based on lifetime revenue generation.
===============================================================================
*/

DROP VIEW IF EXISTS g_report_products;
CREATE VIEW g_report_products AS
	WITH base_query AS (
		/*---------------------------------------------------------------------------
		1) Base Query: Retrieves core columns from fact_sales and dim_products
		---------------------------------------------------------------------------*/
		SELECT
		s.customer_key,
		s.order_number,
		s.order_date,
		s.sales,
		s.quantity,
		p.product_key,
		p.product_name,
		p.category,
		p.subcategory,
		p.cost
		FROM g_dim_products p
		LEFT JOIN g_fact_sales s
			ON p.product_key = s.product_key
		WHERE order_date IS NOT NULL),

	products_aggregation AS (
		SELECT 
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		TIMESTAMPDIFF(month,MIN(order_date),MAX(order_date)) lifespan,
		MAX(order_date) last_order_date,
		COUNT(DISTINCT order_number) total_orders,
		SUM(sales) total_sales,
		SUM(quantity) total_quantity_sold,
		COUNT(DISTINCT customer_key) total_customers,
		ROUND(SUM(sales/NULLIF(quantity,0)),2) avg_selling_price
		FROM base_query
		GROUP BY 
			product_key,
			product_name,
			category,
			subcategory,
			cost)
		
	SELECT
	product_key,
	product_name,
	category,
	subcategory,
	cost,
	last_order_date,
	TIMESTAMPDIFF(MONTH, last_order_date,CURDATE()) recency,
	CASE
		WHEN total_sales > 50000 THEN 'High-Performer'
		WHEN total_sales >= 10000 THEN 'Mid-Range'
		ELSE 'Low-Performer'
	END product_segment,
	total_orders,
	total_sales,
	total_quantity_sold,
	total_customers,
	avg_selling_price,
	lifespan,
	-- Compute Average Order Revenue (AOR)
	CASE
		WHEN total_orders = 0 THEN 0
		ELSE ROUND (total_sales/total_orders,2)
	END avg_order_revenue,
	-- average monthly revenue
	CASE
		WHEN lifespan = 0 THEN total_sales
		ELSE ROUND(total_sales/lifespan,2)
	END avg_monthly_revenue
	FROM products_aggregation;
