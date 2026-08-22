
/*
===============================================================================
Script: Data Profiling & Quality Checks (Pre-Silver Layer)
===============================================================================
What this script does:      
This is my exploratory data analysis (EDA) workspace! Before I built the final 
Silver layer to clean the data, I used this script to investigate the raw Bronze 
tables. I ran these tests to find out exactly what was broken, missing, or 
formatted incorrectly so I knew exactly what my ETL script needed to fix.

Things I investigated in this code:
  - Primary Keys: Checked for NULLs and duplicates in every table using GROUP BY.
  - Text Formatting: Compared raw text to TRIM() versions to find hidden spaces.
  - Data Logic: Found negative prices, weird dates (like years > 2050), and 
    math errors (checking if Sales = Quantity * Price).
  - Referential Integrity: Checked if Foreign Keys matched up across tables 
    (e.g., finding Sales records that had missing Customer IDs).
  - Data Mapping: Used SELECT DISTINCT to see all the weird category names and 
    genders so I could write accurate CASE statements later.
===============================================================================
*/
-- ==================================================
-- preparing and checking data for silver layer
-- Table name: s_crm_cust_info
-- ===================================================

-- check for null and dublicats in primary key 
-- expectation no result
SELECT *
FROM b_crm_cust_info
WHERE cst_id IS NULL;

SELECT cst_id,
COUNT(*)
FROM b_crm_cust_info
GROUP BY cst_id
HAVING COUNT(*) > 1;

SELECT DISTINCT cst_material_status
FROM b_crm_cust_info;

SELECT DISTINCT cst_gndr
FROM b_crm_cust_info;

SELECT cst_firstname
FROM b_crm_cust_info
WHERE cst_firstname != TRIM(cst_firstname);

SELECT cst_lastname
FROM b_crm_cust_info
WHERE cst_lastname != TRIM(cst_lastname);

-- ==================================================
-- preparing and checking data for silver layer
-- Table name: s_crm_prd_info
-- ===================================================
-- check for null and dublicats in primary key 
-- expectation no result

SELECT prd_id,
COUNT(*)
FROM b_crm_prd_info
GROUP BY prd_id
HAVING COUNT(*) > 1 OR prd_id IS NULL;

-- making new column for category id which is the first 5 latter in prd key
SELECT * ,
REPLACE(SUBSTRING(prd_key, 1, 5),'-','_') AS cat_id
FROM b_crm_prd_info
-- check is same as cat_id in other table
WHERE REPLACE(SUBSTRING(prd_key, 1, 5),'-','_') NOT IN
(SELECT DISTINCT id FROM b_erp_px_cat_g1v2);

SELECT * ,
SUBSTRING(prd_key, 7, length(prd_key)) AS prd_key
FROM b_crm_prd_info
-- check is same as prd_key in other table
WHERE SUBSTRING(prd_key, 7, length(prd_key)) IN
(SELECT DISTINCT sls_prd_key FROM b_crm_sales_details);

SELECT prd_nm
FROM b_crm_prd_info
WHERE prd_nm != TRIM(prd_nm);

-- checking for null and negetive numbers
SELECT prd_cost
FROM b_crm_prd_info
WHERE prd_cost < 0 OR prd_cost IS NULL;

SELECT DISTINCT prd_line,
CASE WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
	 WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
	 WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sale'
     WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
     ELSE 'n/a'
END AS prd_line
FROM b_crm_prd_info
;

-- we will use lead window function to get end date which is same as next staring date and do -1
SELECT *
FROM b_crm_prd_info
WHERE prd_end_dt  < prd_start_dt;

-- ==================================================
-- preparing and checking data for silver layer
-- Table name: s_crm_sales_details
-- ===================================================
-- check for null and dublicats in primary key 
-- expectation no result
SELECT * 
FROM b_crm_sales_details
WHERE sls_ord_num != TRIM(sls_ord_num);

SELECT sls_prd_key
FROM b_crm_sales_details
WHERE sls_prd_key NOT IN (SELECT prd_key FROM s_crm_prd_info);

