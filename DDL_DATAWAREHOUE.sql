--we create schema for each layer
create schema bronze;

create schema sliver;

create schema gold;

IF OBJECT_ID('bronze.cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.cust_info;
create table bronze.cust_info(
cst_id int
,cst_key nvarchar(50)
,cst_firstname nvarchar(50)
,cst_lastname nvarchar(50)
,cst_marital_status nvarchar(50)
,cst_gndr nvarchar(50)
,cst_create_date date
)
IF OBJECT_ID('bronze.prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.prd_info;
create table bronze.prd_info(
prd_id int
,prd_key nvarchar(50)
,prd_nm nvarchar(50)
,prd_cost nvarchar(50)
,prd_line nvarchar(50)
,prd_start_dt date
,prd_end_dt date
)
IF OBJECT_ID('bronze.sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.sales_details;
create table bronze.sales_details(
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cust_id int,
sls_order_dt int,
sls_ship_dt int,
sls_due_dt int,
sls_sales int,
sls_quantity int,
sls_price int
)
IF OBJECT_ID('bronze.LOC_A101', 'U') IS NOT NULL
    DROP TABLE bronze.LOC_A101;

create table bronze.LOC_A101(
CID nvarchar(50)
,CNTRY nvarchar(50)
)
IF OBJECT_ID('bronze.CUST_AZ12', 'U') IS NOT NULL
    DROP TABLE bronze.CUST_AZ12;
create table bronze.CUST_AZ12(
CID nvarchar(50),
BDATE date
,GEN nvarchar(50)
)

IF OBJECT_ID('bronze.PX_CAT_G1V2', 'U') IS NOT NULL
    DROP TABLE bronze.PX_CAT_G1V2;
create table bronze.PX_CAT_G1V2(
ID nvarchar(50)
,CAT nvarchar(50)
,SUBCAT nvarchar(50)
,MAINTENANCE nvarchar(50)
)


IF OBJECT_ID('sliver.cust_info', 'U') IS NOT NULL
    DROP TABLE sliver.cust_info;
create table sliver.cust_info(
cst_id int
,cst_key nvarchar(50)
,cst_firstname nvarchar(50)
,cst_lastname nvarchar(50)
,cst_marital_status nvarchar(50)
,cst_gndr nvarchar(50)
,cst_create_date date
,dwh_create_data 
)
IF OBJECT_ID('sliver.prd_info', 'U') IS NOT NULL
    DROP TABLE sliver.prd_info;
create table sliver.prd_info(
prd_id int
,cat_id nvarchar(50)
,prd_key nvarchar(50)
,prd_nm nvarchar(50)
,prd_cost nvarchar(50)
,prd_line nvarchar(50)
,prd_start_dt date
,prd_end_dt date
)
IF OBJECT_ID('sliver.sales_details', 'U') IS NOT NULL
    DROP TABLE sliver.sales_details;
create table sliver.sales_details(
sls_ord_num nvarchar(50),
sls_prd_key nvarchar(50),
sls_cust_id int,
sls_order_dt int,
sls_ship_dt int,
sls_due_dt int,
sls_sales int,
sls_quantity int,
sls_price int
)

IF OBJECT_ID('sliver.LOC_A101', 'U') IS NOT NULL
    DROP TABLE sliver.LOC_A101;
create table sliver.LOC_A101(
CID nvarchar(50)
,CNTRY nvarchar(50)
)
IF OBJECT_ID('sliver.CUST_AZ12', 'U') IS NOT NULL
    DROP TABLE sliver.CUST_AZ12;
create table sliver.CUST_AZ12(
CID nvarchar(50),
BDATE date
,GEN nvarchar(50)
)

IF OBJECT_ID('sliver.PX_CAT_G1V2', 'U') IS NOT NULL
    DROP TABLE sliver.PX_CAT_G1V2;
create table sliver.PX_CAT_G1V2(
ID nvarchar(50)
,CAT nvarchar(50)
,SUBCAT nvarchar(50)
,MAINTENANCE nvarchar(50)
)

