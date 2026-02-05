-- Library Management System - Sample Data
-- Run this after creating the tables with schema.sql

-- =============================================================================
-- MEMBERS DATA
-- =============================================================================
INSERT INTO members (first_name, last_name, email, phone, street, city, state, zip_code, registration_date, current_borrow_count, has_overdue_books, created_at, updated_at) VALUES
('John', 'Doe', 'john.doe@example.com', '555-0101', '123 Main St', 'Boston', 'MA', '02101', '2024-01-15', 2, false, NOW(), NOW()),
('Jane', 'Smith', 'jane.smith@example.com', '555-0102', '456 Oak Ave', 'Cambridge', 'MA', '02138', '2024-02-20', 1, false, NOW(), NOW()),
('Robert', 'Johnson', 'robert.j@example.com', '555-0103', '789 Pine Rd', 'Somerville', 'MA', '02143', '2024-03-10', 0, false, NOW(), NOW()),
('Emily', 'Brown', 'emily.brown@example.com', '555-0104', '321 Elm St', 'Brookline', 'MA', '02445', '2024-01-25', 1, true, NOW(), NOW()),
('Michael', 'Davis', 'michael.d@example.com', '555-0105', '654 Maple Dr', 'Newton', 'MA', '02458', '2024-04-05', 0, false, NOW(), NOW()),
('Sarah', 'Wilson', 'sarah.w@example.com', '555-0106', '987 Cedar Ln', 'Watertown', 'MA', '02472', '2024-02-14', 3, false, NOW(), NOW()),
('David', 'Martinez', 'david.m@example.com', '555-0107', '147 Birch St', 'Arlington', 'MA', '02474', '2024-03-22', 0, false, NOW(), NOW()),
('Lisa', 'Anderson', 'lisa.a@example.com', '555-0108', '258 Spruce Ave', 'Belmont', 'MA', '02478', '2024-01-30', 2, false, NOW(), NOW());

-- =============================================================================
-- BOOKS DATA
-- =============================================================================
INSERT INTO books (title, isbn, genre, publication_year, description, total_copies, available_copies, created_at, updated_at) VALUES
('The Great Gatsby', '978-0-7432-7356-5', 'Classic Fiction', 1925, 'A tale of wealth, love, and the American Dream in the Roaring Twenties.', 5, 3, NOW(), NOW()),
('1984', '978-0-452-28423-4', 'Dystopian Fiction', 1949, 'A dystopian social science fiction novel and cautionary tale about totalitarianism.', 4, 2, NOW(), NOW()),
('To Kill a Mockingbird', '978-0-061-12008-4', 'Classic Fiction', 1960, 'A gripping tale of racial injustice and childhood innocence in the American South.', 6, 4, NOW(), NOW()),
('Pride and Prejudice', '978-0-141-19943-0', 'Romance', 1813, 'A romantic novel of manners exploring themes of marriage, morality, and misconceptions.', 3, 0, NOW(), NOW()),
('The Catcher in the Rye', '978-0-316-76948-0', 'Coming of Age', 1951, 'A story about teenage rebellion and alienation narrated by Holden Caulfield.', 4, 2, NOW(), NOW()),
('Harry Potter and the Philosopher''s Stone', '978-0-747-53273-1', 'Fantasy', 1997, 'The first book in the Harry Potter series about a young wizard''s adventures.', 8, 5, NOW(), NOW()),
('The Hobbit', '978-0-345-33968-3', 'Fantasy', 1937, 'A fantasy novel about Bilbo Baggins'' unexpected journey with dwarves and a wizard.', 5, 3, NOW(), NOW()),
('Brave New World', '978-0-060-85052-4', 'Science Fiction', 1932, 'A dystopian novel set in a futuristic World State of genetically modified citizens.', 3, 2, NOW(), NOW()),
('Jane Eyre', '978-0-141-44114-6', 'Gothic Romance', 1847, 'A novel about an orphaned girl who becomes a governess and falls in love.', 4, 3, NOW(), NOW()),
('The Lord of the Rings', '978-0-618-00222-1', 'Fantasy', 1954, 'An epic high-fantasy novel following Frodo''s quest to destroy the One Ring.', 6, 3, NOW(), NOW()),
('Animal Farm', '978-0-452-28424-1', 'Political Satire', 1945, 'An allegorical novella about a group of farm animals who rebel against their farmer.', 4, 2, NOW(), NOW()),
('Moby-Dick', '978-0-142-43772-5', 'Adventure', 1851, 'The narrative of Captain Ahab''s obsessive quest for revenge on Moby Dick.', 3, 2, NOW(), NOW());

