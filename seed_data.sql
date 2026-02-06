-- Borrowing API - Sample Loan Data
-- Note: Assumes members, books, and book_copies are already seeded by their respective APIs
-- Run this after the database schema is created

-- =============================================================================
-- ACTIVE LOANS DATA (Currently borrowed books)
-- =============================================================================
-- John Doe (member_id: 1) - 2 books
INSERT INTO loans (copy_id, member_id, borrow_date, due_date, created_at) VALUES
(1, 1, NOW() - INTERVAL '5 days', CURRENT_DATE + 9, NOW()),
(19, 1, NOW() - INTERVAL '3 days', CURRENT_DATE + 11, NOW());

-- Jane Smith (member_id: 2) - 1 book
INSERT INTO loans (copy_id, member_id, borrow_date, due_date, created_at) VALUES
(10, 2, NOW() - INTERVAL '7 days', CURRENT_DATE + 7, NOW());

-- Emily Brown (member_id: 4) - 1 book (OVERDUE - due_date in past)
INSERT INTO loans (copy_id, member_id, borrow_date, due_date, created_at) VALUES
(16, 4, NOW() - INTERVAL '20 days', CURRENT_DATE - 6, NOW());

-- Sarah Wilson (member_id: 6) - 3 books (maximum allowed)
INSERT INTO loans (copy_id, member_id, borrow_date, due_date, created_at) VALUES
(6, 6, NOW() - INTERVAL '4 days', CURRENT_DATE + 10, NOW()),
(17, 6, NOW() - INTERVAL '2 days', CURRENT_DATE + 12, NOW()),
(43, 6, NOW() - INTERVAL '1 day', CURRENT_DATE + 13, NOW());

-- Lisa Anderson (member_id: 8) - 2 books
INSERT INTO loans (copy_id, member_id, borrow_date, due_date, created_at) VALUES
(30, 8, NOW() - INTERVAL '6 days', CURRENT_DATE + 8, NOW()),
(37, 8, NOW() - INTERVAL '8 days', CURRENT_DATE + 6, NOW());
