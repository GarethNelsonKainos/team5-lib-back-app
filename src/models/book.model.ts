export interface Book {
    book_id: number;
    title: string;
    isbn: string;
    genre: string;
    publication_year: number;
    description: string;
    total_copies: number;
    available_copies: number;
    authors: string[];
    created_at: Date;
    updated_at: Date;
}