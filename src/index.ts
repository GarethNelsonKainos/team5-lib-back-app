import express from 'express';
import { Request, Response, NextFunction } from 'express';
const app = express();
const port = 3000

app.use(express.json());

app.get('/', (req: Request, res: Response, next: NextFunction) => {
    res.send('Hello world!');
});

app.listen(port, () => {
    console.log(`App listening on port ${port}`);
});