/*
===============================================================================
Script: Create Silver Layer Tables
===============================================================================
What this script does:      
This script sets up the empty tables for the Silver layer, which is where all 
the cleaned data will live. It drops the old tables if they exist and builds 
fresh ones from scratch.

Things I did in this code:
  - Used DROP TABLE IF EXISTS so the script doesn't crash if I need to run it again.
  - Set up all the proper data types (like INT, VARCHAR, and DATE) for MySQL.
  - Added a cool tracking column called 'dwh_create_date'. I used DEFAULT CURRENT_TIMESTAMP 
    so MySQL automatically stamps the exact date and time whenever new data is added!
===============================================================================
*/


-- ======================================================================
 -- CREATING SILVER LAYER TABLE
 -- ADDING NEW COLUMN dwh_create_date with CURRENT TIMESTAMP
 -- ======================================================================
 
 -- creating table from the sources
DROP TABLE IF EXISTS s_crm_cust_info;
CREATE TABLE s_crm_cust_info (
	cst_id INT,
	cst_key VARCHAR (50),
	cst_firstname VARCHAR (50),
	cst_lastname VARCHAR (50),
	cst_marital_status VARCHAR (50),
	cst_gndr VARCHAR (50),
	cst_create_date DATE ,
    dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS s_crm_prd_info;
CREATE TABLE s_crm_prd_info (
prd_id INT,
cat_id VARCHAR (50),
prd_key VARCHAR (50),
prd_nm VARCHAR (50),
prd_cost INT,
prd_line VARCHAR (50),
prd_start_dt DATE,
prd_end_dt DATE,
dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS s_crm_sales_details;
CREATE TABLE s_crm_sales_details(
sls_ord_num VARCHAR (50),
sls_prd_key VARCHAR (50),
sls_cust_id INT,
sls_order_dt DATE,
sls_ship_dt DATE,
sls_due_dt DATE,
sls_sales INT,
sls_quantity INT,
sls_price INT,
dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS s_erp_cust_az12;
CREATE TABLE s_erp_cust_az12 (
cid 	VARCHAR (50),
bdate 	DATE,
gen 	VARCHAR (50),
dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS s_erp_loc_a101;
CREATE TABLE s_erp_loc_a101(
cid 	VARCHAR (50),
cntry 	VARCHAR (50),
dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);

DROP TABLE IF EXISTS s_erp_px_cat_g1v2;
CREATE TABLE s_erp_px_cat_g1v2 (
id 			VARCHAR (50),
cat 		VARCHAR (50),
subcat		VARCHAR (50),
maintenance	VARCHAR (50),
dwh_create_date DATETIME DEFAULT CURRENT_TIMESTAMP
);
