//
//  WaterHistoryScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 26.01.2025.
//

import Charts
import SwiftUI
import SwiftData

struct WaterHistoryScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var waterViewModel: WaterIntakeViewModel
    
    @Query private var waterIntakes: [WaterIntake]
    @State private var showGoalEditor = false
    
    private var historyData: [(date: Date, amount: Double)] {
        waterViewModel.getDailyIntakeHistory(from: waterIntakes)
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                if colorScheme == .dark {
                    CustomMeshGradientView()
                        .ignoresSafeArea()
                } else {
                    LightMeshGradientView()
                        .ignoresSafeArea()
                }
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Today's summary
                        SectionWrapper(title: "Today's Intake", icon: "waterbottle.fill") {
                            VStack(spacing: 16) {
                                HStack(spacing: 20) {
                                    ActivityRingView(
                                        progress: waterViewModel.getTodayProgress(from: waterIntakes),
                                        mainColor: .blue,
                                        lineWidth: 16
                                    )
                                    .frame(width: 60, height: 60)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(Int(waterViewModel.getTodayIntake(from: waterIntakes)))/\(Int(waterViewModel.dailyGoal))")
                                            .font(.title2.bold())
                                            + Text(" ml")
                                            .font(.title3)
                                        
                                        Text("\(Int(waterViewModel.getTodayProgress(from: waterIntakes) * 100))% of daily goal")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                
                                HStack {
                                    Button("Edit Goal") {
                                        showGoalEditor = true
                                    }
                                    .foregroundColor(.blue)
                                    
                                    Spacer()
                                    
                                    Text("Goal: \(Int(waterViewModel.dailyGoal))ml")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                        // Chart
                        SectionWrapper(title: "30-Day History", icon: "chart.bar.fill") {
                            VStack(alignment: .leading, spacing: 12) {
                                if historyData.isEmpty {
                                    Text("No data available")
                                        .foregroundStyle(.secondary)
                                        .frame(height: 200)
                                        .frame(maxWidth: .infinity)
                                } else {
                                    Chart(historyData, id: \.date) {
                                        BarMark(
                                            x: .value("Date", $0.date, unit: .day),
                                            y: .value("Amount", $0.amount)
                                        )
                                        .foregroundStyle(.blue.gradient)
                                        
                                        // Goal line
                                        RuleMark(
                                            y: .value("Goal", waterViewModel.dailyGoal)
                                        )
                                        .foregroundStyle(.orange)
                                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                                    }
                                    .frame(height: 200)
                                    .chartYAxis {
                                        AxisMarks(position: .leading) { value in
                                            AxisValueLabel {
                                                if let intValue = value.as(Double.self) {
                                                    Text("\(Int(intValue))")
                                                }
                                            }
                                        }
                                    }
                                    .chartXAxis {
                                        AxisMarks(values: .stride(by: .day, count: 7)) { value in
                                            AxisValueLabel(format: .dateTime.month(.abbreviated).day())
                                        }
                                    }
                                }
                            }
                        }
                        
                        // Daily breakdown
                        SectionWrapper(title: "Recent Days", icon: "calendar") {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(historyData.suffix(7).reversed()), id: \.date) { dayData in
                                    DailyWaterRow(
                                        date: dayData.date,
                                        amount: dayData.amount,
                                        goal: waterViewModel.dailyGoal
                                    )
                                }
                                
                                if historyData.isEmpty {
                                    Text("Start logging water to see your history!")
                                        .foregroundStyle(.secondary)
                                        .font(.callout)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Water Intake")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showGoalEditor) {
                EditWaterGoalScreen()
            }
        }
    }
}

struct DailyWaterRow: View {
    let date: Date
    let amount: Double
    let goal: Double
    
    private var progress: Double {
        return amount / goal
    }
    
    private var isToday: Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(isToday ? "Today" : date.formatted(.dateTime.weekday(.wide).month(.abbreviated).day()))
                    .font(.callout.bold())
                    .foregroundColor(isToday ? .blue : .primary)
                
                Text(date.formatted(.dateTime.month(.abbreviated).day()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(amount))ml")
                    .font(.callout.bold())
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Mini progress bar
            ProgressView(value: min(progress, 1.0))
                .frame(width: 60)
                .tint(.blue)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isToday ? .blue.opacity(0.1) : .clear)
        )
    }
}

struct EditWaterGoalScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var waterViewModel: WaterIntakeViewModel
    @State private var goal: Double = 1800
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Water Goal") {
                    Picker("Goal (ml)", selection: $goal) {
                        ForEach(Array(stride(from: 500.0, to: 4000.0, by: 100.0)), id: \.self) { value in
                            Text("\(Int(value)) ml").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                Section {
                    Text("Recommended daily water intake varies by person, but generally ranges from 1500-3000ml per day.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Edit Water Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        waterViewModel.updateDailyGoal(goal)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            goal = waterViewModel.dailyGoal
        }
    }
}

#Preview {
    WaterHistoryScreen()
        .environmentObject(WaterIntakeViewModel.shared)
} 