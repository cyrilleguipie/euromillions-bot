//
//  APIClient.swift
//  EuromillionsApp
//
//  API service layer for Euromillions backend
//

import Foundation

class APIClient {
    static let shared = APIClient()
    
    // Configure this with your deployed API URL
    // For local testing: "http://localhost:8080"
    // For production: your Render.com URL
    private let baseURL = "http://localhost:8080"
    
    private init() {}
    
    // MARK: - Fetch History
    func fetchHistory() async throws -> String {
        guard let url = URL(string: "\(baseURL)/history") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknownError
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw APIError.serverError(errorMessage)
            }
            
            return String(data: data, encoding: .utf8) ?? "Success"
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Generate Grids
    func generateGrids() async throws -> [NewGrid] {
        guard let url = URL(string: "\(baseURL)/generate") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknownError
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw APIError.serverError(errorMessage)
            }
            
            let decoder = JSONDecoder()
            let grids = try decoder.decode([NewGrid].self, from: data)
            return grids
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
    
    // MARK: - Fetch Grids
    func fetchGrids() async throws -> [Grid] {
        guard let url = URL(string: "\(baseURL)/grids") else {
            throw APIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.unknownError
            }
            
            guard httpResponse.statusCode == 200 else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                throw APIError.serverError(errorMessage)
            }
            
            let decoder = JSONDecoder()
            let grids = try decoder.decode([Grid].self, from: data)
            return grids
        } catch let error as DecodingError {
            throw APIError.decodingError(error)
        } catch let error as APIError {
            throw error
        } catch {
            throw APIError.networkError(error)
        }
    }
}
