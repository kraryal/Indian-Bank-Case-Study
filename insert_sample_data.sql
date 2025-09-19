USE [INDIAN BANK];
GO

-- =====================================================
-- SAMPLE DATA FOR HIRING MANAGER DEMONSTRATION
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

-- Insert Accounts (Diverse customer profiles for analytics)
INSERT INTO [ACCOUNT MASTER] (ACID, NAME, ADDRESS, BRID, PID, [DATE OF OPENING], [CLEAR BALANCE], [UNCLEAR BALANCE], STATUS) VALUES
-- High-value customers
(1001, 'Praveen Kumar', 'Bandra West, Mumbai', 'BR1', 'SB', '2023-01-15', 150000, 150000, 'O'),
(1002, 'Anita Gupta', 'Vasant Kunj, Delhi', 'BR2', 'CA', '2023-02-10', 250000, 250000, 'O'),
(1003, 'Suresh Reddy', 'Anna Nagar, Chennai', 'BR3', 'SB', '2023-01-20', 75000, 75000, 'O'),

-- Medium-value customers  
(1004, 'Rohit Sharma', 'Koramangala, Bangalore', 'BR3', 'SB', '2023-03-05', 45000, 45000, 'O'),
(1005, 'Kavita Jain', 'Salt Lake, Kolkata', 'BR4', 'SB', '2023-02-28', 32000, 32000, 'O'),
(1006, 'Deepak Mehta', 'Shivaji Nagar, Pune', 'BR5', 'CA', '2023-01-30', 85000, 85000, 'O'),

-- Regular customers
(1007, 'Pooja Singh', 'Powai, Mumbai', 'BR1', 'SB', '2023-04-12', 15000, 15000, 'O'),
(1008, 'Ravi Patel', 'Rajouri Garden, Delhi', 'BR2', 'SB', '2023-03-18', 22000, 22000, 'O'),
(1009, 'Lakshmi Iyer', 'Mylapore, Chennai', 'BR3', 'SB', '2023-02-14', 18000, 18000, 'O'),

-- Inactive/Risk customers
(1010, 'Mohit Agarwal', 'Park Street, Kolkata', 'BR4', 'SB', '2022-08-15', 5000, 5000, 'I'),
(1011, 'Neha Kapoor', 'Viman Nagar, Pune', 'BR5', 'SB', '2023-01-05', 8000, 8000, 'O');

-- Insert Transactions (Realistic patterns for analytics)
-- High-volume customer transactions
INSERT INTO [TRANSACTION MASTER] ([DATE OF TRANSACTION], ACID, BRID, TXN_TYPE, CHQ_NO, CHQ_DATE, TXN_AMOUNT, USERID) VALUES
-- Praveen Kumar (High-value, frequent user)
('2024-01-05', 1001, 'BR1', 'CD', NULL, NULL, 50000, 102),
('2024-01-12', 1001, 'BR1', 'CW', NULL, NULL, 15000, 102),
('2024-01-20', 1001, 'BR1', 'CQD', 12345, '2024-01-19', 25000, 103),
('2024-01-28', 1001, 'BR1', 'CW', NULL, NULL, 8000, 102),

-- Anita Gupta (Business account - high volume)
('2024-01-03', 1002, 'BR2', 'CD', NULL, NULL, 100000, 106),
('2024-01-08', 1002, 'BR2', 'CW', NULL, NULL, 45000, 106),
('2024-01-15', 1002, 'BR2', 'CQD', 67890, '2024-01-14', 75000, 106),
('2024-01-22', 1002, 'BR2', 'CW', NULL, NULL, 30000, 106),

-- Regular transaction patterns
('2024-01-10', 1004, 'BR3', 'CD', NULL, NULL, 15000, 103),
('2024-01-18', 1004, 'BR3', 'CW', NULL, NULL, 5000, 103),
('2024-01-06', 1005, 'BR4', 'CD', NULL, NULL, 8000, 104),
('2024-01-14', 1006, 'BR5', 'CQD', 11111, '2024-01-13', 20000, 106),

-- Small account transactions
('2024-01-16', 1007, 'BR1', 'CD', NULL, NULL, 3000, 102),
('2024-01-24', 1008, 'BR2', 'CW', NULL, NULL, 2000, 106),
('2024-01-11', 1009, 'BR3', 'CD', NULL, NULL, 5000, 103),

-- Add some older transactions for trend analysis
('2023-12-15', 1001, 'BR1', 'CD', NULL, NULL, 40000, 102),
('2023-12-20', 1001, 'BR1', 'CW', NULL, NULL, 12000, 102),
('2023-12-10', 1002, 'BR2', 'CD', NULL, NULL, 80000, 106),
('2023-12-25', 1003, 'BR3', 'CQD', 98765, '2023-12-24', 30000, 103);

PRINT 'Sample data inserted successfully!';
PRINT 'Ready for analytics demonstration!';