SELECT sls_cust_id
FROM b_crm_sales_details
WHERE sls_cust_id NOT IN (SELECT cst_id FROM s_crm_cust_info);

SELECT 
NULLIF(sls_order_dt,0)
FROM b_crm_sales_details
WHERE sls_order_dt <19000101 
	OR sls_order_dt > 20500101 
	OR sls_order_dt <= 0 
	OR LENGTH(sls_order_dt) != 8;

SELECT
NULLIF(sls_ship_dt,0)
FROM b_crm_sales_details
WHERE sls_ship_dt <19000101 
	OR sls_ship_dt > 20500101 
	OR sls_ship_dt <= 0 
	OR LENGTH(sls_ship_dt) != 8;

SELECT
NULLIF(sls_due_dt,0)
FROM b_crm_sales_details
WHERE sls_due_dt <19000101 
	OR sls_due_dt > 20500101 
	OR sls_due_dt <= 0 
	OR LENGTH(sls_due_dt) != 8;

SELECT *
FROM b_crm_sales_details
WHERE sls_order_dt > sls_ship_dt OR sls_order_dt > sls_due_dt; 

SELECT *
FROM b_crm_sales_details;

SELECT 
sls_sales,
sls_price,
sls_quantity
FROM b_crm_sales_details
WHERE sls_sales != (sls_quantity * sls_price);

-- IF sales is negative,zero or null we can derive it from price quantity
-- if price is zero or null we can derive it from sales and quantity
-- if price is negative we can change it to possitive


-- ==================================================
-- preparing and checking data for silver layer
-- Table name: s_erp_cust_az12
-- ===================================================
-- check for null and dublicats in primary key 
-- expectation no result
SELECT *
	FROM (SELECT* ,
	ROW_NUMBER () OVER(PARTITION BY cid ORDER BY cid) row_no
	FROM b_erp_cust_az12) t
WHERE row_no > 1 OR cid IS NULL ;

SELECT cid
FROM b_erp_cust_az12
WHERE cid NOT IN (SELECT cst_key FROM s_crm_cust_info);

SELECT 
CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)
	 ELSE cid
END cid
FROM b_erp_cust_az12
WHERE CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid, 4)
	 ELSE cid
END NOT IN (SELECT cst_key FROM s_crm_cust_info);

-- Identify the date range
SELECT DISTINCT bdate
FROM b_erp_cust_az12
WHERE bdate < '1926-01-01' OR bdate > CURRENT_TIMESTAMP;

SELECT DISTINCT TRIM(gen)
FROM b_erp_cust_az12;

-- ==================================================
-- preparing and checking data for silver layer
-- Table name:  s_erp_loc_a101
-- ===================================================
-- check for null and dublicats in primary key 
-- expectation no result

SELECT *
FROM (SELECT *,
ROW_NUMBER() OVER(PARTITION BY cid) as row_no
FROM b_erp_loc_a101
)t
WHERE row_no > 1;

SELECT DISTINCT cntry
FROM b_erp_loc_a101;

SELECT
REPLACE(cid,'-','') AS cid,
cntry
FROM b_erp_loc_a101
WHERE REPLACE(cid,'-','') NOT IN (SELECT cst_key FROM s_crm_cust_info );

-- ==================================================
--  preparing and checking data for silver layer
-- Table name: s_erp_px_cat_g1v2
-- ===================================================
-- check for null and dublicats in primary key 
-- expectation no result
SELECT id
FROM b_erp_px_cat_g1v2
WHERE id NOT IN (SELECT cat_id FROM s_crm_prd_info);

-- checking unwanted space
SELECT *
FROM b_erp_px_cat_g1v2
WHERE cat = '' OR cat IS NULL OR cat != TRIM(cat)
OR subcat = '' OR subcat IS NULL OR subcat != TRIM(subcat)
OR maintenace = '' OR maintenace IS NULL OR maintenace != TRIM(maintenace);

SELECT DISTINCT cat
FROM b_erp_px_cat_g1v2;
SELECT DISTINCT subcat
FROM b_erp_px_cat_g1v2;
SELECT DISTINCT maintenace
FROM b_erp_px_cat_g1v2;

