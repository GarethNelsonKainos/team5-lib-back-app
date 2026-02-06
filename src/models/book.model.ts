export interface Book {
    book_id: number;
    title: string;
    isbn: string;
    genre: string;
    publication_year: number;
    description: string;
    total_copies: number;
    available_copies: number;
    created_at: Date;
    updated_at: Date;
}

export interface BookWithAuthors extends Book {
    authors: string[];
}