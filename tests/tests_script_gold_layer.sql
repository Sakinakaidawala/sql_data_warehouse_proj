/*
===============================================================================
Section Gold Layer Testing & Integration Checks
===============================================================================
What this section does:   
Before I finalized the Views for the Gold layer, I used these queries to test 
my table joins and business logic. When joining different systems (like CRM 
and ERP), it is really easy to accidentally multiply rows or lose data, so 
these checks ensure the Star Schema is perfectly accurate!

Tests included here:
  - Join Duplication Checks: Grouping by ID to make sure my LEFT JOINs didn't 
    accidentally create duplicate customers or active products.
  - Integration Logic: Testing the COALESCE() function side-by-side to prove 
    that the "fallback" rule for missing genders actually works.
  - Foreign Key Integrity: Checking if there are any "orphan" records in the Fact 
    table (e.g., sales that are attached to a customer or product that doesn't 
    exist in the Dimension tables).
===============================================================================
*/

SELECT cst_id, COUNT(*)
FROM (
	SELECT
		ci.cst_id,
		ci.cst_key,
		ci.cst_firstname,
		ci.cst_lastname,
		ci.cst_material_status,
		ci.cst_gndr,
		ci.cst_create_date,
		ca.bdate,
		ca.gen,
		la.cntry
	FROM s_crm_cust_info ci
	LEFT JOIN s_erp_cust_az12 ca
		ON ci.cst_key = ca.cid
	LEFT JOIN s_erp_loc_a101 la
		ON ci.cst_key = la.cid
)t
GROUP BY cst_id
HAVING COUNT(*) > 1;

-- intigrating gender
-- Assume more importent system is crm we will consider crm data for gender is correct
SELECT DISTINCT 
ci.cst_gndr,
ca.gen,
CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
	 ELSE COALESCE(ca.gen, 'n/a')
END AS new_gen
FROM s_crm_cust_info ci
	LEFT JOIN s_erp_cust_az12 ca
		ON ci.cst_key = ca.cid
	LEFT JOIN s_erp_loc_a101 la
		ON ci.cst_key = la.cid
ORDER BY 1,2;

SELECT * FROM g_dim_customer;
SELECT prd_key, COUNT(*) FROM (
SELECT 
	pn.prd_id,
	pn.cat_id,
	pn.prd_key,
	pn.prd_nm,
	pn.prd_cost,
	pn.prd_line,
	pn.prd_start_dt,
	pc.cat,
	pc.subcat,
	pc.maintenace
FROM s_crm_prd_info pn
LEFT JOIN s_erp_px_cat_g1v2 pc
	ON pn.cat_id = pc.id
WHERE pn.prd_end_dt IS NULL -- Filter Out historical data
)t
GROUP BY prd_key
HAVING COUNT(*) > 1 ;

-- Foregin key integrity
SELECT * FROM g_fact_sales f
LEFT JOIN g_dim_customer c
	ON f.customer_key = c.customer_key
LEFT JOIN g_dim_products p
	ON p.product_key = f.product_key
WHERE p.product_key IS NULL;

SELECT * FROM g_fact_sales f
LEFT JOIN g_dim_customer c
	ON f.customer_key = c.customer_key
WHERE c.customer_key IS NULL;
