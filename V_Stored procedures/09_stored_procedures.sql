USE [INDIAN BANK];
GO

-- =====================================================
-- STORED PROCEDURE - TRANSACTION REPORT
-- =====================================================

CREATE OR ALTER PROCEDURE SP_TRANSACTION_REPORT
    @ACCOUNT_ID INTEGER,
    @FROM_DATE DATE,
    @TO_DATE DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Variables for account information
    DECLARE @CUSTOMER_NAME VARCHAR(40);
    DECLARE @PRODUCT_NAME VARCHAR(25);
    DECLARE @BRANCH_ID CHAR(3);
    DECLARE @CLEARED_BALANCE MONEY;
    DECLARE @MINIMUM_BALANCE MONEY = 1000; -- Default minimum balance
    
    -- Variables for counters
    DECLARE @TOTAL_TRANSACTIONS INT = 0;
    DECLARE @CASH_DEPOSITS INT = 0;
    DECLARE @CASH_WITHDRAWALS INT = 0;
    DECLARE @CHEQUE_DEPOSITS INT = 0;
    
    -- Get account details
    SELECT 
        @CUSTOMER_NAME = am.NAME,
        @PRODUCT_NAME = pm.[PRODUCT NAME],
        @BRANCH_ID = am.BRID,
        @CLEARED_BALANCE = ISNULL(am.[CLEAR BALANCE], 0)
    FROM [ACCOUNT MASTER] am
    INNER JOIN [PRODUCT MASTER] pm ON am.PID = pm.PID
    WHERE am.ACID = @ACCOUNT_ID;
    
    -- Check if account exists
    IF @CUSTOMER_NAME IS NULL
    BEGIN
        PRINT 'Account not found!';
        RETURN;
    END;
    
    -- Print Report Header
    PRINT '-------------------------------------------------------------------------------------------';
    PRINT 'INDIAN BANK';
    PRINT 'List of Transactions from ' + CONVERT(VARCHAR, @FROM_DATE, 107) + ' to ' + CONVERT(VARCHAR, @TO_DATE, 107) + ' Report';
    PRINT '-------------------------------------------------------------------------------------------';
    PRINT '';
    PRINT 'Product Name : ' + @PRODUCT_NAME;
    PRINT 'Account No : ' + CAST(@ACCOUNT_ID AS VARCHAR);
    PRINT 'Branch : ' + @BRANCH_ID;
    PRINT '';
    PRINT 'Customer Name: ' + @CUSTOMER_NAME + CHAR(9) + CHAR(9) + 'Cleared Balance :' + CAST(@CLEARED_BALANCE AS VARCHAR);
    PRINT '';
    PRINT 'SL.NO' + CHAR(9) + 'DATE' + CHAR(9) + CHAR(9) + 'TXN TYPE' + CHAR(9) + 'CHEQUE NO' + CHAR(9) + 'AMOUNT' + CHAR(9) + CHAR(9) + 'RUNNINGBALANCE';
    
    -- Create temporary table for transactions with running balance
    CREATE TABLE #TempTransactions (
        SlNo INT IDENTITY(1,1),
        TransactionDate DATETIME,
        TxnType CHAR(3),
        ChequeNo VARCHAR(20),
        Amount MONEY,
        RunningBalance MONEY
    );
    
    -- Insert transactions with running balance calculation
    DECLARE @RunningBalance MONEY;
    SET @RunningBalance = 0;
    
    -- Get initial balance (balance before the date range)
    SELECT @RunningBalance = ISNULL(SUM(
        CASE 
            WHEN TXN_TYPE IN ('CD', 'CQD') THEN TXN_AMOUNT 
            WHEN TXN_TYPE = 'CW' THEN -TXN_AMOUNT 
            ELSE 0 
        END), 0)
    FROM [TRANSACTION MASTER]
    WHERE ACID = @ACCOUNT_ID 
    AND [DATE OF TRANSACTION] < @FROM_DATE;
    
    -- Insert transactions with running balance
    DECLARE transaction_cursor CURSOR FOR
    SELECT [DATE OF TRANSACTION], TXN_TYPE, CHQ_NO, TXN_AMOUNT
    FROM [TRANSACTION MASTER]
    WHERE ACID = @ACCOUNT_ID
    AND [DATE OF TRANSACTION] BETWEEN @FROM_DATE AND @TO_DATE
    ORDER BY [DATE OF TRANSACTION];
    
    DECLARE @TxnDate DATETIME, @TxnType CHAR(3), @ChequeNo INT, @Amount MONEY;
    
    OPEN transaction_cursor;
    FETCH NEXT FROM transaction_cursor INTO @TxnDate, @TxnType, @ChequeNo, @Amount;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Calculate running balance
        IF @TxnType IN ('CD', 'CQD')
            SET @RunningBalance = @RunningBalance + @Amount;
        ELSE IF @TxnType = 'CW'
            SET @RunningBalance = @RunningBalance - @Amount;
        
        -- Insert into temp table
        INSERT INTO #TempTransactions (TransactionDate, TxnType, ChequeNo, Amount, RunningBalance)
        VALUES (@TxnDate, @TxnType, 
                CASE WHEN @ChequeNo IS NULL THEN '-' ELSE CAST(@ChequeNo AS VARCHAR) END, 
                @Amount, @RunningBalance);
        
        -- Count transactions by type
        SET @TOTAL_TRANSACTIONS = @TOTAL_TRANSACTIONS + 1;
        IF @TxnType = 'CD' SET @CASH_DEPOSITS = @CASH_DEPOSITS + 1;
        IF @TxnType = 'CW' SET @CASH_WITHDRAWALS = @CASH_WITHDRAWALS + 1;
        IF @TxnType = 'CQD' SET @CHEQUE_DEPOSITS = @CHEQUE_DEPOSITS + 1;
        
        FETCH NEXT FROM transaction_cursor INTO @TxnDate, @TxnType, @ChequeNo, @Amount;
    END;
    
    CLOSE transaction_cursor;
    DEALLOCATE transaction_cursor;
    
    -- Display transactions
    DECLARE @SlNo INT, @DisplayDate VARCHAR(20), @DisplayType CHAR(3), @DisplayCheque VARCHAR(20);
    DECLARE @DisplayAmount VARCHAR(20), @DisplayRunning VARCHAR(20);
    
    DECLARE display_cursor CURSOR FOR
    SELECT SlNo, TransactionDate, TxnType, ChequeNo, Amount, RunningBalance
    FROM #TempTransactions;
    
    OPEN display_cursor;
    FETCH NEXT FROM display_cursor INTO @SlNo, @TxnDate, @TxnType, @DisplayCheque, @Amount, @RunningBalance;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @DisplayDate = CASE WHEN @TxnDate IS NULL THEN '-' ELSE CONVERT(VARCHAR, @TxnDate, 101) END;
        SET @DisplayAmount = CAST(@Amount AS VARCHAR);
        SET @DisplayRunning = CAST(@RunningBalance AS VARCHAR);
        
        PRINT CAST(@SlNo AS VARCHAR) + CHAR(9) + 
              @DisplayDate + CHAR(9) + 
              @TxnType + CHAR(9) + CHAR(9) + 
              @DisplayCheque + CHAR(9) + CHAR(9) + 
              @DisplayAmount + CHAR(9) + CHAR(9) + 
              @DisplayRunning;
        
        FETCH NEXT FROM display_cursor INTO @SlNo, @TxnDate, @TxnType, @DisplayCheque, @Amount, @RunningBalance;
    END;
    
    CLOSE display_cursor;
    DEALLOCATE display_cursor;
    
    -- Print summary
    PRINT '';
    PRINT 'Total Number of Transactions :' + CAST(@TOTAL_TRANSACTIONS AS VARCHAR);
    PRINT 'Cash Deposits :' + CAST(@CASH_DEPOSITS AS VARCHAR);
    PRINT 'Cash Withdrawals :' + CAST(@CASH_WITHDRAWALS AS VARCHAR);
    PRINT 'Cheque Deposits :' + CAST(@CHEQUE_DEPOSITS AS VARCHAR);
    PRINT '';
    
    -- Find dates when balance dropped below minimum
    PRINT 'Dates when the Balance dropped below the Minimum Balance for the Product:';
    
    -- Create temp table for balance tracking
    CREATE TABLE #BalanceHistory (
        TransactionDate DATE,
        RunningBalance MONEY
    );
    
    -- Reset running balance for minimum balance check
    SET @RunningBalance = 0;
    
    -- Get all transactions for balance history
    DECLARE balance_cursor CURSOR FOR
    SELECT CAST([DATE OF TRANSACTION] AS DATE), TXN_TYPE, TXN_AMOUNT
    FROM [TRANSACTION MASTER]
    WHERE ACID = @ACCOUNT_ID
    ORDER BY [DATE OF TRANSACTION];
    
    DECLARE @BalanceDate DATE, @BalanceTxnType CHAR(3), @BalanceAmount MONEY;
    
    OPEN balance_cursor;
    FETCH NEXT FROM balance_cursor INTO @BalanceDate, @BalanceTxnType, @BalanceAmount;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Calculate running balance
        IF @BalanceTxnType IN ('CD', 'CQD')
            SET @RunningBalance = @RunningBalance + @BalanceAmount;
        ELSE IF @BalanceTxnType = 'CW'
            SET @RunningBalance = @RunningBalance - @BalanceAmount;
        
        -- Insert into balance history
        INSERT INTO #BalanceHistory (TransactionDate, RunningBalance)
        VALUES (@BalanceDate, @RunningBalance);
        
        FETCH NEXT FROM balance_cursor INTO @BalanceDate, @BalanceTxnType, @BalanceAmount;
    END;
    
    CLOSE balance_cursor;
    DEALLOCATE balance_cursor;
    
    -- Display dates when balance was below minimum
    DECLARE min_balance_cursor CURSOR FOR
    SELECT DISTINCT TransactionDate
    FROM #BalanceHistory
    WHERE RunningBalance < @MINIMUM_BALANCE
    ORDER BY TransactionDate;
    
    DECLARE @MinBalanceDate DATE;
    
    OPEN min_balance_cursor;
    FETCH NEXT FROM min_balance_cursor INTO @MinBalanceDate;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        PRINT CONVERT(VARCHAR, @MinBalanceDate, 107);
        FETCH NEXT FROM min_balance_cursor INTO @MinBalanceDate;
    END;
    
    CLOSE min_balance_cursor;
    DEALLOCATE min_balance_cursor;
    
    -- Print closing balance
    PRINT '';
    PRINT 'Closing Balance : ' + CAST(@CLEARED_BALANCE AS VARCHAR);
    PRINT '----------------------------------------------------------------------------------------------------------';
    PRINT '*** End of Document ***';
    
    -- Clean up
    DROP TABLE #TempTransactions;
    DROP TABLE #BalanceHistory;
