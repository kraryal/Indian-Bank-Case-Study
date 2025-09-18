USE [INDIAN BANK];
GO

-- =====================================================
-- QUERY REQUIREMENTS - BASIC REPORTS (Queries 1-8)
-- =====================================================

-- Query 1: List the transactions that have taken place in a given Branch during the previous month
-- Replace @BRANCH_ID with actual branch ID
DECLARE @BRANCH_ID CHAR(3) = 'BR1'; -- Example branch ID

SELECT 
    tm.[TRANSACTION NUMBER],
    tm.[DATE OF TRANSACTION],
    am.NAME AS [Account Holder Name],
    tm.TXN_TYPE,
    tm.TXN_AMOUNT,
    bm.[BRANCH NAME]
FROM [TRANSACTION MASTER] tm
INNER JOIN [ACCOUNT MASTER] am ON tm.ACID = am.ACID
INNER JOIN [BRANCH MASTER] bm ON tm.BRID = bm.BRID
WHERE tm.BRID = @BRANCH_ID
AND YEAR(tm.[DATE OF TRANSACTION]) = YEAR(DATEADD(MONTH, -1, GETDATE()))
AND MONTH(tm.[DATE OF TRANSACTION]) = MONTH(DATEADD(MONTH, -1, GETDATE()));
GO

-- Query 2: Give the branch-wise total cash deposits that have taken place during the last 5 days
SELECT 
    bm.BRID,
    bm.[BRANCH NAME],
    SUM(tm.TXN_AMOUNT) AS [Total Cash Deposits]
FROM [TRANSACTION MASTER] tm
INNER JOIN [BRANCH MASTER] bm ON tm.BRID = bm.BRID
WHERE tm.TXN_TYPE = 'CD'
AND tm.[DATE OF TRANSACTION] >= DATEADD(DAY, -5, GETDATE())
GROUP BY bm.BRID, bm.[BRANCH NAME]
ORDER BY [Total Cash Deposits] DESC;
GO

-- Query 3: Give the branch-wise total cash withdrawals during the last month, where total > Rs 1,00,000
SELECT 
    bm.BRID,
    bm.[BRANCH NAME],
    SUM(tm.TXN_AMOUNT) AS [Total Cash Withdrawals]
FROM [TRANSACTION MASTER] tm
INNER JOIN [BRANCH MASTER] bm ON tm.BRID = bm.BRID
WHERE tm.TXN_TYPE = 'CW'
AND tm.[DATE OF TRANSACTION] >= DATEADD(MONTH, -1, GETDATE())
GROUP BY bm.BRID, bm.[BRANCH NAME]
HAVING SUM(tm.TXN_AMOUNT) > 100000
ORDER BY [Total Cash Withdrawals] DESC;
GO

-- Query 4: List account holders with corresponding branch names for maximum and minimum Cleared balance
WITH MaxMinBalance AS (
    SELECT 
        MAX([CLEAR BALANCE]) AS MaxBalance,
        MIN([CLEAR BALANCE]) AS MinBalance
    FROM [ACCOUNT MASTER]
    WHERE [CLEAR BALANCE] IS NOT NULL
)
SELECT 
    am.NAME AS [Account Holder Name],
    bm.[BRANCH NAME],
    am.[CLEAR BALANCE],
    CASE 
        WHEN am.[CLEAR BALANCE] = mmb.MaxBalance THEN 'Maximum Balance'
        WHEN am.[CLEAR BALANCE] = mmb.MinBalance THEN 'Minimum Balance'
    END AS [Balance Type]
FROM [ACCOUNT MASTER] am
INNER JOIN [BRANCH MASTER] bm ON am.BRID = bm.BRID
CROSS JOIN MaxMinBalance mmb
WHERE am.[CLEAR BALANCE] IN (mmb.MaxBalance, mmb.MinBalance);
GO

-- Query 5: List account holders for second-highest maximum and minimum Cleared balance
WITH RankedBalances AS (
    SELECT 
        am.NAME,
        bm.[BRANCH NAME],
        am.[CLEAR BALANCE],
        ROW_NUMBER() OVER (ORDER BY am.[CLEAR BALANCE] DESC) as RankDesc,
        ROW_NUMBER() OVER (ORDER BY am.[CLEAR BALANCE] ASC) as RankAsc
    FROM [ACCOUNT MASTER] am
    INNER JOIN [BRANCH MASTER] bm ON am.BRID = bm.BRID
    WHERE am.[CLEAR BALANCE] IS NOT NULL
)
SELECT 
    NAME AS [Account Holder Name],
    [BRANCH NAME],
    [CLEAR BALANCE],
    CASE 
        WHEN RankDesc = 2 THEN 'Second Highest Balance'
        WHEN RankAsc = 2 THEN 'Second Lowest Balance'
    END AS [Balance Type]
FROM RankedBalances
WHERE RankDesc = 2 OR RankAsc = 2;
GO

-- Query 6: List account holder with second-highest cleared balance in branch having maximum cleared balance
WITH MaxBalanceBranch AS (
    SELECT TOP 1 BRID
    FROM [ACCOUNT MASTER]
    WHERE [CLEAR BALANCE] = (SELECT MAX([CLEAR BALANCE]) FROM [ACCOUNT MASTER])
),
SecondHighestInBranch AS (
    SELECT 
        am.NAME,
        am.[CLEAR BALANCE],
        ROW_NUMBER() OVER (ORDER BY am.[CLEAR BALANCE] DESC) as Rank
    FROM [ACCOUNT MASTER] am
    INNER JOIN MaxBalanceBranch mbb ON am.BRID = mbb.BRID
    WHERE am.[CLEAR BALANCE] IS NOT NULL
)
SELECT 
    NAME AS [Account Holder Name],
    [CLEAR BALANCE]
FROM SecondHighestInBranch
WHERE Rank = 2;
GO

-- Query 7: Give TransactionType-wise, branch-wise, total amount for the day
SELECT 
    bm.BRID,
    bm.[BRANCH NAME],
    tm.TXN_TYPE,
    SUM(tm.TXN_AMOUNT) AS [Total Amount]
FROM [TRANSACTION MASTER] tm
INNER JOIN [BRANCH MASTER] bm ON tm.BRID = bm.BRID
WHERE CAST(tm.[DATE OF TRANSACTION] AS DATE) = CAST(GETDATE() AS DATE)
GROUP BY bm.BRID, bm.[BRANCH NAME], tm.TXN_TYPE
ORDER BY bm.BRID, tm.TXN_TYPE;
GO

-- Query 8: Account holders who have not made any Cash deposit transaction during last 15 days
SELECT DISTINCT 
    am.ACID,
    am.NAME AS [Account Holder Name]
FROM [ACCOUNT MASTER] am
WHERE am.ACID NOT IN (
    SELECT DISTINCT tm.ACID
    FROM [TRANSACTION MASTER] tm
    WHERE tm.TXN_TYPE = 'CD'
    AND tm.[DATE OF TRANSACTION] >= DATEADD(DAY, -15, GETDATE())
);
GO

PRINT 'Basic Reports Queries (1-8) completed successfully!';