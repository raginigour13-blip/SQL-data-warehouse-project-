/*
===============================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
===============================================================================
Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files. 
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
===============================================================================
*/
--===================================
--bulk inserting the data into tables 
--===================================

--=========================================
--creating stored processor for reoccuring query
--=========================================


create or alter procedure bronze.load_bronze as 
 begin
   declare @start_time datetime, @end_time datetime,@batch_start_time datetime , @batch_end_time datetime
   begin try
   set @batch_start_time =GETDATE();
        print('===================================');
        print('loading broze layer');
        print('===================================');
    
        print('loading ther crm section of bronze =');
        print('..truncating table:bronze.crm_cust_info ');
        
        set @start_time =getdate();
            truncate table bronze.crm_cust_info --to first empty table and then restore the data
 

            print('loading the data bronze.crm_cust_info');
            bulk insert bronze.crm_cust_info
            from 'C:\Users\Administrator\Downloads\sql-ultimate-course-main\source_crm\cust_info.csv'
            with(
                firstrow = 2,--for excluding the 1st row
                fieldterminator =',',--separating the data
                tablock --locking the table for improving the performance 
            );
         set @end_time = getdate(); 
         print('load duration :' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds');
         --to get the time sql takes to load the data
        ----------------------------------------
        print('..truncating table:bronze.crm_prd_info ');
        set @start_time =getdate();
        truncate table bronze.crm_prd_info --to first empty table and then restore the data

        print('loading the data bronze.crm_prd_info');
        bulk insert bronze.crm_prd_info
        from 'C:\Users\Administrator\Downloads\sql-ultimate-course-main\source_crm\prd_info.csv'
        with(
            firstrow = 2,--for excluding the 1st roe
            fieldterminator =',',--separating the data
            tablock --locking the table for improving the performance 
        );
         set @end_time = getdate(); 
         print('load duration :' + cast(datediff(second,@start_time,@end_time) as nvarchar) +'seconds');


        ----------------------------------------------------------
        print('..truncating table:bronze.crm_sales_detail ');
        set @start_time =getdate();
        truncate table bronze.crm_sales_detail --to first empty table and then restore the data

        print('loading the data BRONZE.crm_sales_detail');
        bulk insert BRONZE.crm_sales_detail
        from 'C:\Users\Administrator\Downloads\sql-ultimate-course-main\source_crm\sales_details.csv'
        with(
            firstrow = 2,--for excluding the 1st roe
            fieldterminator =',',--separating the data
            tablock --locking the table for improving the performance 
        );
         set @end_time = getdate(); 
         print('load duration :' + cast(datediff(second,@start_time,@end_time) as nvarchar)+'seconds');

        ---------------------------------------------------------
        print('---------------------------------');  
        print('loading erp section of bronze layer');
        print('---------------------------------');

        print('..truncating table:BRONZE.erp_cust_AZ12 ')
        set @start_time =getdate();
        truncate table BRONZE.erp_cust_AZ12 --to first empty table and then restore the data

        print('loading the data BRONZE.erp_cust_AZ12 ');
        bulk insert BRONZE.erp_cust_AZ12 
        from 'C:\Users\Administrator\Downloads\sql-ultimate-course-main\source_erp\cust_AZ12.CSV'
        with(
            firstrow = 2,--for excluding the 1st roe
            fieldterminator =',',--separating the data
            tablock --locking the table for improving the performance 
        );

         set @end_time = getdate(); 
         print('load duration :' + cast(datediff(second,@start_time,@end_time)as nvarchar)+'seconds'); 

        --------------------------------------------------------------
        print('..truncating table:BRONZE.erp_LOC_A101');
        set @start_time =getdate();
        truncate table BRONZE.erp_LOC_A101 --to first empty table and then restore the data

        print('loading the data BRONZE.erp_LOC_A101 ');
        bulk insert BRONZE.erp_LOC_A101 
        from 'C:\Users\Administrator\Downloads\sql-ultimate-course-main\source_erp\lOC_A101.CSV'
        with(
            firstrow = 2,--for excluding the 1st roe
            fieldterminator =',',--separating the data
            tablock --locking the table for improving the performance 
        );

         set @end_time = getdate(); 
         print('load duration :' + cast(datediff(second,@start_time,@end_time)as nvarchar)+ 'seconds'); 

        --------------------------------------------------
        print('..truncating table:BRONZE.erp_PX_CAT_G1V2');
        set @start_time =getdate();
        truncate table BRONZE.erp_PX_CAT_G1V2 --to first empty table and then restore the data

        print('loading the data BRONZE.erp_PX_CAT_G1V2 ');
        bulk insert BRONZE.erp_PX_CAT_G1V2
        from 'C:\Users\Administrator\Downloads\sql-ultimate-course-main\source_erp\PX_CAT_G1V2.CSV'
        with(
            firstrow = 2,--for excluding the 1st roe
            fieldterminator =',',--separating the data
            tablock --locking the table for improving the performance 
        );
         set @end_time = getdate(); 
         print('load duration :' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds');
         set @batch_end_time =GETDATE();
         print('time to load whole bonze layer :'+cast( datediff(second,@batch_start_time,@batch_end_time) as nvarchar)+'seconds');
           --to know whole time to execute the query       
     end try 
     begin catch
        print('=======================================');
        print('error occur during loading ther bronze layer');
        print('error occur :' + error_message());
        print('error number :' + cast(error_number() as nvarchar));
        print('error state :' + cast(error_state() as nvarchar));
        print('error line :' + cast(error_line() as nvarchar));
        print('=======================================');
     end catch
 end ;
 exec bronze.load_bronze
