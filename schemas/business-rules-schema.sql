-- Library Management System - Business Rules & Stored Procedures Schema
-- This file contains stored procedures, functions, and constraints for enforcing business rules
-- Requirements: Section 4 - Business Rules & Constraints from library.md

-- =============================================================================
-- BORROWING MANAGEMENT PROCEDURES
-- =============================================================================

-- Procedure to check out a book (borrow process)
CREATE OR REPLACE FUNCTION checkout_book(
    p_member_id VARCHAR,
    p_copy_id VARCHAR,
    p_loan_days INTEGER DEFAULT 14
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    borrow_id INTEGER,
    due_date DATE
) AS $$
DECLARE
    v_member_status membership_status;
    v_can_borrow BOOLEAN;
    v_current_borrow_count INTEGER;
    v_has_overdue BOOLEAN;
    v_copy_status copy_status;
    v_borrow_id INTEGER;
    v_due_date DATE;
BEGIN
    -- Check member eligibility
    SELECT status, can_borrow, current_borrow_count, has_overdue_books
    INTO v_member_status, v_can_borrow, v_current_borrow_count, v_has_overdue
    FROM members
    WHERE member_id = p_member_id;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Member not found', NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;
    
    IF v_member_status != 'Active' THEN
        RETURN QUERY SELECT FALSE, 'Member account is not active', NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;
    
    IF v_has_overdue THEN
        RETURN QUERY SELECT FALSE, 'Member has overdue books and cannot borrow', NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;
    
    IF v_current_borrow_count >= 3 THEN
        RETURN QUERY SELECT FALSE, 'Member has reached maximum borrowing limit (3 books)', NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;
    
    -- Check copy availability
    SELECT status INTO v_copy_status
    FROM book_copies
    WHERE copy_id = p_copy_id;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Book copy not found', NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;
    
    IF v_copy_status != 'Available' THEN
        RETURN QUERY SELECT FALSE, 'Book copy is not available for borrowing', NULL::INTEGER, NULL::DATE;
        RETURN;
    END IF;
    
    -- Calculate due date
    v_due_date := CURRENT_DATE + p_loan_days;
    
    -- Create borrowing record
    INSERT INTO borrow_history (copy_id, member_id, borrow_date, due_date)
    VALUES (p_copy_id, p_member_id, CURRENT_TIMESTAMP, v_due_date)
    RETURNING borrow_history.borrow_id INTO v_borrow_id;
    
    -- Update copy status
    UPDATE book_copies
    SET status = 'Borrowed',
        current_borrower_id = p_member_id,
        borrow_date = CURRENT_DATE,
        due_date = v_due_date
    WHERE copy_id = p_copy_id;
    
    RETURN QUERY SELECT TRUE, 'Book checked out successfully', v_borrow_id, v_due_date;
END;
$$ LANGUAGE plpgsql;

-- Procedure to check in a book (return process)
CREATE OR REPLACE FUNCTION checkin_book(
    p_copy_id VARCHAR,
    p_return_condition copy_condition DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    was_overdue BOOLEAN,
    days_overdue INTEGER
) AS $$
DECLARE
    v_borrow_id INTEGER;
    v_due_date DATE;
    v_was_overdue BOOLEAN;
    v_days_overdue INTEGER;
BEGIN
    -- Find active borrow record
    SELECT bh.borrow_id, bh.due_date
    INTO v_borrow_id, v_due_date
    FROM borrow_history bh
    WHERE bh.copy_id = p_copy_id AND bh.return_date IS NULL
    ORDER BY bh.borrow_date DESC
    LIMIT 1;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'No active borrow record found for this copy', FALSE, 0;
        RETURN;
    END IF;
    
    -- Calculate overdue status
    v_was_overdue := CURRENT_DATE > v_due_date;
    v_days_overdue := CASE WHEN v_was_overdue THEN CURRENT_DATE - v_due_date ELSE 0 END;
    
    -- Update borrow record
    UPDATE borrow_history
    SET return_date = CURRENT_TIMESTAMP,
        is_overdue = v_was_overdue
    WHERE borrow_id = v_borrow_id;
    
    -- Update copy status
    UPDATE book_copies
    SET status = 'Available',
        current_borrower_id = NULL,
        borrow_date = NULL,
        due_date = NULL,
        condition = COALESCE(p_return_condition, condition)
    WHERE copy_id = p_copy_id;
    
    RETURN QUERY SELECT TRUE, 'Book returned successfully', v_was_overdue, v_days_overdue;
