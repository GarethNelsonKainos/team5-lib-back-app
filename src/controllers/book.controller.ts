import { Request, Response } from 'express';
import { BookService } from '../services/book.service.js';

export class BookController {
    /**
     * GET /api/books
     * Get all books with pagination and optional search
     */
    static async getAllBooks(req: Request, res: Response): Promise<void> {
        try {
            const page = parseInt(req.query.page as string) || 1;
            const limit = parseInt(req.query.limit as string) || 10;
            const searchTerm = req.query.search as string | undefined;

            const result = await BookService.getAllBooks(page, limit, searchTerm);

            res.status(200).json({
                success: true,
                data: result.books,
                pagination: {
                    page,
                    limit,
                    total: result.total,
                    totalPages: Math.ceil(result.total / limit)
                }
            });
        } catch (error) {
            console.error('Error fetching books:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to fetch books'
            });
        }
    }

    /**
     * GET /api/books/:id
     * Get a single book by ID
     */
    static async getBookById(req: Request, res: Response): Promise<void> {
        try {
            const bookId = parseInt(req.params.id as string);

            if (isNaN(bookId)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid book ID'
                });
                return;
            }

            const book = await BookService.getBookById(bookId);

            if (!book) {
                res.status(404).json({
                    success: false,
                    message: 'Book not found'
                });
                return;
            }

            res.status(200).json({
                success: true,
                data: book
            });
        } catch (error) {
            console.error('Error fetching book:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to fetch book'
            });
        }
    }

    /**
     * POST /api/books
     * Create a new book
     */
    static async createBook(req: Request, res: Response): Promise<void> {
        try {
            const { title, isbn, genre, publication_year, description, total_copies, authors } = req.body;

            // Basic validation
            if (!title || !isbn || !genre) {
                res.status(400).json({
                    success: false,
                    message: 'Title, ISBN, and genre are required'
                });
                return;
            }

            if (!authors || authors.length === 0) {
                res.status(400).json({
                    success: false,
                    message: 'At least one author is required'
                });
                return;
            }

            const bookData = {
                title,
                isbn,
                genre,
                publication_year: publication_year || 0,
                description: description || '',
                total_copies: total_copies || 0,
                authors
            };

            const newBook = await BookService.createBook(bookData);

            res.status(201).json({
                success: true,
                message: 'Book created successfully',
                data: newBook
            });
        } catch (error: any) {
            console.error('Error creating book:', error);
            
            // Handle duplicate ISBN
            if (error.code === '23505') {
                res.status(409).json({
                    success: false,
                    message: 'Book with this ISBN already exists'
                });
                return;
            }

            res.status(500).json({
                success: false,
                message: 'Failed to create book'
            });
        }
    }

    /**
     * PUT /api/books/:id
     * Update an existing book
     */
    static async updateBook(req: Request, res: Response): Promise<void> {
        try {
            const bookId = parseInt(req.params.id as string);

            if (isNaN(bookId)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid book ID'
                });
                return;
            }

            const { title, isbn, genre, publication_year, description } = req.body;

            const bookData: any = {};
            if (title !== undefined) bookData.title = title;
            if (isbn !== undefined) bookData.isbn = isbn;
            if (genre !== undefined) bookData.genre = genre;
            if (publication_year !== undefined) bookData.publication_year = publication_year;
            if (description !== undefined) bookData.description = description;

            const updatedBook = await BookService.updateBook(bookId, bookData);

            if (!updatedBook) {
                res.status(404).json({
                    success: false,
                    message: 'Book not found'
                });
                return;
            }

            res.status(200).json({
                success: true,
                message: 'Book updated successfully',
                data: updatedBook
            });
        } catch (error: any) {
            console.error('Error updating book:', error);

            // Handle duplicate ISBN
            if (error.code === '23505') {
                res.status(409).json({
                    success: false,
                    message: 'Book with this ISBN already exists'
                });
                return;
            }

            res.status(500).json({
                success: false,
                message: 'Failed to update book'
            });
        }
    }

    /**
     * DELETE /api/books/:id
     * Delete a book
     */
    static async deleteBook(req: Request, res: Response): Promise<void> {
        try {
            const bookId = parseInt(req.params.id as string);

            if (isNaN(bookId)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid book ID'
                });
                return;
            }

            const result = await BookService.deleteBook(bookId);

            if (!result.success) {
                res.status(400).json({
                    success: false,
                    message: result.message
                });
                return;
            }

            res.status(200).json({
                success: true,
                message: result.message
            });
        } catch (error) {
            console.error('Error deleting book:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to delete book'
            });
        }
    }

    /**
     * GET /api/books/genre/:genre
     * Get books by genre
     */
    static async getBooksByGenre(req: Request, res: Response): Promise<void> {
        try {
            const genre = req.params.genre as string;

            const books = await BookService.getBooksByGenre(genre);

            res.status(200).json({
                success: true,
                data: books
            });
        } catch (error) {
            console.error('Error fetching books by genre:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to fetch books'
            });
        }
    }

    /**
     * POST /api/books/:id/authors
     * Add an author to a book
     */
    static async addAuthor(req: Request, res: Response): Promise<void> {
        try {
            const bookId = parseInt(req.params.id as string);
            const { author_name } = req.body;

            if (isNaN(bookId)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid book ID'
                });
                return;
            }

            if (!author_name || author_name.trim() === '') {
                res.status(400).json({
                    success: false,
                    message: 'Author name is required'
                });
                return;
            }

            const newAuthor = await BookService.addAuthor(bookId, author_name.trim());

            res.status(201).json({
                success: true,
                message: 'Author added successfully',
                data: newAuthor
            });
        } catch (error: any) {
            console.error('Error adding author:', error);
            
            // Handle foreign key constraint (book not found)
            if (error.code === '23503') {
                res.status(404).json({
                    success: false,
                    message: 'Book not found'
                });
                return;
            }

            res.status(500).json({
                success: false,
                message: 'Failed to add author'
            });
        }
    }

    /**
     * DELETE /api/books/:id/authors/:authorId
     * Remove an author from a book
     */
    static async removeAuthor(req: Request, res: Response): Promise<void> {
        try {
            const bookId = parseInt(req.params.id as string);
            const authorId = parseInt(req.params.authorId as string);

            if (isNaN(bookId) || isNaN(authorId)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid book ID or author ID'
                });
                return;
            }

            const success = await BookService.removeAuthor(authorId);

            if (!success) {
                res.status(404).json({
                    success: false,
                    message: 'Author not found'
                });
                return;
            }

            res.status(200).json({
                success: true,
                message: 'Author removed successfully'
            });
        } catch (error) {
            console.error('Error removing author:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to remove author'
            });
        }
    }

    /**
     * POST /api/books/:id/copies
     * Add more copies to an existing book
     */
    static async addCopies(req: Request, res: Response): Promise<void> {
        try {
            const bookId = parseInt(req.params.id as string);
            const { quantity } = req.body;

            if (isNaN(bookId)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid book ID'
                });
                return;
            }

            if (!quantity || typeof quantity !== 'number' || quantity <= 0) {
                res.status(400).json({
                    success: false,
                    message: 'Quantity must be a positive number'
                });
                return;
            }

            const result = await BookService.addCopies(bookId, quantity);

            if (!result.success) {
                if (result.message === 'Book not found') {
                    res.status(404).json({
                        success: false,
                        message: result.message
                    });
                } else {
                    res.status(400).json({
                        success: false,
                        message: result.message
                    });
                }
                return;
            }

            res.status(201).json({
                success: true,
                message: result.message,
                data: {
                    addedCopies: result.addedCopies
                }
            });
        } catch (error) {
            console.error('Error adding copies:', error);
            res.status(500).json({
                success: false,
                message: 'Failed to add copies'
            });
        }
    }
}
