USE Data_warehouse;

create or  ALTER PROCEDURE sliver.transformation_data
AS
BEGIN

    /* =========================
       CUSTOMER INFO
    ========================== */

    PRINT 'Truncating table: sliver.cust_info';
    TRUNCATE TABLE sliver.cust_info;

    PRINT 'Inserting data into sliver.cust_info';

    INSERT INTO sliver.cust_info
    (
        cst_id,
        cst_key,
        cst_firstname,
        cst_lastname,
        cst_marital_status,
        cst_gndr,
        cst_create_date
    )

    SELECT 
        cst_id,
        cst_key,
        TRIM(cst_firstname) AS cst_firstname,
        TRIM(cst_lastname) AS cst_lastname,

        CASE 
            WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
            WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            ELSE 'n/a'
        END AS cst_marital_status,

        CASE 
            WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
            ELSE 'n/a'
        END AS cst_gndr,

        cst_create_date

    FROM
    (
        SELECT *,
               ROW_NUMBER() OVER
               (
                   PARTITION BY cst_id
                   ORDER BY cst_create_date DESC
               ) AS flag
        FROM bronze.cust_info
        WHERE cst_id IS NOT NULL
    ) t
    WHERE flag = 1;


    /* =========================
       PRODUCT INFO
    ========================== */

    PRINT 'Truncating table: sliver.prd_info';
    TRUNCATE TABLE sliver.prd_info;

    PRINT 'Inserting data into sliver.prd_info';

    INSERT INTO sliver.prd_info
    (
        prd_id,
        cat_id,
        prd_key,
        prd_nm,
        prd_cost,
        prd_line,
        prd_start_dt,
        prd_end_dt
    )

    SELECT 
        prd_id,

        REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS cat_id,

        SUBSTRING(prd_key,7,LEN(prd_key)) AS prd_key,

        prd_nm,

        ISNULL(prd_cost,0) AS prd_cost,

        CASE 
            WHEN UPPER(TRIM(prd_line)) = 'M' THEN 'Mountain'
            WHEN UPPER(TRIM(prd_line)) = 'R' THEN 'Road'
            WHEN UPPER(TRIM(prd_line)) = 'S' THEN 'Other Sales'
            WHEN UPPER(TRIM(prd_line)) = 'T' THEN 'Touring'
            ELSE 'n/a'
        END AS prd_line,

        CAST(prd_start_dt AS DATE) AS prd_start_dt,

        DATEADD
        (
            DAY,
            -1,
            LEAD(CAST(prd_start_dt AS DATE)) OVER
            (
                PARTITION BY prd_id
                ORDER BY CAST(prd_start_dt AS DATE)
            )
        ) AS prd_end_dt

    FROM bronze.prd_info;


    /* =========================
       SALES DETAILS
    ========================== */

    PRINT 'Truncating table: sliver.sales_details';
    TRUNCATE TABLE sliver.sales_details;

    PRINT 'Inserting data into sliver.sales_details';

    INSERT INTO sliver.sales_details
    (
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
        sls_order_dt,
        sls_ship_dt,
        sls_due_dt,
        sls_sales,
		sls_quantity,
        sls_price
		
    )

    SELECT
        sls_ord_num,
        sls_prd_key,
        sls_cust_id,
		

        CASE
            WHEN sls_order_dt = 0
                 OR LEN(CAST(sls_order_dt AS VARCHAR)) != 8
            THEN NULL
            ELSE TRY_CONVERT(DATE, CAST(sls_order_dt AS VARCHAR), 112)
        END AS sls_order_dt,

        CASE
            WHEN sls_ship_dt = 0
                 OR LEN(CAST(sls_ship_dt AS VARCHAR)) != 8
            THEN NULL
            ELSE TRY_CONVERT(DATE, CAST(sls_ship_dt AS VARCHAR), 112)
        END AS sls_ship_dt,

        CASE
            WHEN sls_due_dt = 0
                 OR LEN(CAST(sls_due_dt AS VARCHAR)) != 8
            THEN NULL
            ELSE TRY_CONVERT(DATE, CAST(sls_due_dt AS VARCHAR), 112)
        END AS sls_due_dt,

        CASE
            WHEN sls_sales IS NULL
                 OR sls_sales <= 0
                 OR sls_sales != sls_quantity * ABS(sls_price)
            THEN sls_quantity * ABS(sls_price)

            ELSE sls_sales
        END AS sls_sales,

		sls_quantity,
		

        CASE
            WHEN sls_price IS NULL
                 OR sls_price <= 0
            THEN sls_sales / NULLIF(sls_quantity,0)

            ELSE sls_price
        END AS sls_price

    FROM bronze.sales_details;


    /* =========================
       ERP - CUST_AZ12
    ========================== */

    PRINT 'Truncating table: sliver.CUST_AZ12';
    TRUNCATE TABLE sliver.CUST_AZ12;

    PRINT 'Inserting data into sliver.CUST_AZ12';

    INSERT INTO sliver.CUST_AZ12
    (
        CID,
        BDATE,
        GEN
    )

    SELECT

        CASE
            WHEN CID LIKE 'NAS%' THEN SUBSTRING(CID,4,LEN(CID))
            ELSE CID
        END AS CID,

        CASE 
            WHEN BDATE > GETDATE() THEN NULL
            ELSE BDATE
        END AS BDATE,

        CASE  
            WHEN UPPER(TRIM(GEN)) IN ('M','MALE') THEN 'Male'
            WHEN UPPER(TRIM(GEN)) IN ('F','FEMALE') THEN 'Female'
            ELSE 'n/a'
        END AS GEN

    FROM bronze.CUST_AZ12;


    /* =========================
       ERP - LOC_A101
    ========================== */

    PRINT 'Truncating table: sliver.LOC_A101';
    
    
	TRUNCATE TABLE sliver.LOC_A101;


    INSERT INTO sliver.LOC_A101
    (
        CID,
        CNTRY
    )

    SELECT

        REPLACE(CID,'-','') AS CID,

        CASE 
            WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
            WHEN TRIM(CNTRY) IN ('US','USA') THEN 'United States'
            WHEN TRIM(CNTRY) = '' OR CNTRY IS NULL THEN 'n/a'
            ELSE CNTRY
        END AS CNTRY

    FROM bronze.LOC_A101;


    /* =========================
       PX_CAT_G1V2
    ========================== */

    PRINT 'Truncating table: sliver.PX_CAT_G1V2';
    TRUNCATE TABLE sliver.PX_CAT_G1V2;

    PRINT 'Inserting data into sliver.PX_CAT_G1V2';

    INSERT INTO sliver.PX_CAT_G1V2
    (
        ID,
        CAT,
        SUBCAT,
        MAINTENANCE
    )

    SELECT
        ID,
        CAT,
        SUBCAT,
        MAINTENANCE
    FROM bronze.PX_CAT_G1V2;

END;
GO
  
EXEC  sliver.transformation_data;