-- =============================================================================
-- BOOK AUTHORS DATA
-- =============================================================================
INSERT INTO book_authors (book_id, author_name, created_at) VALUES
(1, 'F. Scott Fitzgerald', NOW()),
(2, 'George Orwell', NOW()),
(3, 'Harper Lee', NOW()),
(4, 'Jane Austen', NOW()),
(5, 'J.D. Salinger', NOW()),
(6, 'J.K. Rowling', NOW()),
(7, 'J.R.R. Tolkien', NOW()),
(8, 'Aldous Huxley', NOW()),
(9, 'Charlotte Brontë', NOW()),
(10, 'J.R.R. Tolkien', NOW()),
(11, 'George Orwell', NOW()),
(12, 'Herman Melville', NOW());

-- =============================================================================
-- BOOK COPIES DATA (Physical copies of each book)
-- =============================================================================
INSERT INTO book_copies (book_id, created_at, updated_at) VALUES
-- The Great Gatsby (5 copies)
(1, NOW(), NOW()), (1, NOW(), NOW()), (1, NOW(), NOW()), (1, NOW(), NOW()), (1, NOW(), NOW()),
-- 1984 (4 copies)
(2, NOW(), NOW()), (2, NOW(), NOW()), (2, NOW(), NOW()), (2, NOW(), NOW()),
-- To Kill a Mockingbird (6 copies)
(3, NOW(), NOW()), (3, NOW(), NOW()), (3, NOW(), NOW()), (3, NOW(), NOW()), (3, NOW(), NOW()), (3, NOW(), NOW()),
-- Pride and Prejudice (3 copies)
(4, NOW(), NOW()), (4, NOW(), NOW()), (4, NOW(), NOW()),
-- The Catcher in the Rye (4 copies)
(5, NOW(), NOW()), (5, NOW(), NOW()), (5, NOW(), NOW()), (5, NOW(), NOW()),
-- Harry Potter (8 copies)
(6, NOW(), NOW()), (6, NOW(), NOW()), (6, NOW(), NOW()), (6, NOW(), NOW()), (6, NOW(), NOW()), (6, NOW(), NOW()), (6, NOW(), NOW()), (6, NOW(), NOW()),
-- The Hobbit (5 copies)
(7, NOW(), NOW()), (7, NOW(), NOW()), (7, NOW(), NOW()), (7, NOW(), NOW()), (7, NOW(), NOW()),
-- Brave New World (3 copies)
(8, NOW(), NOW()), (8, NOW(), NOW()), (8, NOW(), NOW()),
-- Jane Eyre (4 copies)
(9, NOW(), NOW()), (9, NOW(), NOW()), (9, NOW(), NOW()), (9, NOW(), NOW()),
-- The Lord of the Rings (6 copies)
(10, NOW(), NOW()), (10, NOW(), NOW()), (10, NOW(), NOW()), (10, NOW(), NOW()), (10, NOW(), NOW()), (10, NOW(), NOW()),
-- Animal Farm (4 copies)
(11, NOW(), NOW()), (11, NOW(), NOW()), (11, NOW(), NOW()), (11, NOW(), NOW()),
-- Moby-Dick (3 copies)
(12, NOW(), NOW()), (12, NOW(), NOW()), (12, NOW(), NOW());

-- =============================================================================
-- ACTIVE LOANS DATA (Currently borrowed books)
-- =============================================================================
-- John Doe (member_id: 1) - 2 books
INSERT INTO loans (copy_id, member_id, borrow_date, due_date, is_overdue, created_at) VALUES
(1, 1, NOW() - INTERVAL '5 days', CURRENT_DATE + 9, false, NOW()),
(19, 1, NOW() - INTERVAL '3 days', CURRENT_DATE + 11, false, NOW());

-- Jane Smith (member_id: 2) - 1 book
INSERT INTO loans (copy_id, member_id, borrow_date, due_date, is_overdue, created_at) VALUES
(10, 2, NOW() - INTERVAL '7 days', CURRENT_DATE + 7, false, NOW());

-- Emily Brown (member_id: 4) - 1 book (OVERDUE)
INSERT INTO loans (copy_id, member_id, borrow_date, due_date, is_overdue, created_at) VALUES
(16, 4, NOW() - INTERVAL '20 days', CURRENT_DATE - 6, true, NOW());