END;
$$ LANGUAGE plpgsql;

-- Procedure to renew a borrowed book
CREATE OR REPLACE FUNCTION renew_book(
    p_member_id VARCHAR,
    p_copy_id VARCHAR,
    p_extension_days INTEGER DEFAULT 14
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    new_due_date DATE
) AS $$
DECLARE
    v_borrow_id INTEGER;
    v_renewal_count INTEGER;
    v_is_overdue BOOLEAN;
    v_new_due_date DATE;
BEGIN
    -- Find active borrow record
    SELECT bh.borrow_id, bh.renewal_count, bh.is_overdue
    INTO v_borrow_id, v_renewal_count, v_is_overdue
    FROM borrow_history bh
    WHERE bh.copy_id = p_copy_id 
        AND bh.member_id = p_member_id 
        AND bh.return_date IS NULL
    ORDER BY bh.borrow_date DESC
    LIMIT 1;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'No active borrow record found', NULL::DATE;
        RETURN;
    END IF;
    
    IF v_is_overdue THEN
        RETURN QUERY SELECT FALSE, 'Cannot renew overdue books', NULL::DATE;
        RETURN;
    END IF;
    
    IF v_renewal_count >= 2 THEN
        RETURN QUERY SELECT FALSE, 'Maximum renewal limit (2) reached', NULL::DATE;
        RETURN;
    END IF;
    
    -- Calculate new due date
    v_new_due_date := CURRENT_DATE + p_extension_days;
    
    -- Update borrow record
    UPDATE borrow_history
    SET due_date = v_new_due_date,
        renewal_count = renewal_count + 1
    WHERE borrow_id = v_borrow_id;
    
    -- Update copy record
    UPDATE book_copies
    SET due_date = v_new_due_date
    WHERE copy_id = p_copy_id;
    
    RETURN QUERY SELECT TRUE, 'Book renewed successfully', v_new_due_date;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- BOOK MANAGEMENT PROCEDURES
-- =============================================================================

-- Procedure to add a new book with author(s)
CREATE OR REPLACE FUNCTION add_book(
    p_title VARCHAR,
    p_isbn VARCHAR,
    p_genre VARCHAR,
    p_publication_year INTEGER,
    p_description TEXT DEFAULT NULL,
    p_publisher VARCHAR DEFAULT NULL,
    p_page_count INTEGER DEFAULT NULL,
    p_language VARCHAR DEFAULT 'English',
    p_authors TEXT[] DEFAULT ARRAY[]::TEXT[]
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    book_id INTEGER
) AS $$
DECLARE
    v_book_id INTEGER;
    v_author TEXT;
    v_author_order INTEGER := 1;
BEGIN
    -- Check if ISBN already exists
    IF EXISTS (SELECT 1 FROM books WHERE isbn = p_isbn) THEN
        RETURN QUERY SELECT FALSE, 'Book with this ISBN already exists', NULL::INTEGER;
        RETURN;
    END IF;
    
    -- Insert book record
    INSERT INTO books (title, isbn, genre, publication_year, description, publisher, page_count, language)
    VALUES (p_title, p_isbn, p_genre, p_publication_year, p_description, p_publisher, p_page_count, p_language)
    RETURNING id INTO v_book_id;
    
    -- Insert authors
    IF array_length(p_authors, 1) > 0 THEN
        FOREACH v_author IN ARRAY p_authors
        LOOP
            INSERT INTO book_authors (book_id, author_name, author_order)
            VALUES (v_book_id, v_author, v_author_order);
            v_author_order := v_author_order + 1;
        END LOOP;
    END IF;
    
    RETURN QUERY SELECT TRUE, 'Book added successfully', v_book_id;
