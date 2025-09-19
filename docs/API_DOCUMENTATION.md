# 🔌 API Documentation - Indian Bank Database System

## Overview
This document outlines the stored procedures, functions, and database interfaces that serve as APIs for the Indian Bank Database System. These endpoints can be used for application integration, reporting, and data access.

## 🚀 Quick Reference

| Endpoint | Type | Purpose | Parameters |
|----------|------|---------|------------|
| `SP_TRANSACTION_REPORT` | Stored Procedure | Generate transaction reports | Account ID, Date Range |
| `SP_BRANCH_TRANSACTION_SUMMARY` | Stored Procedure | Branch performance analysis | Branch ID, Date Range |
| `SP_ACCOUNT_STATEMENT` | Stored Procedure | Customer account statement | Account ID, Date Range |
| `VW_ACCOUNT_BASIC_INFO` | View | Customer basic information | None (SELECT query) |
| `VW_CUSTOMER_ACCOUNT_COUNT` | View | Customer portfolio summary | None (SELECT query) |

---

## 📋 Stored Procedures (APIs)

### 1. Transaction Report Generator
**Endpoint:** `SP_TRANSACTION_REPORT`

**Purpose:** Generate comprehensive transaction reports for specific accounts

**Syntax:**
```sql
EXEC SP_TRANSACTION_REPORT 
    @ACCOUNT_ID = [Account Number],
    @FROM_DATE = '[Start Date]',
    @TO_DATE = '[End Date]';
```

**Parameters:**
- `@ACCOUNT_ID` (INTEGER, Required): Target account number
- `@FROM_DATE` (DATE, Required): Report start date  
- `@TO_DATE` (DATE, Required): Report end date

**Example Usage:**
```sql
-- Generate November 2024 report for account 1001
EXEC SP_TRANSACTION_REPORT 
    @ACCOUNT_ID = 1001,
    @FROM_DATE = '2024-11-01',
    @TO_DATE = '2024-11-30';
```

**Response Format:**
```
INDIAN BANK
List of Transactions from November 1, 2024 to November 30, 2024 Report
-------------------------------------------------------------------------
Product Name : SAVINGS BANK
Account No : 1001 Branch : BR1

Customer Name: Praveen Kumar     Cleared Balance: $150,000
SL.NO  DATE        TXN TYPE  CHEQUE NO  AMOUNT    RUNNING BALANCE
1      11/01/2024  CD        -          $50,000   $200,000
2      11/05/2024  CW        -          $15,000   $185,000
...

Total Number of Transactions: 4
Cash Deposits: 2
Cash Withdrawals: 2
Cheque Deposits: 0
```

---

### 2. Branch Performance Summary
**Endpoint:** `SP_BRANCH_TRANSACTION_SUMMARY`

**Purpose:** Generate branch-wise transaction analytics

**Syntax:**
```sql
EXEC SP_BRANCH_TRANSACTION_SUMMARY 
    @BRANCH_ID = '[Branch Code]',  -- Optional
    @FROM_DATE = '[Start Date]',
    @TO_DATE = '[End Date]';
```

**Parameters:**
- `@BRANCH_ID` (CHAR(3), Optional): Specific branch code (NULL for all branches)
- `@FROM_DATE` (DATE, Required): Analysis start date
- `@TO_DATE` (DATE, Required): Analysis end date

**Example Usage:**
```sql
-- All branches summary for current month
EXEC SP_BRANCH_TRANSACTION_SUMMARY 
    @BRANCH_ID = NULL,
    @FROM_DATE = '2024-11-01',
    @TO_DATE = '2024-11-30';

-- Specific branch analysis
EXEC SP_BRANCH_TRANSACTION_SUMMARY 
    @BRANCH_ID = 'BR1',
    @FROM_DATE = '2024-11-01',
    @TO_DATE = '2024-11-30';
```

**Response Format:**
```
Branch ID  Branch Name           Transaction Type  Count  Total Amount
BR1        MUMBAI MAIN BRANCH   CD               25     $2,500,000
BR1        MUMBAI MAIN BRANCH   CW               18     $1,200,000
BR2        DELHI CENTRAL        CD               30     $3,200,000
```

---

### 3. Account Statement Generator
**Endpoint:** `SP_ACCOUNT_STATEMENT`

**Purpose:** Generate detailed account statements for customers

**Syntax:**
```sql
EXEC SP_ACCOUNT_STATEMENT 
    @ACCOUNT_ID = [Account Number],
    @FROM_DATE = '[Start Date]',
    @TO_DATE = '[End Date]';
```

**Example Usage:**
```sql
EXEC SP_ACCOUNT_STATEMENT 
    @ACCOUNT_ID = 1001,
    @FROM_DATE = '2024-11-01',
    @TO_DATE = '2024-11-30';
```

---

## 📊 Views (Read-Only APIs)

### 1. Customer Basic Information
**Endpoint:** `VW_ACCOUNT_BASIC_INFO`

**Purpose:** Retrieve customer basic details (GDPR-compliant subset)

