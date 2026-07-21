/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables (Star Schema)

    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dim_customers
-- =============================================================================

create view gold.dim_customers as
select 
    ROW_NUMBER() over(order by ci.cust_id) as customer_key,--surrogate key
	ci.cust_id as customer_id,
	ci.cust_key as customer_number,
	ci.cust_firstname as first_name,
	ci.cust_lastname as last_name,
	cl.LOC_COUNTRY as country ,
	ci.cust_martialstatus as marital_status,
	CASE WHen ca.cust_gender = 'N/A' then ci.cust_gndr --crm is the master table  
	     else coalesce(ca.cust_gender,'N/A') 
    end gender,
	ca.cust_birthdate as birthday,
	ci.cust_creationdate as Creation_date 
from SILVER.crm_cust_info ci
left join SILVER.erp_cust_AZ12 ca
on ci.cust_key = ca.cust_id
left join SILVER.erp_LOC_A101 cl
on ci.cust_key =cl.LOC_ID

------------------------------------------------------
  --creating gold.dim_procduct
------------------------------------------------------

create view gold.dim_product as
select
    row_number() over(order by pn.prd_start_date,pn.prd_key) as product_key,
	pn.prd_id as product_id,
	pn.prd_key as product_number,
	pn.prd_nm as product_name,
	pn.cat_id as category_id,
	px.PX_category as category,
	PX_subcategory as subcategory,
	PX_maintainence as maintainence,
	pn.prd_cost as cost,
	pn.prd_line as product_line,
	pn.prd_start_date as start_date
from SILVER.crm_prd_info as pn
left join SILVER.erp_PX_CAT_G1V2 as px
on pn.cat_id =PX_id
where prd_end_date is null -- filter out all historical data


---------------------------------------------------
--craeting gold.fact_sales
----------------------------------------------------
create view gold.fact_sales as
select 
	sd.sls_prd_number as order_number,
    pn.product_key,
	ci.customer_key,
	sd.sls_order_date as order_date,
	sd.sls_ship_date as ship_date,
	sd.sls_due_date as due_date,
	sd.sls_sales as sales,
	sd.sls_quantity as quantity,
	sd.sls_price as price
from SILVER.crm_sales_detail sd
left join gold.dim_product pn
on sd.sls_prd_key =pn.product_number
left join gold.dim_customers ci
on sd.sls_customer_id =ci.customer_id



