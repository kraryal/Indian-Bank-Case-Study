# 👥 User Guide - Indian Bank Database System

## Document Information
- **System**: Indian Bank Database Management System
- **Audience**: Bank Staff (Managers, Tellers, Clerks, Officers)
- **Version**: 1.0
- **Last Updated**: November 2024

---

## 🎯 Quick Start Guide

### Getting Started
Welcome to the Indian Bank Database System! This guide will help you understand and use the system effectively for daily banking operations.

### System Access
1. **Login**: Use your assigned User ID and credentials
2. **Role Verification**: Confirm your role (Manager/Teller/Clerk/Officer)
3. **Navigation**: Access features based on your role permissions

---

## 👥 User Roles & Permissions

### 🏆 Manager (M)
**Full System Access**
- ✅ All transaction types and reports
- ✅ Account creation and modification
- ✅ Branch performance analytics
- ✅ High-value transaction approvals
- ✅ User management and system administration

### 💰 Teller (T)  
**Customer Service Focus**
- ✅ Cash deposits and withdrawals
- ✅ Account balance inquiries
- ✅ Transaction processing
- ✅ Customer statements
- ❌ Account creation (Manager approval required)

### 📋 Clerk (C)
**Administrative Support**
- ✅ Account information updates
- ✅ Document processing
- ✅ Basic reporting
- ❌ Transaction processing
- ❌ Cash handling

### 👔 Officer (O)
**Specialized Operations**  
- ✅ Cheque processing
- ✅ Account investigations
- ✅ Compliance reporting
- ✅ Customer relationship management
- ❌ Direct cash transactions

---

## 🏦 Core Operations Guide

### 1. Account Management

#### Creating New Account
**Prerequisites**: Customer KYC documents, initial deposit

**Steps**:
1. **Collect Information**:
   ```
   Customer Name: [Full legal name]
   Address: [Complete address]
   Branch: [Home branch code]
   Product Type: SB/CA/FD/RD
   Initial Deposit: [Amount ≥ minimum balance]
   ```

2. **System Entry**:
   ```sql
   -- Account creation (Manager/authorized users only)
   INSERT INTO [ACCOUNT MASTER] (
       ACID, NAME, ADDRESS, BRID, PID, 
       [DATE OF OPENING], [CLEAR BALANCE], [UNCLEAR BALANCE], STATUS
   ) VALUES (
       [New Account Number], '[Customer Name]', '[Address]', 
       '[Branch Code]', '[Product Code]', GETDATE(), 
       [Initial Amount], [Initial Amount], 'O'
   );
   ```

3. **Verification Checklist**:
   - ✅ Account number generated successfully
   - ✅ Customer details accurately entered
   - ✅ Initial deposit meets minimum requirements
   - ✅ Account status set to 'Operative'

#### Account Status Changes
- **Active to Inactive**: Requires Manager approval
- **Inactive to Closed**: Verify no pending cheques (cleared = uncleared balance)
- **Reactivation**: Customer request with updated KYC

### 2. Transaction Processing

#### Cash Deposit (CD)
**Daily Process**:
1. **Customer Verification**: Confirm account number and identity
2. **Amount Validation**: Count and verify deposit amount
3. **System Entry**:
   ```sql
   -- Cash deposit entry
   INSERT INTO [TRANSACTION MASTER] (
       [DATE OF TRANSACTION], ACID, BRID, TXN_TYPE, 
       CHQ_NO, CHQ_DATE, TXN_AMOUNT, USERID
   ) VALUES (
       GETDATE(), [Account Number], [Branch Code], 'CD',
       NULL, NULL, [Deposit Amount], [Your User ID]
   );
   ```
4. **Receipt Generation**: Provide transaction receipt to customer
5. **Balance Verification**: Confirm updated balance display

#### Cash Withdrawal (CW)
**Security Protocols**:
1. **Identity Verification**: Photo ID and signature verification
2. **Balance Check**: Ensure sufficient funds available
3. **Limit Verification**: Check daily withdrawal count (max 3)
4. **Amount Validation**: Verify withdrawal amount
5. **System Entry**:
   ```sql
   -- Cash withdrawal entry  
   INSERT INTO [TRANSACTION MASTER] (
       [DATE OF TRANSACTION], ACID, BRID, TXN_TYPE,
       CHQ_NO, CHQ_DATE, TXN_AMOUNT, USERID
   ) VALUES (
       GETDATE(), [Account Number], [Branch Code], 'CW',
       NULL, NULL, [Withdrawal Amount], [Your User ID]
   );
   ```

