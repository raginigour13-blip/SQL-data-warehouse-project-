/*
===============================================================================
DDL Script: Create Bronze Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables 
    if they already exist.
	  Run this script to re-define the DDL structure of 'bronze' Tables
===============================================================================
*/

use master; --system database in SQL server 

create database DataWarehouse;

USE DataWarehouse;
--=========================
--CREATE SCHEMAS 
--=========================

CREATE SCHEMA BRONZE ;
GO--IN SQL Works as separater
CREATE SCHEMA SILVER;
GO
CREATE SCHEMA GOLD;
GO

--===============================
--creating broze layer 
--===============================

--table creation only 

if OBJECT_ID('bronze.crm_cust_info','U') is not null 
    drop table bronze.crm_cust_info
create table bronze.crm_cust_info(--crm is file name from source data and cust_info also
    cust_id int,
    cust_key nvarchar(50),
    cust_firstname nvarchar(50),
    cust_lastname nvarchar(50),
    cust_martialstatus nvarchar(20),
    cust_gndr nvarchar(20),
    cust_creationdate date
);

--create SQL DDLscript for ALL CSV file in CRM and ERP system

if OBJECT_ID(' bronze.crm_prd_info','U') is not null 
    drop table bronze.crm_prd_info
create table bronze.crm_prd_info(
    prd_id int,
    prd_key nvarchar(50),
    prd_nm nvarchar(50),
    prd_cost int,
    prd_line nvarchar(20),
    prd_start_date date,
    prd_end_date date
);

if OBJECT_ID(' bronze.crm_sales_detail','U') is not null 
    drop table bronze.crm_sales_detail
create table bronze.crm_sales_detail(
    sls_prd_number nvarchar(50),
    sls_prd_key nvarchar(50),
    sls_customer_id int,
    sls_order_date int,
    sls_ship_date int,
    sls_due_date int,
    sls_sales int,
    sls_quantity int,
    sls_price int
);


if OBJECT_ID(' bronze.erp_PX_CAT_G1V2','U') is not null 
    drop table bronze.erp_PX_CAT_G1V2
create table bronze.erp_PX_CAT_G1V2(
    PX_id nvarchar(50),
    PX_category nvarchar(50),
    PX_subcategory nvarchar(50),
    PX_maintainence nvarchar(10)
);

if OBJECT_ID(' bronze.erp_LOC_A101','U') is not null --U stands for user side table
    drop table bronze.erp_LOC_A101
create table bronze.erp_LOC_A101(
    LOC_ID NVARCHAR(50),
    LOC_COUNTRY NVARCHAR(50)
);


if OBJECT_ID('BRONZE.erp_cust_AZ12','U') is not null --U stands for user side table
    drop table BRONZE.erp_cust_AZ12
CREATE TABLE BRONZE.erp_cust_AZ12(
    cust_id nvarchar(50),
    cust_birthdate date,
    cust_gender nvarchar(15)
);

