import { Member, CreateMemberDTO, UpdateMemberDTO } from '../types/member.types.js';
import pool from '../config/database.js';

export class MemberService {
    /**
     * Get all members with optional pagination
     */
    async getAllMembers(page?: number, limit?: number): Promise<{ members: Member[], total: number }> {
        if (page && limit) {
            const offset = (page - 1) * limit;
            
            // Get total count
            const countResult = await pool.query('SELECT COUNT(*) FROM members');
            const total = parseInt(countResult.rows[0].count);
            
            // Get paginated results
            const result = await pool.query(
                'SELECT * FROM members ORDER BY member_id LIMIT $1 OFFSET $2',
                [limit, offset]
            );
            
            return {
                members: result.rows,
                total
            };
        }
        
        // No pagination - return all
        const result = await pool.query('SELECT * FROM members ORDER BY member_id');
        return {
            members: result.rows,
            total: result.rows.length
        };
    }

    /**
     * Get member by ID
     */
    async getMemberById(id: number): Promise<Member | null> {
        const result = await pool.query('SELECT * FROM members WHERE member_id = $1', [id]);
        return result.rows[0] || null;
    }

    /**
     * Create a new member
     */
    async createMember(memberData: CreateMemberDTO): Promise<Member> {
        const result = await pool.query(
            `INSERT INTO members (
                first_name, last_name, email, phone, street, city, state, zip_code,
                registration_date, current_borrow_count, has_overdue_books, created_at, updated_at
            )
            VALUES ($1, $2, $3, $4, $5, $6, $7, $8, CURRENT_DATE, 0, false, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP)
            RETURNING *`,
            [
                memberData.first_name,
                memberData.last_name,
                memberData.email,
                memberData.phone || null,
                memberData.street || null,
                memberData.city || null,
                memberData.state || null,
                memberData.zip_code || null
            ]
        );
        return result.rows[0];
    }

    /**
     * Update a member
     */
    async updateMember(id: number, memberData: UpdateMemberDTO): Promise<Member | null> {
        const result = await pool.query(
            `UPDATE members 
            SET first_name = COALESCE($2, first_name),
                last_name = COALESCE($3, last_name),
                email = COALESCE($4, email),
                phone = COALESCE($5, phone),
                street = COALESCE($6, street),
                city = COALESCE($7, city),
                state = COALESCE($8, state),
                zip_code = COALESCE($9, zip_code),
                updated_at = CURRENT_TIMESTAMP
            WHERE member_id = $1
            RETURNING *`,
            [
                id,
                memberData.first_name ?? null,
                memberData.last_name ?? null,
                memberData.email ?? null,
                memberData.phone ?? null,
                memberData.street ?? null,
                memberData.city ?? null,
                memberData.state ?? null,
                memberData.zip_code ?? null
            ]
        );
        return result.rows[0] || null;
    }

    /**
     * Delete a member
     */
    async deleteMember(id: number): Promise<boolean> {
        const result = await pool.query('DELETE FROM members WHERE member_id = $1', [id]);
        return result.rowCount !== null && result.rowCount > 0;
    }

    /**
     * Get member by email
     */
    async getMemberByEmail(email: string): Promise<Member | null> {
        const result = await pool.query('SELECT * FROM members WHERE email = $1', [email]);
        return result.rows[0] || null;
    }
}
