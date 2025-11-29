//
//  HistoryView.swift
//  EuromillionsApp
//
//  View to trigger history fetch
//

import SwiftUI

struct HistoryView: View {
    @State private var isFetching = false
    @State private var resultMessage: String?
    @State private var isSuccess = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .padding(.top, 60)
            
            VStack(spacing: 12) {
                Text("Fetch History")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Download the latest Euromillions draw results from the web")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            if let message = resultMessage {
                VStack(spacing: 8) {
                    Image(systemName: isSuccess ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.system(size: 40))
                        .foregroundColor(isSuccess ? .green : .red)
                    
                    Text(message)
                        .font(.body)
                        .foregroundColor(isSuccess ? .green : .red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSuccess ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                )
                .padding(.horizontal, 20)
            }
            
            Spacer()
            
            Button(action: {
                Task {
                    await fetchHistory()
                }
            }) {
                HStack {
                    if isFetching {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "arrow.down.circle.fill")
                        Text("Fetch Now")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .disabled(isFetching)
            .padding(.horizontal, 40)
            .padding(.bottom, 40)
        }
        .navigationTitle("History")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func fetchHistory() async {
        isFetching = true
        resultMessage = nil
        
        do {
            let message = try await APIClient.shared.fetchHistory()
            resultMessage = message
            isSuccess = true
        } catch {
            let errorMsg = (error as? APIError)?.localizedDescription ?? error.localizedDescription
            resultMessage = errorMsg
            isSuccess = false
        }
        
        isFetching = false
    }
}

#Preview {
    NavigationView {
        HistoryView()
    }
}
