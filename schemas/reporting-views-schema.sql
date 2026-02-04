-- Library Management System - Reporting Views Schema
-- This file contains views and materialized views for statistics and reporting
-- Requirements: Section 2.4 - Statistics & Reporting from library.md

-- =============================================================================
-- POPULAR BOOKS ANALYTICS VIEWS
-- =============================================================================

-- Most borrowed books in the past week
CREATE OR REPLACE VIEW popular_books_weekly AS
SELECT 
    b.id as book_id,
    b.title,
    b.isbn,
    b.genre,
    ba.author_name,
    COUNT(bh.borrow_id) as borrow_count,
    COUNT(DISTINCT bh.member_id) as unique_borrowers,
    MIN(bh.borrow_date) as first_borrow_date,
    MAX(bh.borrow_date) as last_borrow_date
FROM books b
LEFT JOIN book_authors ba ON b.id = ba.book_id AND ba.author_order = 1
LEFT JOIN book_copies bc ON b.id = bc.book_id
LEFT JOIN borrow_history bh ON bc.copy_id = bh.copy_id
WHERE bh.borrow_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY b.id, b.title, b.isbn, b.genre, ba.author_name
ORDER BY borrow_count DESC, unique_borrowers DESC;

-- Most borrowed books in the past month
CREATE OR REPLACE VIEW popular_books_monthly AS
SELECT 
    b.id as book_id,
    b.title,
    b.isbn,
    b.genre,
    ba.author_name,
    COUNT(bh.borrow_id) as borrow_count,
    COUNT(DISTINCT bh.member_id) as unique_borrowers,
    MIN(bh.borrow_date) as first_borrow_date,
    MAX(bh.borrow_date) as last_borrow_date
FROM books b
LEFT JOIN book_authors ba ON b.id = ba.book_id AND ba.author_order = 1
LEFT JOIN book_copies bc ON b.id = bc.book_id
LEFT JOIN borrow_history bh ON bc.copy_id = bh.copy_id
WHERE bh.borrow_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY b.id, b.title, b.isbn, b.genre, ba.author_name
ORDER BY borrow_count DESC, unique_borrowers DESC;

-- Most borrowed books in the past year
CREATE OR REPLACE VIEW popular_books_annual AS
SELECT 
    b.id as book_id,
    b.title,
    b.isbn,
    b.genre,
    ba.author_name,
    COUNT(bh.borrow_id) as borrow_count,
    COUNT(DISTINCT bh.member_id) as unique_borrowers,
    MIN(bh.borrow_date) as first_borrow_date,
    MAX(bh.borrow_date) as last_borrow_date
FROM books b
LEFT JOIN book_authors ba ON b.id = ba.book_id AND ba.author_order = 1
LEFT JOIN book_copies bc ON b.id = bc.book_id
LEFT JOIN borrow_history bh ON bc.copy_id = bh.copy_id
WHERE bh.borrow_date >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY b.id, b.title, b.isbn, b.genre, ba.author_name
ORDER BY borrow_count DESC, unique_borrowers DESC;

-- All-time most borrowed books
CREATE OR REPLACE VIEW popular_books_all_time AS
SELECT 
    b.id as book_id,
    b.title,
    b.isbn,
    b.genre,
    ba.author_name,
    COUNT(bh.borrow_id) as borrow_count,
    COUNT(DISTINCT bh.member_id) as unique_borrowers,
    MIN(bh.borrow_date) as first_borrow_date,
    MAX(bh.borrow_date) as last_borrow_date
FROM books b
LEFT JOIN book_authors ba ON b.id = ba.book_id AND ba.author_order = 1
LEFT JOIN book_copies bc ON b.id = bc.book_id
LEFT JOIN borrow_history bh ON bc.copy_id = bh.copy_id
GROUP BY b.id, b.title, b.isbn, b.genre, ba.author_name
HAVING COUNT(bh.borrow_id) > 0
ORDER BY borrow_count DESC, unique_borrowers DESC;

