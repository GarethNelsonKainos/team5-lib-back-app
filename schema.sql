-- Library Management System - Core Database Schema
-- Tables, Relationships, and Data Types Only

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
    total_copies INTEGER,
    available_copies INTEGER,
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
    created_at TIMESTAMP,
    updated_at TIMESTAMP,
    CONSTRAINT fk_book_copy FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
);

-- Loans Table (All loans - active and returned)
CREATE TABLE loans (
    loan_id SERIAL PRIMARY KEY,
    copy_id INTEGER NOT NULL,
    member_id INTEGER NOT NULL,
    borrow_date TIMESTAMP,
    due_date DATE NOT NULL,
    return_date TIMESTAMP,
    created_at TIMESTAMP,
    CONSTRAINT fk_loan_copy FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE CASCADE,
    CONSTRAINT fk_loan_member FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

-- =============================================================================
-- INDEXES FOR PERFORMANCE
-- =============================================================================

-- Foreign key indexes (improve JOIN performance)
CREATE INDEX idx_book_authors_book_id ON book_authors(book_id);
CREATE INDEX idx_book_copies_book_id ON book_copies(book_id);
CREATE INDEX idx_loans_member_id ON loans(member_id);
CREATE INDEX idx_loans_copy_id ON loans(copy_id);
CREATE INDEX idx_books_title ON books(title);

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

3. members (1) → loans (0..3 active)
   - One member can have 0-3 active loans
   - Foreign Key: loans.member_id → members.member_id
   - CASCADE DELETE: Deleting a member deletes their loans

4. book_copies (1) → loans (many)
   - One copy can have multiple loan records (active and historical)
   - Foreign Key: loans.copy_id → book_copies.copy_id
   - CASCADE DELETE: Deleting a copy deletes its loan records

BUSINESS RULES:
- Maximum 3 books per member (enforced by current_borrow_count CHECK constraint)
- Unique ISBN per book
- Available copies cannot exceed total copies
- Loans table contains ALL loans (active and returned)
- Active loans: return_date IS NULL
- Returned loans: return_date IS NOT NULL
- Overdue calculated dynamically: due_date < NOW() AND return_date IS NULL
*/