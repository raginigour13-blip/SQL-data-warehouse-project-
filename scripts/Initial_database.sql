 /*
=============================================================
Create Database and Schemas
=============================================================
Script Purpose:
    This script creates a new database named 'DataWarehouse' after checking if it already exists. 
    If the database exists, it is dropped and recreated. Additionally, the script sets up three schemas 
    within the database: 'bronze', 'silver', and 'gold'.
	
WARNING:
    Running this script will drop the entire 'DataWarehouse' database if it exists. 
    All data in the database will be permanently deleted. Proceed with caution 
    and ensure you have proper backups before running this script.
*/

--================================
--creating database and schema
--================================

use master; --system database in SQL server
go

-- drop and recreate the database 
  if exists(select 1 from sys.database where name = 'dataWarehouse')
  begin
      alter dataWarehouse set single_user with rollback immediate;
      drop database dataWarehouse;
end;
go

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
