export interface Member {
  member_id: number;
  first_name: string;
  last_name: string;
  email: string;
  phone?: string;
  current_borrow_count: number;
  has_overdue_books: boolean;
}

export interface Book {
  book_id: number;
  title: string;
  isbn: string;
  genre: string;
  publication_year?: number;
  description?: string;
  total_copies: number;
  available_copies: number;
}

export interface BookCopy {
  copy_id: number;
  book_id: number;
}

export interface Loan {
  loan_id: number;
  copy_id: number;
  member_id: number;
  borrow_date: Date;
  due_date: Date;
  is_overdue: boolean;
}

export interface BorrowHistory {
  history_id: number;
  copy_id: number;
  member_id: number;
  borrow_date: Date;
  due_date: Date;
  return_date: Date;
  was_overdue: boolean;
}