END;
GO

-- =====================================================
-- ADDITIONAL STORED PROCEDURES
-- =====================================================

-- Stored Procedure to get Branch-wise Transaction Summary
CREATE OR ALTER PROCEDURE SP_BRANCH_TRANSACTION_SUMMARY
    @BRANCH_ID CHAR(3) = NULL,
    @FROM_DATE DATE,
    @TO_DATE DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        bm.BRID AS [Branch ID],
        bm.[BRANCH NAME],
        tm.TXN_TYPE AS [Transaction Type],
        COUNT(tm.[TRANSACTION NUMBER]) AS [Transaction Count],
        SUM(tm.TXN_AMOUNT) AS [Total Amount]
    FROM [TRANSACTION MASTER] tm
    INNER JOIN [BRANCH MASTER] bm ON tm.BRID = bm.BRID
    WHERE tm.[DATE OF TRANSACTION] BETWEEN @FROM_DATE AND @TO_DATE
    AND (@BRANCH_ID IS NULL OR tm.BRID = @BRANCH_ID)
    GROUP BY bm.BRID, bm.[BRANCH NAME], tm.TXN_TYPE
    ORDER BY bm.BRID, tm.TXN_TYPE;
END;
GO

-- Stored Procedure to get Account Statement
CREATE OR ALTER PROCEDURE SP_ACCOUNT_STATEMENT
    @ACCOUNT_ID INTEGER,
    @FROM_DATE DATE,
    @TO_DATE DATE
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        tm.[DATE OF TRANSACTION] AS [Date],
        tm.TXN_TYPE AS [Type],
        tm.CHQ_NO AS [Cheque No],
        tm.TXN_AMOUNT AS [Amount],
        bm.[BRANCH NAME] AS [Branch],
        um.[USER NAME] AS [Processed By]
    FROM [TRANSACTION MASTER] tm
    INNER JOIN [BRANCH MASTER] bm ON tm.BRID = bm.BRID
    INNER JOIN [USER MASTER] um ON tm.USERID = um.USERID
    WHERE tm.ACID = @ACCOUNT_ID
    AND tm.[DATE OF TRANSACTION] BETWEEN @FROM_DATE AND @TO_DATE
    ORDER BY tm.[DATE OF TRANSACTION];
END;
GO

PRINT 'Stored Procedures created successfully!';

-- Example usage:
-- EXEC SP_TRANSACTION_REPORT @ACCOUNT_ID = 101, @FROM_DATE = '2020-11-01', @TO_DATE = '2020-11-30';
-- EXEC SP_BRANCH_TRANSACTION_SUMMARY @BRANCH_ID = 'BR1', @FROM_DATE = '2020-11-01', @TO_DATE = '2020-11-30';
-- EXEC SP_ACCOUNT_STATEMENT @ACCOUNT_ID = 101, @FROM_DATE = '2020-11-01', @TO_DATE = '2020-11-30';