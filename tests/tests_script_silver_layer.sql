-- ==================================================
-- Inserting clean data into silver layer tabls
-- ==================================================
-- insrting data clean into s_crm_cust_info
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
