USE [INDIAN BANK];
GO

-- =====================================================
-- BUSINESS INTEGRITY RULES - TRIGGERS (PART 2)
-- =====================================================

-- Rule 5: When a Transaction is altered, difference between old and new amount cannot be more than 10% if effected by teller
CREATE OR ALTER TRIGGER TRG_CHECK_TRANSACTION_ALTERATION
ON [TRANSACTION MASTER]
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d ON i.[TRANSACTION NUMBER] = d.[TRANSACTION NUMBER]
        INNER JOIN [USER MASTER] um ON i.USERID = um.USERID
        WHERE um.DESIGNATION = 'T'
        AND ABS(i.TXN_AMOUNT - d.TXN_AMOUNT) / d.TXN_AMOUNT > 0.10
    )
    BEGIN
        RAISERROR('Teller cannot alter transaction by more than 10%', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Rule 9: A product should not be removed if there are accounts attached to it
CREATE OR ALTER TRIGGER TRG_PREVENT_PRODUCT_DELETE
ON [PRODUCT MASTER]
FOR DELETE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1
        FROM deleted d
        INNER JOIN [ACCOUNT MASTER] am ON d.PID = am.PID
    )
    BEGIN
        RAISERROR('Cannot delete product - accounts are attached to it', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Rule 12: An account should not be closed if related Cheques are in transit
CREATE OR ALTER TRIGGER TRG_CHECK_ACCOUNT_CLOSURE
ON [ACCOUNT MASTER]
FOR UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN deleted d ON i.ACID = d.ACID
        WHERE i.STATUS = 'C' 
        AND d.STATUS != 'C'
        AND (i.[CLEAR BALANCE] != i.[UNCLEAR BALANCE] OR 
             i.[CLEAR BALANCE] IS NULL OR 
             i.[UNCLEAR BALANCE] IS NULL)
    )
    BEGIN
        RAISERROR('Cannot close account - cheques are in transit (Clear and Unclear balances not equal)', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Rule 14: Minimum balance for Savings Bank should be Rs. 1,000
CREATE OR ALTER TRIGGER TRG_CHECK_MINIMUM_BALANCE
ON [ACCOUNT MASTER]
FOR INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1
        FROM inserted i
        INNER JOIN [PRODUCT MASTER] pm ON i.PID = pm.PID
        WHERE pm.[PRODUCT NAME] LIKE '%SAVINGS%'
        AND (i.[CLEAR BALANCE] < 1000 OR i.[CLEAR BALANCE] IS NULL)
    )
    BEGIN
        RAISERROR('Minimum balance for Savings Bank should be Rs. 1,000', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END;
END;
GO

-- Rule 15: When there is an insert/update in transaction amount, Balance should be updated implicitly
-- Rule 16: If there is no minimum balance, withdrawal should be prohibited
-- Rule 17: If transaction amount > Rs. 50,000, insert into High Value Transaction table
-- Rule 18: Total transactions per month < 5, else Rs. 50 penalty
-- Rule 19: Daily cash withdrawal limit Rs. 50,000, else 1% penalty on extra amount

CREATE OR ALTER TRIGGER TRG_COMPREHENSIVE_TRANSACTION_RULES
ON [TRANSACTION MASTER]
FOR INSERT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @ACID INT, @TXN_AMOUNT MONEY, @TXN_TYPE CHAR(3);
    DECLARE @CURRENT_CLEAR_BALANCE MONEY, @CURRENT_UNCLEAR_BALANCE MONEY;
    DECLARE @DAILY_WITHDRAWALS MONEY, @MONTHLY_COUNT INT;
    
    DECLARE transaction_cursor CURSOR FOR
    SELECT ACID, TXN_AMOUNT, TXN_TYPE FROM inserted;
    
    OPEN transaction_cursor;
    FETCH NEXT FROM transaction_cursor INTO @ACID, @TXN_AMOUNT, @TXN_TYPE;
    
    WHILE @@FETCH_STATUS = 0
    BEGIN
        -- Get current balances
        SELECT @CURRENT_CLEAR_BALANCE = [CLEAR BALANCE], @CURRENT_UNCLEAR_BALANCE = [UNCLEAR BALANCE]
        FROM [ACCOUNT MASTER] WHERE ACID = @ACID;
        
        -- Rule 17: High Value Transaction
        IF @TXN_AMOUNT > 50000
        BEGIN
            INSERT INTO [HIGH VALUE TRANSACTION] (TRANSACTION_NUMBER, ACID, TXN_AMOUNT)
            SELECT [TRANSACTION NUMBER], @ACID, @TXN_AMOUNT 
            FROM inserted WHERE ACID = @ACID AND TXN_AMOUNT = @TXN_AMOUNT;
        END;
        
        -- Rule 16: Check minimum balance for withdrawals
        IF @TXN_TYPE = 'CW'
        BEGIN
            IF (@CURRENT_CLEAR_BALANCE - @TXN_AMOUNT) < 1000
            BEGIN
                RAISERROR('Insufficient minimum balance for withdrawal', 16, 1);
                ROLLBACK TRANSACTION;
                RETURN;
            END;
        END;
        
        -- Rule 18: Monthly transaction limit
        SELECT @MONTHLY_COUNT = COUNT(*)
        FROM [TRANSACTION MASTER]
        WHERE ACID = @ACID
        AND YEAR([DATE OF TRANSACTION]) = YEAR(GETDATE())
        AND MONTH([DATE OF TRANSACTION]) = MONTH(GETDATE());
        
        IF @MONTHLY_COUNT >= 5
        BEGIN
            -- Debit penalty of Rs. 50
            UPDATE [ACCOUNT MASTER]
            SET [CLEAR BALANCE] = [CLEAR BALANCE] - 50
            WHERE ACID = @ACID;
        END;
        
        -- Rule 19: Daily withdrawal limit
        IF @TXN_TYPE = 'CW'
        BEGIN
            SELECT @DAILY_WITHDRAWALS = ISNULL(SUM(TXN_AMOUNT), 0)
            FROM [TRANSACTION MASTER]
            WHERE ACID = @ACID
            AND TXN_TYPE = 'CW'
            AND CAST([DATE OF TRANSACTION] AS DATE) = CAST(GETDATE() AS DATE);
            
            IF (@DAILY_WITHDRAWALS + @TXN_AMOUNT) > 50000
            BEGIN
                DECLARE @EXCESS_AMOUNT MONEY = (@DAILY_WITHDRAWALS + @TXN_AMOUNT) - 50000;
                DECLARE @PENALTY MONEY = @EXCESS_AMOUNT * 0.01;
                
                -- Debit penalty
                UPDATE [ACCOUNT MASTER]
                SET [CLEAR BALANCE] = [CLEAR BALANCE] - @PENALTY
                WHERE ACID = @ACID;
            END;
        END;
        
        -- Rule 15: Update balances
        IF @TXN_TYPE IN ('CD', 'CQD')
        BEGIN
            UPDATE [ACCOUNT MASTER]
            SET [CLEAR BALANCE] = ISNULL([CLEAR BALANCE], 0) + @TXN_AMOUNT,
                [UNCLEAR BALANCE] = CASE WHEN @TXN_TYPE = 'CQD' 
                                   THEN ISNULL([UNCLEAR BALANCE], 0) + @TXN_AMOUNT
                                   ELSE ISNULL([UNCLEAR BALANCE], 0) + @TXN_AMOUNT END
            WHERE ACID = @ACID;
        END
        ELSE IF @TXN_TYPE = 'CW'
        BEGIN
            UPDATE [ACCOUNT MASTER]
            SET [CLEAR BALANCE] = [CLEAR BALANCE] - @TXN_AMOUNT,
                [UNCLEAR BALANCE] = [UNCLEAR BALANCE] - @TXN_AMOUNT
            WHERE ACID = @ACID;
        END;
        
        FETCH NEXT FROM transaction_cursor INTO @ACID, @TXN_AMOUNT, @TXN_TYPE;
    END;
    
    CLOSE transaction_cursor;
    DEALLOCATE transaction_cursor;
END;
GO

PRINT 'Triggers Part 2 created successfully!';
PRINT 'All Business Integrity Rules implemented!';
