-- Indian Bank Database Creation
-- Author: Krishna Aryal
-- Institution: Georgia Institute of Technology

USE master;
GO

-- Drop database if exists
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'IndianBank')
BEGIN
    ALTER DATABASE IndianBank SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE IndianBank;
END
GO

-- Create Indian Bank Database
CREATE DATABASE IndianBank;
GO

USE IndianBank;
GO

PRINT 'Indian Bank Database created successfully!';