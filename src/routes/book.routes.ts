import { Router } from 'express';
import { BookController } from '../controllers/book.controller.js';

const router = Router();

// GET /api/books - Get all books (with pagination & search)
router.get('/', BookController.getAllBooks);

// GET /api/books/genre/:genre - Get books by genre (MUST be before /:id to avoid param conflict)
router.get('/genre/:genre', BookController.getBooksByGenre);

// GET /api/books/:id - Get single book by ID
router.get('/:id', BookController.getBookById);

// POST /api/books - Create new book
router.post('/', BookController.createBook);

// POST /api/books/:id/authors - Add an author to a book
router.post('/:id/authors', BookController.addAuthor);

// DELETE /api/books/:id/authors/:authorId - Remove an author from a book
router.delete('/:id/authors/:authorId', BookController.removeAuthor);

// POST /api/books/:id/copies - Add copies to a book
router.post('/:id/copies', BookController.addCopies);

// PUT /api/books/:id - Update book
router.put('/:id', BookController.updateBook);

// DELETE /api/books/:id - Delete book
router.delete('/:id', BookController.deleteBook);

export default router;
