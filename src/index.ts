import express from 'express';
import { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import memberRoutes from './controllers/memberController.js';
import pool, { closePool } from './config/database.js';

dotenv.config();

const app = express();
const port = parseInt(process.env.PORT || '3000');

// Middleware
app.use(cors());
app.use(express.json({ limit: '10mb' }));

// Health check endpoint
app.get('/health', async (req: Request, res: Response) => {
    try {
        await pool.query('SELECT 1');
        res.status(200).json({
            status: 'healthy',
            database: 'connected',
            timestamp: new Date().toISOString()
        });
    } catch (error) {
        res.status(503).json({
            status: 'unhealthy',
            database: 'disconnected',
            timestamp: new Date().toISOString(),
            error: error instanceof Error ? error.message : 'Unknown error'
        });
    }
});

// Root route
app.get('/', (req: Request, res: Response, next: NextFunction) => {
    res.json({
        message: 'Library Management API',
        version: '1.0.0',
        endpoints: {
            health: '/health',
            members: '/api/members'
        }
    });
});

// API Routes
app.use('/api/members', memberRoutes);

// Test database connection before starting server
const startServer = async () => {
    try {
        // Test database connection
        await pool.query('SELECT 1');
        console.log('✓ Database connection successful');
        
        const server = app.listen(port, () => {
            console.log(`✓ App listening on port ${port}`);
            console.log(`✓ Environment: ${process.env.NODE_ENV || 'development'}`);
        });
        
        // Graceful shutdown
        const gracefulShutdown = async (signal: string) => {
            console.log(`\n${signal} received. Starting graceful shutdown...`);
            
            server.close(async () => {
                console.log('HTTP server closed');
                
                try {
                    await closePool();
                    console.log('All connections closed. Exiting process.');
                    process.exit(0);
                } catch (err) {
                    console.error('Error during shutdown:', err);
                    process.exit(1);
                }
            });
            
            // Force shutdown after 10 seconds
            setTimeout(() => {
                console.error('Forced shutdown after timeout');
                process.exit(1);
            }, 10000);
        };
        
        process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
        process.on('SIGINT', () => gracefulShutdown('SIGINT'));
        
    } catch (error) {
        console.error('✗ Failed to connect to database:', error);
        console.error('✗ Please ensure PostgreSQL is running and configuration is correct');
        process.exit(1);
    }
};

startServer();