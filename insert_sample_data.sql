USE [INDIAN BANK];
GO

-- =====================================================
-- SAMPLE DATA FOR HIRING MANAGER DEMONSTRATION
-- (Fixed for trigger and constraint compatibility)
-- =====================================================

-- Insert Regions
INSERT INTO [REGION MASTER] (RID, [REGION NAME]) VALUES
(1, 'NORTH'),
(2, 'SOUTH'),
(3, 'EAST'),
(4, 'WEST');

-- Insert Products
INSERT INTO [PRODUCT MASTER] (PID, [PRODUCT NAME]) VALUES
('SB', 'SAVINGS BANK'),
('CA', 'CURRENT ACCOUNT'),
('FD', 'FIXED DEPOSIT'),
('RD', 'RECURRING DEPOSIT');

-- Insert Branches
INSERT INTO [BRANCH MASTER] (BRID, [BRANCH NAME], [BRANCH ADDRESS], RID) VALUES
('BR1', 'MUMBAI MAIN BRANCH', 'Fort, Mumbai - 400001', 4),
('BR2', 'DELHI CENTRAL BRANCH', 'CP, New Delhi - 110001', 1),
('BR3', 'CHENNAI BRANCH', 'T.Nagar, Chennai - 600017', 2),
('BR4', 'KOLKATA BRANCH', 'Park Street, Kolkata - 700016', 3),
('BR5', 'PUNE BRANCH', 'FC Road, Pune - 411005', 4);

-- Insert Users
INSERT INTO [USER MASTER] (USERID, [USER NAME], DESIGNATION) VALUES
(101, 'Rajesh Kumar', 'M'),
(102, 'Priya Sharma', 'T'),
(103, 'Amit Singh', 'T'),
(104, 'Sunita Verma', 'C'),
(105, 'Vikram Patel', 'O'),
(106, 'Meera Joshi', 'T'),
(107, 'Arjun Reddy', 'M');

-- Temporarily disable triggers for data insertion
ALTER TABLE [TRANSACTION MASTER] DISABLE TRIGGER ALL;
GO

-- Insert Accounts (Diverse customer profiles for analytics)
INSERT INTO [ACCOUNT MASTER] (ACID, NAME, ADDRESS, BRID, PID, [DATE OF OPENING], [CLEAR BALANCE], [UNCLEAR BALANCE], STATUS) VALUES
-- High-value customers
(1001, 'Praveen Kumar', 'Bandra West, Mumbai', 'BR1', 'SB', GETDATE(), 150000, 150000, 'O'),
(1002, 'Anita Gupta', 'Vasant Kunj, Delhi', 'BR2', 'CA', GETDATE(), 250000, 250000, 'O'),
(1003, 'Suresh Reddy', 'Anna Nagar, Chennai', 'BR3', 'SB', GETDATE(), 75000, 75000, 'O'),

-- Medium-value customers  
(1004, 'Rohit Sharma', 'Koramangala, Bangalore', 'BR3', 'SB', GETDATE(), 45000, 45000, 'O'),
(1005, 'Kavita Jain', 'Salt Lake, Kolkata', 'BR4', 'SB', GETDATE(), 32000, 32000, 'O'),
(1006, 'Deepak Mehta', 'Shivaji Nagar, Pune', 'BR5', 'CA', GETDATE(), 85000, 85000, 'O'),

-- Regular customers
(1007, 'Pooja Singh', 'Powai, Mumbai', 'BR1', 'SB', GETDATE(), 15000, 15000, 'O'),
(1008, 'Ravi Patel', 'Rajouri Garden, Delhi', 'BR2', 'SB', GETDATE(), 22000, 22000, 'O'),
(1009, 'Lakshmi Iyer', 'Mylapore, Chennai', 'BR3', 'SB', GETDATE(), 18000, 18000, 'O'),

-- Inactive/Risk customers
(1010, 'Mohit Agarwal', 'Park Street, Kolkata', 'BR4', 'SB', DATEADD(MONTH, -6, GETDATE()), 5000, 5000, 'I'),
(1011, 'Neha Kapoor', 'Viman Nagar, Pune', 'BR5', 'SB', GETDATE(), 8000, 8000, 'O');