-- =============================================================================
-- GENRE ANALYTICS VIEWS
-- =============================================================================

-- Genre popularity by time period
CREATE OR REPLACE VIEW genre_popularity_weekly AS
SELECT 
    b.genre,
    COUNT(bh.borrow_id) as borrow_count,
    COUNT(DISTINCT b.id) as unique_books_borrowed,
    COUNT(DISTINCT bh.member_id) as unique_borrowers,
    ROUND(AVG(EXTRACT(EPOCH FROM (bh.return_date - bh.borrow_date))/86400), 2) as avg_loan_duration_days
FROM books b
JOIN book_copies bc ON b.id = bc.book_id
JOIN borrow_history bh ON bc.copy_id = bh.copy_id
WHERE bh.borrow_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY b.genre
ORDER BY borrow_count DESC;

CREATE OR REPLACE VIEW genre_popularity_monthly AS
SELECT 
    b.genre,
    COUNT(bh.borrow_id) as borrow_count,
    COUNT(DISTINCT b.id) as unique_books_borrowed,
    COUNT(DISTINCT bh.member_id) as unique_borrowers,
    ROUND(AVG(EXTRACT(EPOCH FROM (bh.return_date - bh.borrow_date))/86400), 2) as avg_loan_duration_days
FROM books b
JOIN book_copies bc ON b.id = bc.book_id
JOIN borrow_history bh ON bc.copy_id = bh.copy_id
WHERE bh.borrow_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY b.genre
ORDER BY borrow_count DESC;

CREATE OR REPLACE VIEW genre_popularity_annual AS
SELECT 
    b.genre,
    COUNT(bh.borrow_id) as borrow_count,
    COUNT(DISTINCT b.id) as unique_books_borrowed,
    COUNT(DISTINCT bh.member_id) as unique_borrowers,
    ROUND(AVG(EXTRACT(EPOCH FROM (bh.return_date - bh.borrow_date))/86400), 2) as avg_loan_duration_days
FROM books b
JOIN book_copies bc ON b.id = bc.book_id
JOIN borrow_history bh ON bc.copy_id = bh.copy_id
WHERE bh.borrow_date >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY b.genre
ORDER BY borrow_count DESC;

-- =============================================================================
-- AUTHOR ANALYTICS VIEWS
-- =============================================================================

-- Most borrowed authors by time period
CREATE OR REPLACE VIEW author_popularity_weekly AS
SELECT 
    ba.author_name,
    COUNT(bh.borrow_id) as borrow_count,
    COUNT(DISTINCT b.id) as unique_books_borrowed,
    COUNT(DISTINCT bh.member_id) as unique_borrowers,
    STRING_AGG(DISTINCT b.genre, ', ') as genres
FROM book_authors ba
JOIN books b ON ba.book_id = b.id
JOIN book_copies bc ON b.id = bc.book_id
JOIN borrow_history bh ON bc.copy_id = bh.copy_id
WHERE bh.borrow_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY ba.author_name
ORDER BY borrow_count DESC;

CREATE OR REPLACE VIEW author_popularity_monthly AS
SELECT 
    ba.author_name,
    COUNT(bh.borrow_id) as borrow_count,
    COUNT(DISTINCT b.id) as unique_books_borrowed,
    COUNT(DISTINCT bh.member_id) as unique_borrowers,
    STRING_AGG(DISTINCT b.genre, ', ') as genres
FROM book_authors ba
JOIN books b ON ba.book_id = b.id
JOIN book_copies bc ON b.id = bc.book_id
JOIN borrow_history bh ON bc.copy_id = bh.copy_id
WHERE bh.borrow_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY ba.author_name
ORDER BY borrow_count DESC;

