/*
===============================================================================
Section:          Product Performance & Year-Over-Year (YoY) Analysis
===============================================================================
What this section does:
This section analyzes the yearly performance of each product by comparing 
its current sales to its historical average and its previous year's sales. 
This is a fundamental technique in financial and retail analysis to identify 
growth trends, product life cycles, and overall business health.

Techniques used in this section:
  - Common Table Expressions (CTE): Used to pre-aggregate the yearly sales 
    data, keeping the main query clean, modular, and readable.
  - Advanced Window Functions: 
      - AVG() OVER() with PARTITION BY to calculate the historical baseline 
        (average sales) per product.
      - LAG() OVER() to retrieve the exact sales figures from the previous 
        year for direct Year-over-Year (YoY) comparison.
  - Complex Conditional Logic: Utilizing Searched CASE statements to categorize 
    performance into actionable text labels ('Above AVG', 'Increase', etc.) 
    making the data instantly readable for BI dashboards.
===============================================================================
*/

SELECT 
order_month,
total_sales,
SUM(total_sales) OVER(ORDER BY order_month) running_total_sales,
ROUND(AVG(avg_price) OVER(ORDER BY order_month),0) moving_avg_price
FROM (
	SELECT DATE_FORMAT(order_date, '%Y-%m') order_month,
	SUM(sales) total_sales,
    AVG(price) avg_price
	FROM g_fact_sales
	WHERE order_date IS NOT NULL
	GROUP BY DATE_FORMAT(order_date, '%Y-%m'))t;

-- =====================================================================
-- performance Analysis
-- =====================================================================
-- analyze the yearly performance of products by comparing each products's sales to both it 
-- average sales performance
-- previous year sales
WITH yearly_products_sales AS(
	SELECT YEAR(s.order_date)order_year,
	p.product_name,
	SUM(s.sales) current_year_sales
	FROM g_fact_sales s
	LEFT JOIN g_dim_product p
		ON s.product_key = p.product_key
	WHERE s.order_date IS NOT NULL
	GROUP BY YEAR(s.order_date), p.product_name)
SELECT
order_year,
product_name,
current_year_sales,
ROUND(AVG(current_year_sales) OVER(PARTITION BY product_name),0) avg_sales,
current_year_sales - ROUND(AVG(current_year_sales) OVER(PARTITION BY product_name),0) diff_avg,
CASE  
	WHEN current_year_sales - ROUND(AVG(current_year_sales) OVER(PARTITION BY product_name),0) > 0 THEN 'Above AVG'
	WHEN current_year_sales - ROUND(AVG(current_year_sales) OVER(PARTITION BY product_name),0) < 0 THEN 'Below AVG'
  ELSE 'AVG'
END avg_change,
-- YOY analysis
LAG(current_year_sales) OVER(PARTITION BY product_name ORDER BY order_year) py_sales,
current_year_sales - LAG(current_year_sales) OVER(PARTITION BY product_name ORDER BY order_year) diff_py,
CASE
	WHEN current_year_sales - LAG(current_year_sales) OVER(PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
  WHEN current_year_sales - LAG(current_year_sales) OVER(PARTITION BY product_name ORDER BY order_year) <0 THEN 'Decrease'
  ELSE 'No change'
END py_sales_change
FROM yearly_products_sales;
