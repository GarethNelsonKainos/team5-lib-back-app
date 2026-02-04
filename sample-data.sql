-- Library Management System - Sample Data Script
-- This script inserts sample data for testing and demonstration purposes

\echo 'Inserting sample data for testing...'

-- =============================================================================
-- SAMPLE MEMBERS
-- =============================================================================

INSERT INTO members (member_id, first_name, last_name, full_name, email, phone, street, city, state, zip_code, country, membership_type, status, registration_date, expiry_date, date_of_birth, gender) VALUES
('MEM001', 'John', 'Smith', 'John Smith', 'john.smith@email.com', '555-0101', '123 Main St', 'Springfield', 'IL', '62701', 'USA', 'Regular', 'Active', '2025-01-15', '2026-01-15', '1985-03-20', 'Male'),
('MEM002', 'Sarah', 'Johnson', 'Sarah Johnson', 'sarah.j@email.com', '555-0102', '456 Oak Ave', 'Springfield', 'IL', '62702', 'USA', 'Student', 'Active', '2025-02-01', '2026-02-01', '2000-07-15', 'Female'),
('MEM003', 'Michael', 'Brown', 'Michael Brown', 'mbrown@email.com', '555-0103', '789 Elm St', 'Springfield', 'IL', '62703', 'USA', 'Regular', 'Active', '2024-11-20', '2025-11-20', '1978-11-30', 'Male'),
('MEM004', 'Emily', 'Davis', 'Emily Davis', 'emily.davis@email.com', '555-0104', '321 Pine Rd', 'Springfield', 'IL', '62704', 'USA', 'Faculty', 'Active', '2025-01-10', '2026-01-10', '1982-05-25', 'Female'),
('MEM005', 'Robert', 'Wilson', 'Robert Wilson', 'rwilson@email.com', '555-0105', '654 Maple Dr', 'Springfield', 'IL', '62705', 'USA', 'Senior', 'Active', '2024-12-05', '2025-12-05', '1955-09-10', 'Male');

-- =============================================================================
-- SAMPLE BOOKS
-- =============================================================================

INSERT INTO books (title, isbn, genre, publication_year, description, publisher, page_count, language) VALUES
('To Kill a Mockingbird', '978-0-06-112008-4', 'Fiction', 1960, 'A classic novel about racial injustice in the American South', 'Harper Perennial', 324, 'English'),
('1984', '978-0-452-28423-4', 'Science Fiction', 1949, 'Dystopian social science fiction novel', 'Signet Classic', 328, 'English'),
('Pride and Prejudice', '978-0-14-143951-8', 'Romance', 1813, 'A romantic novel of manners', 'Penguin Classics', 432, 'English'),
('The Great Gatsby', '978-0-7432-7356-5', 'Fiction', 1925, 'A novel about the American dream', 'Scribner', 180, 'English'),
('The Hobbit', '978-0-547-92822-7', 'Fantasy', 1937, 'A fantasy adventure novel', 'Mariner Books', 310, 'English'),
('Harry Potter and the Sorcerer''s Stone', '978-0-590-35340-3', 'Fantasy', 1997, 'First book in the Harry Potter series', 'Scholastic', 309, 'English'),
('The Catcher in the Rye', '978-0-316-76948-0', 'Fiction', 1951, 'Coming-of-age novel', 'Little, Brown and Company', 234, 'English'),
('Introduction to Algorithms', '978-0-262-03384-8', 'Computer Science', 2009, 'Comprehensive textbook on algorithms', 'MIT Press', 1312, 'English'),
('Clean Code', '978-0-13-235088-4', 'Computer Science', 2008, 'A handbook of agile software craftsmanship', 'Prentice Hall', 464, 'English'),
('The Lord of the Rings', '978-0-544-00341-5', 'Fantasy', 1954, 'Epic high-fantasy novel', 'Mariner Books', 1216, 'English');

-- =============================================================================
-- SAMPLE BOOK AUTHORS
-- =============================================================================

INSERT INTO book_authors (book_id, author_name, author_order) VALUES
(1, 'Harper Lee', 1),
(2, 'George Orwell', 1),
(3, 'Jane Austen', 1),
(4, 'F. Scott Fitzgerald', 1),
(5, 'J.R.R. Tolkien', 1),
(6, 'J.K. Rowling', 1),
(7, 'J.D. Salinger', 1),
(8, 'Thomas H. Cormen', 1),
(8, 'Charles E. Leiserson', 2),
(8, 'Ronald L. Rivest', 3),
(8, 'Clifford Stein', 4),
(9, 'Robert C. Martin', 1),
(10, 'J.R.R. Tolkien', 1);

