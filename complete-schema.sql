-- Combined Library Management System Schema
-- This file creates the complete database schema with proper relationships

-- Enable UUID extension (if needed for any future UUID fields)
-- CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =============================================================================
-- ENUM TYPES
-- =============================================================================

-- Book-related enums
CREATE TYPE copy_status AS ENUM ('Available', 'Borrowed', 'Damaged', 'Lost', 'Reserved');
CREATE TYPE copy_condition AS ENUM ('New', 'Good', 'Fair', 'Poor');

-- Member-related enums  
CREATE TYPE membership_type AS ENUM ('Regular', 'Student', 'Senior', 'Faculty', 'Staff');
CREATE TYPE membership_status AS ENUM ('Active', 'Inactive', 'Suspended', 'Expired');
CREATE TYPE gender_type AS ENUM ('Male', 'Female', 'Other', 'Prefer not to say');

-- =============================================================================
-- CORE TABLES
-- =============================================================================

-- Members table (should be created first due to foreign key dependencies)
CREATE TABLE members (
    member_id VARCHAR(20) PRIMARY KEY,
    -- Personal Information
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL, 
    full_name VARCHAR(200) NOT NULL,
    date_of_birth DATE,
    gender gender_type,
    
    -- Contact Information
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    alternate_phone VARCHAR(20),
    
    -- Address Information
    street VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20),
    country VARCHAR(100),
    
    -- Membership Information
    membership_type membership_type NOT NULL,
    status membership_status NOT NULL DEFAULT 'Active',
    registration_date DATE NOT NULL,
    expiry_date DATE,
    last_renewal_date DATE,
    
    -- Borrowing Information (maintained by triggers)
    current_borrow_count INTEGER DEFAULT 0 CHECK (current_borrow_count >= 0 AND current_borrow_count <= 3),
    has_overdue_books BOOLEAN DEFAULT FALSE,
    total_books_borrowed INTEGER DEFAULT 0 CHECK (total_books_borrowed >= 0),
    can_borrow BOOLEAN DEFAULT TRUE,
    
    -- Preferences
    email_reminders BOOLEAN DEFAULT TRUE,
    overdue_notifications BOOLEAN DEFAULT TRUE,
    new_book_alerts BOOLEAN DEFAULT FALSE,
    
    -- System Fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    
    CONSTRAINT chk_member_id_format CHECK (member_id ~ '^[A-Z0-9]{6,12}$')
);

-- Books table
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    isbn VARCHAR(17) UNIQUE NOT NULL,
    genre VARCHAR(100) NOT NULL,
    publication_year INTEGER CHECK (publication_year >= 1000 AND publication_year <= 2100),
    description TEXT,
    publisher VARCHAR(200),
    page_count INTEGER CHECK (page_count > 0),
    language VARCHAR(50),
    total_copies INTEGER DEFAULT 0 CHECK (total_copies >= 0),
    available_copies INTEGER DEFAULT 0 CHECK (available_copies >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_available_copies CHECK (available_copies <= total_copies)
);

