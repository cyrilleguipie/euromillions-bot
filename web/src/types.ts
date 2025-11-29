// API Types
export interface Draw {
    id: number;
    date: string;
    numbers: number[];
    stars: number[];
}

export interface Grid {
    id: number;
    draw_date: string;
    numbers: number[];
    stars: number[];
    created_at?: string;
}

export interface NewGrid {
    draw_date: string;
    numbers: number[];
    stars: number[];
}

export class APIError extends Error {
    constructor(message: string, public statusCode?: number) {
        super(message);
        this.name = 'APIError';
    }
}
