USE [INDIAN BANK];
GO

-- =====================================================
-- QUERY REQUIREMENTS - COMPLEX ANALYSIS (Queries 17-24 + 20)
-- =====================================================

-- Query 17: List clients who have accounts in all products
WITH TotalProducts AS (
    SELECT COUNT(*) as ProductCount FROM [PRODUCT MASTER]
),
CustomerProductCount AS (
    SELECT 
        am.NAME,
        COUNT(DISTINCT am.PID) as CustomerProducts
    FROM [ACCOUNT MASTER] am
    GROUP BY am.NAME
)
SELECT 
    cpc.NAME AS [Client Name]
FROM CustomerProductCount cpc
CROSS JOIN TotalProducts tp
WHERE cpc.CustomerProducts = tp.ProductCount;
GO

-- Query 18: List accounts likely to become "Inoperative" next month
-- Assuming accounts become inoperative if no transactions for 90 days
SELECT 
    am.ACID AS [Account Number],
    am.NAME AS [Account Holder Name],
    bm.[BRANCH NAME],
    MAX(tm.[DATE OF TRANSACTION]) AS [Last Transaction Date],
    DATEDIFF(DAY, MAX(tm.[DATE OF TRANSACTION]), GETDATE()) AS [Days Since Last Transaction]
FROM [ACCOUNT MASTER] am
INNER JOIN [BRANCH MASTER] bm ON am.BRID = bm.BRID
LEFT JOIN [TRANSACTION MASTER] tm ON am.ACID = tm.ACID
WHERE am.STATUS = 'O'
GROUP BY am.ACID, am.NAME, bm.[BRANCH NAME]
HAVING MAX(tm.[DATE OF TRANSACTION]) < DATEADD(DAY, -60, GETDATE()) 
OR MAX(tm.[DATE OF TRANSACTION]) IS NULL
ORDER BY [Days Since Last Transaction] DESC;
GO

-- Query 19: List user who has entered maximum number of transactions today
WITH UserTransactionCount AS (
    SELECT 
        um.USERID,
        um.[USER NAME],
        COUNT(tm.[TRANSACTION NUMBER]) as TransactionCount
    FROM [USER MASTER] um
    LEFT JOIN [TRANSACTION MASTER] tm ON um.USERID = tm.USERID 
        AND CAST(tm.[DATE OF TRANSACTION] AS DATE) = CAST(GETDATE() AS DATE)
    GROUP BY um.USERID, um.[USER NAME]
)
SELECT 
    USERID,
    [USER NAME],
    TransactionCount AS [Transactions Entered Today]
FROM UserTransactionCount
WHERE TransactionCount = (SELECT MAX(TransactionCount) FROM UserTransactionCount);
GO

-- Query 20: Given a branch, list heaviest day in terms of transactions/value during last month
-- Replace @BRANCH_ID with actual branch ID
DECLARE @BRANCH_ID CHAR(3) = 'BR1'; -- Example branch ID

WITH DailyStats AS (
    SELECT 
        CAST(tm.[DATE OF TRANSACTION] AS DATE) as TransactionDate,
        COUNT(tm.[TRANSACTION NUMBER]) as TransactionCount,
        SUM(CASE WHEN tm.TXN_TYPE = 'CD' THEN tm.TXN_AMOUNT ELSE 0 END) as CashDepositValue
    FROM [TRANSACTION MASTER] tm
    WHERE tm.BRID = @BRANCH_ID
    AND tm.[DATE OF TRANSACTION] >= DATEADD(MONTH, -1, GETDATE())
    GROUP BY CAST(tm.[DATE OF TRANSACTION] AS DATE)
)
SELECT TOP 1
    TransactionDate AS [Heaviest Day],
    TransactionCount AS [Number of Transactions],
    CashDepositValue AS [Cash Deposit Value]
FROM DailyStats
ORDER BY TransactionCount DESC, CashDepositValue DESC;
GO

-- Query 21: List clients who have not used cheque books during last 15 days
SELECT DISTINCT 
    am.ACID AS [Account Number],
    am.NAME AS [Client Name]
FROM [ACCOUNT MASTER] am
WHERE am.ACID NOT IN (
    SELECT DISTINCT tm.ACID
    FROM [TRANSACTION MASTER] tm
    WHERE tm.TXN_TYPE = 'CQD'
    AND tm.[DATE OF TRANSACTION] >= DATEADD(DAY, -15, GETDATE())
);
GO

-- Query 22: Transactions where transacting branch differs from account branch (same region)
SELECT 
    tm.[TRANSACTION NUMBER],
    am.ACID AS [Account Number],
    am.NAME AS [Account Holder],
    acc_bm.[BRANCH NAME] AS [Account Branch],
    txn_bm.[BRANCH NAME] AS [Transaction Branch],
    rm.[REGION NAME],
    tm.TXN_AMOUNT
