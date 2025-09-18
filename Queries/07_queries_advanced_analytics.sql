USE [INDIAN BANK];
GO

-- =====================================================
-- QUERY REQUIREMENTS - ADVANCED ANALYTICS (Queries 9-16)
-- =====================================================

-- Query 9: List the product having the maximum number of accounts
WITH ProductAccountCount AS (
    SELECT 
        pm.PID,
        pm.[PRODUCT NAME],
        COUNT(am.ACID) AS AccountCount
    FROM [PRODUCT MASTER] pm
    LEFT JOIN [ACCOUNT MASTER] am ON pm.PID = am.PID
    GROUP BY pm.PID, pm.[PRODUCT NAME]
)
SELECT 
    PID,
    [PRODUCT NAME],
    AccountCount AS [Number of Accounts]
FROM ProductAccountCount
WHERE AccountCount = (SELECT MAX(AccountCount) FROM ProductAccountCount);
GO

-- Query 10: List product having maximum monthly average number of transactions (last 6 months)
WITH MonthlyTransactionCount AS (
    SELECT 
        am.PID,
        YEAR(tm.[DATE OF TRANSACTION]) as TxnYear,
        MONTH(tm.[DATE OF TRANSACTION]) as TxnMonth,
        COUNT(tm.[TRANSACTION NUMBER]) as MonthlyCount
    FROM [TRANSACTION MASTER] tm
    INNER JOIN [ACCOUNT MASTER] am ON tm.ACID = am.ACID
    WHERE tm.[DATE OF TRANSACTION] >= DATEADD(MONTH, -6, GETDATE())
    GROUP BY am.PID, YEAR(tm.[DATE OF TRANSACTION]), MONTH(tm.[DATE OF TRANSACTION])
),
ProductAvgTransactions AS (
    SELECT 
        pm.PID,
        pm.[PRODUCT NAME],
        AVG(CAST(mtc.MonthlyCount AS FLOAT)) as AvgMonthlyTransactions
    FROM [PRODUCT MASTER] pm
    LEFT JOIN MonthlyTransactionCount mtc ON pm.PID = mtc.PID
    GROUP BY pm.PID, pm.[PRODUCT NAME]
)
SELECT 
    PID,
    [PRODUCT NAME],
    AvgMonthlyTransactions
FROM ProductAvgTransactions
WHERE AvgMonthlyTransactions = (SELECT MAX(AvgMonthlyTransactions) FROM ProductAvgTransactions);
GO

-- Query 11: List product showing increasing trend in average number of transactions per month
WITH MonthlyProductStats AS (
    SELECT 
        am.PID,
        YEAR(tm.[DATE OF TRANSACTION]) * 100 + MONTH(tm.[DATE OF TRANSACTION]) as YearMonth,
        COUNT(tm.[TRANSACTION NUMBER]) as TransactionCount,
        ROW_NUMBER() OVER (PARTITION BY am.PID ORDER BY YEAR(tm.[DATE OF TRANSACTION]), MONTH(tm.[DATE OF TRANSACTION])) as MonthRank
    FROM [TRANSACTION MASTER] tm
    INNER JOIN [ACCOUNT MASTER] am ON tm.ACID = am.ACID
    WHERE tm.[DATE OF TRANSACTION] >= DATEADD(MONTH, -6, GETDATE())
    GROUP BY am.PID, YEAR(tm.[DATE OF TRANSACTION]), MONTH(tm.[DATE OF TRANSACTION])
),
TrendAnalysis AS (
    SELECT 
        PID,
        COUNT(CASE WHEN TransactionCount > LAG(TransactionCount) OVER (PARTITION BY PID ORDER BY YearMonth) THEN 1 END) as IncreasingMonths,
        COUNT(*) - 1 as TotalComparisons
    FROM MonthlyProductStats
    GROUP BY PID
)
SELECT 
    pm.PID,
    pm.[PRODUCT NAME]
FROM [PRODUCT MASTER] pm
INNER JOIN TrendAnalysis ta ON pm.PID = ta.PID
WHERE ta.TotalComparisons > 0 
AND ta.IncreasingMonths >= ta.TotalComparisons * 0.6; -- At least 60% increasing trend
GO

-- Query 12: List account holders and number of transactions for a given day
-- Replace @GIVEN_DATE with actual date
DECLARE @GIVEN_DATE DATE = CAST(GETDATE() AS DATE); -- Example: today's date

