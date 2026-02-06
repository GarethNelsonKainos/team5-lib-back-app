/**
 * Sanitize string input by trimming whitespace
 */
export const sanitizeString = (value: string | undefined): string | undefined => {
    if (value === undefined || value === null) {
        return undefined;
    }
    const trimmed = String(value).trim();
    return trimmed === '' ? undefined : trimmed;
};

/**
 * Sanitize member data by trimming all string fields
 */
export const sanitizeMemberData = <T extends Record<string, any>>(data: T): T => {
    const sanitized: any = {};
    
    for (const key in data) {
        if (data.hasOwnProperty(key)) {
            const value = data[key];
            if (typeof value === 'string') {
                sanitized[key] = sanitizeString(value);
            } else {
                sanitized[key] = value;
            }
        }
    }
    
    return sanitized as T;
};