CREATE OR REPLACE VIEW author_popularity_annual AS
SELECT 
    ba.author_name,
    COUNT(bh.borrow_id) as borrow_count,
    COUNT(DISTINCT b.id) as unique_books_borrowed,
    COUNT(DISTINCT bh.member_id) as unique_borrowers,
    STRING_AGG(DISTINCT b.genre, ', ') as genres
FROM book_authors ba
JOIN books b ON ba.book_id = b.id
JOIN book_copies bc ON b.id = bc.book_id
JOIN borrow_history bh ON bc.copy_id = bh.copy_id
WHERE bh.borrow_date >= CURRENT_DATE - INTERVAL '1 year'
GROUP BY ba.author_name
ORDER BY borrow_count DESC;

-- =============================================================================
-- MEMBER ACTIVITY VIEWS
-- =============================================================================

-- Active members with recent borrowing activity
CREATE OR REPLACE VIEW active_members_summary AS
SELECT 
    m.member_id,
    m.full_name,
    m.membership_type,
    m.status,
    m.registration_date,
    COUNT(DISTINCT bh.borrow_id) as total_borrows,
    COUNT(DISTINCT CASE WHEN bh.borrow_date >= CURRENT_DATE - INTERVAL '30 days' THEN bh.borrow_id END) as recent_borrows_30d,
    COUNT(DISTINCT CASE WHEN bh.borrow_date >= CURRENT_DATE - INTERVAL '90 days' THEN bh.borrow_id END) as recent_borrows_90d,
    MAX(bh.borrow_date) as last_borrow_date,
    m.current_borrow_count,
    m.has_overdue_books
FROM members m
LEFT JOIN borrow_history bh ON m.member_id = bh.member_id
GROUP BY m.member_id, m.full_name, m.membership_type, m.status, 
         m.registration_date, m.current_borrow_count, m.has_overdue_books
ORDER BY recent_borrows_30d DESC, total_borrows DESC;

-- New member registrations by time period
CREATE OR REPLACE VIEW new_members_weekly AS
SELECT 
    member_id,
    full_name,
    email,
    membership_type,
    registration_date,
    status
FROM members
WHERE registration_date >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY registration_date DESC;

CREATE OR REPLACE VIEW new_members_monthly AS
SELECT 
    member_id,
    full_name,
    email,
    membership_type,
    registration_date,
    status
FROM members
WHERE registration_date >= CURRENT_DATE - INTERVAL '30 days'
ORDER BY registration_date DESC;

-- Member borrowing patterns by membership type
CREATE OR REPLACE VIEW member_borrowing_patterns AS
SELECT 
    m.membership_type,
    COUNT(DISTINCT m.member_id) as total_members,
    COUNT(DISTINCT CASE WHEN m.current_borrow_count > 0 THEN m.member_id END) as active_borrowers,
    SUM(m.total_books_borrowed) as total_borrows,
    ROUND(AVG(m.total_books_borrowed), 2) as avg_borrows_per_member,
    ROUND(AVG(m.current_borrow_count), 2) as avg_current_borrows,
    COUNT(DISTINCT CASE WHEN m.has_overdue_books THEN m.member_id END) as members_with_overdue
FROM members m
GROUP BY m.membership_type
ORDER BY total_borrows DESC;

-- =============================================================================
-- COLLECTION UTILIZATION VIEWS
-- =============================================================================

-- Books never borrowed
CREATE OR REPLACE VIEW never_borrowed_books AS
SELECT 
    b.id as book_id,
    b.title,
    b.isbn,
    b.genre,
    ba.author_name,
    b.publication_year,
    b.total_copies,
    b.created_at
FROM books b
LEFT JOIN book_authors ba ON b.id = ba.book_id AND ba.author_order = 1
LEFT JOIN book_copies bc ON b.id = bc.book_id
LEFT JOIN borrow_history bh ON bc.copy_id = bh.copy_id
WHERE bh.borrow_id IS NULL
ORDER BY b.created_at ASC;

