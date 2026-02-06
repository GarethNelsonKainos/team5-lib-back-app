import { Book } from '../models/book.model.js';
import { Author } from '../models/bookAuthor.model.js';
import { pool } from '../config/database.js';

export class BookService {
    /**
     * Get all books with pagination and optional search
     */
    static async getAllBooks(
        page: number = 1,
        limit: number = 10,
        searchTerm?: string
    ): Promise<{ books: Book[]; total: number }> {
        const offset = (page - 1) * limit;

        let query = `
            SELECT 
                b.*,
                COALESCE(
                    json_agg(
                        DISTINCT ba.author_name
                    ) FILTER (WHERE ba.author_name IS NOT NULL),
                    '[]'
                ) as authors
            FROM books b
            LEFT JOIN book_authors ba ON b.book_id = ba.book_id
        `;

        const params: any[] = [];

        if (searchTerm) {
            query += ` WHERE b.title ILIKE $1 OR ba.author_name ILIKE $1`;
            params.push(`%${searchTerm}%`);
        }

        query += `
            GROUP BY b.book_id
            ORDER BY b.title
            LIMIT $${params.length + 1} OFFSET $${params.length + 2}
        `;

        params.push(limit, offset);

        // Count total
        let countQuery = `SELECT COUNT(DISTINCT b.book_id) as total FROM books b`;
        if (searchTerm) {
            countQuery += ` LEFT JOIN book_authors ba ON b.book_id = ba.book_id
                           WHERE b.title ILIKE $1 OR ba.author_name ILIKE $1`;
        }

        const [booksResult, countResult] = await Promise.all([
            pool.query(query, params),
            pool.query(countQuery, searchTerm ? [`%${searchTerm}%`] : [])
        ]);

        return {
            books: booksResult.rows,
            total: parseInt(countResult.rows[0].total)
        };
    }

    /**
     * Get a single book by ID with its authors
     */
    static async getBookById(bookId: number): Promise<Book | null> {
        const query = `
            SELECT 
                b.*,
                COALESCE(
                    json_agg(
                        DISTINCT ba.author_name
                    ) FILTER (WHERE ba.author_name IS NOT NULL),
                    '[]'
                ) as authors
            FROM books b
            LEFT JOIN book_authors ba ON b.book_id = ba.book_id
            WHERE b.book_id = $1
            GROUP BY b.book_id
        `;

        const result = await pool.query(query, [bookId]);
        return result.rows[0] || null;
    }

