# Borrowing API Documentation

## Base URL
```
http://localhost:3000/api/borrowings
```

## Endpoints Overview

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/borrowings` | Get all active borrowings |
| GET | `/api/borrowings/user/:userId` | Get user's active borrowings |
| GET | `/api/borrowings/overdue` | Get overdue borrowings |
| GET | `/api/borrowings/history` | Get all returned loans |
| GET | `/api/borrowings/history/user/:userId` | Get user's returned loans |
| POST | `/api/borrowings` | Borrow a book |
| PUT | `/api/borrowings/:id/return` | Return a book |

---

## Endpoints

### 1. Get All Active Borrowings
Retrieves all active borrowing records (not yet returned).

**Endpoint:** `GET /api/borrowings`

**Response:** `200 OK`
```json
[
  {
    "loan_id": 1,
    "member_id": 1,
    "member_name": "John Doe",
    "member_email": "john@example.com",
    "book_copy_id": 5,
    "book_id": 2,
    "book_title": "The Great Gatsby",
    "isbn": "978-0743273565",
    "borrow_date": "2026-01-15T00:00:00.000Z",
    "due_date": "2026-02-14T00:00:00.000Z",
    "return_date": null
  }
]
```

**Example Request:**
```bash
curl http://localhost:3000/api/borrowings
```

---

### 2. Get User Active Borrowings
Retrieves all active borrowing records for a specific user.

**Endpoint:** `GET /api/borrowings/user/:userId`

**URL Parameters:**
- `userId` (number, required) - The ID of the member

**Response:** `200 OK`
```json
[
  {
    "loan_id": 1,
    "member_id": 1,
    "member_name": "John Doe",
    "member_email": "john@example.com",
    "book_copy_id": 5,
    "book_id": 2,
    "book_title": "The Great Gatsby",
    "isbn": "978-0743273565",
    "borrow_date": "2026-01-15T00:00:00.000Z",
    "due_date": "2026-02-14T00:00:00.000Z",
    "return_date": null
  }
]
```

**Error Response:** `500 Internal Server Error`
```json
{
  "error": "Error message"
}
```

**Example Request:**
```bash
curl http://localhost:3000/api/borrowings/user/1
```

---

### 3. Get Overdue Borrowings
Retrieves all borrowings that are past their due date and not yet returned.

**Endpoint:** `GET /api/borrowings/overdue`

**Response:** `200 OK`
```json
[
  {
    "loan_id": 3,
    "member_id": 2,
    "member_name": "Jane Smith",
    "member_email": "jane@example.com",
    "book_copy_id": 8,
    "book_id": 4,
    "book_title": "1984",
    "isbn": "978-0451524935",
    "borrow_date": "2026-01-01T00:00:00.000Z",
    "due_date": "2026-01-31T00:00:00.000Z",
    "return_date": null
  }
]
```

**Example Request:**
```bash
curl http://localhost:3000/api/borrowings/overdue
```

---

### 4. Get All Borrowing History
Retrieves all completed borrowing records (returned loans).

**Endpoint:** `GET /api/borrowings/history`

**Response:** `200 OK`
```json
[
  {
    "loan_id": 5,
    "member_id": 1,
    "member_name": "John Doe",
    "member_email": "john@example.com",
    "book_copy_id": 3,
    "book_id": 1,
    "book_title": "The Great Gatsby",
    "isbn": "978-0743273565",
    "borrow_date": "2026-01-01T00:00:00.000Z",
    "due_date": "2026-01-15T00:00:00.000Z",
    "return_date": "2026-01-14T00:00:00.000Z"
  }
]
```

**Example Request:**
```bash
curl http://localhost:3000/api/borrowings/history
```

---

### 5. Get User Borrowing History
Retrieves all completed borrowing records for a specific user.

**Endpoint:** `GET /api/borrowings/history/user/:userId`

**URL Parameters:**
- `userId` (number, required) - The ID of the member

**Response:** `200 OK`
```json
[
  {
    "loan_id": 5,
    "member_id": 1,
    "book_copy_id": 3,
    "book_id": 1,
    "book_title": "The Great Gatsby",
    "isbn": "978-0743273565",
    "borrow_date": "2026-01-01T00:00:00.000Z",
    "due_date": "2026-01-15T00:00:00.000Z",
    "return_date": "2026-01-14T00:00:00.000Z"
  }
]
```

**Example Request:**
```bash
curl http://localhost:3000/api/borrowings/history/user/1
```

---

### 6. Borrow a Book
Creates a new borrowing record (loan) for a specific book copy.

**Endpoint:** `POST /api/borrowings`

**Request Body:**
```json
{
  "memberId": 1,
  "copyId": 5
}
```

**Request Body Parameters:**
- `memberId` (number, required) - The ID of the member borrowing the book
- `copyId` (number, required) - The ID of the specific book copy to borrow

**Response:** `201 Created`
```json
{
  "loan_id": 10,
  "member_id": 1,
  "book_copy_id": 5,
  "borrow_date": "2026-02-06T00:00:00.000Z",
  "due_date": "2026-03-08T00:00:00.000Z",
  "return_date": null
}
```

**Error Responses:**

`400 Bad Request` - Missing required fields
```json
{
  "error": "memberId is required"
}
```
```json
{
  "error": "copyId is required"
}
```

`400 Bad Request` - Business logic error
```json
{
  "error": "Copy not available or does not exist"
}
```

**Example Request:**
```bash
curl -X POST http://localhost:3000/api/borrowings \
  -H "Content-Type: application/json" \
  -d '{"memberId": 1, "copyId": 5}'