-- High-demand titles (with copy utilization rate)
CREATE OR REPLACE VIEW high_demand_books AS
SELECT 
    b.id as book_id,
    b.title,
    b.isbn,
    b.genre,
    ba.author_name,
    b.total_copies,
    b.available_copies,
    COUNT(bh.borrow_id) as total_borrows,
    COUNT(DISTINCT CASE WHEN bh.borrow_date >= CURRENT_DATE - INTERVAL '30 days' THEN bh.borrow_id END) as borrows_last_30d,
    ROUND(COUNT(bh.borrow_id)::NUMERIC / NULLIF(b.total_copies, 0), 2) as borrows_per_copy,
    ROUND((b.total_copies - b.available_copies)::NUMERIC / NULLIF(b.total_copies, 0) * 100, 2) as utilization_rate
FROM books b
LEFT JOIN book_authors ba ON b.id = ba.book_id AND ba.author_order = 1
LEFT JOIN book_copies bc ON b.id = bc.book_id
LEFT JOIN borrow_history bh ON bc.copy_id = bh.copy_id
GROUP BY b.id, b.title, b.isbn, b.genre, ba.author_name, b.total_copies, b.available_copies
HAVING COUNT(bh.borrow_id) > 0
ORDER BY utilization_rate DESC, borrows_last_30d DESC;

-- Collection gaps - popular books needing more copies
CREATE OR REPLACE VIEW collection_gaps AS
SELECT 
    b.id as book_id,
    b.title,
    b.isbn,
    b.genre,
    ba.author_name,
    b.total_copies as current_copies,
    b.available_copies,
    COUNT(DISTINCT CASE WHEN bh.borrow_date >= CURRENT_DATE - INTERVAL '90 days' THEN bh.borrow_id END) as borrows_last_90d,
    COUNT(DISTINCT CASE WHEN bh.borrow_date >= CURRENT_DATE - INTERVAL '30 days' THEN bh.borrow_id END) as borrows_last_30d,
    ROUND(COUNT(DISTINCT CASE WHEN bh.borrow_date >= CURRENT_DATE - INTERVAL '90 days' THEN bh.borrow_id END)::NUMERIC / 90 * 30, 0) as projected_monthly_demand,
    CASE 
        WHEN b.total_copies = 0 THEN 0
        ELSE ROUND((b.total_copies - b.available_copies)::NUMERIC / NULLIF(b.total_copies, 0) * 100, 2)
    END as current_utilization_rate,
    CASE 
        WHEN b.total_copies < 2 AND COUNT(DISTINCT CASE WHEN bh.borrow_date >= CURRENT_DATE - INTERVAL '30 days' THEN bh.borrow_id END) >= 5 THEN 'High Priority'
        WHEN b.total_copies < 3 AND COUNT(DISTINCT CASE WHEN bh.borrow_date >= CURRENT_DATE - INTERVAL '30 days' THEN bh.borrow_id END) >= 10 THEN 'High Priority'
        WHEN COUNT(DISTINCT CASE WHEN bh.borrow_date >= CURRENT_DATE - INTERVAL '30 days' THEN bh.borrow_id END) >= 15 THEN 'Medium Priority'
        ELSE 'Low Priority'
    END as priority
FROM books b
LEFT JOIN book_authors ba ON b.id = ba.book_id AND ba.author_order = 1
LEFT JOIN book_copies bc ON b.id = bc.book_id
LEFT JOIN borrow_history bh ON bc.copy_id = bh.copy_id
GROUP BY b.id, b.title, b.isbn, b.genre, ba.author_name, b.total_copies, b.available_copies
HAVING COUNT(DISTINCT CASE WHEN bh.borrow_date >= CURRENT_DATE - INTERVAL '90 days' THEN bh.borrow_id END) > 0
ORDER BY 
    CASE priority
        WHEN 'High Priority' THEN 1
        WHEN 'Medium Priority' THEN 2
        ELSE 3
    END,
    borrows_last_30d DESC;

