import { Request, Response } from 'express';
import borrowingService from '../services/borrowingService';

interface AuthRequest extends Request {
  user?: {
    id: number;
  };
}

export const borrowBook = async (req: AuthRequest, res: Response): Promise<void> => {
  try {
    const { bookId } = req.body;
    const memberId = req.user?.id;
    
    if (!memberId) {
      res.status(401).json({ error: 'Unauthorized' });
      return;
    }
    
    const loan = await borrowingService.borrowBook(memberId, Number(bookId));
    res.status(201).json(loan);
  } catch (error) {
    res.status(400).json({ error: (error as Error).message });
  }
};

export const returnBook = async (req: Request, res: Response): Promise<void> => {
  try {
    const { id } = req.params;
    const history = await borrowingService.returnBook(Number(id));
    res.json(history);
  } catch (error) {
    res.status(400).json({ error: (error as Error).message });
  }
};

export const getUserBorrowings = async (req: Request, res: Response): Promise<void> => {
  try {
    const { userId } = req.params;
    const borrowings = await borrowingService.getUserBorrowings(Number(userId));
    res.json(borrowings);
  } catch (error) {
    res.status(500).json({ error: (error as Error).message });
  }
};

export const getAllBorrowings = async (req: Request, res: Response): Promise<void> => {
  try {
    const borrowings = await borrowingService.getAllBorrowings();
    res.json(borrowings);
  } catch (error) {
    res.status(500).json({ error: (error as Error).message });
  }
};

export const getOverdueBorrowings = async (req: Request, res: Response): Promise<void> => {
  try {
    const borrowings = await borrowingService.getOverdueBorrowings();
    res.json(borrowings);
  } catch (error) {
    res.status(500).json({ error: (error as Error).message });
  }
};