SELECT 
    am.NAME AS [Account Holder Name],
    COUNT(tm.[TRANSACTION NUMBER]) AS [Number of Transactions]
FROM [ACCOUNT MASTER] am
INNER JOIN [TRANSACTION MASTER] tm ON am.ACID = tm.ACID
WHERE CAST(tm.[DATE OF TRANSACTION] AS DATE) = @GIVEN_DATE
GROUP BY am.ACID, am.NAME
ORDER BY [Number of Transactions] DESC;
GO

-- Query 13: Account holders with more than one cash withdrawal on same day (last 20 days)
SELECT 
    am.NAME AS [Account Holder Name],
    am.ACID AS [Account Number],
    CAST(tm.[DATE OF TRANSACTION] AS DATE) as [Transaction Date],
    SUM(tm.TXN_AMOUNT) AS [Total Withdrawal Amount]
FROM [ACCOUNT MASTER] am
INNER JOIN [TRANSACTION MASTER] tm ON am.ACID = tm.ACID
WHERE tm.TXN_TYPE = 'CW'
AND tm.[DATE OF TRANSACTION] >= DATEADD(DAY, -20, GETDATE())
GROUP BY am.ACID, am.NAME, CAST(tm.[DATE OF TRANSACTION] AS DATE)
HAVING COUNT(tm.[TRANSACTION NUMBER]) > 1
ORDER BY am.NAME, [Transaction Date];
GO

-- Query 14: Customers with at least one transaction in each transaction type (last 10 days)
WITH CustomerTransactionTypes AS (
    SELECT 
        am.ACID,
        am.NAME,
        COUNT(DISTINCT tm.TXN_TYPE) as UniqueTransactionTypes,
        SUM(tm.TXN_AMOUNT) as TotalAmount
    FROM [ACCOUNT MASTER] am
    INNER JOIN [TRANSACTION MASTER] tm ON am.ACID = tm.ACID
    WHERE tm.[DATE OF TRANSACTION] >= DATEADD(DAY, -10, GETDATE())
    GROUP BY am.ACID, am.NAME
)
SELECT 
    NAME AS [Account Holder Name],
    ACID AS [Account Number],
    TotalAmount AS [Total Transaction Amount]
FROM CustomerTransactionTypes
WHERE UniqueTransactionTypes = 3; -- All three transaction types: CW, CD, CQD
GO

-- Query 15: Number of transactions authorized by Manager today
SELECT 
    COUNT(tm.[TRANSACTION NUMBER]) AS [Transactions Authorized by Manager Today]
FROM [TRANSACTION MASTER] tm
INNER JOIN [USER MASTER] um ON tm.USERID = um.USERID
WHERE um.DESIGNATION = 'M'
AND CAST(tm.[DATE OF TRANSACTION] AS DATE) = CAST(GETDATE() AS DATE);
GO

-- Query 16: Region-wise, branch-wise transaction breakup (last 3 days) where region total > 100
WITH RegionTransactionCount AS (
    SELECT 
        rm.RID,
        rm.[REGION NAME],
        bm.BRID,
        bm.[BRANCH NAME],
        COUNT(tm.[TRANSACTION NUMBER]) as BranchTransactions
    FROM [TRANSACTION MASTER] tm
    INNER JOIN [BRANCH MASTER] bm ON tm.BRID = bm.BRID
    INNER JOIN [REGION MASTER] rm ON bm.RID = rm.RID
    WHERE tm.[DATE OF TRANSACTION] >= DATEADD(DAY, -3, GETDATE())
    GROUP BY rm.RID, rm.[REGION NAME], bm.BRID, bm.[BRANCH NAME]
),
RegionTotals AS (
    SELECT 
        RID,
        SUM(BranchTransactions) as RegionTotal
    FROM RegionTransactionCount
    GROUP BY RID
)
SELECT 
    rtc.RID,
    rtc.[REGION NAME],
    rtc.BRID,
    rtc.[BRANCH NAME],
    rtc.BranchTransactions AS [Number of Transactions]
FROM RegionTransactionCount rtc
INNER JOIN RegionTotals rt ON rtc.RID = rt.RID
WHERE rt.RegionTotal > 100
ORDER BY rtc.RID, rtc.BRID;
GO

PRINT 'Advanced Analytics Queries (9-16) completed successfully!';