-- Copy efficiency - utilization rate per copy
CREATE OR REPLACE VIEW copy_efficiency AS
SELECT 
    bc.copy_id,
    b.title,
    b.isbn,
    b.genre,
    ba.author_name,
    bc.status,
    bc.condition,
    COUNT(bh.borrow_id) as total_borrows,
    COUNT(DISTINCT CASE WHEN bh.borrow_date >= CURRENT_DATE - INTERVAL '90 days' THEN bh.borrow_id END) as borrows_last_90d,
    MIN(bh.borrow_date) as first_borrow_date,
    MAX(bh.borrow_date) as last_borrow_date,
    CASE 
        WHEN bc.acquired_date IS NOT NULL THEN 
            ROUND(COUNT(bh.borrow_id)::NUMERIC / NULLIF(EXTRACT(EPOCH FROM (CURRENT_DATE - bc.acquired_date))/2592000, 0), 2)
        ELSE NULL
    END as borrows_per_month,
    CASE 
        WHEN COUNT(bh.borrow_id) = 0 THEN 'Never Borrowed'
        WHEN COUNT(DISTINCT CASE WHEN bh.borrow_date >= CURRENT_DATE - INTERVAL '90 days' THEN bh.borrow_id END) = 0 THEN 'Inactive'
        WHEN COUNT(DISTINCT CASE WHEN bh.borrow_date >= CURRENT_DATE - INTERVAL '90 days' THEN bh.borrow_id END) > 5 THEN 'High Usage'
        ELSE 'Normal Usage'
    END as usage_category
FROM book_copies bc
JOIN books b ON bc.book_id = b.id
LEFT JOIN book_authors ba ON b.id = ba.book_id AND ba.author_order = 1
LEFT JOIN borrow_history bh ON bc.copy_id = bh.copy_id
GROUP BY bc.copy_id, b.title, b.isbn, b.genre, ba.author_name, bc.status, bc.condition, bc.acquired_date
ORDER BY total_borrows DESC;

-- =============================================================================
-- BORROWING TRENDS VIEWS
-- =============================================================================

-- Borrowing trends by day of week
CREATE OR REPLACE VIEW borrowing_trends_by_day AS
SELECT 
    TO_CHAR(bh.borrow_date, 'Day') as day_of_week,
    EXTRACT(DOW FROM bh.borrow_date) as day_number,
    COUNT(bh.borrow_id) as borrow_count,
    COUNT(DISTINCT bh.member_id) as unique_members,
    COUNT(DISTINCT bc.book_id) as unique_books
FROM borrow_history bh
JOIN book_copies bc ON bh.copy_id = bc.copy_id
WHERE bh.borrow_date >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY TO_CHAR(bh.borrow_date, 'Day'), EXTRACT(DOW FROM bh.borrow_date)
ORDER BY day_number;

-- Borrowing trends by month
CREATE OR REPLACE VIEW borrowing_trends_by_month AS
SELECT 
    TO_CHAR(bh.borrow_date, 'YYYY-MM') as year_month,
    TO_CHAR(bh.borrow_date, 'Month YYYY') as month_name,
    COUNT(bh.borrow_id) as borrow_count,
    COUNT(DISTINCT bh.member_id) as unique_members,
    COUNT(DISTINCT bc.book_id) as unique_books,
    COUNT(DISTINCT CASE WHEN bh.return_date IS NOT NULL THEN bh.borrow_id END) as returned_count,
    COUNT(DISTINCT CASE WHEN bh.is_overdue THEN bh.borrow_id END) as overdue_count
FROM borrow_history bh
JOIN book_copies bc ON bh.copy_id = bc.copy_id
GROUP BY TO_CHAR(bh.borrow_date, 'YYYY-MM'), TO_CHAR(bh.borrow_date, 'Month YYYY')
ORDER BY year_month DESC;

