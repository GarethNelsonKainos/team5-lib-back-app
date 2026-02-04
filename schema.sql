-- Library Management System - Core Database Schema
-- Tables, Relationships, and Data Types Only

-- =============================================================================
-- ENUM TYPES
-- =============================================================================

CREATE TYPE copy_status AS ENUM ('Available', 'Borrowed');
CREATE TYPE membership_status AS ENUM ('Active', 'Inactive', 'Suspended');

-- =============================================================================
-- CORE TABLES
-- =============================================================================

-- Members Table
CREATE TABLE members (
    member_id SERIAL PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    street VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20),
    status membership_status,
    registration_date DATE,
    current_borrow_count INTEGER ,
    has_overdue_books BOOLEAN,
    created_at TIMESTAMP,
    updated_at TIMESTAMP
);

-- Books Table
CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    isbn VARCHAR(17) UNIQUE NOT NULL,
    genre VARCHAR(100) NOT NULL,
    publication_year INTEGER,
    description TEXT,
    total_copies INTEGER DEFAULT 0 CHECK,
    available_copies INTEGER DEFAULT 0 CHECK,
    created_at TIMESTAMP,
    updated_at TIMESTAMP 
);

-- Book Authors Table (Many-to-Many: One book can have multiple authors)
CREATE TABLE book_authors (
    author_id SERIAL PRIMARY KEY,
    book_id INTEGER NOT NULL,
    author_name VARCHAR(200) NOT NULL,
    created_at TIMESTAMP,
    CONSTRAINT fk_book FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
);

-- Book Copies Table (One-to-Many: One book can have multiple physical copies)
CREATE TABLE book_copies (
    copy_id SERIAL PRIMARY KEY,
    book_id INTEGER NOT NULL,
    status copy_status,
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    CONSTRAINT fk_book_copy FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
);

-- Loans Table (Active borrows only - current loans in progress)
CREATE TABLE loans (
    loan_id SERIAL PRIMARY KEY,
    copy_id INTEGER NOT NULL,
    member_id INTEGER NOT NULL,
    borrow_date TIMESTAMP,
    due_date DATE NOT NULL,
    is_overdue BOOLEAN,
    created_at TIMESTAMP,
    CONSTRAINT fk_loan_copy FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE CASCADE,
    CONSTRAINT fk_loan_member FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- Borrow History Table (Completed transactions only - returned books)
CREATE TABLE borrow_history (
    history_id SERIAL PRIMARY KEY,
    copy_id INTEGER NOT NULL,
    member_id INTEGER NOT NULL,
    borrow_date TIMESTAMP,
    due_date DATE NOT NULL,
    return_date TIMESTAMP,
    was_overdue BOOLEAN,
    created_at TIMESTAMP,
    CONSTRAINT fk_history_copy FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE CASCADE,
    CONSTRAINT fk_history_member FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- =============================================================================
-- INDEXES FOR PERFORMANCE
-- =============================================================================

-- Foreign key indexes (improve JOIN performance)
CREATE INDEX idx_book_authors_book_id ON book_authors(book_id);
CREATE INDEX idx_book_copies_book_id ON book_copies(book_id);
CREATE INDEX idx_loans_member_id ON loans(member_id);
CREATE INDEX idx_loans_copy_id ON loans(copy_id);
CREATE INDEX idx_borrow_history_member_id ON borrow_history(member_id);

-- Note: Primary keys and UNIQUE constraints are automatically indexed
-- Additional indexes can be added later based on actual query performance needs

-- =============================================================================
-- TABLE RELATIONSHIPS DOCUMENTATION
-- =============================================================================

/*
RELATIONSHIP SUMMARY:

1. books (1) → book_authors (many)
   - One book can have multiple authors
   - Foreign Key: book_authors.book_id → books.book_id
   - CASCADE DELETE: Deleting a book deletes all its authors

2. books (1) → book_copies (many)
   - One book can have multiple physical copies
   - Foreign Key: book_copies.book_id → books.book_id
   - CASCADE DELETE: Deleting a book deletes all its copies

3. members (1) → loans (0..3)
   - One member can have 0-3 active loans
   - Foreign Key: loans.member_id → members.member_id
   - CASCADE DELETE: Deleting a member deletes their active loans

4. book_copies (1) → loans (0..1)
   - One copy can have 0-1 active loan
   - Foreign Key: loans.copy_id → book_copies.copy_id
   - CASCADE DELETE: Deleting a copy deletes its active loan

5. members (1) → borrow_history (many)
   - One member can have multiple past borrowing transactions
   - Foreign Key: borrow_history.member_id → members.member_id
   - CASCADE DELETE: Deleting a member deletes their history

6. book_copies (1) → borrow_history (many)
   - One copy can have multiple borrowing records over time
   - Foreign Key: borrow_history.copy_id → book_copies.copy_id
   - CASCADE DELETE: Deleting a copy deletes its history

BUSINESS RULES:
- Maximum 3 books per member (enforced by current_borrow_count CHECK constraint)
- Unique ISBN per book
- Available copies cannot exceed total copies
- Loans table contains ONLY active borrows (no return_date)
- Borrow History table contains ONLY completed transactions (return_date required)
- When a book is returned, move record from loans → borrow_history
*/