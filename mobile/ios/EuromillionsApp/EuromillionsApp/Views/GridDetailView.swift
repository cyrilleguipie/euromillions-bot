//
//  GridDetailView.swift
//  EuromillionsApp
//
//  Detailed view of a single grid
//

import SwiftUI

struct GridDetailView: View {
    let grid: Grid
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 8) {
                    Text("Grid for")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    Text(formattedDate(grid.drawDate))
                        .font(.title)
                        .fontWeight(.bold)
                }
                .padding(.top, 20)
                
                // Numbers Section
                VStack(spacing: 16) {
                    Text("Numbers")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 12) {
                        ForEach(grid.numbers, id: \.self) { number in
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 55, height: 55)
                                    .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 2)
                                
                                Text("\(number)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(.vertical)
                
                Divider()
                    .padding(.horizontal, 40)
                
                // Stars Section
                VStack(spacing: 16) {
                    Text("Lucky Stars")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 16) {
                        ForEach(grid.stars, id: \.self) { star in
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.orange, Color.yellow]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 55, height: 55)
                                    .shadow(color: .orange.opacity(0.4), radius: 5, x: 0, y: 2)
                                
                                Image(systemName: "star.fill")
                                    .foregroundColor(.white)
                                    .font(.caption)
                                
                                Text("\(star)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding(.vertical)
                
                // Info Section
                if let createdAt = grid.createdAt {
                    VStack(spacing: 8) {
                        Divider()
                            .padding(.horizontal, 40)
                            .padding(.top, 20)
                        
                        Text("Generated on")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(formattedDateTime(createdAt))
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 20)
                }
            }
            .padding()
        }
        .navigationTitle("Grid Details")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    NavigationView {
        GridDetailView(grid: Grid(
            id: 1,
            drawDate: Date(),
            numbers: [5, 12, 23, 34, 45],
            stars: [3, 9],
            createdAt: Date()
        ))
    }
}