#### Cheque Deposit (CQD)
**Processing Requirements**:
1. **Cheque Validation**:
   - Date within 6 months ✅
   - Proper endorsement ✅
   - Legible amount and signature ✅
   
2. **System Entry**:
   ```sql
   -- Cheque deposit entry
   INSERT INTO [TRANSACTION MASTER] (
       [DATE OF TRANSACTION], ACID, BRID, TXN_TYPE,
       CHQ_NO, CHQ_DATE, TXN_AMOUNT, USERID
   ) VALUES (
       GETDATE(), [Account Number], [Branch Code], 'CQD',
       [Cheque Number], '[Cheque Date]', [Cheque Amount], [Your User ID]
   );
   ```

3. **Clearing Process**: 
   - Amount added to uncleared balance immediately
   - Cleared balance updated after bank clearing (2-3 days)

---

## 📊 Reports & Inquiries

### Customer Account Statement
**Generate monthly/custom period statements**

**Usage**:
```sql
-- Execute account statement procedure
EXEC SP_ACCOUNT_STATEMENT 
    @ACCOUNT_ID = [Account Number],
    @FROM_DATE = '[Start Date]',
    @TO_DATE = '[End Date]';
```

**Output Includes**:
- Opening balance
- All transactions chronologically  
- Running balance after each transaction
- Closing balance
- Summary by transaction type

### Branch Performance Report
**For Managers - Daily/Monthly analysis**

**Usage**:
```sql  
-- Branch transaction summary
EXEC SP_BRANCH_TRANSACTION_SUMMARY 
    @BRANCH_ID = '[Branch Code]',
    @FROM_DATE = '[Start Date]',
    @TO_DATE = '[End Date]';
```

**Key Metrics**:
- Transaction volumes by type
- Customer activity levels
- Revenue generation
- Comparative branch performance

### Customer Information Lookup
**Quick customer details for service**

**Usage**:
```sql
-- Basic customer information
SELECT * FROM VW_ACCOUNT_BASIC_INFO 
WHERE [Account Number] = [Customer Account];

-- Detailed account summary
SELECT * FROM VW_CUSTOMER_TRANSACTION_SUMMARY
WHERE [Account Number] = [Customer Account];
```

---

## ⚠️ Important Business Rules

### Transaction Limits & Restrictions
| Rule | Limit | Action if Exceeded |
|------|-------|-------------------|
| Daily Cash Withdrawals | 3 per account | Transaction blocked |
| Monthly Cash Deposits | 3 per account | Transaction blocked |  
| Daily Withdrawal Amount | ₹50,000 | 1% penalty on excess |
| Monthly Transactions | 5 total | ₹50 penalty fee |
| Cheque Age | 6 months | Cheque rejected |

### Account Status Rules
- **Operative (O)**: All transactions allowed
- **Inoperative (I)**: No transactions permitted
- **Closed (C)**: Account permanently closed

### Balance Requirements
- **Savings Account**: Minimum ₹1,000 balance
- **Current Account**: No minimum (overdraft facility)
- **Fixed Deposit**: Full amount locked for term
- **Recurring Deposit**: Monthly installment required

---

## 🚨 Error Handling & Troubleshooting

### Common Error Messages

#### "Account not found"
**Cause**: Invalid account number entered
**Solution**: 
1. Verify account number with customer
2. Check for leading zeros or special characters
3. Use account lookup function

#### "Transaction not allowed on inactive account"
**Cause**: Account status is 'I' (Inoperative) or 'C' (Closed)
**Solution**:
1. Check account status: `SELECT STATUS FROM [ACCOUNT MASTER] WHERE ACID = [Account Number]`
2. For reactivation, contact Manager
3. For closed accounts, inform customer

#### "Insufficient balance for withdrawal"
**Cause**: Withdrawal amount exceeds available balance
**Solution**:
1. Check current balance
2. Inform customer of available amount
3. Process partial withdrawal if customer agrees

#### "Daily withdrawal limit exceeded"  
**Cause**: More than 3 cash withdrawals attempted in same day
**Solution**:
1. Explain daily limit policy to customer
2. Suggest alternative: cheque or next banking day
3. Manager override available for emergencies

#### "Cheque date too old"
**Cause**: Cheque dated more than 6 months ago
**Solution**:
1. Inform customer of 6-month validity rule
2. Request fresh cheque from drawer
3. Return old cheque to customer

### System Performance Issues

