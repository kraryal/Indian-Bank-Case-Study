# Indian Bank SQL Server Case Study

## Project Overview
A comprehensive SQL Server database implementation for an Indian Bank system with complete transaction management, account handling, and business rule enforcement.

## Features
- Complete bank database schema with 6 master tables
- 19 business integrity rules implemented via triggers and constraints
- 5 custom views for data analysis
- 25+ complex queries for various banking operations
- Stored procedures for transaction reports

## Database Schema
- **Account Master**: Customer account information
- **Product Master**: Bank products (SB, LA, FD, RD)
- **Branch Master**: Branch details and locations
- **Region Master**: Regional information
- **User Master**: Bank employee details
- **Transaction Master**: All banking transactions

## Technologies Used
- SQL Server
- T-SQL
- Triggers
- Stored Procedures
- Views
- Constraints

## Setup Instructions
1. Execute `database/01_database_creation.sql`
2. Run `database/02_table_creation.sql`
3. Insert sample data using `database/03_sample_data.sql`
4. Apply business rules with `database/04_constraints_triggers.sql`

## Business Rules Implemented
- Account status validation
- Transaction limits and penalties
- Minimum balance enforcement
- Cheque validity checks
- Daily/monthly transaction limits

## Author
Krishna Aryal - Georgia Institute of Technology

#Project Structure
```
Indian-Bank-SQL-Case-Study/
├── README.md
├── database/
│   ├── 01_database_creation.sql
│   ├── 02_table_creation.sql
│   ├── 03_sample_data.sql
│   └── 04_constraints_triggers.sql
├── views/
│   └── bank_views.sql
├── queries/
│   ├── basic_queries.sql
│   ├── advanced_queries.sql
│   └── reporting_queries.sql
├── stored_procedures/
│   └── bank_procedures.sql
├── documentation/
│   ├── database_schema.md
│   └── business_rules.md
└── images/
    └── erd_diagram.png
```
