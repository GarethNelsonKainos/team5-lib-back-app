-- Library Management System - Master Deployment Script
-- This script deploys all schema components in the correct order
-- Run this file to set up the complete database

-- =============================================================================
-- DEPLOYMENT INFORMATION
-- =============================================================================
-- Database: Library Management System
-- Version: 1.0
-- Created: February 2026
-- Description: Complete schema deployment for library management system
-- Requirements: PostgreSQL 12 or higher
-- =============================================================================

\echo '=========================================================================='
\echo 'Library Management System - Database Schema Deployment'
\echo 'Starting deployment...'
\echo '=========================================================================='

-- Enable timing for deployment monitoring
\timing on

-- =============================================================================
-- STEP 1: Create Core Schema (Tables, Enums, Indexes, Triggers)
-- =============================================================================
\echo ''
\echo '--- STEP 1: Deploying Core Schema ---'
\echo 'Creating tables, enums, indexes, and triggers...'

\i complete-schema.sql

\echo 'Core schema deployed successfully.'

-- =============================================================================
-- STEP 2: Create Reporting Views and Analytics
-- =============================================================================
\echo ''
\echo '--- STEP 2: Deploying Reporting Views ---'
\echo 'Creating views for statistics and analytics...'

\i reporting-views-schema.sql

\echo 'Reporting views deployed successfully.'

-- =============================================================================
-- STEP 3: Create Business Rules and Stored Procedures
-- =============================================================================
\echo ''
\echo '--- STEP 3: Deploying Business Rules and Procedures ---'
\echo 'Creating stored procedures and business logic functions...'

\i business-rules-schema.sql

\echo 'Business rules and procedures deployed successfully.'

-- =============================================================================
-- STEP 4: Verify Deployment
-- =============================================================================
\echo ''
\echo '--- STEP 4: Verifying Deployment ---'

-- Count tables
SELECT COUNT(*) as table_count FROM information_schema.tables 
WHERE table_schema = 'public' AND table_type = 'BASE TABLE';

-- Count views
SELECT COUNT(*) as view_count FROM information_schema.views 
WHERE table_schema = 'public';

-- Count functions
SELECT COUNT(*) as function_count FROM pg_proc p
JOIN pg_namespace n ON p.pronamespace = n.oid
WHERE n.nspname = 'public' AND p.prokind = 'f';

-- Count triggers
SELECT COUNT(*) as trigger_count FROM information_schema.triggers
WHERE trigger_schema = 'public';

\echo ''
\echo '=========================================================================='
\echo 'Deployment Summary:'
\echo '=========================================================================='
\echo 'Core Tables: 7 (members, books, book_authors, book_copies, borrow_history,'
\echo '             member_preferred_genres, member_borrowing_restrictions)'
\echo 'Views: 30+ (analytics, reports, operational views)'
\echo 'Functions: 25+ (business logic, validation, maintenance)'
\echo 'Triggers: 10+ (data integrity, automation)'
\echo 'Indexes: 25+ (performance optimization)'
\echo '=========================================================================='
\echo 'Deployment completed successfully!'
\echo 'The database is now ready for use.'
\echo '=========================================================================='

-- =============================================================================
-- OPTIONAL: Insert Sample Data for Testing
-- =============================================================================
\echo ''
\echo 'Would you like to insert sample data for testing? (Y/N)'
\echo 'If yes, run: \\i sample-data.sql'

\timing off
