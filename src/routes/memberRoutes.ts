import { Router } from 'express';
import { MemberController } from '../controllers/memberController.js';

const router = Router();
const memberController = new MemberController();

// GET /api/members - Get all members
router.get('/', (req, res) => memberController.getAllMembers(req, res));

// GET /api/members/:id - Get member by ID
router.get('/:id', (req, res) => memberController.getMemberById(req, res));

// POST /api/members - Create a new member
router.post('/', (req, res) => memberController.createMember(req, res));

// PUT /api/members/:id - Update a member
router.put('/:id', (req, res) => memberController.updateMember(req, res));

// DELETE /api/members/:id - Delete a member
router.delete('/:id', (req, res) => memberController.deleteMember(req, res));

export default router;
