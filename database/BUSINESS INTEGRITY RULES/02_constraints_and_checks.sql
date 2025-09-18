USE [INDIAN BANK];
GO

-- =====================================================
-- BUSINESS INTEGRITY RULES - CONSTRAINTS & CHECKS
-- =====================================================

-- Rule 1: Account ID, Branch ID, Product ID and Region ID fields should be UNIQUE
-- (Already implemented as PRIMARY KEYS)

-- Rule 10: Transaction Amount should not be negative
ALTER TABLE [TRANSACTION MASTER]
ADD CONSTRAINT CHK_TXN_AMOUNT_POSITIVE CHECK (TXN_AMOUNT > 0);
GO

-- Rule 11: Transaction Type should only be 'CW' or 'CD' or 'CQD'
-- (Already implemented in table creation)

-- Rule 13: Uncleared balance should not be less than Cleared balance
ALTER TABLE [ACCOUNT MASTER]
ADD CONSTRAINT CHK_UNCLEAR_BALANCE CHECK ([UNCLEAR BALANCE] >= [CLEAR BALANCE] OR [UNCLEAR BALANCE] IS NULL OR [CLEAR BALANCE] IS NULL);
GO

-- Rule 8: Cheque Number and Cheque Date columns should not be 'NULL', if Transaction type is 'Cheque Deposit'
ALTER TABLE [TRANSACTION MASTER]
ADD CONSTRAINT CHK_CHEQUE_DETAILS CHECK (
    (TXN_TYPE = 'CQD' AND CHQ_NO IS NOT NULL AND CHQ_DATE IS NOT NULL) OR
    (TXN_TYPE IN ('CW', 'CD'))
);
GO

-- Rule 3: A Cheque which is more than six months old should not be accepted
ALTER TABLE [TRANSACTION MASTER]
ADD CONSTRAINT CHK_CHEQUE_DATE CHECK (
    (TXN_TYPE = 'CQD' AND CHQ_DATE >= DATEADD(MONTH, -6, GETDATE())) OR
    (TXN_TYPE IN ('CW', 'CD'))
);
GO

-- Create High Value Transaction table for Rule 17
CREATE TABLE [HIGH VALUE TRANSACTION] (
    HVT_ID              INTEGER         IDENTITY(1,1) PRIMARY KEY,
    TRANSACTION_NUMBER  INTEGER         NOT NULL FOREIGN KEY REFERENCES [TRANSACTION MASTER]([TRANSACTION NUMBER]),
    ACID                INTEGER         NOT NULL,
    TXN_AMOUNT          MONEY           NOT NULL,
    DATE_INSERTED       DATETIME        DEFAULT GETDATE()
);
GO

PRINT 'Constraints and Checks created successfully!';
