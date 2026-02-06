import express, { Request, Response } from 'express';
import borrowingService from '../services/borrowingService.js';

interface AuthRequest extends Request {
  user?: {
    id: number;
  };
}

/**
 * Borrow a specific book copy
 * Expects copyId (not bookId) - this reflects real library workflow
 * where a specific copy barcode is scanned
 */
const borrowBook = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { copyId, memberId } = req.body;
    
    if (!memberId) {
      res.status(400).json({ error: 'memberId is required' });
      return;
    }
    
    if (!copyId) {
      res.status(400).json({ error: 'copyId is required' });
      return;
    }
    
    const loan = await borrowingService.borrowBook(Number(memberId), Number(copyId));
    res.status(201).json(loan);
  } catch (error) {
    res.status(400).json({ error: (error as Error).message });
  }
};

const returnBook = async (req: Request, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const loan = await borrowingService.returnBook(Number(id));
    res.json(loan);
  } catch (error) {
    res.status(400).json({ error: (error as Error).message });
  }
};

const getUserBorrowings = async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId } = req.params;
    const borrowings = await borrowingService.getUserBorrowings(Number(userId));
    res.json(borrowings);
  } catch (error) {
    res.status(500).json({ error: (error as Error).message });
  }
};

const getAllBorrowings = async (req: Request, res: Response): Promise<void> => {
  try {
    const borrowings = await borrowingService.getAllBorrowings();
    res.json(borrowings);
  } catch (error) {
    res.status(500).json({ error: (error as Error).message });
  }
};

const getOverdueBorrowings = async (req: Request, res: Response): Promise<void> => {
  try {
    const borrowings = await borrowingService.getOverdueBorrowings();
    res.json(borrowings);
  } catch (error) {
    res.status(500).json({ error: (error as Error).message });
  }
};

const getBorrowHistory = async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId } = req.params;
    const history = userId 
      ? await borrowingService.getUserHistory(Number(userId))
      : await borrowingService.getAllHistory();
    res.json(history);
  } catch (error) {
    res.status(500).json({ error: (error as Error).message });
  }
};

// Routes
const router = express.Router();

router.post('/', borrowBook);
router.put('/:id/return', returnBook);
router.get('/user/:userId', getUserBorrowings);
router.get('/history/user/:userId', getBorrowHistory);
router.get('/history', getBorrowHistory);
router.get('/overdue', getOverdueBorrowings);
router.get('/', getAllBorrowings);

export default router;