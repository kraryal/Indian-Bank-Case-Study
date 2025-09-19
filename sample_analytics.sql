USE [INDIAN BANK];
GO

-- =====================================================
-- 🎯 SAMPLE ANALYTICS FOR HIRING MANAGERS
-- Demonstrates real-world data science applications
-- =====================================================

PRINT '🏦 INDIAN BANK - DATA ANALYTICS SHOWCASE';
PRINT '========================================';
PRINT '';

-- 📊 1. CUSTOMER SEGMENTATION ANALYSIS
PRINT '1️⃣  CUSTOMER SEGMENTATION BY VALUE';
PRINT '----------------------------------';
WITH CustomerSegments AS (
    SELECT 
        am.ACID,
        am.NAME AS customer_name,
        am.[CLEAR BALANCE] AS current_balance,
        COUNT(tm.[TRANSACTION NUMBER]) as total_transactions,
        SUM(tm.TXN_AMOUNT) as total_volume,
        AVG(tm.TXN_AMOUNT) as avg_transaction,
        CASE 
            WHEN am.[CLEAR BALANCE] >= 100000 THEN 'HIGH VALUE'
            WHEN am.[CLEAR BALANCE] >= 50000 THEN 'MEDIUM VALUE'
            ELSE 'REGULAR'
        END as customer_segment
    FROM [ACCOUNT MASTER] am
    LEFT JOIN [TRANSACTION MASTER] tm ON am.ACID = tm.ACID
    WHERE am.STATUS = 'O'
    GROUP BY am.ACID, am.NAME, am.[CLEAR BALANCE]
)
SELECT 
    customer_segment AS [Segment],
    COUNT(*) AS [Customer Count],
    AVG(current_balance) AS [Avg Balance],
    AVG(total_transactions) AS [Avg Transactions],
    SUM(total_volume) AS [Total Volume]
FROM CustomerSegments
GROUP BY customer_segment
ORDER BY [Avg Balance] DESC;

PRINT '';

-- 🎯 2. BRANCH PERFORMANCE DASHBOARD  
PRINT '2️⃣  BRANCH PERFORMANCE ANALYSIS';
PRINT '--------------------------------';
SELECT 
    bm.[BRANCH NAME] AS [Branch],
    rm.[REGION NAME] AS [Region],
    COUNT(DISTINCT am.ACID) AS [Total Accounts],
    COUNT(tm.[TRANSACTION NUMBER]) AS [Transactions],
    FORMAT(SUM(tm.TXN_AMOUNT), 'C') AS [Total Volume],
    FORMAT(AVG(am.[CLEAR BALANCE]), 'C') AS [Avg Balance],
    FORMAT(AVG(tm.TXN_AMOUNT), 'C') AS [Avg Transaction]
FROM [BRANCH MASTER] bm
JOIN [REGION MASTER] rm ON bm.RID = rm.RID
LEFT JOIN [ACCOUNT MASTER] am ON bm.BRID = am.BRID
LEFT JOIN [TRANSACTION MASTER] tm ON am.ACID = tm.ACID
GROUP BY bm.BRID, bm.[BRANCH NAME], rm.[REGION NAME]
ORDER BY SUM(tm.TXN_AMOUNT) DESC;

PRINT '';

-- 🚨 3. RISK ANALYSIS - HIGH VALUE INACTIVE CUSTOMERS
PRINT '3️⃣  RISK ANALYSIS - HIGH VALUE CUSTOMERS';  
PRINT '---------------------------------------';
WITH CustomerActivity AS (
    SELECT 
        am.ACID,
        am.NAME AS customer_name,
        am.[CLEAR BALANCE],
        bm.[BRANCH NAME],
        MAX(tm.[DATE OF TRANSACTION]) as last_transaction,
        COUNT(tm.[TRANSACTION NUMBER]) as transaction_count,
        DATEDIFF(day, MAX(tm.[DATE OF TRANSACTION]), GETDATE()) as days_inactive
    FROM [ACCOUNT MASTER] am
    JOIN [BRANCH MASTER] bm ON am.BRID = bm.BRID
    LEFT JOIN [TRANSACTION MASTER] tm ON am.ACID = tm.ACID
    WHERE am.[CLEAR BALANCE] > 30000 AND am.STATUS = 'O'
    GROUP BY am.ACID, am.NAME, am.[CLEAR BALANCE], bm.[BRANCH NAME]
)
SELECT 
    customer_name AS [Customer],
    FORMAT([CLEAR BALANCE], 'C') AS [Balance],
    [BRANCH NAME] AS [Branch],
    last_transaction AS [Last Transaction],
    days_inactive AS [Days Inactive],
    CASE 
        WHEN days_inactive > 30 THEN '🔴 HIGH RISK'
        WHEN days_inactive > 15 THEN '🟡 MEDIUM RISK'
        ELSE '🟢 ACTIVE'
    END AS [Risk Level]
FROM CustomerActivity
ORDER BY days_inactive DESC;

PRINT '';

-- 💰 4. TRANSACTION PATTERN ANALYSIS
PRINT '4️⃣  TRANSACTION PATTERN INSIGHTS';
PRINT '--------------------------------';
SELECT 
    TXN_TYPE AS [Transaction Type],
    COUNT(*) AS [Count],
    FORMAT(SUM(TXN_AMOUNT), 'C') AS [Total Amount],
    FORMAT(AVG(TXN_AMOUNT), 'C') AS [Average Amount],
    FORMAT(MIN(TXN_AMOUNT), 'C') AS [Min Amount],
    FORMAT(MAX(TXN_AMOUNT), 'C') AS [Max Amount]
FROM [TRANSACTION MASTER]
GROUP BY TXN_TYPE
ORDER BY SUM(TXN_AMOUNT) DESC;

PRINT '';

-- 🏆 5. TOP PERFORMERS 
PRINT '5️⃣  TOP PERFORMING CUSTOMERS';
PRINT '-----------------------------';
SELECT TOP 5
    am.NAME AS [Customer Name],
    bm.[BRANCH NAME] AS [Branch],
    FORMAT(am.[CLEAR BALANCE], 'C') AS [Current Balance],
    COUNT(tm.[TRANSACTION NUMBER]) AS [Total Transactions],
    FORMAT(SUM(tm.TXN_AMOUNT), 'C') AS [Total Volume],
    FORMAT(AVG(tm.TXN_AMOUNT), 'C') AS [Avg Transaction]
FROM [ACCOUNT MASTER] am
JOIN [BRANCH MASTER] bm ON am.BRID = bm.BRID  
LEFT JOIN [TRANSACTION MASTER] tm ON am.ACID = tm.ACID
WHERE am.STATUS = 'O'
GROUP BY am.ACID, am.NAME, bm.[BRANCH NAME], am.[CLEAR BALANCE]
ORDER BY SUM(tm.TXN_AMOUNT) DESC;

PRINT '';
PRINT '✅ Analytics Complete - Perfect for Data Science Roles!';
PRINT '🎯 This demonstrates: Customer Segmentation, Risk Analysis, Performance Metrics';
