/*
===============================================================================
Section:          Ranking Analysis
===============================================================================
What this section does:
This section identifies the extreme ends of the business's performance by 
ranking products and customers. Ranking analysis is crucial for executive 
decision-making, such as identifying which products to scale (top performers) 
or phase out (underperformers), and recognizing high-value customers for 
loyalty programs.

Techniques used in this section:
  - Top N / Bottom N Reporting: Utilizing the `LIMIT` clause paired with 
    `ORDER BY` (both ASC and DESC) to extract exact ranking subsets.
  - Advanced Ranking: Showcasing technical flexibility by calculating the top 
    5 products using both the standard `LIMIT` method and a Subquery utilizing 
    the `ROW_NUMBER()` Window Function.
  - Distinct Counting: Using `COUNT(DISTINCT)` to accurately rank customers 
    based on unique orders placed, ensuring data integrity.
===============================================================================
*/

-- which 5 products generate the highest revenue?
SELECT  p.product_name, SUM(s.price) total_revenue
FROM g_fact_sales s
LEFT JOIN g_dim_product p
	ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY 2 DESC
LIMIT 5;

-- using window function
SELECT *
	FROM (SELECT  p.product_name, SUM(s.price) total_revenue,
	ROW_NUMBER() OVER(ORDER BY SUM(s.price) DESC) rank_price
	FROM g_fact_sales s
	LEFT JOIN g_dim_product p
		ON s.product_key = p.product_key
	GROUP BY p.product_name) t
WHERE rank_price <= 5;

-- what are the five worst performing product
SELECT  p.product_name, SUM(s.price) total_revenue
FROM g_fact_sales s
LEFT JOIN g_dim_product p
	ON s.product_key = p.product_key
GROUP BY p.product_name
ORDER BY 2
LIMIT 5;

-- find the top 10 customers who have generated the highest revenue
SELECT c.customer_key,
c.first_name,
c.last_name,
SUM(s.price) total_revanue
FROM g_fact_sales s
LEFT JOIN g_dim_customer c
	ON s.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY 4 DESC
LIMIT 10;

-- the 3 customers with the fewest order placed
SELECT
c.customer_key,
c.first_name,
c.last_name,
COUNT(DISTINCT s.order_number) AS total_order
FROM g_fact_sales s
LEFT JOIN g_dim_customer c
	ON s.customer_key = c.customer_key
GROUP BY c.customer_key, c.first_name, c.last_name
ORDER BY 4 
LIMIT 3;
