--تسرع عمليه الادخال (PERFORMANCE اعلى)
	--تمنع اى حد يستخدم الجدول تانى 
CREATE OR ALTER procedure bronze.load_to_warehouse as
begin
begin try
   declare @starttime datetime,@endtime datetime;
      
print 'loading Bronze Layer'
print '------------------------------'
print 'loading crm table'
print '------------------------------'
print 'trucate_cust_info'
set @starttime=GETDATE();
truncate table bronze.cust_info;
print 'insert data into cust_info '
bulk insert  bronze.cust_info
from 'D:\course_data analysis\project_data_warehouse\crm\cust_info.csv'
with(
    FIRSTROW=2,
    FIELDTERMINATOR=',',
    TABLOCK
)
print 'trucate_prd_info'
truncate table bronze.prd_info;
print 'insert data into _prd_info'
bulk insert  bronze.prd_info
from 'D:\course_data analysis\project_data_warehouse\crm\prd_info.csv'
with(
    FIRSTROW=2,
    FIELDTERMINATOR=',',
    TABLOCK
)
print 'trucate_sales_details'
truncate table bronze.sales_details;
print 'insert_into_sales_details'
bulk insert  bronze.sales_details
from 'D:\course_data analysis\project_data_warehouse\crm\sales_details.csv'
with(
    FIRSTROW=2,
    FIELDTERMINATOR=',',
    TABLOCK
)

print 'loading from erp '
print '------------------------'
print 'truncate CUST_AZ12_erp'
truncate table bronze.CUST_AZ12;
print 'insert data into CUST_AZ12'
bulk insert bronze.CUST_AZ12
from 'D:\course_data analysis\project_data_warehouse\erp\CUST_AZ12.csv'
with(
    FIRSTROW=2,
    FIELDTERMINATOR=',',
    TABLOCK
)
print 'truncate LOC_A101_erp'
truncate table bronze.LOC_A101;
print 'insert data into LOC_A101_erp'
bulk insert bronze.LOC_A101
from '"D:\course_data analysis\project_data_warehouse\erp\LOC_A101.csv"'
with(
    FIRSTROW=2,
    FIELDTERMINATOR=',',
    TABLOCK
)
print 'truncate PX_CAT_G1V2_erp'
truncate table bronze.PX_CAT_G1V2;
print 'insert PX_CAT_G1V2_erp'
bulk insert bronze.PX_CAT_G1V2
from 'D:\course_data analysis\project_data_warehouse\erp\PX_CAT_G1V2.csv'
with(
    FIRSTROW=2,
    FIELDTERMINATOR=',',
    TABLOCK
)
set @endtime=GETDATE();
print '<<<<<load_duration of loading all_tables ' + cast(datediff(second,@endtime,@starttime) as nvarchar) + 'second'
end try
begin catch
print '----------------'
print 'Error_Message during loading bronze table'
print 'Error Message'+ERROR_MESSAGE()
print 'Error Message'+CAST(ERROR_NUMBER() AS NVARCHAR)
print 'Error Message'+CAST(ERROR_STATE() AS NVARCHAR)
END catch

END
exec bronze.load_to_warehouse;
