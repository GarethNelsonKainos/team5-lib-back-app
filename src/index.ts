import 'dotenv/config';
import express from 'express';
import { Request, Response, NextFunction } from 'express';
import borrowingRoutes from './routes/borrowingRoute';
import path from 'path';
import { fileURLToPath } from 'url';
import { Pool } from 'pg';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const port = 3000;

// Database connection pool
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT) || 5432,
  database: process.env.DB_NAME || 'library',
  user: process.env.DB_USER || 'postgres',
  password: process.env.DB_PASSWORD || '',
});

app.use(express.json());

// Serve static files from public directory
app.use(express.static(path.join(__dirname, '../public')));

// Root endpoint - redirect to UI
app.get('/', (req: Request, res: Response, next: NextFunction) => {
    res.sendFile(path.join(__dirname, '../public/index.html'));
});

// Test data endpoint
app.get('/api/test-data', (req: Request, res: Response) => {
    const testData = {
        members: [
            { 
                member_id: 1, 
                first_name: 'John', 
                last_name: 'Doe', 
                email: 'john.doe@example.com',
                current_borrow_count: 2,
                has_overdue_books: false
            },
            { 
                member_id: 2, 
                first_name: 'Jane', 
                last_name: 'Smith', 
                email: 'jane.smith@example.com',
                current_borrow_count: 1,
                has_overdue_books: false
            },
            { 
                member_id: 3, 
                first_name: 'Robert', 
                last_name: 'Johnson', 
                email: 'robert.j@example.com',
                current_borrow_count: 0,
                has_overdue_books: false
            },
            { 
                member_id: 4, 
                first_name: 'Emily', 
                last_name: 'Brown', 
                email: 'emily.brown@example.com',
                current_borrow_count: 1,
                has_overdue_books: true
            }
        ],
        books: [
            { 
                book_id: 1, 
                title: 'The Great Gatsby', 
                isbn: '978-0-7432-7356-5', 
                genre: 'Classic Fiction',
                total_copies: 5,
                available_copies: 3 
            },
            { 
                book_id: 2, 
                title: '1984', 
                isbn: '978-0-452-28423-4',
                genre: 'Dystopian Fiction',
                total_copies: 4,
                available_copies: 2 
            },
            { 
                book_id: 3, 
                title: 'To Kill a Mockingbird', 
                isbn: '978-0-061-12008-4',
                genre: 'Classic Fiction',
                total_copies: 6,
                available_copies: 4 
            },
            { 
                book_id: 4, 
                title: 'Pride and Prejudice', 
                isbn: '978-0-141-19943-0',
                genre: 'Romance',
                total_copies: 3,
                available_copies: 0 
            },
            { 
                book_id: 5, 
                title: 'The Catcher in the Rye', 
                isbn: '978-0-316-76948-0',
                genre: 'Coming of Age',
                total_copies: 4,
                available_copies: 2 
            }
        ],
        loans: [
            { 
                loan_id: 1, 
                member_id: 1, 
                copy_id: 1, 
                borrow_date: new Date(Date.now() - 5 * 24 * 60 * 60 * 1000), 
                due_date: new Date(Date.now() + 9 * 24 * 60 * 60 * 1000),
                is_overdue: false
            },
            { 
                loan_id: 2, 
                member_id: 1, 
                copy_id: 5, 
                borrow_date: new Date(Date.now() - 3 * 24 * 60 * 60 * 1000), 
                due_date: new Date(Date.now() + 11 * 24 * 60 * 60 * 1000),
                is_overdue: false
            },
            { 
                loan_id: 3, 
                member_id: 2, 
                copy_id: 3, 
                borrow_date: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000), 
                due_date: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
                is_overdue: false
            },
            { 
                loan_id: 4, 
                member_id: 4, 
                copy_id: 8, 
                borrow_date: new Date(Date.now() - 20 * 24 * 60 * 60 * 1000), 
                due_date: new Date(Date.now() - 6 * 24 * 60 * 60 * 1000),
                is_overdue: true
            }
        ]
    };
    res.json(testData);
});

// Health check endpoint
app.get('/api/health', (req: Request, res: Response) => {
    res.json({ status: 'ok', service: 'borrowing-api', timestamp: new Date() });
});

// Database connection test endpoint
app.get('/api/db-test', async (req: Request, res: Response) => {
    try {
        const client = await pool.connect();
        const result = await client.query('SELECT NOW() as current_time, version()');
        client.release();
        res.json({ 
            status: 'connected', 
            database: process.env.DB_NAME || 'library',
            host: process.env.DB_HOST || 'localhost',
            current_time: result.rows[0].current_time,
            version: result.rows[0].version
        });
    } catch (error) {
        res.status(500).json({ 
            status: 'error', 
            message: 'Database connection failed',
            error: (error as Error).message,
            hint: 'Make sure PostgreSQL is running and the database exists'
        });
    }
});

// Borrowing API routes
app.use('/api/borrowings', borrowingRoutes);

// 404 handler
app.use((req: Request, res: Response) => {
    res.status(404).json({ error: 'Route not found' });
});

app.listen(port, () => {
    console.log(`\n🚀 App listening on port ${port}`);
    console.log(`\n📊 UI Dashboard: http://localhost:${port}`);
    console.log(`\n📋 Available Endpoints:`);
    console.log(`   Test data:        http://localhost:${port}/api/test-data`);
    console.log(`   Health check:     http://localhost:${port}/api/health`);
    console.log(`   DB Connection:    http://localhost:${port}/api/db-test`);
    console.log(`   Borrowing API:    http://localhost:${port}/api/borrowings`);
    console.log(`\n💾 Database: ${process.env.DB_NAME || 'library'} @ ${process.env.DB_HOST || 'localhost'}:${process.env.DB_PORT || 5432}`);
    console.log(`\n✨ Open http://localhost:${port} in your browser to test all endpoints!\n`);
});