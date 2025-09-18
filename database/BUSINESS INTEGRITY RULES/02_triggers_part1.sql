USE [INDIAN BANK];
GO

-- =====================================================
-- BUSINESS INTEGRITY RULES - TRIGGERS (PART 1)
-- =====================================================

-- Rule 2: Date of Transaction (DOT) and Date of Opening (DOO) should be the current date
CREATE OR ALTER TRIGGER TRG_CHECK_CURRENT_DATES
ON [TRANSACTION MASTER]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Insert with current date for Date of Transaction
    INSERT INTO [TRANSACTION MASTER] (
        [DATE OF TRANSACTION], ACID, BRID, TXN_TYPE, CHQ_NO, CHQ_DATE, TXN_AMOUNT, USERID
    )
    SELECT 
        GETDATE(), ACID, BRID, TXN_TYPE, CHQ_NO, CHQ_DATE, TXN_AMOUNT, USERID
    FROM inserted;
END;
GO

-- Rule 2: Date of Opening should be current date
CREATE OR ALTER TRIGGER TRG_CHECK_OPENING_DATE
ON [ACCOUNT MASTER]
INSTEAD OF INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Insert with current date for Date of Opening
    INSERT INTO [ACCOUNT MASTER] (
        ACID, NAME, ADDRESS, BRID, PID, [DATE OF OPENING], [CLEAR BALANCE], [UNCLEAR BALANCE], STATUS
    )
    SELECT 
        ACID, NAME, ADDRESS, BRID, PID, GETDATE(), [CLEAR BALANCE], [UNCLEAR BALANCE], STATUS
    FROM inserted;
END;
GO

-- Rule 4: No Transactions should be allowed on Accounts marked "Inoperative/closed"
CREATE OR ALTER TRIGGER TRG_CHECK_ACCOUNT_STATUS
ON [TRANSACTION MASTER]
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1 
        FROM inserted i
        INNER JOIN [ACCOUNT MASTER] am ON i.ACID = am.ACID
        WHERE am.STATUS IN ('I', 'C')
    )
    BEGIN
        RAISERROR('Transactions not allowed on Inoperative or Closed accounts', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Rule 6: More than three Cash Withdrawal transactions in a single account on the same day should not be allowed
CREATE OR ALTER TRIGGER TRG_CHECK_DAILY_CW_LIMIT
ON [TRANSACTION MASTER]
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.TXN_TYPE = 'CW'
        AND (
            SELECT COUNT(*)
            FROM [TRANSACTION MASTER] tm
            WHERE tm.ACID = i.ACID
            AND tm.TXN_TYPE = 'CW'
            AND CAST(tm.[DATE OF TRANSACTION] AS DATE) = CAST(GETDATE() AS DATE)
        ) >= 3
    )
    BEGIN
        RAISERROR('More than 3 Cash Withdrawal transactions per day not allowed', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Rule 7: More than three Cash Deposit transactions in a single account on the same month should not be allowed
CREATE OR ALTER TRIGGER TRG_CHECK_MONTHLY_CD_LIMIT
ON [TRANSACTION MASTER]
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.TXN_TYPE = 'CD'
        AND (
            SELECT COUNT(*)
            FROM [TRANSACTION MASTER] tm
            WHERE tm.ACID = i.ACID
            AND tm.TXN_TYPE = 'CD'
            AND YEAR(tm.[DATE OF TRANSACTION]) = YEAR(GETDATE())
            AND MONTH(tm.[DATE OF TRANSACTION]) = MONTH(GETDATE())
        ) >= 3
    )
    BEGIN
        RAISERROR('More than 3 Cash Deposit transactions per month not allowed', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

PRINT 'Triggers Part 1 created successfully!';
