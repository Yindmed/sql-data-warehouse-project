/*
=============================================================
Description:
 This script initializes the Data Warehouse environment.
 It performs the following actions:
 1. Drops the existing DataWarehouse database (if exists)
 2. Creates a new DataWarehouse database
 3. Creates the Medallion Architecture schemas:
    - bronze (raw data)
    - silver (cleaned data)
    - gold (analytics-ready data)

Notes:
 - WARNING: This script will delete the existing database.
 - Intended for development and testing environments.
 - Must be executed with sufficient permissions.

=============================================================
*/
  -- Step 1: Use master to manage database
USE master;
GO

-- Step 2: Drop database if exists
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END
GO

-- Step 3: Create new database
CREATE DATABASE DataWarehouse;
GO

-- Step 4: Switch to new database
USE DataWarehouse;
GO

-- Step 5: Create schemas (Medallion Architecture)
CREATE SCHEMA bronze;
GO

CREATE SCHEMA silver;
GO

CREATE SCHEMA gold;
GO
