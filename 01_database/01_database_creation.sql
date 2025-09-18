-- Create Database
CREATE DATABASE [INDIAN BANK];
GO

USE [INDIAN BANK];
GO

-- Create PRODUCT MASTER table (needed first for ACCOUNT MASTER FK)
CREATE TABLE [PRODUCT MASTER] (
    PID                 CHAR(2)         PRIMARY KEY,
    [PRODUCT NAME]      VARCHAR(25)     NOT NULL
);
GO

-- Create REGION MASTER table (needed first for BRANCH MASTER FK)
CREATE TABLE [REGION MASTER] (
    RID                 INTEGER         PRIMARY KEY,
    [REGION NAME]       CHAR(6)         NOT NULL
);
GO

-- Create BRANCH MASTER table (needed first for ACCOUNT MASTER FK)
CREATE TABLE [BRANCH MASTER] (
    BRID                CHAR(3)         PRIMARY KEY,
    [BRANCH NAME]       VARCHAR(30)     NOT NULL,
    [BRANCH ADDRESS]    VARCHAR(50)     NOT NULL,
    RID                 INT             NOT NULL FOREIGN KEY REFERENCES [REGION MASTER](RID)
);
GO

-- Create USER MASTER table (needed first for TRANSACTION MASTER FK)
CREATE TABLE [USER MASTER] (
    USERID              INTEGER         PRIMARY KEY,
    [USER NAME]         VARCHAR(30)     NOT NULL,
    DESIGNATION         CHAR(1)         NOT NULL CHECK (DESIGNATION IN ('M', 'T', 'C', 'O'))
);
GO

-- 1. ACCOUNT MASTER (first in document order)
CREATE TABLE [ACCOUNT MASTER] (
    ACID                INTEGER         PRIMARY KEY,
    NAME                VARCHAR(40)     NOT NULL,
    ADDRESS             VARCHAR(50)     NOT NULL,
    BRID                CHAR(3)         NOT NULL FOREIGN KEY REFERENCES [BRANCH MASTER](BRID),
    PID                 CHAR(2)         NOT NULL FOREIGN KEY REFERENCES [PRODUCT MASTER](PID),
    [DATE OF OPENING]   DATETIME        NOT NULL,
    [CLEAR BALANCE]     MONEY           NULL,
    [UNCLEAR BALANCE]   MONEY           NULL,
    STATUS              CHAR(1)         NOT NULL DEFAULT 'O' CHECK (STATUS IN ('O', 'I', 'C'))
);
GO

-- 6. TRANSACTION MASTER (last in document order)
CREATE TABLE [TRANSACTION MASTER] (
    [TRANSACTION NUMBER]    INTEGER         IDENTITY(1,1) PRIMARY KEY,
    [DATE OF TRANSACTION]   DATETIME        NOT NULL,
    ACID                    INTEGER         NOT NULL FOREIGN KEY REFERENCES [ACCOUNT MASTER](ACID),
    BRID                    CHAR(3)         NOT NULL FOREIGN KEY REFERENCES [BRANCH MASTER](BRID),
    TXN_TYPE               CHAR(3)         NOT NULL CHECK (TXN_TYPE IN ('CW', 'CD', 'CQD')),
    CHQ_NO                 INTEGER         NULL,
    CHQ_DATE               SMALLDATETIME   NULL,
    TXN_AMOUNT             MONEY           NOT NULL,
    USERID                 INTEGER         NOT NULL FOREIGN KEY REFERENCES [USER MASTER](USERID)
);
GO

-- Display confirmation message
PRINT 'Database "INDIAN BANK" and all tables have been created successfully!';