```

---

### 7. Return a Book
Marks a borrowing record as returned by setting the return date.

**Endpoint:** `PUT /api/borrowings/:id/return`

**URL Parameters:**
- `id` (number, required) - The loan ID to mark as returned

**Response:** `200 OK`
```json
{
  "loan_id": 10,
  "member_id": 1,
  "book_copy_id": 5,
  "borrow_date": "2026-02-06T00:00:00.000Z",
  "due_date": "2026-03-08T00:00:00.000Z",
  "return_date": "2026-02-10T00:00:00.000Z"
}
```

**Error Response:** `400 Bad Request`
```json
{
  "error": "Loan not found or already returned"
}
```

**Example Request:**
```bash
curl -X PUT http://localhost:3000/api/borrowings/10/return
```

---

## Data Models

### Loan Object
```typescript
{
  loan_id: number;           // Unique identifier for the loan
  member_id: number;         // ID of the member who borrowed
  copy_id: number;           // ID of the specific book copy
  borrow_date: string;       // ISO 8601 date when borrowed
  due_date: string;          // ISO 8601 date when due
  return_date: string | null; // ISO 8601 date when returned (null if active)
  created_at: string;        // ISO 8601 date when loan was created
}
```

### Borrowing Details Object (Extended Loan with JOINs)
```typescript
{
  loan_id: number;
  member_id: number;
  member_name: string;       // Member's full name (from JOIN)
  member_email: string;      // Member's email address (from JOIN)
  copy_id: number;
  book_id: number;           // ID of the book (from JOIN)
  book_title: string;        // Title of the book (from JOIN)
  isbn: string;              // ISBN of the book (from JOIN)
  borrow_date: string;
  due_date: string;
  return_date: string | null;
  created_at: string;
}
```

**Note:** Overdue status is calculated dynamically: `due_date < current_date AND return_date IS NULL`

---

## Error Handling

All endpoints follow a consistent error response format:

```json
{
  "error": "Error message describing what went wrong"
}
```

### HTTP Status Codes

- `200 OK` - Successful GET/PUT request
- `201 Created` - Successful POST request (resource created)
- `400 Bad Request` - Invalid request data or business logic error
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server-side error

---

## Business Rules

1. **Borrowing a Book:**
   - User specifies a specific book copy (copyId) to borrow
   - This reflects real library workflow where a barcode is scanned
   - The specific copy must not be currently on loan (return_date IS NULL)
   - Due date is automatically set to 14 days from borrow date

2. **Returning a Book:**
   - Loan must exist
   - Loan must not already be returned (return_date must be NULL)
   - Return date is set to current timestamp

3. **Overdue Detection:**
   - A loan is considered overdue if:
     - `due_date < current_date` AND
     - `return_date IS NULL` (not yet returned)
   - Overdue status is calculated dynamically, not stored

4. **History Tracking:**
   - All loans remain in the loans table
   - Active loans: `return_date IS NULL`
   - Historical loans: `return_date IS NOT NULL`
   - Single source of truth for all borrowing data

---

## Testing

### Test Scenario 1: Complete Borrowing Flow
```bash
# 1. Check active borrowings
curl http://localhost:3000/api/borrowings

# 2. Borrow a specific book copy
curl -X POST http://localhost:3000/api/borrowings \
  -H "Content-Type: application/json" \
  -d '{"memberId": 1, "copyId": 5}'

# 3. View user's active borrowings
curl http://localhost:3000/api/borrowings/user/1

# 4. Return the book
curl -X PUT http://localhost:3000/api/borrowings/1/return

# 5. View user's borrowing history
curl http://localhost:3000/api/borrowings/history/user/1
```

### Test Scenario 2: Check Overdue Books
```bash
# Get all overdue borrowings
curl http://localhost:3000/api/borrowings/overdue
```

### Test Scenario 3: View History
```bash
# Get all completed borrowings
curl http://localhost:3000/api/borrowings/history

# Get specific user's history
curl http://localhost:3000/api/borrowings/history/user/1
```

---

## Notes

- All dates are returned in ISO 8601 format
- The API uses PostgreSQL database for data persistence
- Uses raw SQL queries with `pg` (PostgreSQL driver)
- CORS is enabled for cross-origin requests
- Authentication/Authorization is not yet implemented
- All loans (active and returned) are stored in the `loans` table
- History is queried by filtering on `return_date IS NOT NULL`
