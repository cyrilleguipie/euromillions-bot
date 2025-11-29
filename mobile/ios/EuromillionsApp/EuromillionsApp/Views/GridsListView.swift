//
//  GridsListView.swift
//  EuromillionsApp
//
//  Main view displaying list of generated grids
//

import SwiftUI

struct GridsListView: View {
    @State private var grids: [Grid] = []
    @State private var isLoading = false
    @State private var isGenerating = false
    @State private var errorMessage: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                if isLoading {
                    ProgressView("Loading grids...")
                } else if grids.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "star.circle")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        Text("No grids yet")
                            .font(.title2)
                            .foregroundColor(.secondary)
                        Text("Tap the button below to generate your first grids")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    List(grids) { grid in
                        NavigationLink(destination: GridDetailView(grid: grid)) {
                            GridRowView(grid: grid)
                        }
                    }
                    .refreshable {
                        await loadGrids()
                    }
                }
            }
            .navigationTitle("My Grids")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task {
                            await generateGrids()
                        }
                    }) {
                        if isGenerating {
                            ProgressView()
                        } else {
                            Label("Generate", systemImage: "plus.circle.fill")
                        }
                    }
                    .disabled(isGenerating)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: HistoryView()) {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }
                }
            }
            .alert("Error", isPresented: .constant(errorMessage != nil)) {
                Button("OK") {
                    errorMessage = nil
                }
            } message: {
                if let error = errorMessage {
                    Text(error)
                }
            }
            .task {
                await loadGrids()
            }
        }
    }
    
    private func loadGrids() async {
        isLoading = true
        errorMessage = nil
        
        do {
            grids = try await APIClient.shared.fetchGrids()
        } catch {
            errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func generateGrids() async {
        isGenerating = true
        errorMessage = nil
        
        do {
            _ = try await APIClient.shared.generateGrids()
            // Reload grids after generation
            await loadGrids()
        } catch {
            errorMessage = (error as? APIError)?.localizedDescription ?? error.localizedDescription
        }
        
        isGenerating = false
    }
}

// MARK: - Grid Row View
struct GridRowView: View {
    let grid: Grid
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(formattedDate(grid.drawDate))
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 4) {
                Text("Numbers:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ForEach(grid.numbers, id: \.self) { number in
                    Text("\(number)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color.blue))
                }
            }
            
            HStack(spacing: 4) {
                Text("Stars:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                ForEach(grid.stars, id: \.self) { star in
                    Text("\(star)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Circle().fill(Color.orange))
                }
            }
            
            if let createdAt = grid.createdAt {
                Text("Generated: \(formattedDateTime(createdAt))")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formattedDateTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

#Preview {
    GridsListView()
}
