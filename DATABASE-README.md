# Library Management System - Database Schema Documentation

## Overview

This repository contains the complete PostgreSQL database schema for the Library Management System, a web-based application that enables librarians to efficiently manage books, track member borrowing, and generate insights through statistical reporting.

## Requirements

- **PostgreSQL**: Version 12 or higher
- **Extensions**: None required (optional UUID extension commented out for future use)
- **Permissions**: CREATE, ALTER, DROP privileges on target database

## Schema Files

### 1. `complete-schema.sql`
**Core Database Schema** - Foundation tables, enums, triggers, and indexes

**Components:**
- **Enum Types**: 6 custom types (copy_status, copy_condition, membership_type, membership_status, gender_type)
- **Core Tables**: 
  - `members` - Member registration and profile information
  - `books` - Book catalog with metadata
  - `book_authors` - Many-to-many relationship for book authors
  - `book_copies` - Physical copy tracking
  - `borrow_history` - Complete borrowing transaction history
  - `member_preferred_genres` - Member genre preferences
  - `member_borrowing_restrictions` - Active borrowing restrictions
- **Views**: `current_borrows` - Active loans view
- **Functions**: Automated triggers for maintaining counts, status updates, and restrictions
- **Indexes**: 20+ performance-optimized indexes

### 2. `reporting-views-schema.sql`
**Statistics & Reporting Views** - Analytics and operational reports

**Components:**
- **Popular Books Analytics**: Weekly, monthly, annual, and all-time views
- **Genre Analytics**: Borrowing statistics by genre across time periods
- **Author Analytics**: Most borrowed authors with detailed metrics
- **Member Activity**: Active members, new registrations, borrowing patterns
- **Collection Utilization**: Never borrowed books, high-demand titles, collection gaps
- **Borrowing Trends**: Daily, monthly, and seasonal patterns
- **Operational Reports**: Overdue summaries, inventory status, member compliance
- **Dashboard Summary**: Quick overview statistics
- **Reporting Functions**: Custom date range queries and member statistics

**Views Created**: 30+ analytical and operational views

### 3. `business-rules-schema.sql`
**Business Logic & Stored Procedures** - Enforces library policies and workflows

**Components:**
- **Borrowing Management**:
  - `checkout_book()` - Full validation checkout process
  - `checkin_book()` - Return processing with overdue calculation
  - `renew_book()` - Renewal with 2-renewal limit enforcement
  
- **Book Management**:
  - `add_book()` - Add book with multiple authors
  - `add_book_copy()` - Register physical copies
  - `delete_book()` - Safe deletion with validation
  
- **Member Management**:
  - `add_member()` - Member registration
  - `update_member()` - Profile updates
  - `delete_member()` - Safe deletion with validation
  - `update_member_status()` - Suspend/activate accounts
  - `renew_membership()` - Membership renewal
  
- **Maintenance Functions**:
  - `update_overdue_status()` - Daily overdue processing
  - `expire_memberships()` - Automatic expiration
  - `daily_maintenance()` - Combined maintenance tasks
  
- **Validation Functions**:
  - `can_member_borrow()` - Eligibility checking
  - `is_copy_available()` - Availability verification
  - `calculate_late_fee()` - Fee calculation (future use)
  
- **Utility Functions**:
  - `generate_member_id()` - Unique ID generation
  - `generate_copy_id()` - Copy ID generation

**Functions Created**: 25+ business logic and utility functions

### 4. `deploy-schema.sql`
**Master Deployment Script** - Automated deployment of all components

Deploys schemas in correct order:
1. Core schema (tables and triggers)
2. Reporting views (analytics)
3. Business rules (procedures)
4. Verification and summary

### 5. `sample-data.sql`
**Sample Data for Testing** - Pre-populated test data

Includes:
- 5 sample members (various membership types)
- 10 books (various genres)
- 25 book copies
- 15+ borrowing transactions
- Member preferences

## Business Rules Enforced

### Borrowing Constraints
- **Maximum 3 books per member** at any time
- **14-day standard loan period** (configurable)
- **No borrowing with overdue items**
- **Maximum 2 renewals** per book
- **Active membership required** for borrowing

### Book Management Rules
- **Cannot delete books** with active borrows
- **Unique ISBN** per book (not per copy)
- **Unique copy IDs** across entire collection
- **Cascade delete** for related records

### Member Management Rules
- **Unique member ID** per member
- **Unique email address** per member
- **Cannot delete members** with active borrows
- **Automatic status updates** based on borrowing activity