    /**
     * Create a new book with authors
     */
    static async createBook(bookData: Omit<Book, 'book_id' | 'created_at' | 'updated_at' | 'available_copies'> & { authors: string[] }): Promise<Book> {
        const client = await pool.connect();

        try {
            await client.query('BEGIN');

            const totalCopies = bookData.total_copies ?? 0;
            const book = await this.insertBook(client, bookData, totalCopies);

            if (bookData.authors && bookData.authors.length > 0) {
                await this.insertAuthors(client, book.book_id, bookData.authors);
            }

            const copiesToCreate = Math.max(0, totalCopies);
            if (copiesToCreate > 0) {
                await this.insertBookCopies(client, book.book_id, copiesToCreate);
            }

            await client.query('COMMIT');

            // Fetch and return the complete book with authors
            return await this.getBookById(book.book_id) as Book;

        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }

    /**
     * Helper: Insert a new book record
     */
    private static async insertBook(
        client: any,
        bookData: Omit<Book, 'book_id' | 'created_at' | 'updated_at' | 'available_copies'> & { authors: string[] },
        totalCopies: number
    ): Promise<any> {
        const bookQuery = `
            INSERT INTO books (
                title, isbn, genre, publication_year, description,
                total_copies, available_copies, created_at, updated_at
            )
            VALUES ($1, $2, $3, $4, $5, $6, $6, NOW(), NOW())
            RETURNING *
        `;

        const bookResult = await client.query(bookQuery, [
            bookData.title,
            bookData.isbn,
            bookData.genre,
            bookData.publication_year ?? null,
            bookData.description ?? null,
            totalCopies
        ]);

        return bookResult.rows[0];
    }

    /**
     * Helper: Insert authors for a book
     */
    private static async insertAuthors(
        client: any,
        bookId: number,
        authors: string[]
    ): Promise<void> {
        const authorValues = authors.map((author, index) =>
            `($1, $${index + 2}, NOW())`
        ).join(', ');

        const authorQuery = `
            INSERT INTO book_authors (book_id, author_name, created_at)
            VALUES ${authorValues}
            RETURNING *
        `;

        await client.query(authorQuery, [bookId, ...authors]);
    }

    /**
     * Helper: Insert book copies
     */
    private static async insertBookCopies(
        client: any,
        bookId: number,
        numberOfCopies: number
    ): Promise<void> {
        const copiesQuery = `
            INSERT INTO book_copies (book_id, created_at, updated_at)
            SELECT $1, NOW(), NOW()
            FROM generate_series(1, $2)
        `;

        await client.query(copiesQuery, [bookId, numberOfCopies]);
    }

    /**
     * Update an existing book
     */
    static async updateBook(bookId: number, bookData: Partial<Omit<Book, 'book_id' | 'created_at' | 'updated_at'>>): Promise<Book | null> {
        const fields: string[] = [];
        const values: any[] = [];
        let paramCount = 1;

        if (bookData.title !== undefined) {
            fields.push(`title = $${paramCount++}`);
            values.push(bookData.title);
        }
        if (bookData.isbn !== undefined) {
            fields.push(`isbn = $${paramCount++}`);
            values.push(bookData.isbn);
        }
        if (bookData.genre !== undefined) {
            fields.push(`genre = $${paramCount++}`);
            values.push(bookData.genre);
        }
        if (bookData.publication_year !== undefined) {
            fields.push(`publication_year = $${paramCount++}`);
            values.push(bookData.publication_year);
        }
        if (bookData.description !== undefined) {
            fields.push(`description = $${paramCount++}`);
            values.push(bookData.description);
        }

        if (fields.length === 0) {
            return await this.getBookById(bookId);
        }

        fields.push(`updated_at = NOW()`);
        values.push(bookId);

        const query = `
            UPDATE books
            SET ${fields.join(', ')}
            WHERE book_id = $${paramCount}
            RETURNING *
        `;

        const result = await pool.query(query, values);

        if (result.rows.length === 0) {
            return null;
        }

        return await this.getBookById(bookId);
    }

    /**
     * Delete a book (only if no active loans exist)
     */
    static async deleteBook(bookId: number): Promise<{ success: boolean; message: string }> {
        const client = await pool.connect();

        try {
            await client.query('BEGIN');

            const bookExists = await this.checkBookExists(client, bookId);
            if (!bookExists) {
                await client.query('ROLLBACK');
                return { success: false, message: 'Book not found' };
            }

            const hasActiveLoans = await this.checkActiveLoans(client, bookId);
            if (hasActiveLoans) {
                await client.query('ROLLBACK');
                return {
                    success: false,
                    message: 'Cannot delete book with active loans'
                };
            }

            await this.performDeleteBook(client, bookId);
            await client.query('COMMIT');
            return { success: true, message: 'Book deleted successfully' };

        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }

    /**
     * Helper: Check if a book exists
     */
    private static async checkBookExists(client: any, bookId: number): Promise<boolean> {
        const result = await client.query(
            'SELECT book_id FROM books WHERE book_id = $1',
            [bookId]
        );
        return result.rows.length > 0;
    }

    /**
     * Helper: Check if book has active loans
     */
    private static async checkActiveLoans(client: any, bookId: number): Promise<boolean> {
        const result = await client.query(`
            SELECT COUNT(*) as count
            FROM loans l
            JOIN book_copies bc ON l.copy_id = bc.copy_id
            WHERE bc.book_id = $1
              AND l.returned_at IS NULL
        `, [bookId]);

        return parseInt(result.rows[0].count) > 0;
    }

    /**
     * Helper: Perform the book deletion
     */
    private static async performDeleteBook(client: any, bookId: number): Promise<void> {
        await client.query('DELETE FROM books WHERE book_id = $1', [bookId]);
    }

    /**
     * Add an author to a book
     */
    static async addAuthor(bookId: number, authorName: string): Promise<Author> {
        const query = `
            INSERT INTO book_authors (book_id, author_name, created_at)
            VALUES ($1, $2, NOW())
            RETURNING *
        `;

        const result = await pool.query(query, [bookId, authorName]);
        return result.rows[0];
    }

    /**
     * Remove an author from a book
     */
    static async removeAuthor(bookId: number, authorId: number): Promise<boolean> {
        const query = 'DELETE FROM book_authors WHERE author_id = $1 AND book_id = $2';
        const result = await pool.query(query, [authorId, bookId]);
        return result.rowCount !== null && result.rowCount > 0;
    }

    /**
     * Add multiple copies to an existing book
     */
    static async addCopies(bookId: number, numberOfCopies: number): Promise<{ success: boolean; message: string; addedCopies: number }> {
        const validationError = this.validateCopiesInput(numberOfCopies);
        if (validationError) {
            return validationError;
        }

        const client = await pool.connect();

        try {
            await client.query('BEGIN');

            const bookData = await this.getBookForCopyUpdate(client, bookId);
            if (!bookData) {
                await client.query('ROLLBACK');
                return { success: false, message: 'Book not found', addedCopies: 0 };
            }

            const currentTotalCopies = bookData.total_copies;
            await this.updateCopyTotals(client, bookId, numberOfCopies);
            await this.insertNewCopies(client, bookId, numberOfCopies);

            await client.query('COMMIT');

            return {
                success: true,
                message: `${numberOfCopies} copies added successfully. Total copies: ${currentTotalCopies + numberOfCopies}`,
                addedCopies: numberOfCopies
            };

        } catch (error) {
            await client.query('ROLLBACK');
            throw error;
        } finally {
            client.release();
        }
    }

    /**
     * Helper: Validate copies input
     */
    private static validateCopiesInput(numberOfCopies: number): { success: boolean; message: string; addedCopies: number } | null {
        if (numberOfCopies <= 0) {
            return { success: false, message: 'Number of copies must be greater than 0', addedCopies: 0 };
        }
        return null;
    }

    /**
     * Helper: Get book data for copy update
     */
    private static async getBookForCopyUpdate(client: any, bookId: number): Promise<{ total_copies: number } | null> {
        const result = await client.query(
            'SELECT book_id, total_copies FROM books WHERE book_id = $1',
            [bookId]
        );
        return result.rows[0] || null;
    }

    /**
     * Helper: Update total and available copies
     */
    private static async updateCopyTotals(client: any, bookId: number, numberOfCopies: number): Promise<void> {
        await client.query(
            `UPDATE books SET total_copies = total_copies + $1,
            available_copies = available_copies + $1, updated_at = NOW() WHERE book_id = $2`, 
            [numberOfCopies, bookId]
        );
    }

    /**
     * Helper: Insert new book copies
     */
    private static async insertNewCopies(client: any, bookId: number, numberOfCopies: number): Promise<void> {
        const copiesQuery = `
            INSERT INTO book_copies (book_id, created_at, updated_at)
            SELECT $1, NOW(), NOW()
            FROM generate_series(1, $2)
        `;
        await client.query(copiesQuery, [bookId, numberOfCopies]);
    }

    /**
     * Get books by genre
     */
    static async getBooksByGenre(genre: string): Promise<Book[]> {
        const query = `
            SELECT 
                b.*,
                COALESCE(
                    json_agg(
                        DISTINCT ba.author_name
                    ) FILTER (WHERE ba.author_name IS NOT NULL),
                    '[]'
                ) as authors
            FROM books b
            LEFT JOIN book_authors ba ON b.book_id = ba.book_id
            WHERE b.genre = $1
            GROUP BY b.book_id
            ORDER BY b.title
        `;

        const result = await pool.query(query, [genre]);
        return result.rows;
    }
}