FROM [TRANSACTION MASTER] tm
INNER JOIN [ACCOUNT MASTER] am ON tm.ACID = am.ACID
INNER JOIN [BRANCH MASTER] acc_bm ON am.BRID = acc_bm.BRID
INNER JOIN [BRANCH MASTER] txn_bm ON tm.BRID = txn_bm.BRID
INNER JOIN [REGION MASTER] rm ON acc_bm.RID = rm.RID
WHERE am.BRID != tm.BRID
AND acc_bm.RID = txn_bm.RID;
GO

-- Query 23: Transactions where transacting branch differs from account branch (different regions)
SELECT 
    tm.[TRANSACTION NUMBER],
    am.ACID AS [Account Number],
    am.NAME AS [Account Holder],
    acc_bm.[BRANCH NAME] AS [Account Branch],
    txn_bm.[BRANCH NAME] AS [Transaction Branch],
    acc_rm.[REGION NAME] AS [Account Region],
    txn_rm.[REGION NAME] AS [Transaction Region],
    tm.TXN_AMOUNT
FROM [TRANSACTION MASTER] tm
INNER JOIN [ACCOUNT MASTER] am ON tm.ACID = am.ACID
INNER JOIN [BRANCH MASTER] acc_bm ON am.BRID = acc_bm.BRID
INNER JOIN [BRANCH MASTER] txn_bm ON tm.BRID = txn_bm.BRID
INNER JOIN [REGION MASTER] acc_rm ON acc_bm.RID = acc_rm.RID
INNER JOIN [REGION MASTER] txn_rm ON txn_bm.RID = txn_rm.RID
WHERE am.BRID != tm.BRID
AND acc_bm.RID != txn_bm.RID;
GO

-- Query 24: Average transaction amount TransactionType-wise for given branch and date
-- Replace @BRANCH_ID and @GIVEN_DATE with actual values
DECLARE @BRANCH_ID CHAR(3) = 'BR1'; -- Example branch ID
DECLARE @GIVEN_DATE DATE = CAST(GETDATE() AS DATE); -- Example date

SELECT 
    tm.TXN_TYPE AS [Transaction Type],
    AVG(tm.TXN_AMOUNT) AS [Average Transaction Amount],
    COUNT(tm.[TRANSACTION NUMBER]) AS [Number of Transactions]
FROM [TRANSACTION MASTER] tm
WHERE tm.BRID = @BRANCH_ID
AND CAST(tm.[DATE OF TRANSACTION] AS DATE) = @GIVEN_DATE
GROUP BY tm.TXN_TYPE
ORDER BY tm.TXN_TYPE;
GO

-- Query 20 (Additional): Account Master Analysis
-- Product-wise, month-wise, number of accounts
SELECT 
    pm.[PRODUCT NAME],
    YEAR(am.[DATE OF OPENING]) AS [Year],
    MONTH(am.[DATE OF OPENING]) AS [Month],
    COUNT(am.ACID) AS [Number of Accounts]
FROM [ACCOUNT MASTER] am
INNER JOIN [PRODUCT MASTER] pm ON am.PID = pm.PID
GROUP BY pm.PID, pm.[PRODUCT NAME], YEAR(am.[DATE OF OPENING]), MONTH(am.[DATE OF OPENING])
ORDER BY pm.[PRODUCT NAME], [Year], [Month];
GO

-- Total number of accounts for each product
SELECT 
    pm.[PRODUCT NAME],
    COUNT(am.ACID) AS [Total Accounts]
FROM [PRODUCT MASTER] pm
LEFT JOIN [ACCOUNT MASTER] am ON pm.PID = am.PID
GROUP BY pm.PID, pm.[PRODUCT NAME]
ORDER BY [Total Accounts] DESC;
GO

-- Total number of accounts for each month
SELECT 
    YEAR([DATE OF OPENING]) AS [Year],
    MONTH([DATE OF OPENING]) AS [Month],
    COUNT(ACID) AS [Accounts Opened]
FROM [ACCOUNT MASTER]
GROUP BY YEAR([DATE OF OPENING]), MONTH([DATE OF OPENING])
ORDER BY [Year], [Month];
GO

-- Total number of accounts in our bank
SELECT 
    COUNT(ACID) AS [Total Accounts in Bank],
    COUNT(CASE WHEN STATUS = 'O' THEN 1 END) AS [Active Accounts],
    COUNT(CASE WHEN STATUS = 'I' THEN 1 END) AS [Inoperative Accounts],
    COUNT(CASE WHEN STATUS = 'C' THEN 1 END) AS [Closed Accounts]
FROM [ACCOUNT MASTER];
GO

PRINT 'Complex Analysis Queries (17-24 + 20) completed successfully!';
PRINT 'All Query Requirements completed successfully!';
