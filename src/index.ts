import express from 'express';
import { Request, Response, NextFunction } from 'express';
import * as dotenv from 'dotenv';
import { setupBookRoutes } from './controllers/book.controller.js';
import { checkDatabaseConnection } from './config/database.js';

// Load environment variables
dotenv.config();

const app = express();
const port = process.env.PORT || 3000;

app.use(express.json());

app.get('/', (req: Request, res: Response, next: NextFunction) => {
    res.send('Hello world!');
});

// Mount book routes
app.use('/api/books', setupBookRoutes());

// Start server with database connection check
const startServer = async () => {
    try {
        // Check database connection
        const isConnected = await checkDatabaseConnection();
        
        if (!isConnected) {
            console.error('❌ Failed to connect to database. Please check your .env configuration.');
            process.exit(1);
        }
        
        app.listen(port, () => {
            console.log(`🚀 Server listening on port ${port}`);
        });
    } catch (error) {
        console.error('❌ Failed to start server:', error);
        process.exit(1);
    }
};

startServer();