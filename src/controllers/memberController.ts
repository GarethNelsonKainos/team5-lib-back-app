import { Request, Response, Router } from 'express';
import { MemberService } from '../services/memberService.js';
import { CreateMemberDTO, UpdateMemberDTO } from '../types/member.types.js';
import { isValidEmail } from '../utils/validation.js';

export class MemberController {
    private memberService: MemberService;

    constructor(memberService: MemberService = new MemberService()) {
        this.memberService = memberService;
    }

    /**
     * GET /api/members
     * Get all members
     */
    async getAllMembers(req: Request, res: Response): Promise<void> {
        try {
            const members = await this.memberService.getAllMembers();
            res.status(200).json({
                data: members
            });
        } catch (error) {
            res.status(500).json({
                error: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    }

    /**
     * GET /api/members/:id
     * Get member by ID
     */
    async getMemberById(req: Request, res: Response): Promise<void> {
        try {
            const id = parseInt(String(req.params.id));
            
            if (isNaN(id)) {
                res.status(400).json({
                    success: false,
                    error: 'Invalid member ID'
                });
                return;
            }

            const member = await this.memberService.getMemberById(id);
            
            if (!member) {
                res.status(404).json({
                    error: 'Member not found'
                });
                return;
            }

            res.status(200).json({
                data: member
            });
        } catch (error) {
            res.status(500).json({
                error: error instanceof Error ? error.message : 'Error fetching member'
            });
        }
    }

    /**
     * POST /api/members
     * Create a new member
     */
    async createMember(req: Request, res: Response): Promise<void> {
        try {
            const memberData: CreateMemberDTO = req.body;

            // Validate required fields
            if (!memberData.first_name || !memberData.last_name || !memberData.email) {
                res.status(400).json({
                    error: 'Missing required fields: first_name, last_name, and email are required'
                });
                return;
            }

            // Validate email format
            if (!isValidEmail(memberData.email)) {
                res.status(400).json({
                    error: 'Invalid email format'
                });
                return;
            }

            // Check if email already exists
            const existingMember = await this.memberService.getMemberByEmail(memberData.email);
            if (existingMember) {
                res.status(409).json({
                    error: 'Member with this email already exists'
                });
                return;
            }

            const newMember = await this.memberService.createMember(memberData);
            
            res.status(201).json({
                message: 'Member created successfully',
                data: newMember
            });
        } catch (error) {
            res.status(500).json({
                error: error instanceof Error ? error.message : 'Error creating member'
            });
        }
    }

    /**
     * PUT /api/members/:id
     * Update a member
     */
    async updateMember(req: Request, res: Response): Promise<void> {
        try {
            const id = parseInt(String(req.params.id));
            
            if (isNaN(id)) {
                res.status(400).json({
                    error: 'Invalid member ID'
                });
                return;
            }

            const memberData: UpdateMemberDTO = req.body;

            // Validate email format if provided
            if (memberData.email) {
                if (!isValidEmail(memberData.email)) {
                    res.status(400).json({
                        error: 'Invalid email format'
                    });
                    return;
                }

                // Check if email already exists for a different member
                const existingMember = await this.memberService.getMemberByEmail(memberData.email);
                if (existingMember && existingMember.member_id !== id) {
                    res.status(409).json({
                        error: 'Email already in use by another member'
                    });
                    return;
                }
            }

            const updatedMember = await this.memberService.updateMember(id, memberData);
            
            if (!updatedMember) {
                res.status(404).json({
                    error: 'Member not found'
                });
                return;
            }

            res.status(200).json({
                message: 'Member updated successfully',
                data: updatedMember
            });
        } catch (error) {
            res.status(500).json({
                error: error instanceof Error ? error.message : 'Error updating member'
            });
        }
    }

    /**
     * DELETE /api/members/:id
     * Delete a member
     */
    async deleteMember(req: Request, res: Response): Promise<void> {
        try {
            const id = parseInt(String(req.params.id));
            
            if (isNaN(id)) {
                res.status(400).json({
                    error: 'Invalid member ID'
                });
                return;
            }

            const deleted = await this.memberService.deleteMember(id);
            
            if (!deleted) {
                res.status(404).json({
                    error: 'Member not found'
                });
                return;
            }

            res.status(200).json({
                message: 'Member deleted successfully'
            });
        } catch (error) {
            res.status(500).json({
                error: error instanceof Error ? error.message : 'Error deleting member'
            });
        }
    }
}

// Create router and define routes
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