-- =============================================================================
-- SAMPLE BOOK COPIES
-- =============================================================================

INSERT INTO book_copies (copy_id, book_id, status, condition, location, acquired_date) VALUES
-- To Kill a Mockingbird (2 copies)
('978-0-06-112008-4-00001', 1, 'Available', 'Good', 'A-101', '2024-01-15'),
('978-0-06-112008-4-00002', 1, 'Available', 'New', 'A-101', '2025-01-10'),

-- 1984 (3 copies)
('978-0-452-28423-4-00001', 2, 'Available', 'Good', 'A-102', '2024-02-20'),
('978-0-452-28423-4-00002', 2, 'Available', 'Fair', 'A-102', '2024-02-20'),
('978-0-452-28423-4-00003', 2, 'Available', 'Good', 'A-102', '2024-11-15'),

-- Pride and Prejudice (2 copies)
('978-0-14-143951-8-00001', 3, 'Available', 'Good', 'A-103', '2024-03-10'),
('978-0-14-143951-8-00002', 3, 'Available', 'Good', 'A-103', '2024-08-22'),

-- The Great Gatsby (2 copies)
('978-0-7432-7356-5-00001', 4, 'Available', 'New', 'A-104', '2025-01-05'),
('978-0-7432-7356-5-00002', 4, 'Available', 'Good', 'A-104', '2024-06-18'),

-- The Hobbit (3 copies)
('978-0-547-92822-7-00001', 5, 'Available', 'Good', 'B-201', '2024-04-12'),
('978-0-547-92822-7-00002', 5, 'Available', 'Fair', 'B-201', '2024-04-12'),
('978-0-547-92822-7-00003', 5, 'Available', 'New', 'B-201', '2025-01-20'),

-- Harry Potter (4 copies - popular book)
('978-0-590-35340-3-00001', 6, 'Available', 'Fair', 'B-202', '2024-01-08'),
('978-0-590-35340-3-00002', 6, 'Available', 'Good', 'B-202', '2024-05-15'),
('978-0-590-35340-3-00003', 6, 'Available', 'Good', 'B-202', '2024-09-10'),
('978-0-590-35340-3-00004', 6, 'Available', 'New', 'B-202', '2025-01-25'),

-- The Catcher in the Rye (2 copies)
('978-0-316-76948-0-00001', 7, 'Available', 'Good', 'A-105', '2024-07-20'),
('978-0-316-76948-0-00002', 7, 'Available', 'Good', 'A-105', '2024-12-05'),

-- Introduction to Algorithms (2 copies)
('978-0-262-03384-8-00001', 8, 'Available', 'New', 'C-301', '2025-01-15'),
('978-0-262-03384-8-00002', 8, 'Available', 'Good', 'C-301', '2024-09-01'),

-- Clean Code (3 copies)
('978-0-13-235088-4-00001', 9, 'Available', 'Good', 'C-302', '2024-10-10'),
('978-0-13-235088-4-00002', 9, 'Available', 'New', 'C-302', '2025-01-18'),
('978-0-13-235088-4-00003', 9, 'Available', 'Good', 'C-302', '2024-11-22'),

-- The Lord of the Rings (2 copies)
('978-0-544-00341-5-00001', 10, 'Available', 'Good', 'B-203', '2024-05-05'),
('978-0-544-00341-5-00002', 10, 'Available', 'Fair', 'B-203', '2024-05-05');

-- =============================================================================
-- SAMPLE BORROWING HISTORY
-- =============================================================================

-- Some recent borrows (last 30 days)
INSERT INTO borrow_history (copy_id, member_id, borrow_date, due_date, return_date, is_overdue) VALUES
('978-0-06-112008-4-00001', 'MEM001', CURRENT_TIMESTAMP - INTERVAL '25 days', CURRENT_DATE - INTERVAL '11 days', CURRENT_TIMESTAMP - INTERVAL '10 days', FALSE),
('978-0-452-28423-4-00001', 'MEM002', CURRENT_TIMESTAMP - INTERVAL '20 days', CURRENT_DATE - INTERVAL '6 days', CURRENT_TIMESTAMP - INTERVAL '5 days', FALSE),
('978-0-590-35340-3-00001', 'MEM003', CURRENT_TIMESTAMP - INTERVAL '15 days', CURRENT_DATE - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '2 days', FALSE),
('978-0-547-92822-7-00001', 'MEM004', CURRENT_TIMESTAMP - INTERVAL '10 days', CURRENT_DATE + INTERVAL '4 days', NULL, FALSE),
('978-0-7432-7356-5-00001', 'MEM005', CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_DATE + INTERVAL '9 days', NULL, FALSE);