## Database Schema Diagram

```
┌─────────────┐         ┌──────────────┐         ┌────────────────┐
│   members   │────────>│ book_copies  │<────────│     books      │
│             │ borrows │              │ belongs │                │
│ PK:member_id│         │ PK:copy_id   │   to    │ PK:id          │
└─────────────┘         └──────────────┘         └────────────────┘
       │                        │                        │
       │                        │                        │
       ▼                        ▼                        ▼
┌─────────────┐         ┌──────────────┐         ┌────────────────┐
│  preferred  │         │    borrow    │         │ book_authors   │
│   genres    │         │   history    │         │                │
└─────────────┘         └──────────────┘         └────────────────┘
       │                        
       ▼                        
┌─────────────┐         
│ restrictions│         
└─────────────┘         
```

## Installation

### Option 1: Complete Deployment (Recommended)

```bash
# Connect to your PostgreSQL database
psql -U your_username -d library_db

# Run the master deployment script
\i deploy-schema.sql

# Optionally add sample data for testing
\i sample-data.sql
```

### Option 2: Manual Step-by-Step Deployment

```bash
# Step 1: Core schema
psql -U your_username -d library_db -f complete-schema.sql

# Step 2: Reporting views
psql -U your_username -d library_db -f reporting-views-schema.sql

# Step 3: Business rules
psql -U your_username -d library_db -f business-rules-schema.sql

# Step 4: Sample data (optional)
psql -U your_username -d library_db -f sample-data.sql
```

### Option 3: Docker Deployment

```bash
# Create database container
docker run --name library-postgres -e POSTGRES_PASSWORD=yourpassword -d postgres:14

# Copy SQL files to container
docker cp complete-schema.sql library-postgres:/complete-schema.sql
docker cp reporting-views-schema.sql library-postgres:/reporting-views-schema.sql
docker cp business-rules-schema.sql library-postgres:/business-rules-schema.sql

# Execute deployment
docker exec -it library-postgres psql -U postgres -c "CREATE DATABASE library_db;"
docker exec -it library-postgres psql -U postgres -d library_db -f /complete-schema.sql
docker exec -it library-postgres psql -U postgres -d library_db -f /reporting-views-schema.sql
docker exec -it library-postgres psql -U postgres -d library_db -f /business-rules-schema.sql
```

## Usage Examples

### Checking Out a Book

```sql
-- Check if member can borrow
SELECT * FROM can_member_borrow('MEM001');

-- Check out a book
SELECT * FROM checkout_book(
    p_member_id := 'MEM001',
    p_copy_id := '978-0-06-112008-4-00001',
    p_loan_days := 14
);
```

### Returning a Book

```sql
-- Return a book
SELECT * FROM checkin_book(
    p_copy_id := '978-0-06-112008-4-00001',
    p_return_condition := 'Good'
);
```

### Adding a New Book

```sql
-- Add a book with multiple authors
SELECT * FROM add_book(
    p_title := 'The Pragmatic Programmer',
    p_isbn := '978-0-13-595705-9',
    p_genre := 'Computer Science',
    p_publication_year := 2019,
    p_description := 'A guide to software development best practices',
    p_publisher := 'Addison-Wesley',
    p_page_count := 352,
    p_language := 'English',
    p_authors := ARRAY['Andrew Hunt', 'David Thomas']
);
```

### Viewing Popular Books

```sql
-- Most borrowed books this week
SELECT * FROM popular_books_weekly LIMIT 10;

-- Most borrowed books this month
SELECT * FROM popular_books_monthly LIMIT 10;

-- Custom date range
SELECT * FROM get_popular_books_by_date_range(
    '2025-01-01'::DATE,
    '2025-01-31'::DATE,
    10
);
```

### Checking Overdue Books

```sql
-- View all overdue books
SELECT * FROM overdue_summary ORDER BY days_overdue DESC;

-- Members with overdue books
SELECT * FROM members WHERE has_overdue_books = TRUE;
```

### Dashboard Statistics

```sql
-- Quick dashboard overview
SELECT * FROM library_dashboard_summary;
```

### Member Statistics

```sql
-- Detailed member borrowing statistics
SELECT * FROM get_member_statistics('MEM001');
```

## Maintenance

### Daily Maintenance Tasks

```sql
-- Run all daily maintenance (recommended to schedule this)
SELECT daily_maintenance();

-- Or run individually:
SELECT * FROM update_overdue_status();
SELECT * FROM expire_memberships();
```

