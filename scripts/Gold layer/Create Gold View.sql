/* =============================================================================
DDL SCRIPT : Create Gold View
 =============================================================================
What this script does:      
This is the final step! It takes all our clean data, links it together, and 
creates the final "Gold" tables. These tables are fully ready to be plugged 
into a dashboard tool (like Power BI or Tableau) to make charts and reports.

Things I did in this code:
  - Added a "drop if exists" step at the top so I can run this script over 
    and over without getting errors.
  - Used the main CRM system as my base, and attached the extra ERP data to it.
  - Created brand new, clean ID numbers for every customer and product to keep 
    everything perfectly organized.
  - Filled in missing customer genders by borrowing that info from the ERP system.
  - Filtered out old products that are no longer active.
  - Linked the final Sales table directly to the clean Customer and Product tables!
=====================================================================================
*/
-- CRM is the master
-- macking row_no as surrogate key

DROP VIEW  IF EXISTS g_dim_customer ;
CREATE VIEW g_dim_customer AS
	SELECT 
		ROW_NUMBER() OVER(ORDER BY ci.cst_id) AS customer_key,
		ci.cst_id AS customer_id,
		ci.cst_key AS customer_number,
		ci.cst_firstname AS first_name,
		ci.cst_lastname AS last_name,
		la.cntry AS country,
		ci.cst_material_status AS material_status,
		CASE WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
			 ELSE COALESCE(ca.gen, 'n/a')
		END AS gender,
		ca.bdate AS birthdate,
		ci.cst_create_date AS create_date
	FROM s_crm_cust_info ci
	LEFT JOIN s_erp_cust_az12 ca 
		ON ci.cst_key = ca.cid
	LEFT JOIN s_erp_loc_a101 la 
		ON ci.cst_key = la.cid;
    
    DROP VIEW  IF EXISTS g_dim_products ;
    CREATE VIEW g_dim_products AS
		SELECT 
		ROW_NUMBER () OVER(ORDER BY pn.prd_start_dt, pn.prd_key) AS product_key,
		pn.prd_id AS product_id,
		pn.prd_key AS product_number,
		pn.prd_nm AS product_name,
		pn.cat_id AS category_id,
		pc.cat AS category,
		pc.subcat AS subcategory,
		pc.maintenace,
		pn.prd_cost AS cost,
		pn.prd_line AS product_line,
		pn.prd_start_dt AS start_date
	FROM s_crm_prd_info pn
	LEFT JOIN s_erp_px_cat_g1v2 pc
		ON pn.cat_id = pc.id
	WHERE pn.prd_end_dt IS NULL; -- Filter Out historical data
	
DROP VIEW  IF EXISTS g_fact_sales ;
CREATE VIEW g_fact_sales AS
	SELECT
		sls_ord_num AS order_number,
		pr.product_key,
		cm.customer_key,
		sls_order_dt AS order_date,
		sls_ship_dt AS ship_date,
		sls_due_dt AS due_date,
		sls_sales AS sales,
		sls_quantity AS quantity,
		sls_price AS price
	FROM s_crm_sales_details sd
	LEFT JOIN g_dim_products pr
		ON sd.sls_prd_key = pr.product_number
	LEFT JOIN g_dim_customer cm
		on sd.sls_cust_id = cm.customer_id;
