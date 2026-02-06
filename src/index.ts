import express from 'express';
import { Request, Response, NextFunction } from 'express';
import memberRoutes from './controllers/memberController.js';

const app = express();
const port = 3000

app.use(express.json());

// API Routes
app.use('/api/members', memberRoutes);

// Root route
app.get('/', (req: Request, res: Response, next: NextFunction) => {
    res.send('Hello world!');
});

app.listen(port, () => {
    console.log(`App listening on port ${port}`);
});