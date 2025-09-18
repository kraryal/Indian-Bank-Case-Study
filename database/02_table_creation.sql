-- Table Creation Script for Indian Bank
-- Author: Krishna Aryal

USE IndianBank;
GO

-- Region Master Table
CREATE TABLE RMASTER (
    RID int PRIMARY KEY,
    RNAME char(6) NOT NULL
);

-- Product Master Table  
CREATE TABLE PMASTER (
    PID char(2) PRIMARY KEY,
    PNAME varchar(25) NOT NULL
);

-- Branch Master Table
CREATE TABLE BRMASTER (
    BRID char(3) PRIMARY KEY,
    BRNAME varchar(30) NOT NULL,
    BRADD varchar(50) NOT NULL,
    RID int NOT NULL FOREIGN KEY REFERENCES RMASTER(RID)
);

-- User Master Table
CREATE TABLE UMASTER (
    UID int PRIMARY KEY,
    UNAME varchar(30) NOT NULL,
    DESGN char(1) NOT NULL CHECK (DESGN IN ('M','C','T','O'))
);

-- Account Master Table
CREATE TABLE AMASTER (
    ACID int PRIMARY KEY,
    NAME varchar(40) NOT NULL,
    ADDRESS varchar(50) NOT NULL,
    BRID char(3) NOT NULL FOREIGN KEY REFERENCES BRMASTER(BRID),
    PID char(2) NOT NULL FOREIGN KEY REFERENCES PMASTER(PID),
    DOO datetime NOT NULL,
    CBAL money NULL,
    UBAL money NULL CHECK (UBAL >= CBAL),
    STATUS char(1) NULL CHECK (STATUS IN('I','C','O')) DEFAULT 'O'
);

-- Transaction Master Table
CREATE TABLE TMASTER (
    TNO int PRIMARY KEY IDENTITY(1,1),
    DOT datetime NOT NULL,
    ACID int NOT NULL FOREIGN KEY REFERENCES AMASTER(ACID),
    BRID char(3) NOT NULL FOREIGN KEY REFERENCES BRMASTER(BRID),
    TXNTYPE char(3) NOT NULL CHECK (TXNTYPE IN ('CW','CD','CQD')),
    CHQNO int NULL,
    CHQDATE smalldatetime NULL,
    TXNAMT money NOT NULL CHECK (TXNAMT >= 0),
    UID int NOT NULL FOREIGN KEY REFERENCES UMASTER(UID)
);

PRINT 'All tables created successfully!';