#### Slow Response Times
**Possible Causes**:
- High transaction volume during peak hours
- Network connectivity issues
- Database maintenance in progress

**Immediate Actions**:
1. Wait for current transaction to complete
2. Avoid multiple simultaneous queries
3. Contact IT support if persistent

#### Connection Failures
**Emergency Procedures**:
1. Use offline transaction log
2. Manual receipt generation
3. Update system when connection restored
4. Verify all offline transactions

---

## 📋 Daily Procedures

### Opening Procedures (Start of Business Day)
1. **System Login**: Verify access and role permissions
2. **Cash Verification**: Count and verify opening cash balance
3. **System Health Check**: Verify database connectivity
4. **Previous Day Reconciliation**: Review pending transactions
5. **Equipment Check**: Ensure all hardware functioning

### Transaction Processing Guidelines
1. **Customer Service**: Greet customer and verify identity
2. **Transaction Verification**: Confirm transaction details
3. **System Entry**: Accurate data entry with verification
4. **Receipt Generation**: Provide transaction confirmation
5. **Cash Handling**: Secure cash management procedures

### End of Day Procedures
1. **Transaction Reconciliation**: Verify all entries processed
2. **Cash Counting**: Physical cash vs system balance
3. **Report Generation**: Daily transaction summary
4. **System Backup**: Ensure automatic backup completed
5. **Security Procedures**: System logout and cash securing

---

## 🎯 Tips for Efficient Operations

### Speed & Accuracy Tips
- **Use shortcuts**: Learn keyboard shortcuts for common operations
- **Batch processing**: Group similar transactions when possible  
- **Double-check**: Verify amounts and account numbers before submission
- **Customer communication**: Keep customers informed during processing

### Customer Service Excellence
- **Professional greeting**: Welcome customers warmly
- **Active listening**: Understand customer needs fully
- **Clear communication**: Explain procedures and requirements clearly
- **Problem resolution**: Escalate complex issues appropriately

### System Navigation
- **Bookmark queries**: Save frequently used report queries
- **Use filters**: Apply date/amount filters for faster searches
- **Print efficiently**: Use print preview to avoid waste
- **Regular updates**: Stay informed about system enhancements

---

## 📞 Support & Escalation

### Technical Support
- **Level 1**: Basic system issues → Local IT Support
- **Level 2**: Database problems → Database Administrator  
- **Level 3**: Critical system failure → IT Manager

### Business Support  
- **Customer complaints** → Branch Manager
- **Policy clarifications** → Operations Manager
- **Regulatory issues** → Compliance Officer
- **Emergency situations** → Regional Manager

### Contact Information
```
IT Help Desk: ext. 2001
Branch Manager: ext. 2010
Operations Manager: ext. 2020
Emergency Line: ext. 2000
```

---

## 🎓 Training & Certification

### New User Training Path
1. **System Overview**: 2 hours - Understanding database structure
2. **Role-specific Training**: 4 hours - Your role responsibilities
3. **Hands-on Practice**: 8 hours - Supervised transaction processing
4. **Assessment**: 1 hour - Competency evaluation
5. **Certification**: Ongoing - Annual recertification required

### Ongoing Education
- **Monthly Updates**: System enhancements and new features
- **Quarterly Reviews**: Best practices and procedure updates
- **Annual Training**: Advanced features and compliance updates
- **Cross-training**: Understanding other roles for better teamwork

---

## 📚 Quick Reference

### Common Queries
```sql
-- Check account balance
SELECT [CLEAR BALANCE], [UNCLEAR BALANCE] 
FROM [ACCOUNT MASTER] WHERE ACID = [Account Number];

-- Last 5 transactions
SELECT TOP 5 * FROM [TRANSACTION MASTER] 
WHERE ACID = [Account Number] 
ORDER BY [DATE OF TRANSACTION] DESC;

-- Daily transaction count
SELECT COUNT(*) FROM [TRANSACTION MASTER]
WHERE CAST([DATE OF TRANSACTION] AS DATE) = CAST(GETDATE() AS DATE);
```

### Transaction Codes
- **CD**: Cash Deposit
- **CW**: Cash Withdrawal  
- **CQD**: Cheque Deposit

### Status Codes
- **O**: Operative (Active)
- **I**: Inoperative (Inactive)
- **C**: Closed

### User Designations  
- **M**: Manager
- **T**: Teller
- **C**: Clerk
- **O**: Officer

---

*This User Guide serves as your comprehensive reference for daily operations with the Indian Bank Database System. For additional support or training, contact your Branch Manager or IT Support team.*
```