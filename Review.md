<issue 1>
The route is scoped to a book (/api/books/:id/authors/:authorId), but the implementation ignores bookId and deletes solely by authorId. This allows removing an author record that belongs to a different book if the caller knows/guesses the authorId. Fix by changing the service to delete with both identifiers (e.g., WHERE author_id = $1 AND book_id = $2) and passing bookId through.
taking place in : src/controllers/book.controller.ts
line 325, recommended change :             const success = await BookService.removeAuthor(bookId, authorId);
<end issue 1>
<issue 2>
Think this could just be in Book, a book must have a least 1 author. No need to extend, should be part of book : 
    updated_at: Date;


export interface BookWithAuthors extends Book 
 taking place in : src/models/book.model.ts
   line 11 - 14

recommended change : add author_id to book without extending
<end issue 2>
<issue 3>
    static async createBook(bookData: Omit<Book, 'book_id' | 'created_at' | 'updated_at' | 'available_copies'> & { authors: string[] }): Promise<BookWithAuthors> 

located at : src/services/book.service.ts
starting at line 88

Would update this method to have parameters of the needed fields and parse them in the controller before calling this method. Omit can be messy to maintain
Also there's a lot going on in this one method. Remember Single responsibility principle. Create methods for each of these steps/queries to make it more readable, reusable and maintainable
<end issue 3>
<issue 4>
static async deleteBook(bookId: number): Promise<{ success: boolean; message: string }> {
        const client = await pool.connect();

located at : src/services/book.service.ts
starting at line 212
Again, single resp principle. Create methods for each step/query
<end issue 4>
<issue 5>
static async addCopies(bookId: number, numberOfCopies: number): Promise<{ success: boolean; message: string; addedCopies: number }> {
        if (numberOfCopies <= 0) {

located at : src/services/book.service.ts
starting at line 285

Single resp principle
<end issue 5>
