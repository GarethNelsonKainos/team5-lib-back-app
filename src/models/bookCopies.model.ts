interface Copy {
    copy_id: number;
    book_id: number;
    status: 'available' | 'checked_out' | 'reserved';
    created_at: Date;
    updated_at: Date;
}