import { pool } from '../config/database.js';
import { Loan } from '../models/loan.js';

class BorrowingService {
  /**
   * Borrow a specific book copy
   * In a real library, the user would scan the barcode of a specific copy,
   * so we accept copyId directly rather than auto-selecting a copy
   */
  async borrowBook(memberId: number, copyId: number): Promise<Loan> {
    // Check if the specific copy exists and is available (not currently on loan)
    const copyCheck = await pool.query(
      `SELECT bc.copy_id
       FROM book_copies bc
       LEFT JOIN loans l ON bc.copy_id = l.copy_id AND l.return_date IS NULL
       WHERE bc.copy_id = $1 AND l.loan_id IS NULL`,
      [copyId]
    );

    if (copyCheck.rows.length === 0) {
      throw new Error('Copy not available or does not exist');
    }

    // Create loan with 14-day due date
    const dueDate = new Date(Date.now() + 14 * 24 * 60 * 60 * 1000);
    const result = await pool.query(
      `INSERT INTO loans (copy_id, member_id, borrow_date, due_date, created_at)
       VALUES ($1, $2, NOW(), $3, NOW())
       RETURNING *`,
      [copyId, memberId, dueDate]
    );

    return result.rows[0];
  }

  /**
   * Return a book by updating the loan with return_date
   * Instead of deleting and moving to history table, we keep everything in loans table
   */
  async returnBook(loanId: number): Promise<Loan> {
    // Update loan with return_date
    // If loan doesn't exist or already returned, this returns 0 rows
    const result = await pool.query(
      `UPDATE loans 
       SET return_date = NOW()
       WHERE loan_id = $1 AND return_date IS NULL
       RETURNING *`,
      [loanId]
    );

    if (result.rows.length === 0) {
      throw new Error('Loan not found or already returned');
    }

    return result.rows[0];
  }

  async getUserBorrowings(memberId: number): Promise<Loan[]> {
    const result = await pool.query(
      `SELECT l.*, b.title, b.isbn, bc.book_id
       FROM loans l
       JOIN book_copies bc ON l.copy_id = bc.copy_id
       JOIN books b ON bc.book_id = b.book_id
       WHERE l.member_id = $1 AND l.return_date IS NULL
       ORDER BY l.borrow_date DESC`,
      [memberId]
    );
    return result.rows;
  }

  async getAllBorrowings(): Promise<Loan[]> {
    const result = await pool.query(
      `SELECT l.*, m.first_name, m.last_name, m.email, b.title, b.isbn, bc.book_id
       FROM loans l
       JOIN members m ON l.member_id = m.member_id
       JOIN book_copies bc ON l.copy_id = bc.copy_id
       JOIN books b ON bc.book_id = b.book_id
       WHERE l.return_date IS NULL
       ORDER BY l.borrow_date DESC`
    );
    return result.rows;
  }

  async getOverdueBorrowings(): Promise<Loan[]> {
    const result = await pool.query(
      `SELECT l.*, m.first_name, m.last_name, m.email, b.title, b.isbn, bc.book_id
       FROM loans l
       JOIN members m ON l.member_id = m.member_id
       JOIN book_copies bc ON l.copy_id = bc.copy_id
       JOIN books b ON bc.book_id = b.book_id
       WHERE l.due_date < NOW() AND l.return_date IS NULL
       ORDER BY l.due_date ASC`
    );
    return result.rows;
  }

  async getUserHistory(memberId: number): Promise<Loan[]> {
    const result = await pool.query(
      `SELECT l.*, b.title, b.isbn, bc.book_id
       FROM loans l
       JOIN book_copies bc ON l.copy_id = bc.copy_id
       JOIN books b ON bc.book_id = b.book_id
       WHERE l.member_id = $1 AND l.return_date IS NOT NULL
       ORDER BY l.return_date DESC`,
      [memberId]
    );
    return result.rows;
  }

  async getAllHistory(): Promise<Loan[]> {
    const result = await pool.query(
      `SELECT l.*, m.first_name, m.last_name, m.email, b.title, b.isbn, bc.book_id
       FROM loans l
       JOIN members m ON l.member_id = m.member_id
       JOIN book_copies bc ON l.copy_id = bc.copy_id
       JOIN books b ON bc.book_id = b.book_id
       WHERE l.return_date IS NOT NULL
       ORDER BY l.return_date DESC`
    );
    return result.rows;
  }
}

export default new BorrowingService();