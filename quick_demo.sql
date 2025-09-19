USE [INDIAN BANK];
GO

-- =====================================================
-- 🎯 QUICK DEMO FOR HIRING MANAGERS (30-second showcase)
-- =====================================================

PRINT '🏦 INDIAN BANK DATABASE - QUICK DEMO';
PRINT '====================================';
PRINT '';

-- Show database scale
SELECT 'Database Overview' AS [Section];
SELECT 'Total Accounts' AS [Metric], COUNT(*) AS [Value] FROM [ACCOUNT MASTER]
UNION ALL SELECT 'Total Transactions', COUNT(*) FROM [TRANSACTION MASTER]
UNION ALL SELECT 'Active Branches', COUNT(*) FROM [BRANCH MASTER]
UNION ALL SELECT 'Products Offered', COUNT(*) FROM [PRODUCT MASTER];

PRINT '';

-- Top 3 customers by value
SELECT 'Top 3 Customers by Transaction Volume' AS [Section];
SELECT TOP 3
    am.NAME AS [Customer], 
    FORMAT(SUM(tm.TXN_AMOUNT), 'C0') AS [Total Volume],
    COUNT(*) AS [Transactions]
FROM [ACCOUNT MASTER] am
JOIN [TRANSACTION MASTER] tm ON am.ACID = tm.ACID
GROUP BY am.NAME
ORDER BY SUM(tm.TXN_AMOUNT) DESC;

-- Business rule in action
SELECT 'Business Rules Demo - High Value Transactions (>$50K)' AS [Section];
SELECT 
    am.NAME AS [Customer],
    FORMAT(tm.TXN_AMOUNT, 'C0') AS [Amount],
    tm.TXN_TYPE AS [Type],
    'Auto-flagged for compliance' AS [Status]
FROM [TRANSACTION MASTER] tm
JOIN [ACCOUNT MASTER] am ON tm.ACID = am.ACID
WHERE tm.TXN_AMOUNT > 50000;

PRINT '✅ Demo Complete - Perfect for Data Science roles in Banking!';