-- Some older borrows (2-6 months ago)
INSERT INTO borrow_history (copy_id, member_id, borrow_date, due_date, return_date, is_overdue) VALUES
('978-0-452-28423-4-00002', 'MEM001', CURRENT_TIMESTAMP - INTERVAL '180 days', CURRENT_DATE - INTERVAL '166 days', CURRENT_TIMESTAMP - INTERVAL '165 days', FALSE),
('978-0-14-143951-8-00001', 'MEM002', CURRENT_TIMESTAMP - INTERVAL '150 days', CURRENT_DATE - INTERVAL '136 days', CURRENT_TIMESTAMP - INTERVAL '130 days', FALSE),
('978-0-590-35340-3-00002', 'MEM001', CURRENT_TIMESTAMP - INTERVAL '120 days', CURRENT_DATE - INTERVAL '106 days', CURRENT_TIMESTAMP - INTERVAL '105 days', FALSE),
('978-0-590-35340-3-00003', 'MEM003', CURRENT_TIMESTAMP - INTERVAL '90 days', CURRENT_DATE - INTERVAL '76 days', CURRENT_TIMESTAMP - INTERVAL '75 days', FALSE),
('978-0-13-235088-4-00001', 'MEM004', CURRENT_TIMESTAMP - INTERVAL '60 days', CURRENT_DATE - INTERVAL '46 days', CURRENT_TIMESTAMP - INTERVAL '45 days', FALSE);

-- Popular book (Harry Potter) - multiple borrows
INSERT INTO borrow_history (copy_id, member_id, borrow_date, due_date, return_date, is_overdue) VALUES
('978-0-590-35340-3-00001', 'MEM001', CURRENT_TIMESTAMP - INTERVAL '120 days', CURRENT_DATE - INTERVAL '106 days', CURRENT_TIMESTAMP - INTERVAL '100 days', FALSE),
('978-0-590-35340-3-00001', 'MEM002', CURRENT_TIMESTAMP - INTERVAL '95 days', CURRENT_DATE - INTERVAL '81 days', CURRENT_TIMESTAMP - INTERVAL '80 days', FALSE),
('978-0-590-35340-3-00001', 'MEM005', CURRENT_TIMESTAMP - INTERVAL '70 days', CURRENT_DATE - INTERVAL '56 days', CURRENT_TIMESTAMP - INTERVAL '55 days', FALSE),
('978-0-590-35340-3-00002', 'MEM003', CURRENT_TIMESTAMP - INTERVAL '110 days', CURRENT_DATE - INTERVAL '96 days', CURRENT_TIMESTAMP - INTERVAL '92 days', FALSE),
('978-0-590-35340-3-00002', 'MEM004', CURRENT_TIMESTAMP - INTERVAL '85 days', CURRENT_DATE - INTERVAL '71 days', CURRENT_TIMESTAMP - INTERVAL '70 days', FALSE);

-- =============================================================================
-- SAMPLE MEMBER PREFERENCES
-- =============================================================================

INSERT INTO member_preferred_genres (member_id, genre) VALUES
('MEM001', 'Fiction'),
('MEM001', 'Science Fiction'),
('MEM002', 'Fantasy'),
('MEM002', 'Romance'),
('MEM003', 'Fantasy'),
('MEM004', 'Computer Science'),
('MEM004', 'Science Fiction'),
('MEM005', 'Fiction');

-- =============================================================================
-- VERIFY SAMPLE DATA
-- =============================================================================

\echo ''
\echo 'Sample data inserted successfully!'
\echo ''
\echo 'Data Summary:'
SELECT 
    (SELECT COUNT(*) FROM members) as members,
    (SELECT COUNT(*) FROM books) as books,
    (SELECT COUNT(*) FROM book_copies) as copies,
    (SELECT COUNT(*) FROM borrow_history) as total_borrows,
    (SELECT COUNT(*) FROM current_borrows) as active_borrows;

\echo ''
\echo 'You can now test the system with the sample data.'
