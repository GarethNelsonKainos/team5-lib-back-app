# Database Setup Instructions

## Quick Setup (Recommended)

Run the automated setup script:

```bash
./setup_database.sh
```

This will:
- ✅ Create the `ben_library_app` database
- ✅ Run the schema to create all tables
- ✅ Load sample data (8 members, 12 books, 9 active loans, etc.)

---

## Manual Setup (Alternative)

If you prefer to set up step-by-step:

### 1. Create the Database

```bash
createdb ben_library_app
```

### 2. Run the Schema

```bash
psql ben_library_app < schema.sql
```

### 3. Load Sample Data

```bash
psql ben_library_app < seed_data.sql
```

### 4. Verify Data

```bash
psql ben_library_app -c "SELECT COUNT(*) FROM members;"
psql ben_library_app -c "SELECT COUNT(*) FROM books;"
psql ben_library_app -c "SELECT COUNT(*) FROM loans;"
```

---

## What Sample Data is Included?

- **8 Members** - Library patrons with various borrowing statuses
- **12 Books** - Classic literature and popular fiction
- **60 Book Copies** - Physical copies available for borrowing
- **9 Active Loans** - Currently borrowed books
- **15 History Records** - Past borrowing transactions

### Featured Books:
- The Great Gatsby
- 1984
- To Kill a Mockingbird
- Pride and Prejudice
- Harry Potter and the Philosopher's Stone
- The Hobbit
- And 6 more classics!

---

## Testing the Connection

After setup, test your database connection:

1. Start your app:
   ```bash
   npm run dev
   ```

2. Visit the database test endpoint:
   ```
   http://localhost:3000/api/db-test
   ```

3. You should see:
   ```json
   {
     "status": "connected",
     "database": "ben_library_app",
     "host": "localhost",
     "current_time": "..."
   }
   ```

---

## Troubleshooting

### PostgreSQL not running?
```bash
brew services start postgresql@14
```

### Database already exists?
```bash
dropdb ben_library_app
./setup_database.sh
```

### Permission denied?
```bash
chmod +x setup_database.sh
```

### Connection refused?
- Check your `.env` file has correct credentials
- Make sure PostgreSQL is running: `pg_isready`

---

## Useful Commands

```bash
# Connect to database
psql ben_library_app

# List all tables
\dt

# View members
SELECT * FROM members;

# View active loans with details
SELECT m.first_name, m.last_name, b.title, l.due_date 
FROM loans l
JOIN members m ON l.member_id = m.member_id
JOIN book_copies bc ON l.copy_id = bc.copy_id
JOIN books b ON bc.book_id = b.book_id;

# Exit psql
\q
```