-- Insert Transactions with valid dates (all current dates, recent cheque dates)
INSERT INTO [TRANSACTION MASTER] ([DATE OF TRANSACTION], ACID, BRID, TXN_TYPE, CHQ_NO, CHQ_DATE, TXN_AMOUNT, USERID) VALUES
-- Recent transactions with current dates
(GETDATE(), 1001, 'BR1', 'CD', NULL, NULL, 50000, 102),
(DATEADD(DAY, -1, GETDATE()), 1001, 'BR1', 'CW', NULL, NULL, 15000, 102),
(DATEADD(DAY, -2, GETDATE()), 1001, 'BR1', 'CQD', 12345, DATEADD(DAY, -3, GETDATE()), 25000, 103),
(DATEADD(DAY, -5, GETDATE()), 1001, 'BR1', 'CW', NULL, NULL, 8000, 102),

-- Anita Gupta (Business account - high volume)
(DATEADD(DAY, -1, GETDATE()), 1002, 'BR2', 'CD', NULL, NULL, 100000, 106),
(DATEADD(DAY, -3, GETDATE()), 1002, 'BR2', 'CW', NULL, NULL, 45000, 106),
(DATEADD(DAY, -5, GETDATE()), 1002, 'BR2', 'CQD', 67890, DATEADD(DAY, -6, GETDATE()), 75000, 106),
(DATEADD(DAY, -7, GETDATE()), 1002, 'BR2', 'CW', NULL, NULL, 30000, 106),

-- Regular transaction patterns
(DATEADD(DAY, -2, GETDATE()), 1004, 'BR3', 'CD', NULL, NULL, 15000, 103),
(DATEADD(DAY, -4, GETDATE()), 1004, 'BR3', 'CW', NULL, NULL, 5000, 103),
(DATEADD(DAY, -3, GETDATE()), 1005, 'BR4', 'CD', NULL, NULL, 8000, 104),
(DATEADD(DAY, -6, GETDATE()), 1006, 'BR5', 'CQD', 11111, DATEADD(DAY, -7, GETDATE()), 20000, 106),

-- Small account transactions
(DATEADD(DAY, -1, GETDATE()), 1007, 'BR1', 'CD', NULL, NULL, 3000, 102),
(DATEADD(DAY, -3, GETDATE()), 1008, 'BR2', 'CW', NULL, NULL, 2000, 106),
(DATEADD(DAY, -2, GETDATE()), 1009, 'BR3', 'CD', NULL, NULL, 5000, 103),

-- Add some older transactions for trend analysis
(DATEADD(DAY, -15, GETDATE()), 1001, 'BR1', 'CD', NULL, NULL, 40000, 102),
(DATEADD(DAY, -20, GETDATE()), 1001, 'BR1', 'CW', NULL, NULL, 12000, 102),
(DATEADD(DAY, -10, GETDATE()), 1002, 'BR2', 'CD', NULL, NULL, 80000, 106),
(DATEADD(DAY, -25, GETDATE()), 1003, 'BR3', 'CQD', 98765, DATEADD(DAY, -26, GETDATE()), 30000, 103);

-- Re-enable triggers
ALTER TABLE [TRANSACTION MASTER] ENABLE TRIGGER ALL;
GO

PRINT '? Sample data inserted successfully!';
PRINT '?? Ready for analytics demonstration!';
PRINT '';
PRINT 'Data Summary:';
SELECT 'Accounts' as [Table], COUNT(*) as [Records] FROM [ACCOUNT MASTER]
UNION ALL
SELECT 'Transactions', COUNT(*) FROM [TRANSACTION MASTER]
UNION ALL  
SELECT 'Branches', COUNT(*) FROM [BRANCH MASTER]
UNION ALL
SELECT 'Products', COUNT(*) FROM [PRODUCT MASTER];

select * from [ACCOUNT MASTER]