-- Seasonal borrowing patterns
CREATE OR REPLACE VIEW seasonal_borrowing_patterns AS
SELECT 
    CASE 
        WHEN EXTRACT(MONTH FROM bh.borrow_date) IN (12, 1, 2) THEN 'Winter'
        WHEN EXTRACT(MONTH FROM bh.borrow_date) IN (3, 4, 5) THEN 'Spring'
        WHEN EXTRACT(MONTH FROM bh.borrow_date) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END as season,
    EXTRACT(YEAR FROM bh.borrow_date) as year,
    COUNT(bh.borrow_id) as borrow_count,
    COUNT(DISTINCT bh.member_id) as unique_members,
    COUNT(DISTINCT bc.book_id) as unique_books,
    STRING_AGG(DISTINCT b.genre, ', ' ORDER BY b.genre) as popular_genres
FROM borrow_history bh
JOIN book_copies bc ON bh.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.id
GROUP BY 
    CASE 
        WHEN EXTRACT(MONTH FROM bh.borrow_date) IN (12, 1, 2) THEN 'Winter'
        WHEN EXTRACT(MONTH FROM bh.borrow_date) IN (3, 4, 5) THEN 'Spring'
        WHEN EXTRACT(MONTH FROM bh.borrow_date) IN (6, 7, 8) THEN 'Summer'
        ELSE 'Fall'
    END,
    EXTRACT(YEAR FROM bh.borrow_date)
ORDER BY year DESC, 
    CASE season
        WHEN 'Spring' THEN 1
        WHEN 'Summer' THEN 2
        WHEN 'Fall' THEN 3
        WHEN 'Winter' THEN 4
    END;

-- =============================================================================
-- OPERATIONAL REPORTS VIEWS
-- =============================================================================

-- Overdue summary
CREATE OR REPLACE VIEW overdue_summary AS
SELECT 
    cb.member_id,
    m.full_name,
    m.email,
    m.phone,
    cb.copy_id,
    cb.book_title,
    cb.borrow_date,
    cb.due_date,
    cb.days_overdue,
    cb.renewal_count,
    m.current_borrow_count,
    CASE 
        WHEN cb.days_overdue > 30 THEN 'Critical'
        WHEN cb.days_overdue > 14 THEN 'High'
        WHEN cb.days_overdue > 7 THEN 'Medium'
        ELSE 'Low'
    END as priority
FROM current_borrows cb
JOIN members m ON cb.member_id = m.member_id
WHERE cb.is_overdue = TRUE
ORDER BY cb.days_overdue DESC;

-- Inventory status report
CREATE OR REPLACE VIEW inventory_status_report AS
SELECT 
    b.genre,
    COUNT(DISTINCT b.id) as unique_books,
    SUM(b.total_copies) as total_copies,
    SUM(b.available_copies) as available_copies,
    SUM(b.total_copies) - SUM(b.available_copies) as borrowed_copies,
    ROUND(SUM(b.available_copies)::NUMERIC / NULLIF(SUM(b.total_copies), 0) * 100, 2) as availability_rate,
    COUNT(DISTINCT CASE WHEN b.available_copies = 0 THEN b.id END) as fully_borrowed_books
FROM books b
GROUP BY b.genre
ORDER BY unique_books DESC;

-- Members at borrowing limit
CREATE OR REPLACE VIEW members_at_limit AS
SELECT 
    m.member_id,
    m.full_name,
    m.email,
    m.phone,
    m.membership_type,
    m.current_borrow_count,
    STRING_AGG(b.title, '; ' ORDER BY cb.due_date) as borrowed_books,
    MIN(cb.due_date) as earliest_due_date,
    MAX(cb.due_date) as latest_due_date,
    m.has_overdue_books
FROM members m
JOIN current_borrows cb ON m.member_id = cb.member_id
JOIN books b ON cb.book_id = b.id
WHERE m.current_borrow_count >= 3
GROUP BY m.member_id, m.full_name, m.email, m.phone, m.membership_type, 
         m.current_borrow_count, m.has_overdue_books
ORDER BY earliest_due_date ASC;

