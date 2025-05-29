//
//  LogWaterView.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 26.01.2025.
//

import SwiftUI
import SwiftData
import Toasts

struct LogWaterView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.presentToast) private var presentToast
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var waterViewModel: WaterIntakeViewModel
    
    @State private var amount: Int = 250 // Default to 250ml
    
    // Common water amounts for quick selection
    private let quickAmounts = [100, 250, 300, 500, 750, 1000]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                // Quick amount buttons
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Add")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(quickAmounts, id: \.self) { quickAmount in
                            Button {
                                amount = quickAmount
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "waterbottle.fill")
                                        .font(.title2)
                                    Text("\(quickAmount)ml")
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .foregroundColor(amount == quickAmount ? .white : .blue)
                                .frame(height: 60)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(amount == quickAmount ? .blue : .blue.opacity(0.1))
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Custom amount picker
                Form {
                    Section("Custom Amount") {
                        Picker("Amount (ml)", selection: $amount) {
                            ForEach(Array(stride(from: 50, to: 2000, by: 50)), id: \.self) { value in
                                Text("\(value) ml").tag(value)
                            }
                        }
                        .pickerStyle(.wheel)
                    }
                }
            }
            .navigationTitle("Log Water")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        logWater()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private func logWater() {
        let waterIntake = WaterIntake(amount: Double(amount))
        modelContext.insert(waterIntake)
        
        do {
            try modelContext.save()
            
            let toast = ToastValue(
                icon: Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.blue),
                message: "\(amount)ml added to today's intake"
            )
            presentToast(toast)
            
            dismiss()
        } catch {
            print("Failed to save water intake: \(error)")
            
            let toast = ToastValue(
                icon: Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red),
                message: "Failed to log water intake"
            )
            presentToast(toast)
        }
    }
}

#Preview {
    LogWaterView()
        .environmentObject(WaterIntakeViewModel.shared)
} 
