/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/
--------------------------------------------
--stored processor for silver
---------------------------------------------
create or alter procedure silver.load_silver as
begin
  declare @start_time datetime, @end_time datetime,@batch_start_time datetime , @batch_end_time datetime
	begin try
	set @batch_start_time = GETDATE();
        print('===================================');
        print('loading silver layer');
        print('===================================');
		print('loading CRM tables');
		print('===================================');
	set @start_time =GETDATE();
		print('truncating data into silver.crm_cust_info');
		truncate table silver.crm_cust_info
		print('inserting data into silver.crm_cust_info');
	
			insert into SILVER.crm_cust_info(
				cust_id,
				cust_key,
				cust_firstname,
				cust_lastname,
				cust_martialstatus,
				cust_gndr,
				cust_creationdate)
			select
			cust_id,
			cust_key,
			trim(cust_firstname) as cust_firstname,
			trim(cust_lastname) as cust_lastname,
				case when upper(trim(cust_martialstatus)) ='S' THEN 'Single'
					 when upper(trim(cust_martialstatus))='M' THEN 'Married'
					 ELSE 'N/A'
				END cust_martialstatus,
        
				case when upper(trim(cust_gndr)) ='F' THEN 'Female'
					 when upper(trim(cust_gndr))='M' THEN 'Male'
					 ELSE 'N/A'
				END cust_gndr,
			cust_creationdate
			from(
				select*,
				row_number() over(partition by cust_id order by cust_creationdate desc) flag
				from BRONZE.crm_cust_info
				where cust_id is not null
				)a
			where flag = 1
		 set @end_time = getdate(); 
         print('load duration :' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds');
         --to get the time sql takes to load the data
		 print('----------divison --------------------');
		 print(' ');
-------------------------------------------------------------------------
	set @start_time =GETDATE();
	    print('truncating data into SILVER.crm_prd_info');
		truncate table SILVER.crm_prd_info
		print('inserting data into SILVER.crm_prd_info');

			insert into SILVER.crm_prd_info(
				prd_id,
				cat_id,
				prd_key,
				prd_nm,
				prd_cost,
				prd_line,
				prd_start_date,
				prd_end_date)
			select
				prd_id,
				replace(SUBSTRING(prd_key,1,5),'-','_') as cust_id,
				SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key,
				prd_nm,
				coalesce(prd_cost,0) as prd_cost,
					case when upper(trim(prd_line)) = 'M' THEN 'Mountain'
						 when upper(trim(prd_line)) = 'R' THEN 'Road'
						 when upper(trim(prd_line)) = 'S' THEN 'Other Sales'
						 when upper(trim(prd_line)) = 'T' THEN 'Touring'
						 else 'n/a'
					end prd_line,
				prd_start_date,
				dateadd(day,-1, lead(prd_start_date) over (partition by prd_key ORDER BY prd_start_date )) as prd_end_date
			from BRONZE.crm_prd_info
		 set @end_time = getdate(); 
         print('load duration :' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds');
         --to get the time sql takes to load the data
         print('----------divison --------------------');
		 print(' ');
----------------------------------------------------------------
	set @start_time =GETDATE();	
		print('truncating data into silver.crm_sales_detail');
		truncate table silver.crm_sales_detail
		print('inserting data into silver.crm_sales_detail');
	
			insert into SILVER.crm_sales_detail(
				sls_prd_number,
				sls_prd_key,
				sls_customer_id,
				sls_order_date,
				sls_ship_date,
				sls_due_date,
				sls_sales,
				sls_quantity,
				sls_price
			)
			SELECT 
				   sls_prd_number,
				   sls_prd_key,
				   sls_customer_id,
						case when sls_order_date = 0 or len(sls_order_date) != 8 then null
						else cast(cast(sls_order_date as nvarchar)as date)
						end sls_order_date,
						case when sls_ship_date = 0 or len(sls_ship_date) != 8 then null
						else cast(cast(sls_ship_date as nvarchar)as date)
						end sls_ship_date,
						case when sls_due_date = 0 or len(sls_due_date) != 8 then null
						else cast(cast(sls_due_date as nvarchar)as date)
						end sls_due_date,        
						case when sls_sales is null or sls_sales <= 0 or sls_sales !=sls_quantity *abs(sls_price) then sls_quantity * abs(sls_price)
						else sls_sales
						end as sls_sales,
				   sls_quantity,
						case when sls_price is null or sls_price <= 0 then sls_sales/nullif(sls_quantity,0)
						else sls_price
						end sls_price
			  FROM BRONZE.crm_sales_detail
		 set @end_time = getdate(); 
         print('load duration :' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds');
         --to get the time sql takes to load the data
		 print('----------divison --------------------');
		 print(' ');
		 print('===================================');
		 print('loading ERP tables');
		 print('===================================');
----------------------------------------------------------------------
	set @start_time =GETDATE();
		print('truncating data into silver.erp_cut_az12');
		truncate table silver.erp_cust_az12
		print('inserting data into silver.erp_cut_az12');
			insert into SILVER.erp_cust_AZ12(
				cust_id,
				cust_birthdate,
				cust_gender
			)
			select
				CASE WHEN cust_id LIKE 'NAS%' then SUBSTRING(cust_id,4,LEN(cust_id))
					else cust_id
				end cust_id,
	
				case when cust_birthdate > GETDATE() then null
					else cust_birthdate
				end cust_birthdate,
	
				case when upper(trim(cust_gender)) in ('F','Female') then 'Female'
					 when Upper(trim(cust_gender)) in ('M','Male')  then 'Male'
					 else 'n/a'
				end cust_gender
			from BRONZE.erp_cust_AZ12
		 set @end_time = getdate(); 
         print('load duration :' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds');
         --to get the time sql takes to load the data
		 print('----------divison --------------------');
		 print(' ');
--------------------------------------------------------------------------------
 set @start_time =GETDATE();
		print('truncating data into silver.erp_loc_A101')
		truncate table silver.erp_LOC_A101
		print('inserting data into silver.erp_LOC_A101')

			insert into SILVER.erp_LOC_A101(
				LOC_ID,
				LOC_COUNTRY
			)
			select
			REPLACE(LOC_ID,'-',''),
			CASE WHEN UPPER(TRIM(LOC_COUNTRY)) IN('USA' ,'UNITED STATES','US') THEN 'United State'
				 WHEN UPPER(TRIM(LOC_COUNTRY))= 'DE' THEN 'Germany'
				 when LOC_COUNTRY is null OR TRIM(LOC_COUNTRY) = '' then 'n/a'
				 else trim(LOC_COUNTRY)
			end loc_country
			from bronze.erp_LOC_A101 
         set @end_time = getdate(); 
         print('load duration :' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds');
         --to get the time sql takes to load the data
		 print('----------divison --------------------');
		 print(' ');
------------------------------------------------------------------
	set @start_time =GETDATE();
		print('truncating data into silver.erp_PX_CAT_G1V2')
		truncate table silver.erp_PX_CAT_G1V2
		print('inserting data into silver.erp_PX_CAT_G1V2')
	
			insert into SILVER.erp_PX_CAT_G1V2(
			PX_id,
			PX_category,
			PX_subcategory,
			PX_maintainence
			 )
			select 
				PX_id,
				PX_category,
				PX_subcategory,
				PX_maintainence
			from BRONZE.erp_PX_CAT_G1V2
		 set @end_time = getdate(); 
         print('load duration :' + cast(datediff(second,@start_time,@end_time) as nvarchar) + 'seconds');
         --to get the time sql takes to load the data
		 set @batch_end_time =GETDATE();
         print('time to load whole silver layer :'+cast( datediff(second,@batch_start_time,@batch_end_time) as nvarchar)+'seconds');
           --to know whole time to execute the query
--------------------------------------------------------------------------------
		end try 
		begin catch
        print('=======================================');
        print('error occur during loading ther silver layer');
        print('error occur :' + error_message());
        print('error number :' + cast(error_number() as nvarchar));
        print('error state :' + cast(error_state() as nvarchar));
        print('error line :' + cast(error_line() as nvarchar));
        print('=======================================');
     end catch
end 

exec silver.load_silver