END;
$$ LANGUAGE plpgsql;

-- Procedure to add a new copy of an existing book
CREATE OR REPLACE FUNCTION add_book_copy(
    p_book_id INTEGER,
    p_copy_id VARCHAR,
    p_condition copy_condition DEFAULT 'Good',
    p_location VARCHAR DEFAULT NULL,
    p_acquired_date DATE DEFAULT CURRENT_DATE
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    -- Check if book exists
    IF NOT EXISTS (SELECT 1 FROM books WHERE id = p_book_id) THEN
        RETURN QUERY SELECT FALSE, 'Book not found';
        RETURN;
    END IF;
    
    -- Check if copy_id already exists
    IF EXISTS (SELECT 1 FROM book_copies WHERE copy_id = p_copy_id) THEN
        RETURN QUERY SELECT FALSE, 'Copy ID already exists';
        RETURN;
    END IF;
    
    -- Insert copy
    INSERT INTO book_copies (copy_id, book_id, status, condition, location, acquired_date)
    VALUES (p_copy_id, p_book_id, 'Available', p_condition, p_location, p_acquired_date);
    
    RETURN QUERY SELECT TRUE, 'Book copy added successfully';
END;
$$ LANGUAGE plpgsql;

-- Procedure to delete a book (with validation)
CREATE OR REPLACE FUNCTION delete_book(
    p_book_id INTEGER
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_active_borrows INTEGER;
BEGIN
    -- Check if book exists
    IF NOT EXISTS (SELECT 1 FROM books WHERE id = p_book_id) THEN
        RETURN QUERY SELECT FALSE, 'Book not found';
        RETURN;
    END IF;
    
    -- Check for active borrows
    SELECT COUNT(*) INTO v_active_borrows
    FROM book_copies bc
    JOIN borrow_history bh ON bc.copy_id = bh.copy_id
    WHERE bc.book_id = p_book_id AND bh.return_date IS NULL;
    
    IF v_active_borrows > 0 THEN
        RETURN QUERY SELECT FALSE, 'Cannot delete book with active borrows';
        RETURN;
    END IF;
    
    -- Delete book (cascade will handle related records)
    DELETE FROM books WHERE id = p_book_id;
    
    RETURN QUERY SELECT TRUE, 'Book deleted successfully';
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- MEMBER MANAGEMENT PROCEDURES
-- =============================================================================

-- Procedure to add a new member
CREATE OR REPLACE FUNCTION add_member(
    p_member_id VARCHAR,
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_email VARCHAR,
    p_phone VARCHAR DEFAULT NULL,
    p_street VARCHAR DEFAULT NULL,
    p_city VARCHAR DEFAULT NULL,
    p_state VARCHAR DEFAULT NULL,
    p_zip_code VARCHAR DEFAULT NULL,
    p_country VARCHAR DEFAULT NULL,
    p_membership_type membership_type DEFAULT 'Regular',
    p_date_of_birth DATE DEFAULT NULL,
    p_gender gender_type DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    -- Check if member_id already exists
    IF EXISTS (SELECT 1 FROM members WHERE member_id = p_member_id) THEN
        RETURN QUERY SELECT FALSE, 'Member ID already exists';
        RETURN;
    END IF;
    
    -- Check if email already exists
    IF EXISTS (SELECT 1 FROM members WHERE email = p_email) THEN
        RETURN QUERY SELECT FALSE, 'Email already registered';
        RETURN;
    END IF;
    
    -- Insert member
    INSERT INTO members (
        member_id, first_name, last_name, full_name, email, phone,
        street, city, state, zip_code, country,
        membership_type, status, registration_date, expiry_date,
        date_of_birth, gender
    ) VALUES (
        p_member_id, p_first_name, p_last_name, p_first_name || ' ' || p_last_name,
        p_email, p_phone, p_street, p_city, p_state, p_zip_code, p_country,
        p_membership_type, 'Active', CURRENT_DATE, CURRENT_DATE + INTERVAL '1 year',
        p_date_of_birth, p_gender
    );
    
    RETURN QUERY SELECT TRUE, 'Member added successfully';
END;
$$ LANGUAGE plpgsql;

-- Procedure to update member information
CREATE OR REPLACE FUNCTION update_member(
    p_member_id VARCHAR,
    p_first_name VARCHAR DEFAULT NULL,
    p_last_name VARCHAR DEFAULT NULL,
    p_email VARCHAR DEFAULT NULL,
    p_phone VARCHAR DEFAULT NULL,
    p_street VARCHAR DEFAULT NULL,
    p_city VARCHAR DEFAULT NULL,
    p_state VARCHAR DEFAULT NULL,
    p_zip_code VARCHAR DEFAULT NULL,
    p_country VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    -- Check if member exists
    IF NOT EXISTS (SELECT 1 FROM members WHERE member_id = p_member_id) THEN
        RETURN QUERY SELECT FALSE, 'Member not found';
        RETURN;
    END IF;
    
    -- Update member (only non-null values)
    UPDATE members
    SET 
        first_name = COALESCE(p_first_name, first_name),
        last_name = COALESCE(p_last_name, last_name),
        full_name = COALESCE(p_first_name, first_name) || ' ' || COALESCE(p_last_name, last_name),
        email = COALESCE(p_email, email),
        phone = COALESCE(p_phone, phone),
        street = COALESCE(p_street, street),
        city = COALESCE(p_city, city),
        state = COALESCE(p_state, state),
        zip_code = COALESCE(p_zip_code, zip_code),
        country = COALESCE(p_country, country)
    WHERE member_id = p_member_id;
    
    RETURN QUERY SELECT TRUE, 'Member updated successfully';
END;
$$ LANGUAGE plpgsql;

-- Procedure to delete a member (with validation)
CREATE OR REPLACE FUNCTION delete_member(
    p_member_id VARCHAR
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_active_borrows INTEGER;
BEGIN
    -- Check if member exists
    IF NOT EXISTS (SELECT 1 FROM members WHERE member_id = p_member_id) THEN
        RETURN QUERY SELECT FALSE, 'Member not found';
        RETURN;
    END IF;
    
    -- Check for active borrows
    SELECT COUNT(*) INTO v_active_borrows
    FROM borrow_history
    WHERE member_id = p_member_id AND return_date IS NULL;
    
    IF v_active_borrows > 0 THEN
        RETURN QUERY SELECT FALSE, 'Cannot delete member with active borrows';
        RETURN;
    END IF;
    
    -- Delete member
    DELETE FROM members WHERE member_id = p_member_id;
    
    RETURN QUERY SELECT TRUE, 'Member deleted successfully';
END;
$$ LANGUAGE plpgsql;

-- Procedure to suspend/activate member account
CREATE OR REPLACE FUNCTION update_member_status(
    p_member_id VARCHAR,
    p_new_status membership_status,
    p_notes TEXT DEFAULT NULL
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT
) AS $$
BEGIN
    -- Check if member exists
    IF NOT EXISTS (SELECT 1 FROM members WHERE member_id = p_member_id) THEN
        RETURN QUERY SELECT FALSE, 'Member not found';
        RETURN;
    END IF;
    
    -- Update status
    UPDATE members
    SET status = p_new_status,
        notes = COALESCE(p_notes, notes)
    WHERE member_id = p_member_id;
    
    RETURN QUERY SELECT TRUE, 'Member status updated successfully';
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- MAINTENANCE AND UTILITY PROCEDURES
-- =============================================================================

-- Procedure to update overdue status for all active borrows
CREATE OR REPLACE FUNCTION update_overdue_status()
RETURNS TABLE (
    overdue_count INTEGER,
    affected_members INTEGER
) AS $$
DECLARE
    v_overdue_count INTEGER;
    v_affected_members INTEGER;
BEGIN
    -- Update is_overdue flag in borrow_history
    UPDATE borrow_history
    SET is_overdue = TRUE
    WHERE return_date IS NULL 
        AND due_date < CURRENT_DATE
        AND is_overdue = FALSE;
    
    GET DIAGNOSTICS v_overdue_count = ROW_COUNT;
    
    -- Update member overdue status
    UPDATE members m
    SET has_overdue_books = TRUE
    WHERE EXISTS (
        SELECT 1 FROM current_borrows cb
        WHERE cb.member_id = m.member_id AND cb.is_overdue = TRUE
    ) AND m.has_overdue_books = FALSE;
    
    GET DIAGNOSTICS v_affected_members = ROW_COUNT;
    
    -- Update can_borrow status for affected members
    UPDATE members
    SET can_borrow = FALSE
    WHERE has_overdue_books = TRUE AND can_borrow = TRUE;
    
    RETURN QUERY SELECT v_overdue_count, v_affected_members;
END;
$$ LANGUAGE plpgsql;

-- Procedure to expire memberships
CREATE OR REPLACE FUNCTION expire_memberships()
RETURNS TABLE (
    expired_count INTEGER
) AS $$
DECLARE
    v_expired_count INTEGER;
BEGIN
    -- Update expired memberships
    UPDATE members
    SET status = 'Expired',
        can_borrow = FALSE
    WHERE expiry_date < CURRENT_DATE 
        AND status = 'Active';
    
    GET DIAGNOSTICS v_expired_count = ROW_COUNT;
    
    RETURN QUERY SELECT v_expired_count;
END;
$$ LANGUAGE plpgsql;

-- Procedure to renew membership
CREATE OR REPLACE FUNCTION renew_membership(
    p_member_id VARCHAR,
    p_extension_months INTEGER DEFAULT 12
)
RETURNS TABLE (
    success BOOLEAN,
    message TEXT,
    new_expiry_date DATE
) AS $$
DECLARE
    v_current_expiry DATE;
    v_new_expiry DATE;
BEGIN
    -- Get current expiry date
    SELECT expiry_date INTO v_current_expiry
    FROM members
    WHERE member_id = p_member_id;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Member not found', NULL::DATE;
        RETURN;
    END IF;
    
    -- Calculate new expiry date
    IF v_current_expiry IS NULL OR v_current_expiry < CURRENT_DATE THEN
        v_new_expiry := CURRENT_DATE + (p_extension_months || ' months')::INTERVAL;
    ELSE
        v_new_expiry := v_current_expiry + (p_extension_months || ' months')::INTERVAL;
    END IF;
    
    -- Update member
    UPDATE members
    SET expiry_date = v_new_expiry,
        last_renewal_date = CURRENT_DATE,
        status = CASE WHEN status = 'Expired' THEN 'Active' ELSE status END
    WHERE member_id = p_member_id;
    
    RETURN QUERY SELECT TRUE, 'Membership renewed successfully', v_new_expiry;
END;
$$ LANGUAGE plpgsql;

-- Procedure to generate a unique member ID
CREATE OR REPLACE FUNCTION generate_member_id()
RETURNS VARCHAR AS $$
DECLARE
    v_new_id VARCHAR;
    v_exists BOOLEAN;
BEGIN
    LOOP
        -- Generate random alphanumeric ID (6-8 characters)
        v_new_id := UPPER(
            SUBSTRING(MD5(RANDOM()::TEXT || CURRENT_TIMESTAMP::TEXT) FROM 1 FOR 8)
        );
        
        -- Check if it already exists
        SELECT EXISTS(SELECT 1 FROM members WHERE member_id = v_new_id) INTO v_exists;
        
        EXIT WHEN NOT v_exists;
    END LOOP;
    
    RETURN v_new_id;
END;
$$ LANGUAGE plpgsql;

-- Procedure to generate a unique copy ID
CREATE OR REPLACE FUNCTION generate_copy_id(p_book_id INTEGER)
RETURNS VARCHAR AS $$
DECLARE
    v_isbn VARCHAR;
    v_copy_count INTEGER;
    v_new_copy_id VARCHAR;
BEGIN
    -- Get book ISBN
    SELECT isbn INTO v_isbn
    FROM books
    WHERE id = p_book_id;
    
    IF NOT FOUND THEN
        RETURN NULL;
    END IF;
    
    -- Count existing copies
    SELECT COUNT(*) INTO v_copy_count
    FROM book_copies
    WHERE book_id = p_book_id;
    
    -- Generate copy ID: ISBN-XXXXX format
    v_new_copy_id := v_isbn || '-' || LPAD((v_copy_count + 1)::TEXT, 5, '0');
    
    RETURN v_new_copy_id;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- VALIDATION FUNCTIONS
-- =============================================================================

-- Function to check if a member can borrow
CREATE OR REPLACE FUNCTION can_member_borrow(p_member_id VARCHAR)
RETURNS TABLE (
    can_borrow BOOLEAN,
    reason TEXT
) AS $$
DECLARE
    v_member RECORD;
BEGIN
    SELECT 
        m.status, 
        m.current_borrow_count, 
        m.has_overdue_books,
        m.expiry_date,
        m.can_borrow as member_can_borrow
    INTO v_member
    FROM members m
    WHERE m.member_id = p_member_id;
    
    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Member not found';
        RETURN;
    END IF;
    
    IF v_member.status != 'Active' THEN
        RETURN QUERY SELECT FALSE, 'Member account is not active';
        RETURN;
    END IF;
    
    IF v_member.has_overdue_books THEN
        RETURN QUERY SELECT FALSE, 'Member has overdue books';
        RETURN;
    END IF;
    
    IF v_member.current_borrow_count >= 3 THEN
        RETURN QUERY SELECT FALSE, 'Member has reached borrowing limit (3 books)';
        RETURN;
    END IF;
    
    IF v_member.expiry_date IS NOT NULL AND v_member.expiry_date < CURRENT_DATE THEN
        RETURN QUERY SELECT FALSE, 'Membership has expired';
        RETURN;
    END IF;
    
    RETURN QUERY SELECT TRUE, 'Member is eligible to borrow';
END;
$$ LANGUAGE plpgsql;

-- Function to check if a book copy is available
CREATE OR REPLACE FUNCTION is_copy_available(p_copy_id VARCHAR)
RETURNS BOOLEAN AS $$
DECLARE
    v_status copy_status;
BEGIN
    SELECT status INTO v_status
    FROM book_copies
    WHERE copy_id = p_copy_id;
    
    RETURN (v_status = 'Available');
END;
$$ LANGUAGE plpgsql;

-- Function to calculate late fees (if needed in future)
CREATE OR REPLACE FUNCTION calculate_late_fee(
    p_days_overdue INTEGER,
    p_fee_per_day NUMERIC DEFAULT 0.50
)
RETURNS NUMERIC AS $$
BEGIN
    IF p_days_overdue <= 0 THEN
        RETURN 0.00;
    END IF;
    
    -- Simple calculation: $0.50 per day, max $25
    RETURN LEAST(p_days_overdue * p_fee_per_day, 25.00);
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- SCHEDULED MAINTENANCE FUNCTIONS
-- =============================================================================

-- Function to be run daily to maintain data integrity
CREATE OR REPLACE FUNCTION daily_maintenance()
RETURNS TEXT AS $$
DECLARE
    v_overdue_count INTEGER;
    v_affected_members INTEGER;
    v_expired_count INTEGER;
    v_result TEXT;
BEGIN
    -- Update overdue status
    SELECT overdue_count, affected_members 
    INTO v_overdue_count, v_affected_members
    FROM update_overdue_status();
    
    -- Expire memberships
    SELECT expired_count 
    INTO v_expired_count
    FROM expire_memberships();
    
    v_result := FORMAT(
        'Daily maintenance completed: %s overdue items updated, %s members affected, %s memberships expired',
        v_overdue_count, v_affected_members, v_expired_count
    );
    
    RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- =============================================================================
-- CONSTRAINTS AND VALIDATION TRIGGERS
-- =============================================================================

-- Trigger to prevent deleting books with active borrows
CREATE OR REPLACE FUNCTION prevent_book_deletion_with_active_borrows()
RETURNS TRIGGER AS $$
DECLARE
    v_active_borrows INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_active_borrows
    FROM book_copies bc
    JOIN borrow_history bh ON bc.copy_id = bh.copy_id
    WHERE bc.book_id = OLD.id AND bh.return_date IS NULL;
    
    IF v_active_borrows > 0 THEN
        RAISE EXCEPTION 'Cannot delete book with active borrows';
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_prevent_book_deletion
    BEFORE DELETE ON books
    FOR EACH ROW EXECUTE FUNCTION prevent_book_deletion_with_active_borrows();

-- Trigger to prevent deleting members with active borrows
CREATE OR REPLACE FUNCTION prevent_member_deletion_with_active_borrows()
RETURNS TRIGGER AS $$
DECLARE
    v_active_borrows INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_active_borrows
    FROM borrow_history
    WHERE member_id = OLD.member_id AND return_date IS NULL;
    
    IF v_active_borrows > 0 THEN
        RAISE EXCEPTION 'Cannot delete member with active borrows';
    END IF;
    
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_prevent_member_deletion
    BEFORE DELETE ON members
    FOR EACH ROW EXECUTE FUNCTION prevent_member_deletion_with_active_borrows();

-- Trigger to validate borrow limits before inserting borrow record
CREATE OR REPLACE FUNCTION validate_borrow_before_insert()
RETURNS TRIGGER AS $$
DECLARE
    v_member_record RECORD;
BEGIN
    -- Get member information
    SELECT status, current_borrow_count, has_overdue_books, expiry_date
    INTO v_member_record
    FROM members
    WHERE member_id = NEW.member_id;
    
    -- Validate member eligibility
    IF v_member_record.status != 'Active' THEN
        RAISE EXCEPTION 'Member account is not active';
    END IF;
    
    IF v_member_record.has_overdue_books THEN
        RAISE EXCEPTION 'Member has overdue books and cannot borrow';
    END IF;
    
    IF v_member_record.current_borrow_count >= 3 THEN
        RAISE EXCEPTION 'Member has reached maximum borrowing limit';
    END IF;
    
    IF v_member_record.expiry_date IS NOT NULL AND v_member_record.expiry_date < CURRENT_DATE THEN
        RAISE EXCEPTION 'Membership has expired';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validate_borrow
    BEFORE INSERT ON borrow_history
    FOR EACH ROW EXECUTE FUNCTION validate_borrow_before_insert();

-- =============================================================================
-- COMMENTS AND DOCUMENTATION
-- =============================================================================

COMMENT ON FUNCTION checkout_book IS 'Check out a book to a member with full validation';
COMMENT ON FUNCTION checkin_book IS 'Return a book and update availability';
COMMENT ON FUNCTION renew_book IS 'Renew a borrowed book with validation';
COMMENT ON FUNCTION add_book IS 'Add a new book with author information';
COMMENT ON FUNCTION add_book_copy IS 'Add a physical copy of an existing book';
COMMENT ON FUNCTION delete_book IS 'Delete a book with validation for active borrows';
COMMENT ON FUNCTION add_member IS 'Register a new library member';
COMMENT ON FUNCTION update_member IS 'Update member contact information';
COMMENT ON FUNCTION delete_member IS 'Delete a member with validation for active borrows';
COMMENT ON FUNCTION update_overdue_status IS 'Daily maintenance to update overdue status';
COMMENT ON FUNCTION expire_memberships IS 'Daily maintenance to expire memberships';
COMMENT ON FUNCTION daily_maintenance IS 'Run all daily maintenance tasks';
COMMENT ON FUNCTION can_member_borrow IS 'Check if a member is eligible to borrow books';
COMMENT ON FUNCTION is_copy_available IS 'Check if a book copy is available for borrowing';