-- Member compliance report
CREATE OR REPLACE VIEW member_compliance_report AS
SELECT 
    m.membership_type,
    m.status,
    COUNT(DISTINCT m.member_id) as total_members,
    COUNT(DISTINCT CASE WHEN m.can_borrow THEN m.member_id END) as eligible_to_borrow,
    COUNT(DISTINCT CASE WHEN m.has_overdue_books THEN m.member_id END) as with_overdue_books,
    COUNT(DISTINCT CASE WHEN m.current_borrow_count >= 3 THEN m.member_id END) as at_borrow_limit,
    COUNT(DISTINCT CASE WHEN m.status = 'Suspended' THEN m.member_id END) as suspended_accounts,
    COUNT(DISTINCT CASE WHEN m.expiry_date < CURRENT_DATE THEN m.member_id END) as expired_memberships,
    ROUND(COUNT(DISTINCT CASE WHEN m.can_borrow THEN m.member_id END)::NUMERIC / NULLIF(COUNT(DISTINCT m.member_id), 0) * 100, 2) as compliance_rate
FROM members m
GROUP BY m.membership_type, m.status
ORDER BY total_members DESC;

-- =============================================================================
-- DASHBOARD SUMMARY VIEW
-- =============================================================================

-- Library dashboard summary (for quick overview)
CREATE OR REPLACE VIEW library_dashboard_summary AS
SELECT 
    (SELECT COUNT(*) FROM books) as total_books,
    (SELECT SUM(total_copies) FROM books) as total_copies,
    (SELECT SUM(available_copies) FROM books) as available_copies,
    (SELECT COUNT(*) FROM members WHERE status = 'Active') as active_members,
    (SELECT COUNT(*) FROM current_borrows) as current_borrows,
    (SELECT COUNT(*) FROM current_borrows WHERE is_overdue = TRUE) as overdue_items,
    (SELECT COUNT(*) FROM members WHERE current_borrow_count >= 3) as members_at_limit,
    (SELECT COUNT(*) FROM borrow_history WHERE borrow_date >= CURRENT_DATE - INTERVAL '7 days') as borrows_last_7_days,
    (SELECT COUNT(*) FROM borrow_history WHERE return_date >= CURRENT_DATE - INTERVAL '7 days') as returns_last_7_days,
    (SELECT COUNT(*) FROM members WHERE registration_date >= CURRENT_DATE - INTERVAL '30 days') as new_members_last_30_days;

-- =============================================================================
-- INDEXES FOR REPORTING PERFORMANCE
-- =============================================================================

-- Additional indexes to support reporting queries
CREATE INDEX IF NOT EXISTS idx_borrow_history_borrow_date_desc ON borrow_history(borrow_date DESC);
CREATE INDEX IF NOT EXISTS idx_borrow_history_return_date_not_null ON borrow_history(return_date) WHERE return_date IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_members_registration_date ON members(registration_date);
CREATE INDEX IF NOT EXISTS idx_books_genre_id ON books(genre, id);
CREATE INDEX IF NOT EXISTS idx_book_copies_acquired_date ON book_copies(acquired_date);

-- =============================================================================
-- REPORTING FUNCTIONS
-- =============================================================================

