import express from 'express';
import * as borrowingController from '../controllers/borrowingController.js';
// import { authenticate, isAdmin } from '../middleware/auth'; // Uncomment when auth middleware is ready

const router = express.Router();

// POST /api/borrowings - Borrow a book
router.post('/', borrowingController.borrowBook);

// PUT /api/borrowings/:id/return - Return a book
router.put('/:id/return', borrowingController.returnBook);

// GET /api/borrowings/user/:userId - Get user's borrowing history
router.get('/user/:userId', borrowingController.getUserBorrowings);

// GET /api/borrowings - Get all borrowings (admin only)
router.get('/', borrowingController.getAllBorrowings);

// GET /api/borrowings/overdue - Get overdue borrowings
router.get('/overdue', borrowingController.getOverdueBorrowings);

export default router;