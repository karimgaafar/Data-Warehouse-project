USE Data_warehouse;
select 
    row_number() over(order by cst.cst_id) as customer_key,
    cst.cst_id as customer_id,
    cst.cst_key as customer_number,
    cst.cst_firstname as firstname,
    cst.cst_lastname as lastname,
    cloc.CNTRY as Country,
    cst.cst_marital_status as Marital_Status,
    case when (ca.GEN != 'N/A') then ca.GEN 
         else coalesce(ca.GEN, 'n/a') 
    end as Gender,
    cst.cst_create_date,
    ca.BDATE
INTO gold.DIM_CUSTOMER
from sliver.cust_info as cst
left join sliver.CUST_AZ12 as ca
    on cst.cst_key = ca.CID
left join sliver.LOC_A101 as cloc
    on cst.cst_key = cloc.CID;



select 
  row_number() over(order by pd.prd_key,pd.prd_start_dt) as prdouct_key,
  pd.prd_id as product_id,
  pd.prd_key as product_number,
  pd.prd_nm as product_name,
  pd.cat_id as category_id,
  cat.CAT as category,
  cat.SUBCAT as subcategory,
  cat.MAINTENANCE,
  pd.prd_cost as product_cost
  ,pd.prd_line as product_line,
  pd.prd_start_dt as product_start_date
  INTO gold.DIM_PRODUCTS
  from sliver.prd_info as pd
  left join  sliver.PX_CAT_G1V2 as cat
  on cat.id=pd.cat_id
  


 



--design_fact_table


select
sls_ord_num as sales_order_number,
dim_prod.prdouct_key as product_key,
DIM_CUSTOMER.customer_key AS customer_keyy,
CONVERT(INT,CONVERT(VARCHAR(8),sls_order_dt,112))
AS order_date_key,

CONVERT(INT,CONVERT(VARCHAR(8),sls_ship_dt,112))
AS ship_date_key,

CONVERT(INT,CONVERT(VARCHAR(8),sls_due_dt,112))
AS due_date_key,
sls_sales,
sls_quantity,
sls_price
INTO gold.FACT_SALES
from sliver.sales_details as sl
left join gold.DIM_PRODUCTS as dim_prod
on dim_prod.product_number=sl.sls_prd_key
left join gold.DIM_CUSTOMER
on DIM_CUSTOMER.customer_id=sl.sls_cust_id;


select product_key from gold.FACT_SALES

CREATE TABLE gold.DIM_DATE
(
    date_key INT PRIMARY KEY,
    full_date DATE,
    day_number TINYINT,
    day_name VARCHAR(20),
    month_number TINYINT,
    month_name VARCHAR(20),
    quarter_number TINYINT,
    year_number SMALLINT,
    week_number TINYINT,
    is_weekend BIT
);

DECLARE @StartDate DATE='2010-01-01';
DECLARE @EndDate DATE='2014-02-28';

WHILE @StartDate<=@EndDate
BEGIN

    INSERT INTO gold.DIM_DATE
    (
        date_key,
        full_date,
        day_number,
        day_name,
        month_number,
        month_name,
        quarter_number,
        year_number,
        week_number,
        is_weekend
    )
    VALUES
    (
        CONVERT(INT,CONVERT(VARCHAR(8),@StartDate,112)),
        @StartDate,
        DAY(@StartDate),
        DATENAME(WEEKDAY,@StartDate),
        MONTH(@StartDate),
        DATENAME(MONTH,@StartDate),
        DATEPART(QUARTER,@StartDate),
        YEAR(@StartDate),
        DATEPART(WEEK,@StartDate),
        CASE
            WHEN DATENAME(WEEKDAY,@StartDate) IN ('Friday','Saturday')
            THEN 1
            ELSE 0
        END
    );

    SET @StartDate = DATEADD(DAY,1,@StartDate);

END;


ALTER TABLE gold.FACT_SALES
ADD CONSTRAINT FK_FACT_order_date_key
FOREIGN KEY(order_date_key)
REFERENCES gold.DIM_DATE(date_key);


create or alter view data_view
as
select * from gold.DIM_DATE