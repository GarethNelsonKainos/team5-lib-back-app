export interface Loan {
  loan_id: number;
  copy_id: number;
  member_id: number;
  borrow_date: Date;
  due_date: Date;
  is_overdue: boolean;
}