-- Function to get popular books for a custom date range
CREATE OR REPLACE FUNCTION get_popular_books_by_date_range(
    start_date DATE,
    end_date DATE,
    limit_count INTEGER DEFAULT 10
)
RETURNS TABLE (
    book_id INTEGER,
    title VARCHAR,
    isbn VARCHAR,
    genre VARCHAR,
    author_name VARCHAR,
    borrow_count BIGINT,
    unique_borrowers BIGINT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        b.id,
        b.title,
        b.isbn,
        b.genre,
        ba.author_name,
        COUNT(bh.borrow_id) as borrow_count,
        COUNT(DISTINCT bh.member_id) as unique_borrowers
    FROM books b
    LEFT JOIN book_authors ba ON b.id = ba.book_id AND ba.author_order = 1
    LEFT JOIN book_copies bc ON b.id = bc.book_id
    LEFT JOIN borrow_history bh ON bc.copy_id = bh.copy_id
    WHERE bh.borrow_date BETWEEN start_date AND end_date
    GROUP BY b.id, b.title, b.isbn, b.genre, ba.author_name
    ORDER BY borrow_count DESC, unique_borrowers DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get member borrowing statistics
CREATE OR REPLACE FUNCTION get_member_statistics(p_member_id VARCHAR)
RETURNS TABLE (
    member_id VARCHAR,
    full_name VARCHAR,
    membership_type membership_type,
    total_borrows BIGINT,
    current_borrows INTEGER,
    overdue_books INTEGER,
    total_genres_borrowed BIGINT,
    favorite_genre VARCHAR,
    avg_loan_duration NUMERIC,
    on_time_return_rate NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        m.member_id,
        m.full_name,
        m.membership_type,
        COUNT(bh.borrow_id) as total_borrows,
        m.current_borrow_count,
        COUNT(DISTINCT CASE WHEN cb.is_overdue THEN cb.borrow_id END)::INTEGER as overdue_books,
        COUNT(DISTINCT b.genre) as total_genres_borrowed,
        (
            SELECT b2.genre
            FROM borrow_history bh2
            JOIN book_copies bc2 ON bh2.copy_id = bc2.copy_id
            JOIN books b2 ON bc2.book_id = b2.id
            WHERE bh2.member_id = m.member_id
            GROUP BY b2.genre
            ORDER BY COUNT(*) DESC
            LIMIT 1
        ) as favorite_genre,
        ROUND(AVG(EXTRACT(EPOCH FROM (bh.return_date - bh.borrow_date))/86400), 2) as avg_loan_duration,
        ROUND(
            COUNT(CASE WHEN bh.return_date IS NOT NULL AND bh.return_date <= bh.due_date THEN 1 END)::NUMERIC / 
            NULLIF(COUNT(CASE WHEN bh.return_date IS NOT NULL THEN 1 END), 0) * 100, 
            2
        ) as on_time_return_rate
    FROM members m
    LEFT JOIN borrow_history bh ON m.member_id = bh.member_id
    LEFT JOIN book_copies bc ON bh.copy_id = bc.copy_id
    LEFT JOIN books b ON bc.book_id = b.id
    LEFT JOIN current_borrows cb ON m.member_id = cb.member_id
    WHERE m.member_id = p_member_id
    GROUP BY m.member_id, m.full_name, m.membership_type, m.current_borrow_count;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- COMMENTS AND DOCUMENTATION
-- =============================================================================

COMMENT ON VIEW popular_books_weekly IS 'Most borrowed books in the past 7 days';
COMMENT ON VIEW popular_books_monthly IS 'Most borrowed books in the past 30 days';
COMMENT ON VIEW popular_books_annual IS 'Most borrowed books in the past year';
COMMENT ON VIEW genre_popularity_weekly IS 'Genre borrowing statistics for the past week';
COMMENT ON VIEW author_popularity_weekly IS 'Author borrowing statistics for the past week';
COMMENT ON VIEW active_members_summary IS 'Summary of active members with borrowing activity';
COMMENT ON VIEW never_borrowed_books IS 'Books that have never been borrowed';
COMMENT ON VIEW high_demand_books IS 'Books with high utilization rates';
COMMENT ON VIEW collection_gaps IS 'Popular books that may need additional copies';
COMMENT ON VIEW overdue_summary IS 'Current overdue books with member contact information';
COMMENT ON VIEW library_dashboard_summary IS 'Quick statistics for the library dashboard';
COMMENT ON FUNCTION get_popular_books_by_date_range IS 'Get most popular books within a custom date range';
COMMENT ON FUNCTION get_member_statistics IS 'Get detailed borrowing statistics for a specific member';
