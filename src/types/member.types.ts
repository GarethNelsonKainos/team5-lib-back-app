export interface Member {
    member_id: number;
    first_name: string;
    last_name: string;
    email: string;
    phone?: string;
    street?: string;
    city?: string;
    state?: string;
    zip_code?: string;
    registration_date?: Date;
    current_borrow_count?: number;
    has_overdue_books?: boolean;
    created_at?: Date;
    updated_at?: Date;
}

export interface CreateMemberDTO {
    first_name: string;
    last_name: string;
    email: string;
    phone?: string;
    street?: string;
    city?: string;
    state?: string;
    zip_code?: string;
}

export interface UpdateMemberDTO {
    first_name?: string;
    last_name?: string;
    email?: string;
    phone?: string;
    street?: string;
    city?: string;
    state?: string;
    zip_code?: string;
}
