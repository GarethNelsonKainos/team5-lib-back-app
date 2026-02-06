import { Request, Response, Router } from 'express';
import { MemberService } from '../services/memberService.js';
import { CreateMemberDTO, UpdateMemberDTO } from '../types/member.types.js';
import { sanitizeMemberData } from '../utils/sanitize.js';

const memberService = new MemberService();

export class MemberController {
    /**
     * GET /api/members?page=1&limit=50
     * Get all members with optional pagination
     */
    async getAllMembers(req: Request, res: Response): Promise<void> {
        try {
            const page = req.query.page ? parseInt(String(req.query.page)) : undefined;
            const limit = req.query.limit ? parseInt(String(req.query.limit)) : undefined;
            
            // Validate pagination parameters
            if (page !== undefined && (isNaN(page) || page < 1)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid page number. Must be a positive integer.'
                });
                return;
            }
            
            if (limit !== undefined && (isNaN(limit) || limit < 1 || limit > 100)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid limit. Must be between 1 and 100.'
                });
                return;
            }
            
            const { members, total } = await memberService.getAllMembers(page, limit);
            
            const response: any = {
                success: true,
                data: members,
                count: members.length,
                total: total
            };
            
            // Add pagination metadata if pagination is used
            if (page && limit) {
                response.pagination = {
                    page,
                    limit,
                    totalPages: Math.ceil(total / limit),
                    hasNextPage: page * limit < total,
                    hasPrevPage: page > 1
                };
            }
            
            res.status(200).json(response);
        } catch (error) {
            console.error('Error fetching members:', error);
            res.status(500).json({
                success: false,
                message: 'Error fetching members',
                error: process.env.NODE_ENV === 'development' 
                    ? (error instanceof Error ? error.message : 'Unknown error')
                    : undefined
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
                    message: 'Invalid member ID'
                });
                return;
            }

            const member = await memberService.getMemberById(id);
            
            if (!member) {
                res.status(404).json({
                    success: false,
                    message: 'Member not found'
                });
                return;
            }

            res.status(200).json({
                success: true,
                data: member
            });
        } catch (error) {
            console.error('Error fetching member:', error);
            res.status(500).json({
                success: false,
                message: 'Error fetching member',
                error: process.env.NODE_ENV === 'development'
                    ? (error instanceof Error ? error.message : 'Unknown error')
                    : undefined
            });
        }
    }

    /**
     * POST /api/members
     * Create a new member
     */
    async createMember(req: Request, res: Response): Promise<void> {
        try {
            // Sanitize input data
            const memberData: CreateMemberDTO = sanitizeMemberData(req.body);

            // Validate required fields
            if (!memberData.first_name || !memberData.last_name || !memberData.email) {
                res.status(400).json({
                    success: false,
                    message: 'Missing required fields: first_name, last_name, and email are required'
                });
                return;
            }

            // Validate email format
            const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
            if (!emailRegex.test(memberData.email)) {
                res.status(400).json({
                    success: false,
                    message: 'Invalid email format'
                });
                return;
            }

            const newMember = await memberService.createMember(memberData);
            
            res.status(201).json({
                success: true,
                message: 'Member created successfully',
                data: newMember
            });
        } catch (error: any) {
            console.error('Error creating member:', error);
            
            // Handle database unique constraint violation
            if (error.code === '23505') {
                res.status(409).json({
                    success: false,
                    message: 'Member with this email already exists'
                });
                return;
            }
            
            res.status(500).json({
                success: false,
                message: 'Error creating member',
                error: process.env.NODE_ENV === 'development'
                    ? (error instanceof Error ? error.message : 'Unknown error')
                    : undefined
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
                    success: false,
                    message: 'Invalid member ID'
                });
                return;
            }

            // Sanitize input data
            const memberData: UpdateMemberDTO = sanitizeMemberData(req.body);

            // Validate email format if provided
            if (memberData.email) {
                const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(memberData.email)) {
                    res.status(400).json({
                        success: false,
                        message: 'Invalid email format'
                    });
                    return;
                }
            }

            const updatedMember = await memberService.updateMember(id, memberData);
            
            if (!updatedMember) {
                res.status(404).json({
                    success: false,
                    message: 'Member not found'
                });
                return;
            }

            res.status(200).json({
                success: true,
                message: 'Member updated successfully',
                data: updatedMember
            });
        } catch (error: any) {
            console.error('Error updating member:', error);
            
            // Handle database unique constraint violation
            if (error.code === '23505') {
                res.status(409).json({
                    success: false,
                    message: 'Email already in use by another member'
                });
                return;
            }
            
            res.status(500).json({
                success: false,
                message: 'Error updating member',
                error: process.env.NODE_ENV === 'development'
                    ? (error instanceof Error ? error.message : 'Unknown error')
                    : undefined
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
                    success: false,
                    message: 'Invalid member ID'
                });
                return;
            }

            const deleted = await memberService.deleteMember(id);
            
            if (!deleted) {
                res.status(404).json({
                    success: false,
                    message: 'Member not found'
                });
                return;
            }

            res.status(200).json({
                success: true,
                message: 'Member deleted successfully'
            });
        } catch (error) {
            console.error('Error deleting member:', error);
            res.status(500).json({
                success: false,
                message: 'Error deleting member',
                error: process.env.NODE_ENV === 'development'
                    ? (error instanceof Error ? error.message : 'Unknown error')
                    : undefined
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