**Usage:**
```sql
SELECT * FROM VW_ACCOUNT_BASIC_INFO;
SELECT * FROM VW_ACCOUNT_BASIC_INFO WHERE [Account Number] = 1001;
```

**Response Schema:**
```sql
Account Number  | INT     | Primary identifier
Name           | VARCHAR | Customer full name  
Address        | VARCHAR | Customer address
```

---

### 2. Customer Portfolio Summary
**Endpoint:** `VW_CUSTOMER_ACCOUNT_COUNT`

**Usage:**
```sql
SELECT * FROM VW_CUSTOMER_ACCOUNT_COUNT;
```

**Response Schema:**
```sql
Customer Name              | VARCHAR | Customer full name
Number of Accounts Held    | INT     | Total accounts per customer
```

---

## 🔐 Security & Access Control

### Authentication Requirements
- Database connection requires valid SQL Server authentication
- Stored procedures require `EXECUTE` permissions
- Views require `SELECT` permissions on underlying tables

### Role-Based Access
```sql
-- Manager role - Full access
GRANT EXECUTE ON SP_TRANSACTION_REPORT TO ManagerRole;
GRANT SELECT ON VW_CUSTOMER_ACCOUNT_COUNT TO ManagerRole;

-- Teller role - Limited access
GRANT EXECUTE ON SP_ACCOUNT_STATEMENT TO TellerRole;
GRANT SELECT ON VW_ACCOUNT_BASIC_INFO TO TellerRole;

-- Auditor role - Read-only access
GRANT SELECT ON VW_ACCOUNT_BASIC_INFO TO AuditorRole;
```

### Data Privacy Compliance
- Personal information access logged via triggers
- Sensitive data masked for non-privileged users
- GDPR-compliant data retention policies

---

## 📈 Performance Considerations

### Optimization Guidelines
- **Large Date Ranges**: Use indexed date columns for filtering
- **Batch Processing**: Process large result sets in chunks
- **Connection Pooling**: Reuse database connections for efficiency
- **Caching**: Cache frequently requested static data

### Response Time Expectations
| Endpoint | Typical Response Time | Max Records |
|----------|----------------------|-------------|
| Account Statement | <2 seconds | 1,000 transactions |
| Branch Summary | <5 seconds | All branches |
| Transaction Report | <3 seconds | Monthly data |

---

## 🔧 Integration Examples

### C# Application Integration
```csharp
using (SqlConnection conn = new SqlConnection(connectionString))
{
    using (SqlCommand cmd = new SqlCommand("SP_TRANSACTION_REPORT", conn))
    {
        cmd.CommandType = CommandType.StoredProcedure;
        cmd.Parameters.AddWithValue("@ACCOUNT_ID", 1001);
        cmd.Parameters.AddWithValue("@FROM_DATE", DateTime.Now.AddMonths(-1));
        cmd.Parameters.AddWithValue("@TO_DATE", DateTime.Now);
        
        conn.Open();
        SqlDataReader reader = cmd.ExecuteReader();
        // Process results...
    }
}
```

### Python Integration
```python
import pyodbc

def get_account_statement(account_id, from_date, to_date):
    conn = pyodbc.connect(connection_string)
    cursor = conn.cursor()
    
    cursor.execute("""
        EXEC SP_ACCOUNT_STATEMENT 
        @ACCOUNT_ID = ?, @FROM_DATE = ?, @TO_DATE = ?
    """, account_id, from_date, to_date)
    
    return cursor.fetchall()
```

### REST API Wrapper Example
```javascript
// Node.js Express endpoint
app.get('/api/account/:id/statement', async (req, res) => {
    const { id } = req.params;
    const { from_date, to_date } = req.query;
    
    const result = await sql.query`
        EXEC SP_ACCOUNT_STATEMENT 
        @ACCOUNT_ID = ${id}, 
        @FROM_DATE = ${from_date}, 
        @TO_DATE = ${to_date}
    `;
    
    res.json(result.recordset);
});
```

---

## 🚨 Error Handling

### Common Error Codes
- **Account Not Found**: Account ID doesn't exist
- **Invalid Date Range**: FROM_DATE > TO_DATE  
- **Access Denied**: Insufficient permissions
- **Data Limit Exceeded**: Too many records requested

### Error Response Format
```sql
-- Example error handling in stored procedure
IF @ACCOUNT_ID IS NULL OR NOT EXISTS (SELECT 1 FROM [ACCOUNT MASTER] WHERE ACID = @ACCOUNT_ID)
BEGIN
    RAISERROR('Invalid Account ID: Account does not exist', 16, 1);
    RETURN;
END
```

---

## 📞 Support & Maintenance

### API Versioning
- Current Version: **v1.0**
- Backward Compatibility: Guaranteed for stored procedures
- Deprecation Notice: 90 days advance notice for breaking changes

### Monitoring & Logging
- All API calls logged with user context
- Performance metrics tracked via SQL Server DMVs
- Error rates monitored and alerted

---

*This API documentation ensures seamless integration with external applications while maintaining security and performance standards.*
```