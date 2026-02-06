import 'dotenv/config';
import express from 'express';
import { Request, Response } from 'express';
import borrowingRoutes from './controllers/borrowingController.js';
import { testConnection } from './config/database.js';

const app = express();
const port = 3000;

app.use(express.json());

// Routes
app.use('/api/borrowings', borrowingRoutes);

// Root endpoint
app.get('/', (req: Request, res: Response) => {
    res.send('Hello world!');
});

// Start server
app.listen(port, async () => {
    console.log(`App listening on port ${port}`);
    await testConnection();
});
