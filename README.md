# 🏦 Indian Bank Database Management System

> **Perfect for Data Science Interviews** - Comprehensive banking system showcasing SQL expertise, business intelligence, and financial analytics.

[![View Demo Results](https://img.shields.io/badge/📊-View%20Demo%20Results-blue)](./DEMO_RESULTS.md)
[![Quick Demo](https://img.shields.io/badge/⚡-Quick%20Demo-green)](./QUICK_DEMO.sql)
[![Database Ready](https://img.shields.io/badge/💾-Database%20Ready-orange)](./Ibank.bak)

## 🚀 **For Hiring Managers - 30 Second Demo**
1. **Import Database**: Restore `Ibank.bak` in SQL Server
2. **Run Quick Demo**: Execute `QUICK_DEMO.sql`  
3. **See Full Analytics**: Run `sample_analytics.sql`

## 💼 **Skills Demonstrated**
- Advanced SQL (Triggers, Stored Procedures, Complex Analytics)
- Database Architecture & Design
- Business Intelligence & Reporting
- Financial Domain Expertise
- Data-driven Decision Making

## 📈 **Real-World Applications**
- **Customer Segmentation**: Identify high-value customers and risk patterns
- **Fraud Detection**: Automated transaction monitoring and alerts
- **Business Intelligence**: Branch performance and revenue analysis
- **Compliance**: Automated enforcement of banking regulations

---
*This project demonstrates production-ready database skills applicable to Data Science roles in Banking, Finance, and Business Intelligence.*

### 2. **Add Sample Queries Showcase**
**File: `sample_analytics.sql`**
```sql
-- =====================================================
-- SAMPLE ANALYTICS FOR HIRING MANAGERS
-- =====================================================

-- 🎯 Customer Behavior Analysis
```
```sql
SELECT 
    am.NAME AS customer_name,
    COUNT(tm.TRANSACTION_NUMBER) as transaction_count,
    SUM(tm.TXN_AMOUNT) as total_volume,
    AVG(tm.TXN_AMOUNT) as avg_transaction,
    MAX(tm.DATE_OF_TRANSACTION) as last_transaction
FROM [ACCOUNT MASTER] am
LEFT JOIN [TRANSACTION MASTER] tm ON am.ACID = tm.ACID
GROUP BY am.ACID, am.NAME
ORDER BY total_volume DESC;
```
-- 📊 Branch Performance Dashboard
```sql
SELECT 
    bm.[BRANCH NAME],
    COUNT(DISTINCT am.ACID) as total_accounts,
    COUNT(tm.TRANSACTION_NUMBER) as total_transactions,
    SUM(tm.TXN_AMOUNT) as branch_volume,
    AVG(am.[CLEAR BALANCE]) as avg_balance
FROM [BRANCH MASTER] bm
LEFT JOIN [ACCOUNT MASTER] am ON bm.BRID = am.BRID
LEFT JOIN [TRANSACTION MASTER] tm ON am.ACID = tm.ACID
GROUP BY bm.BRID, bm.[BRANCH NAME]
ORDER BY branch_volume DESC;
```
-- 🚨 Risk Analysis - High Value Customers
```sql
WITH high_value_customers AS (
    SELECT 
        am.NAME,
        am.[CLEAR BALANCE],
        COUNT(tm.TRANSACTION_NUMBER) as txn_frequency,
        DATEDIFF(day, MAX(tm.[DATE OF TRANSACTION]), GETDATE()) as days_inactive
    FROM [ACCOUNT MASTER] am
    LEFT JOIN [TRANSACTION MASTER] tm ON am.ACID = tm.ACID
    WHERE am.[CLEAR BALANCE] > 50000
    GROUP BY am.ACID, am.NAME, am.[CLEAR BALANCE]
)
SELECT * FROM high_value_customers
WHERE days_inactive > 30 OR days_inactive IS NULL;
```

### 3. **Create Project Documentation**
**File: `PROJECT_STRUCTURE.md`**

# 📁 Project Structure Guide

## 🗂️ File Organization
```
├── 📄 Ibank.bak                    # Complete database backup
├── 🔧 01_database_creation.sql     # Database & table creation
├── ⚙️ 02_constraints_and_checks.sql # Business rule constraints  
├── 🔄 03_triggers_part1.sql        # Transaction validation triggers
├── 🔄 04_triggers_part2.sql        # Advanced business logic
├── 👁️ 05_views.sql                 # Reporting views
├── 📊 06_queries_basic_reports.sql # Standard reports
├── 📈 07_queries_advanced_analytics.sql # Complex analytics
├── 🧮 08_queries_complex_analysis.sql # Advanced analysis
├── 📋 09_stored_procedures.sql     # Automated reporting
└── 💡 sample_analytics.sql        # Demo queries for hiring managers
```
## 🚀 **Quick Start for Hiring Managers**
```bash
# Option 1: Use backup file (Recommended)
1. Restore Ibank.bak in SQL Server Management Studio
2. Run QUICK_DEMO.sql for immediate results

# Option 2: Build from scratch  
1. Execute files in numerical order (01_database_creation.sql → 09_stored_procedures.sql)
2. Run 07_sample_data_extended.sql for realistic data
3. Execute 10_demo_analytics.sql for impressive results
