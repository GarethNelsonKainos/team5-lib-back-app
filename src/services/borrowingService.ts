import { pool } from '../config/database.js';
import { Loan, BorrowHistory } from '../models/index.js';

class BorrowingService {
  async borrowBook(memberId: number, bookId: number): Promise<Loan> {
    const client = await pool.connect();
    
    try {
      await client.query('BEGIN');

      // Check if book has available copies
      const bookResult = await client.query(
        'SELECT available_copies FROM books WHERE book_id = $1',
        [bookId]
      );

      if (bookResult.rows.length === 0 || bookResult.rows[0].available_copies <= 0) {
        throw new Error('Book not available');
      }

      // Find an available copy
      const copyResult = await client.query(
        `SELECT bc.copy_id FROM book_copies bc
         LEFT JOIN loans l ON bc.copy_id = l.copy_id
         WHERE bc.book_id = $1 AND l.loan_id IS NULL
         LIMIT 1`,
        [bookId]
      );

      if (copyResult.rows.length === 0) {
        throw new Error('No copies available');
      }

      const copyId = copyResult.rows[0].copy_id;

      // Create loan
      const dueDate = new Date(Date.now() + 14 * 24 * 60 * 60 * 1000); // 14 days
      const loanResult = await client.query(
        `INSERT INTO loans (copy_id, member_id, borrow_date, due_date, is_overdue, created_at)
         VALUES ($1, $2, NOW(), $3, false, NOW())
         RETURNING *`,
        [copyId, memberId, dueDate]
      );

      // Update available copies
      await client.query(
        'UPDATE books SET available_copies = available_copies - 1 WHERE book_id = $1',
        [bookId]
      );

      await client.query('COMMIT');
      return loanResult.rows[0];
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  async returnBook(loanId: number): Promise<BorrowHistory> {
    const client = await pool.connect();
    
    try {
      await client.query('BEGIN');

      // Get loan details
      const loanResult = await client.query(
        `SELECT l.*, bc.book_id FROM loans l
         JOIN book_copies bc ON l.copy_id = bc.copy_id
         WHERE l.loan_id = $1`,
        [loanId]
      );

      if (loanResult.rows.length === 0) {
        throw new Error('Loan not found');
      }

      const loan = loanResult.rows[0];
      const wasOverdue = new Date() > new Date(loan.due_date);

      // Create history record
      const historyResult = await client.query(
        `INSERT INTO borrow_history (copy_id, member_id, borrow_date, due_date, return_date, was_overdue, created_at)
         VALUES ($1, $2, $3, $4, NOW(), $5, NOW())
         RETURNING *`,
        [loan.copy_id, loan.member_id, loan.borrow_date, loan.due_date, wasOverdue]
      );

      // Delete loan
      await client.query('DELETE FROM loans WHERE loan_id = $1', [loanId]);

      // Update available copies
      await client.query(
        'UPDATE books SET available_copies = available_copies + 1 WHERE book_id = $1',
        [loan.book_id]
      );

      await client.query('COMMIT');
      return historyResult.rows[0];
    } catch (error) {
      await client.query('ROLLBACK');
      throw error;
    } finally {
      client.release();
    }
  }

  async getUserBorrowings(memberId: number): Promise<Loan[]> {
    const result = await pool.query(
      `SELECT l.*, b.title, b.isbn, bc.book_id
       FROM loans l
       JOIN book_copies bc ON l.copy_id = bc.copy_id
       JOIN books b ON bc.book_id = b.book_id
       WHERE l.member_id = $1
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
       WHERE l.due_date < NOW() AND l.is_overdue = false`
    );
    return result.rows;
  }
}

export default new BorrowingService();