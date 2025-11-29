import type { Draw, Grid, NewGrid } from './types';
import { APIError } from './types';

// Configure this with your deployed API URL
// For local development: 'http://localhost:8080'
// For production: your Render.com URL
const BASE_URL = 'http://localhost:8080';

async function fetchAPI<T>(endpoint: string, options?: RequestInit): Promise<T> {
    const url = `${BASE_URL}${endpoint}`;

    try {
        const response = await fetch(url, {
            ...options,
            headers: {
                'Content-Type': 'application/json',
                ...options?.headers,
            },
        });

        if (!response.ok) {
            const errorText = await response.text();
            throw new APIError(
                errorText || `HTTP error! status: ${response.status}`,
                response.status
            );
        }

        // Handle text responses (like /history endpoint)
        const contentType = response.headers.get('content-type');
        if (contentType && contentType.includes('application/json')) {
            return await response.json();
        } else {
            return await response.text() as T;
        }
    } catch (error) {
        if (error instanceof APIError) {
            throw error;
        }
        throw new APIError(
            error instanceof Error ? error.message : 'Network error occurred'
        );
    }
}

export const api = {
    // Fetch history from the web and store in database
    async fetchHistory(): Promise<string> {
        return fetchAPI<string>('/history');
    },

    // Generate 4 optimized grids for the next draw
    async generateGrids(): Promise<NewGrid[]> {
        return fetchAPI<NewGrid[]>('/generate');
    },

    // Get the 20 most recent generated grids
    async fetchGrids(): Promise<Grid[]> {
        return fetchAPI<Grid[]>('/grids');
    },
};
