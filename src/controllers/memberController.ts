import { Request, Response } from 'express';
import { MemberService } from '../services/memberService.js';
import { CreateMemberDTO, UpdateMemberDTO } from '../types/member.types.js';

const memberService = new MemberService();

export class MemberController {
    /**
     * GET /api/members
     * Get all members
     */
    async getAllMembers(req: Request, res: Response): Promise<void> {
        try {
            const members = await memberService.getAllMembers();
            res.status(200).json({
                success: true,
                data: members,
                count: members.length
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error fetching members',
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
            res.status(500).json({
                success: false,
                message: 'Error fetching member',
                error: error instanceof Error ? error.message : 'Unknown error'
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

            // Check if email already exists
            const existingMember = await memberService.getMemberByEmail(memberData.email);
            if (existingMember) {
                res.status(409).json({
                    success: false,
                    message: 'Member with this email already exists'
                });
                return;
            }

            const newMember = await memberService.createMember(memberData);
            
            res.status(201).json({
                success: true,
                message: 'Member created successfully',
                data: newMember
            });
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error creating member',
                error: error instanceof Error ? error.message : 'Unknown error'
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

            const memberData: UpdateMemberDTO = req.body;

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

                // Check if email already exists for a different member
                const existingMember = await memberService.getMemberByEmail(memberData.email);
                if (existingMember && existingMember.member_id !== id) {
                    res.status(409).json({
                        success: false,
                        message: 'Email already in use by another member'
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
        } catch (error) {
            res.status(500).json({
                success: false,
                message: 'Error updating member',
                error: error instanceof Error ? error.message : 'Unknown error'
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
            res.status(500).json({
                success: false,
                message: 'Error deleting member',
                error: error instanceof Error ? error.message : 'Unknown error'
            });
        }
    }
}