-- Book Authors table (Many-to-many: One book can have multiple authors)
CREATE TABLE book_authors (
    id SERIAL PRIMARY KEY,
    book_id INTEGER NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    author_name VARCHAR(200) NOT NULL,
    author_order INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Book Copies table (One-to-many: One book can have multiple physical copies)
CREATE TABLE book_copies (
    copy_id VARCHAR(50) PRIMARY KEY,
    book_id INTEGER NOT NULL REFERENCES books(id) ON DELETE CASCADE,
    status copy_status NOT NULL DEFAULT 'Available',
    condition copy_condition NOT NULL DEFAULT 'Good',
    location VARCHAR(50),
    current_borrower_id VARCHAR(20),
    borrow_date DATE,
    due_date DATE,
    acquired_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    -- Foreign key relationships
    CONSTRAINT fk_current_borrower FOREIGN KEY (current_borrower_id) REFERENCES members(member_id) ON DELETE SET NULL
);

-- Borrowing History table (Tracks all borrowing transactions)
CREATE TABLE borrow_history (
    borrow_id SERIAL PRIMARY KEY,
    copy_id VARCHAR(50) NOT NULL,
    member_id VARCHAR(20) NOT NULL,
    borrow_date TIMESTAMP WITH TIME ZONE NOT NULL,
    due_date DATE NOT NULL,
    return_date TIMESTAMP WITH TIME ZONE,
    is_overdue BOOLEAN DEFAULT FALSE,
    renewal_count INTEGER DEFAULT 0 CHECK (renewal_count >= 0),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    -- Foreign key relationships
    CONSTRAINT fk_borrower FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE,
    CONSTRAINT fk_borrowed_copy FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE CASCADE
);

-- =============================================================================
-- MEMBER RELATED TABLES
-- =============================================================================

-- Member Preferred Genres table (One-to-many: One member can have multiple preferred genres)
CREATE TABLE member_preferred_genres (
    id SERIAL PRIMARY KEY,
    member_id VARCHAR(20) NOT NULL REFERENCES members(member_id) ON DELETE CASCADE,
    genre VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Member Borrowing Restrictions table (One-to-many: One member can have multiple active restrictions)
CREATE TABLE member_borrowing_restrictions (
    id SERIAL PRIMARY KEY,
    member_id VARCHAR(20) NOT NULL REFERENCES members(member_id) ON DELETE CASCADE,
    restriction_type VARCHAR(50) NOT NULL CHECK (
        restriction_type IN ('Overdue Items', 'Maximum Limit Reached', 'Suspended Account', 'Expired Membership')
    ),
    restriction_date DATE NOT NULL DEFAULT CURRENT_DATE,
    notes TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- =============================================================================
-- VIEWS
-- =============================================================================

-- Current Borrows view (shows all currently active loans)
CREATE VIEW current_borrows AS
SELECT 
    bh.borrow_id,
    bh.member_id,
    bh.copy_id,
    bc.book_id,
    b.title as book_title,
    bh.borrow_date,
    bh.due_date,
    CASE 
        WHEN bh.due_date < CURRENT_DATE THEN TRUE 
        ELSE FALSE 
    END as is_overdue,
    CASE 
        WHEN bh.due_date < CURRENT_DATE THEN (CURRENT_DATE - bh.due_date) 
        ELSE 0 
    END as days_overdue,
    bh.renewal_count,
    CASE 
        WHEN bh.renewal_count < 2 AND bh.due_date >= CURRENT_DATE THEN TRUE 
        ELSE FALSE 
    END as can_renew
FROM borrow_history bh
JOIN book_copies bc ON bh.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.id
WHERE bh.return_date IS NULL;

-- Popular Books Analytics view (weekly borrowing statistics)
CREATE VIEW popular_books_weekly AS
SELECT 
    b.id as book_id,
    b.title,
    b.genre,
    ba.author_name,
    COUNT(bh.borrow_id) as borrow_count,
    COUNT(DISTINCT bh.member_id) as unique_borrowers,
    DATE_TRUNC('week', bh.borrow_date) as week_start
FROM books b
LEFT JOIN book_authors ba ON b.id = ba.book_id AND ba.author_order = 1
LEFT JOIN book_copies bc ON b.id = bc.book_id
LEFT JOIN borrow_history bh ON bc.copy_id = bh.copy_id
WHERE bh.borrow_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY b.id, b.title, b.genre, ba.author_name, DATE_TRUNC('week', bh.borrow_date)
ORDER BY borrow_count DESC;

-- Popular Books Analytics view (monthly borrowing statistics)
CREATE VIEW popular_books_monthly AS
SELECT 
    b.id as book_id,
    b.title,
    b.genre,
    ba.author_name,
    COUNT(bh.borrow_id) as borrow_count,
    COUNT(DISTINCT bh.member_id) as unique_borrowers,
    EXTRACT(YEAR FROM bh.borrow_date) as year,
    EXTRACT(MONTH FROM bh.borrow_date) as month
FROM books b
LEFT JOIN book_authors ba ON b.id = ba.book_id AND ba.author_order = 1
LEFT JOIN book_copies bc ON b.id = bc.book_id
LEFT JOIN borrow_history bh ON bc.copy_id = bh.copy_id
WHERE bh.borrow_date >= DATE_TRUNC('month', CURRENT_DATE)
GROUP BY b.id, b.title, b.genre, ba.author_name, EXTRACT(YEAR FROM bh.borrow_date), EXTRACT(MONTH FROM bh.borrow_date)
ORDER BY borrow_count DESC;

-- Popular Books Analytics view (annual borrowing statistics)
CREATE VIEW popular_books_annual AS
SELECT 
    b.id as book_id,
    b.title,
    b.genre,
    ba.author_name,
    COUNT(bh.borrow_id) as borrow_count,
    COUNT(DISTINCT bh.member_id) as unique_borrowers,
    EXTRACT(YEAR FROM bh.borrow_date) as year
FROM books b
LEFT JOIN book_authors ba ON b.id = ba.book_id AND ba.author_order = 1
LEFT JOIN book_copies bc ON b.id = bc.book_id
LEFT JOIN borrow_history bh ON bc.copy_id = bh.copy_id
WHERE bh.borrow_date >= DATE_TRUNC('year', CURRENT_DATE)
GROUP BY b.id, b.title, b.genre, ba.author_name, EXTRACT(YEAR FROM bh.borrow_date)
ORDER BY borrow_count DESC;

-- Genre Analytics view (most popular genres by time period)
CREATE VIEW popular_genres AS
SELECT 
    b.genre,
    COUNT(bh.borrow_id) as total_borrows,
    COUNT(DISTINCT bh.member_id) as unique_borrowers,
    COUNT(DISTINCT b.id) as unique_books,
    DATE_TRUNC('month', bh.borrow_date) as period
FROM books b
JOIN book_copies bc ON b.id = bc.book_id
JOIN borrow_history bh ON bc.copy_id = bh.copy_id
GROUP BY b.genre, DATE_TRUNC('month', bh.borrow_date)
ORDER BY total_borrows DESC;

-- Author Analytics view (most borrowed authors)
CREATE VIEW popular_authors AS
SELECT 
    ba.author_name,
    COUNT(bh.borrow_id) as total_borrows,
    COUNT(DISTINCT bh.member_id) as unique_borrowers,
    COUNT(DISTINCT b.id) as books_count,
    DATE_TRUNC('month', bh.borrow_date) as period
FROM book_authors ba
JOIN books b ON ba.book_id = b.id
JOIN book_copies bc ON b.id = bc.book_id
JOIN borrow_history bh ON bc.copy_id = bh.copy_id
GROUP BY ba.author_name, DATE_TRUNC('month', bh.borrow_date)
ORDER BY total_borrows DESC;

-- Library Usage Statistics view
CREATE VIEW library_usage_stats AS
SELECT 
    COUNT(DISTINCT m.member_id) as total_members,
    COUNT(DISTINCT CASE WHEN m.status = 'Active' THEN m.member_id END) as active_members,
    COUNT(DISTINCT CASE WHEN m.registration_date >= CURRENT_DATE - INTERVAL '30 days' THEN m.member_id END) as new_members_this_month,
    COUNT(DISTINCT cb.member_id) as members_with_active_borrows,
    COUNT(DISTINCT b.id) as total_books,
    COUNT(DISTINCT bc.copy_id) as total_copies,
    COUNT(DISTINCT CASE WHEN bc.status = 'Available' THEN bc.copy_id END) as available_copies,
    COUNT(DISTINCT CASE WHEN bc.status = 'Borrowed' THEN bc.copy_id END) as borrowed_copies,
    COUNT(DISTINCT cb.borrow_id) as current_active_borrows,
    COUNT(DISTINCT CASE WHEN cb.is_overdue THEN cb.borrow_id END) as overdue_borrows
FROM members m
CROSS JOIN books b
CROSS JOIN book_copies bc
LEFT JOIN current_borrows cb ON TRUE;

-- Operational Reports view (overdue summary)
CREATE VIEW overdue_summary AS
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
    cb.renewal_count
FROM current_borrows cb
JOIN members m ON cb.member_id = m.member_id
WHERE cb.is_overdue = TRUE
ORDER BY cb.days_overdue DESC;

-- Collection Utilization view (books never borrowed or high-demand)
CREATE VIEW collection_utilization AS
SELECT 
    b.id as book_id,
    b.title,
    b.genre,
    ba.author_name,
    b.total_copies,
    b.available_copies,
    COUNT(bh.borrow_id) as total_borrows,
    COUNT(DISTINCT bh.member_id) as unique_borrowers,
    MAX(bh.borrow_date) as last_borrowed_date,
    CASE 
        WHEN COUNT(bh.borrow_id) = 0 THEN 'Never Borrowed'
        WHEN COUNT(bh.borrow_id) > 50 THEN 'High Demand'
        WHEN COUNT(bh.borrow_id) > 20 THEN 'Medium Demand'
        ELSE 'Low Demand'
    END as demand_category,
    CASE 
        WHEN b.available_copies = 0 AND COUNT(bh.borrow_id) > 20 THEN TRUE
        ELSE FALSE
    END as needs_more_copies
FROM books b
LEFT JOIN book_authors ba ON b.id = ba.book_id AND ba.author_order = 1
LEFT JOIN book_copies bc ON b.id = bc.book_id
LEFT JOIN borrow_history bh ON bc.copy_id = bh.copy_id
GROUP BY b.id, b.title, b.genre, ba.author_name, b.total_copies, b.available_copies
ORDER BY total_borrows DESC;

-- =============================================================================
-- INDEXES FOR PERFORMANCE
-- =============================================================================

-- Books indexes
CREATE INDEX idx_books_title ON books(title);
CREATE INDEX idx_books_genre ON books(genre);
CREATE INDEX idx_books_isbn ON books(isbn);
CREATE INDEX idx_books_publication_year ON books(publication_year);

-- Book Authors indexes
CREATE INDEX idx_book_authors_book_id ON book_authors(book_id);
CREATE INDEX idx_book_authors_name ON book_authors(author_name);

-- Book Copies indexes
CREATE INDEX idx_book_copies_book_id ON book_copies(book_id);
CREATE INDEX idx_book_copies_status ON book_copies(status);
CREATE INDEX idx_book_copies_current_borrower ON book_copies(current_borrower_id);

-- Borrow History indexes
CREATE INDEX idx_borrow_history_copy_id ON borrow_history(copy_id);
CREATE INDEX idx_borrow_history_member_id ON borrow_history(member_id);
CREATE INDEX idx_borrow_history_borrow_date ON borrow_history(borrow_date);
CREATE INDEX idx_borrow_history_return_date ON borrow_history(return_date);

-- Members indexes
CREATE INDEX idx_members_email ON members(email);
CREATE INDEX idx_members_full_name ON members(full_name);
CREATE INDEX idx_members_status ON members(status);
CREATE INDEX idx_members_membership_type ON members(membership_type);
CREATE INDEX idx_members_can_borrow ON members(can_borrow);
CREATE INDEX idx_members_has_overdue ON members(has_overdue_books);

-- Member related tables indexes
CREATE INDEX idx_member_genres_member_id ON member_preferred_genres(member_id);
CREATE INDEX idx_member_genres_genre ON member_preferred_genres(genre);
CREATE INDEX idx_member_restrictions_member_id ON member_borrowing_restrictions(member_id);
CREATE INDEX idx_member_restrictions_active ON member_borrowing_restrictions(is_active);

-- =============================================================================
-- FUNCTIONS AND TRIGGERS
-- =============================================================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function to update book copy counts
CREATE OR REPLACE FUNCTION update_book_copy_counts()
RETURNS TRIGGER AS $$
BEGIN
    -- Update total_copies count
    UPDATE books 
    SET total_copies = (
        SELECT COUNT(*) 
        FROM book_copies 
        WHERE book_id = COALESCE(NEW.book_id, OLD.book_id)
    )
    WHERE id = COALESCE(NEW.book_id, OLD.book_id);
    
    -- Update available_copies count
    UPDATE books 
    SET available_copies = (
        SELECT COUNT(*) 
        FROM book_copies 
        WHERE book_id = COALESCE(NEW.book_id, OLD.book_id) 
        AND status = 'Available'
    )
    WHERE id = COALESCE(NEW.book_id, OLD.book_id);
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Function to update member borrowing status
CREATE OR REPLACE FUNCTION update_member_borrowing_status()
RETURNS TRIGGER AS $$
DECLARE
    target_member_id VARCHAR(20);
    overdue_count INTEGER;
BEGIN
    -- Get member ID from the affected record
    IF TG_OP = 'DELETE' THEN
        target_member_id := OLD.member_id;
    ELSE
        target_member_id := NEW.member_id;
    END IF;
    
    -- Update current borrow count
    UPDATE members 
    SET current_borrow_count = (
        SELECT COUNT(*)
        FROM current_borrows cb
        WHERE cb.member_id = target_member_id
    )
    WHERE member_id = target_member_id;
    
    -- Update overdue status
    SELECT COUNT(*) INTO overdue_count
    FROM current_borrows cb
    WHERE cb.member_id = target_member_id AND cb.is_overdue = TRUE;
    
    UPDATE members 
    SET has_overdue_books = (overdue_count > 0)
    WHERE member_id = target_member_id;
    
    -- Update borrowing eligibility
    UPDATE members 
    SET can_borrow = (
        status = 'Active' AND 
        current_borrow_count < 3 AND 
        has_overdue_books = FALSE AND
        (expiry_date IS NULL OR expiry_date >= CURRENT_DATE)
    )
    WHERE member_id = target_member_id;
    
    -- Update total books borrowed count
    UPDATE members 
    SET total_books_borrowed = (
        SELECT COUNT(*)
        FROM borrow_history bh
        WHERE bh.member_id = target_member_id
    )
    WHERE member_id = target_member_id;
    
    RETURN COALESCE(NEW, OLD);
END;
$$ LANGUAGE plpgsql;

-- Function to automatically manage borrowing restrictions
CREATE OR REPLACE FUNCTION manage_borrowing_restrictions()
RETURNS TRIGGER AS $$
BEGIN
    -- Clear existing restrictions for this member
    UPDATE member_borrowing_restrictions 
    SET is_active = FALSE 
    WHERE member_id = NEW.member_id;
    
    -- Add new restrictions based on current status
    IF NEW.has_overdue_books THEN
        INSERT INTO member_borrowing_restrictions (member_id, restriction_type, notes)
        VALUES (NEW.member_id, 'Overdue Items', 'Member has overdue books');
    END IF;
    
    IF NEW.current_borrow_count >= 3 THEN
        INSERT INTO member_borrowing_restrictions (member_id, restriction_type, notes)
        VALUES (NEW.member_id, 'Maximum Limit Reached', 'Member has reached maximum borrowing limit');
    END IF;
    
    IF NEW.status = 'Suspended' THEN
        INSERT INTO member_borrowing_restrictions (member_id, restriction_type, notes)
        VALUES (NEW.member_id, 'Suspended Account', 'Member account is suspended');
    END IF;
    
    IF NEW.expiry_date IS NOT NULL AND NEW.expiry_date < CURRENT_DATE THEN
        INSERT INTO member_borrowing_restrictions (member_id, restriction_type, notes)
        VALUES (NEW.member_id, 'Expired Membership', 'Member membership has expired');
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- TRIGGER ASSIGNMENTS
-- =============================================================================

-- Triggers for updating updated_at timestamps
CREATE TRIGGER trigger_books_updated_at
    BEFORE UPDATE ON books
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER trigger_members_updated_at
    BEFORE UPDATE ON members
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Triggers for maintaining book copy counts
CREATE TRIGGER trigger_update_book_copy_counts
    AFTER INSERT OR UPDATE OR DELETE ON book_copies
    FOR EACH ROW EXECUTE FUNCTION update_book_copy_counts();

-- Triggers for maintaining member borrowing status
CREATE TRIGGER trigger_update_member_status_on_borrow
    AFTER INSERT OR UPDATE OR DELETE ON borrow_history
    FOR EACH ROW EXECUTE FUNCTION update_member_borrowing_status();

CREATE TRIGGER trigger_manage_borrowing_restrictions
    AFTER UPDATE ON members
    FOR EACH ROW EXECUTE FUNCTION manage_borrowing_restrictions();

-- =============================================================================
-- RELATIONSHIP DOCUMENTATION
-- =============================================================================

/*
TABLE RELATIONSHIPS SUMMARY:

PRIMARY ENTITIES:
- books (id SERIAL PK)
- members (member_id VARCHAR PK)
- book_copies (copy_id VARCHAR PK)

RELATIONSHIP MAPPINGS:

books (1) -> book_authors (many)
  books.id <- book_authors.book_id

books (1) -> book_copies (many) 
  books.id <- book_copies.book_id

members (1) -> book_copies (0..3) [current borrows only]
  members.member_id <- book_copies.current_borrower_id

members (1) -> borrow_history (many) [complete history]
  members.member_id <- borrow_history.member_id

book_copies (1) -> borrow_history (many) [copy history]
  book_copies.copy_id <- borrow_history.copy_id

members (1) -> member_preferred_genres (many)
  members.member_id <- member_preferred_genres.member_id

members (1) -> member_borrowing_restrictions (many)
  members.member_id <- member_borrowing_restrictions.member_id

BUSINESS RULES ENFORCED:
- Maximum 3 current borrows per member
- Unique ISBN per book
- Unique copy_id across all copies
- Unique member_id per member
- Cascade deletes maintain referential integrity
- Triggers maintain derived fields (counts, availability, etc.)
*/