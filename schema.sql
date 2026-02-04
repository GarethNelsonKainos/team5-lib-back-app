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
    member_id VARCHAR(20) PRIMARY KEY,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(20),
    street VARCHAR(200),
    city VARCHAR(100),
    state VARCHAR(100),
    zip_code VARCHAR(20),
    status membership_status NOT NULL DEFAULT 'Active',
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    current_borrow_count INTEGER DEFAULT 0 CHECK (current_borrow_count >= 0 AND current_borrow_count <= 3),
    has_overdue_books BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Books Table
CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(500) NOT NULL,
    isbn VARCHAR(17) UNIQUE NOT NULL,
    genre VARCHAR(100) NOT NULL,
    publication_year INTEGER CHECK (publication_year >= 1000 AND publication_year <= 2100),
    description TEXT,
    total_copies INTEGER DEFAULT 0 CHECK (total_copies >= 0),
    available_copies INTEGER DEFAULT 0 CHECK (available_copies >= 0),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_available_copies CHECK (available_copies <= total_copies)
);

-- Book Authors Table (Many-to-Many: One book can have multiple authors)
CREATE TABLE book_authors (
    author_id SERIAL PRIMARY KEY,
    book_id INTEGER NOT NULL,
    author_name VARCHAR(200) NOT NULL,
    author_order INTEGER DEFAULT 1,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_book FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE
);

-- Book Copies Table (One-to-Many: One book can have multiple physical copies)
CREATE TABLE book_copies (
    copy_id VARCHAR(50) PRIMARY KEY,
    book_id INTEGER NOT NULL,
    status copy_status NOT NULL DEFAULT 'Available',
    current_borrower_id VARCHAR(20),
    borrow_date DATE,
    due_date DATE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_book_copy FOREIGN KEY (book_id) REFERENCES books(book_id) ON DELETE CASCADE,
    CONSTRAINT fk_current_borrower FOREIGN KEY (current_borrower_id) REFERENCES members(member_id) ON DELETE SET NULL
);

-- Borrow History Table (Tracks all borrowing transactions)
CREATE TABLE borrow_history (
    borrow_id SERIAL PRIMARY KEY,
    copy_id VARCHAR(50) NOT NULL,
    member_id VARCHAR(20) NOT NULL,
    borrow_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    due_date DATE NOT NULL,
    return_date TIMESTAMP WITH TIME ZONE,
    is_overdue BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_borrowed_copy FOREIGN KEY (copy_id) REFERENCES book_copies(copy_id) ON DELETE CASCADE,
    CONSTRAINT fk_borrower FOREIGN KEY (member_id) REFERENCES members(member_id) ON DELETE CASCADE
);

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
CREATE INDEX idx_members_status ON members(status);

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

3. members (1) → book_copies (0..3)
   - One member can currently borrow 0-3 book copies
   - Foreign Key: book_copies.current_borrower_id → members.member_id
   - SET NULL on DELETE: Deleting a member clears the borrower reference

4. members (1) → borrow_history (many)
   - One member can have multiple borrowing transactions
   - Foreign Key: borrow_history.member_id → members.member_id
   - CASCADE DELETE: Deleting a member deletes their history

5. book_copies (1) → borrow_history (many)
   - One copy can have multiple borrowing records over time
   - Foreign Key: borrow_history.copy_id → book_copies.copy_id
   - CASCADE DELETE: Deleting a copy deletes its history

BUSINESS RULES:
- Maximum 3 books per member (enforced by current_borrow_count CHECK constraint)
- Unique ISBN per book
- Unique copy_id across all copies
- Unique member_id per member
- Available copies cannot exceed total copies
*/
