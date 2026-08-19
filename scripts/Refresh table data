/*
================================================================================
LOAD SCRIPT: delete old existing data and loads fresh data into the data 
              warehouse tables using LOAD DATA INFILE
NOTE: To successfully run this script, MySQL requires the source CSV files to be 
placed inside its designated secure upload folder
TO check the parth of secure upload folder youse folloing query
  SHOW VARIABLES LIKE 'secure_file_priv'
and copy the part and past it in file
and copy past  all the cvs file in it
================================================================================
*/

TRUNCATE TABLE b_crm_cust_info;	 
	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cust_info.csv'
	INTO TABLE b_crm_cust_info
	FIELDS TERMINATED BY ','
	LINES TERMINATED BY '\r\n'
	IGNORE 1 ROWS
    (cst_id, cst_key, cst_firstname, cst_lastname, cst_material_status, cst_gndr, @raw_date)
    SET cst_create_date = STR_TO_DATE(@raw_date, '%d-%m-%Y');
    
	TRUNCATE TABLE b_crm_prd_info;
	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/prd_info.csv'
	INTO TABLE b_crm_prd_info
	FIELDS TERMINATED BY ','
	LINES TERMINATED BY '\r\n'
	IGNORE 1 ROWS
	(prd_id, prd_key, prd_nm, @raw_cost, prd_line, prd_start_dt, @raw_prd_end_dt) 
	SET prd_cost = NULLIF(@raw_cost, ''), prd_end_dt = NULLIF(@raw_prd_end_dt,'') ;

	TRUNCATE TABLE b_crm_sales_details;
	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sales_details.csv'
	INTO TABLE b_crm_sales_details
	FIELDS TERMINATED BY ','
	LINES TERMINATED BY '\r\n'
	IGNORE 1 ROWS
	(sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,@raw_sls_sales,sls_quantity, @raw_sls_price)
	SET sls_price = NULLIF(@raw_sls_price,''), sls_sales = NULLIF(@raw_sls_sales,'');

	TRUNCATE TABLE b_erp_cust_az12;
	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/CUST_AZ12.csv'
	INTO TABLE b_erp_cust_az12
	FIELDS TERMINATED BY ','
	LINES TERMINATED BY '\r\n'
	IGNORE 1 ROWS
	(CID, @raw_BDATE, @raw_GEN)
	SET bdate = NULLIF(@raw_BDATE,''), gen = NULLIF(@raw_GEN,'');

	TRUNCATE TABLE b_erp_loc_a101;
	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LOC_A101.csv'
	INTO TABLE b_erp_loc_a101
	FIELDS TERMINATED BY ','
	LINES TERMINATED BY '\r\n'
	IGNORE 1 ROWS;

	TRUNCATE TABLE b_erp_px_cat_g1v2;
	LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/PX_CAT_G1V2.csv'
	INTO TABLE b_erp_px_cat_g1v2
	FIELDS TERMINATED BY ','
	LINES TERMINATED BY '\r\n'
	IGNORE 1 ROWS;
