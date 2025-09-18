USE [INDIAN BANK];
GO

-- =====================================================
-- VIEW REQUIREMENTS
-- =====================================================

-- View 1: Only the Account Number, Name and Address from the 'Account Master'
CREATE VIEW VW_ACCOUNT_BASIC_INFO
AS
SELECT 
    ACID AS [Account Number],
    NAME,
    ADDRESS
FROM [ACCOUNT MASTER];
GO

-- View 2: Account Number, Name, Date of last Transaction, total number of transactions in the Account
CREATE VIEW VW_ACCOUNT_TRANSACTION_SUMMARY
AS
SELECT 
    am.ACID AS [Account Number],
    am.NAME,
    MAX(tm.[DATE OF TRANSACTION]) AS [Date of Last Transaction],
    COUNT(tm.[TRANSACTION NUMBER]) AS [Total Number of Transactions]
FROM [ACCOUNT MASTER] am
LEFT JOIN [TRANSACTION MASTER] tm ON am.ACID = tm.ACID
GROUP BY am.ACID, am.NAME;
GO

-- View 3: Branch-wise, Product-wise, sum of Uncleared balance
CREATE VIEW VW_BRANCH_PRODUCT_UNCLEARED_BALANCE
AS
SELECT 
    bm.BRID AS [Branch ID],
    bm.[BRANCH NAME],
    pm.PID AS [Product ID],
    pm.[PRODUCT NAME],
    SUM(ISNULL(am.[UNCLEAR BALANCE], 0)) AS [Sum of Uncleared Balance]
FROM [ACCOUNT MASTER] am
INNER JOIN [BRANCH MASTER] bm ON am.BRID = bm.BRID
INNER JOIN [PRODUCT MASTER] pm ON am.PID = pm.PID
GROUP BY bm.BRID, bm.[BRANCH NAME], pm.PID, pm.[PRODUCT NAME];
GO

-- View 4: Customer-wise, number of accounts held
CREATE VIEW VW_CUSTOMER_ACCOUNT_COUNT
AS
SELECT 
    NAME AS [Customer Name],
    COUNT(ACID) AS [Number of Accounts Held]
FROM [ACCOUNT MASTER]
GROUP BY NAME;
GO

-- View 5: TransactionType-wise, Account-wise, sum of transaction amount for the current month
CREATE VIEW VW_CURRENT_MONTH_TRANSACTION_SUMMARY
AS
SELECT 
    tm.TXN_TYPE AS [Transaction Type],
    tm.ACID AS [Account Number],
    am.NAME AS [Account Holder Name],
    SUM(tm.TXN_AMOUNT) AS [Sum of Transaction Amount]
FROM [TRANSACTION MASTER] tm
INNER JOIN [ACCOUNT MASTER] am ON tm.ACID = am.ACID
WHERE YEAR(tm.[DATE OF TRANSACTION]) = YEAR(GETDATE())
AND MONTH(tm.[DATE OF TRANSACTION]) = MONTH(GETDATE())
GROUP BY tm.TXN_TYPE, tm.ACID, am.NAME;
GO

PRINT 'All Views created successfully!';

-- Optional: Test Views
PRINT 'Testing Views...';

SELECT 'View 1: Account Basic Info' AS [View Name];
SELECT TOP 5 * FROM VW_ACCOUNT_BASIC_INFO;

SELECT 'View 2: Account Transaction Summary' AS [View Name];
SELECT TOP 5 * FROM VW_ACCOUNT_TRANSACTION_SUMMARY;

SELECT 'View 3: Branch Product Uncleared Balance' AS [View Name];
SELECT TOP 5 * FROM VW_BRANCH_PRODUCT_UNCLEARED_BALANCE;

SELECT 'View 4: Customer Account Count' AS [View Name];
SELECT TOP 5 * FROM VW_CUSTOMER_ACCOUNT_COUNT;

SELECT 'View 5: Current Month Transaction Summary' AS [View Name];
SELECT TOP 5 * FROM VW_CURRENT_MONTH_TRANSACTION_SUMMARY;