-- Sarah Wilson (member_id: 6) - 3 books (maximum allowed)
INSERT INTO loans (copy_id, member_id, borrow_date, due_date, is_overdue, created_at) VALUES
(6, 6, NOW() - INTERVAL '4 days', CURRENT_DATE + 10, false, NOW()),
(17, 6, NOW() - INTERVAL '2 days', CURRENT_DATE + 12, false, NOW()),
(43, 6, NOW() - INTERVAL '1 day', CURRENT_DATE + 13, false, NOW());

-- Lisa Anderson (member_id: 8) - 2 books
INSERT INTO loans (copy_id, member_id, borrow_date, due_date, is_overdue, created_at) VALUES
(30, 8, NOW() - INTERVAL '6 days', CURRENT_DATE + 8, false, NOW()),
(37, 8, NOW() - INTERVAL '8 days', CURRENT_DATE + 6, false, NOW());

-- =============================================================================
-- BORROW HISTORY DATA (Returned books - past transactions)
-- =============================================================================
INSERT INTO borrow_history (copy_id, member_id, borrow_date, due_date, return_date, was_overdue, created_at) VALUES
-- John Doe's past borrowings
(2, 1, NOW() - INTERVAL '45 days', CURRENT_DATE - 31, NOW() - INTERVAL '32 days', false, NOW()),
(7, 1, NOW() - INTERVAL '60 days', CURRENT_DATE - 46, NOW() - INTERVAL '47 days', false, NOW()),
(22, 1, NOW() - INTERVAL '90 days', CURRENT_DATE - 76, NOW() - INTERVAL '74 days', true, NOW()),

-- Jane Smith's past borrowings
(3, 2, NOW() - INTERVAL '30 days', CURRENT_DATE - 16, NOW() - INTERVAL '18 days', false, NOW()),
(26, 2, NOW() - INTERVAL '70 days', CURRENT_DATE - 56, NOW() - INTERVAL '55 days', true, NOW()),

-- Robert Johnson's past borrowings
(11, 3, NOW() - INTERVAL '25 days', CURRENT_DATE - 11, NOW() - INTERVAL '12 days', false, NOW()),
(31, 3, NOW() - INTERVAL '50 days', CURRENT_DATE - 36, NOW() - INTERVAL '38 days', false, NOW()),

-- Emily Brown's past borrowings
(4, 4, NOW() - INTERVAL '80 days', CURRENT_DATE - 66, NOW() - INTERVAL '65 days', true, NOW()),

-- Michael Davis's past borrowings
(12, 5, NOW() - INTERVAL '35 days', CURRENT_DATE - 21, NOW() - INTERVAL '22 days', false, NOW()),
(27, 5, NOW() - INTERVAL '55 days', CURRENT_DATE - 41, NOW() - INTERVAL '40 days', true, NOW()),
(38, 5, NOW() - INTERVAL '75 days', CURRENT_DATE - 61, NOW() - INTERVAL '59 days', true, NOW()),

-- Sarah Wilson's past borrowings
(5, 6, NOW() - INTERVAL '40 days', CURRENT_DATE - 26, NOW() - INTERVAL '27 days', false, NOW()),

-- David Martinez's past borrowings
(13, 7, NOW() - INTERVAL '20 days', CURRENT_DATE - 6, NOW() - INTERVAL '7 days', false, NOW()),
(28, 7, NOW() - INTERVAL '65 days', CURRENT_DATE - 51, NOW() - INTERVAL '50 days', true, NOW()),

-- Lisa Anderson's past borrowings
(8, 8, NOW() - INTERVAL '85 days', CURRENT_DATE - 71, NOW() - INTERVAL '69 days', true, NOW());

-- =============================================================================
-- VERIFICATION QUERIES
-- =============================================================================
-- Uncomment these to verify data after insertion:

-- SELECT COUNT(*) as total_members FROM members;
-- SELECT COUNT(*) as total_books FROM books;
-- SELECT COUNT(*) as total_authors FROM book_authors;
-- SELECT COUNT(*) as total_copies FROM book_copies;
-- SELECT COUNT(*) as active_loans FROM loans;
-- SELECT COUNT(*) as past_borrowings FROM borrow_history;

-- Show books with their available vs total copies:
-- SELECT title, total_copies, available_copies, (total_copies - available_copies) as borrowed 
-- FROM books ORDER BY title;

-- Show active loans with member and book details:
-- SELECT l.loan_id, m.first_name || ' ' || m.last_name as member, b.title, l.borrow_date, l.due_date, l.is_overdue
-- FROM loans l
-- JOIN members m ON l.member_id = m.member_id
-- JOIN book_copies bc ON l.copy_id = bc.copy_id
-- JOIN books b ON bc.book_id = b.book_id
-- ORDER BY l.due_date;