### Scheduled Maintenance (Using pg_cron)

```sql
-- Install pg_cron extension
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule daily maintenance at midnight
SELECT cron.schedule('library-daily-maintenance', '0 0 * * *', 'SELECT daily_maintenance()');
```

## Performance Considerations

### Indexes
- All foreign keys are indexed for join performance
- Frequently queried columns (status, dates, names) have indexes
- Composite indexes for common query patterns

### Views vs Materialized Views
- All reporting views are regular views for real-time data
- For high-traffic scenarios, consider converting to materialized views:

```sql
-- Convert to materialized view (example)
DROP VIEW popular_books_weekly;
CREATE MATERIALIZED VIEW popular_books_weekly AS
-- [view definition]
;

-- Refresh periodically
REFRESH MATERIALIZED VIEW popular_books_weekly;
```

### Query Optimization Tips
- Use the provided views instead of writing complex joins
- Leverage the indexed columns in WHERE clauses
- Use `EXPLAIN ANALYZE` to identify slow queries

## Security Considerations

### Role-Based Access Control

```sql
-- Create roles
CREATE ROLE librarian;
CREATE ROLE member;
CREATE ROLE reports_viewer;

-- Librarian: Full access
GRANT ALL ON ALL TABLES IN SCHEMA public TO librarian;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO librarian;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO librarian;

-- Member: Limited access (read own data)
GRANT SELECT ON members, books, book_authors, book_copies TO member;
GRANT SELECT ON current_borrows, borrow_history TO member;

-- Reports Viewer: Read-only access to views
GRANT SELECT ON ALL TABLES IN SCHEMA public TO reports_viewer;
```

## Backup and Recovery

### Backup Commands

```bash
# Full database backup
pg_dump -U your_username -d library_db -F c -b -v -f library_db_backup.dump

# Schema only
pg_dump -U your_username -d library_db --schema-only -f library_schema_backup.sql

# Data only
pg_dump -U your_username -d library_db --data-only -f library_data_backup.sql
```

### Restore Commands

```bash
# Restore from custom format
pg_restore -U your_username -d library_db -v library_db_backup.dump

# Restore from SQL file
psql -U your_username -d library_db -f library_schema_backup.sql
```

## Troubleshooting

### Common Issues

**Issue**: "Cannot delete book with active borrows"
```sql
-- Check for active borrows
SELECT * FROM current_borrows WHERE book_id = <book_id>;
-- Return all copies before deleting
```

**Issue**: "Member has reached borrowing limit"
```sql
-- Check member status
SELECT * FROM members WHERE member_id = '<member_id>';
SELECT * FROM current_borrows WHERE member_id = '<member_id>';
-- Member must return a book before borrowing another
```

**Issue**: Views not showing updated data
```sql
-- Check if triggers are enabled
SELECT tgname, tgenabled FROM pg_trigger WHERE tgrelid = 'borrow_history'::regclass;
-- Re-enable if disabled
ALTER TABLE borrow_history ENABLE TRIGGER ALL;
```

## Testing

### Verify Schema Deployment

```sql
-- Check all tables
SELECT tablename FROM pg_tables WHERE schemaname = 'public';

-- Check all views
SELECT viewname FROM pg_views WHERE schemaname = 'public';

-- Check all functions
SELECT proname, pg_get_functiondef(oid) 
FROM pg_proc 
WHERE pronamespace = 'public'::regnamespace;
```

### Run Test Queries

```sql
-- Test checkout process
SELECT * FROM checkout_book('MEM001', '978-0-06-112008-4-00001', 14);

-- Test reporting views
SELECT * FROM library_dashboard_summary;
SELECT * FROM popular_books_weekly;
```

## Contributing

When making changes to the schema:

1. Update the appropriate SQL file (complete-schema.sql, reporting-views-schema.sql, or business-rules-schema.sql)
2. Add migration scripts if modifying existing structures
3. Update this README with any new features or changes
4. Test thoroughly with sample data
5. Document any new functions or views

## License

[Specify your license here]

## Support

For issues, questions, or contributions, please [contact information or repository link].

## Version History

- **v1.0** (February 2026): Initial schema release
  - Core tables and relationships
  - 30+ reporting views
  - 25+ stored procedures and functions
  - Comprehensive business rules enforcement
  - Sample data for testing

## References

- Project Requirements: See `library.md` for detailed functional requirements
- PostgreSQL Documentation: https://www.postgresql.org/docs/
