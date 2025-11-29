//
//  Models.swift
//  EuromillionsApp
//
//  Data models for Euromillions API
//

import Foundation

// MARK: - Draw Model
struct Draw: Codable, Identifiable {
    let id: Int
    let date: Date
    let numbers: [Int]
    let stars: [Int]
    
    enum CodingKeys: String, CodingKey {
        case id, date, numbers, stars
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        
        // Decode date string to Date
        let dateString = try container.decode(String.self, forKey: .date)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let parsedDate = formatter.date(from: dateString) {
            date = parsedDate
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .date,
                in: container,
                debugDescription: "Date string does not match format yyyy-MM-dd"
            )
        }
        
        numbers = try container.decode([Int].self, forKey: .numbers)
        stars = try container.decode([Int].self, forKey: .stars)
    }
}

// MARK: - Grid Model
struct Grid: Codable, Identifiable {
    let id: Int
    let drawDate: Date
    let numbers: [Int]
    let stars: [Int]
    let createdAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case id
        case drawDate = "draw_date"
        case numbers, stars
        case createdAt = "created_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Decode draw_date
        let drawDateString = try container.decode(String.self, forKey: .drawDate)
        if let parsedDate = dateFormatter.date(from: drawDateString) {
            drawDate = parsedDate
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .drawDate,
                in: container,
                debugDescription: "Date string does not match format yyyy-MM-dd"
            )
        }
        
        numbers = try container.decode([Int].self, forKey: .numbers)
        stars = try container.decode([Int].self, forKey: .stars)
        
        // Decode created_at (ISO 8601 datetime)
        if let createdAtString = try container.decodeIfPresent(String.self, forKey: .createdAt) {
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let parsedDate = isoFormatter.date(from: createdAtString) {
                createdAt = parsedDate
            } else {
                // Try without fractional seconds
                isoFormatter.formatOptions = [.withInternetDateTime]
                createdAt = isoFormatter.date(from: createdAtString)
            }
        } else {
            createdAt = nil
        }
    }
}

// MARK: - New Grid (for generation response)
struct NewGrid: Codable {
    let drawDate: Date
    let numbers: [Int]
    let stars: [Int]
    
    enum CodingKeys: String, CodingKey {
        case drawDate = "draw_date"
        case numbers, stars
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let drawDateString = try container.decode(String.self, forKey: .drawDate)
        if let parsedDate = dateFormatter.date(from: drawDateString) {
            drawDate = parsedDate
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .drawDate,
                in: container,
                debugDescription: "Date string does not match format yyyy-MM-dd"
            )
        }
        
        numbers = try container.decode([Int].self, forKey: .numbers)
        stars = try container.decode([Int].self, forKey: .stars)
    }
}

// MARK: - API Error
enum APIError: Error {
    case invalidURL
    case networkError(Error)
    case decodingError(Error)
    case serverError(String)
    case unknownError
    
    var localizedDescription: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .decodingError(let error):
            return "Failed to decode response: \(error.localizedDescription)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .unknownError:
            return "An unknown error occurred"
        }
    }
}
