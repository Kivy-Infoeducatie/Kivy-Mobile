//
//  CalorieHistoryScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 26.01.2025.
//

import Charts
import SwiftUI
import SwiftData

struct CalorieHistoryScreen: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject private var calorieViewModel: CalorieIntakeViewModel
    @EnvironmentObject private var health: HealthKitViewModel
    
    @Query private var calorieIntakes: [CalorieIntake]
    @State private var showGoalEditor = false
    @State private var todayActiveEnergy: Double = 0
    
    private var historyData: [(date: Date, amount: Double)] {
        calorieViewModel.getDailyIntakeHistory(from: calorieIntakes)
    }
    
    private var todayIntake: Double {
        calorieViewModel.getTodayIntake(from: calorieIntakes)
    }
    
    private var netCalories: Double {
        calorieViewModel.getNetCalories(intake: todayIntake, activeEnergyBurnt: todayActiveEnergy)
    }
    
    private var remainingCalories: Double {
        calorieViewModel.getRemainingCalories(intake: todayIntake, activeEnergyBurnt: todayActiveEnergy)
    }
    
    private var todayIntakesBySource: [IntakeSourceType: [CalorieIntake]] {
        calorieViewModel.getTodayIntakesBySource(from: calorieIntakes)
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
                        // Today's summary with net calories
                        SectionWrapper(title: "Today's Intake", icon: "flame.fill") {
                            VStack(spacing: 16) {
                                HStack(spacing: 20) {
                                    ActivityRingView(
                                        progress: calorieViewModel.getTodayProgress(intake: todayIntake, activeEnergyBurnt: todayActiveEnergy),
                                        mainColor: .orange,
                                        lineWidth: 16
                                    )
                                    .frame(width: 60, height: 60)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("\(Int(netCalories))/\(Int(calorieViewModel.dailyGoal))")
                                            .font(.title2.bold())
                                            + Text(" kcal")
                                            .font(.title3)
                                        
                                        Text("Net calories (intake - burned)")
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                
                                // Breakdown
                                VStack(spacing: 8) {
                                    HStack {
                                        Text("Consumed:")
                                            .font(.callout)
                                        Spacer()
                                        Text("\(Int(todayIntake)) kcal")
                                            .font(.callout.bold())
                                            .foregroundColor(.green)
                                    }
                                    
                                    HStack {
                                        Text("Active Energy Burned:")
                                            .font(.callout)
                                        Spacer()
                                        Text("-\(Int(todayActiveEnergy)) kcal")
                                            .font(.callout.bold())
                                            .foregroundColor(.red)
                                    }
                                    
                                    Divider()
                                    
                                    HStack {
                                        Text("Net Calories:")
                                            .font(.callout.bold())
                                        Spacer()
                                        Text("\(Int(netCalories)) kcal")
                                            .font(.callout.bold())
                                            .foregroundColor(netCalories >= 0 ? .primary : .red)
                                    }
                                    
                                    HStack {
                                        Text("Remaining:")
                                            .font(.callout)
                                        Spacer()
                                        Text("\(Int(remainingCalories)) kcal")
                                            .font(.callout.bold())
                                            .foregroundColor(remainingCalories > 0 ? .blue : .orange)
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(.ultraThinMaterial)
                                )
                                
                                HStack {
                                    Button("Edit Goal") {
                                        showGoalEditor = true
                                    }
                                    .foregroundColor(.orange)
                                    
                                    Spacer()
                                    
                                    Text("Goal: \(Int(calorieViewModel.dailyGoal)) kcal")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        
                        // Today's intake breakdown by source
                        if !todayIntakesBySource.isEmpty {
                            SectionWrapper(title: "Today's Entries", icon: "list.bullet") {
                                LazyVStack(spacing: 12) {
                                    ForEach(IntakeSourceType.allCases, id: \.self) { sourceType in
                                        if let entries = todayIntakesBySource[sourceType], !entries.isEmpty {
                                            VStack(alignment: .leading, spacing: 8) {
                                                HStack {
                                                    Image(systemName: sourceType.icon)
                                                        .foregroundColor(.orange)
                                                    Text(sourceType.displayName)
                                                        .font(.headline)
                                                    Spacer()
                                                    Text("\(Int(entries.reduce(0) { $0 + $1.amount })) kcal")
                                                        .font(.callout.bold())
                                                }
                                                
                                                ForEach(entries.sorted { $0.date > $1.date }, id: \.id) { entry in
                                                    CalorieEntryRow(entry: entry)
                                                }
                                            }
                                        }
                                    }
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
                                        .foregroundStyle(.orange.gradient)
                                        
                                        // Goal line
                                        RuleMark(
                                            y: .value("Goal", calorieViewModel.dailyGoal)
                                        )
                                        .foregroundStyle(.blue)
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
                                    DailyCalorieRow(
                                        date: dayData.date,
                                        amount: dayData.amount,
                                        goal: calorieViewModel.dailyGoal
                                    )
                                }
                                
                                if historyData.isEmpty {
                                    Text("Start logging calories to see your history!")
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
                .onAppear {
                    loadTodayActiveEnergy()
                }
            }
            .navigationTitle("Calorie Intake")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showGoalEditor) {
                EditCalorieGoalScreen()
            }
        }
    }
    
    private func loadTodayActiveEnergy() {
        health.readActiveEnergyBurnedToday { energy in
            todayActiveEnergy = round(energy)
        }
    }
}

struct CalorieEntryRow: View {
    let entry: CalorieIntake
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.source)
                    .font(.callout)
                    .lineLimit(1)
                
                Text(entry.date.formatted(.dateTime.hour().minute()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                if let notes = entry.notes, !notes.isEmpty, notes != entry.source {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            Text("\(Int(entry.amount)) kcal")
                .font(.callout.bold())
        }
        .padding(.vertical, 4)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
    }
}

struct DailyCalorieRow: View {
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
                    .foregroundColor(isToday ? .orange : .primary)
                
                Text(date.formatted(.dateTime.month(.abbreviated).day()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("\(Int(amount)) kcal")
                    .font(.callout.bold())
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            // Mini progress bar
            ProgressView(value: min(progress, 1.0))
                .frame(width: 60)
                .tint(.orange)
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isToday ? .orange.opacity(0.1) : .clear)
        )
    }
}

struct EditCalorieGoalScreen: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var calorieViewModel: CalorieIntakeViewModel
    @State private var goal: Double = 2000
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Daily Calorie Goal") {
                    Picker("Goal (kcal)", selection: $goal) {
                        ForEach(Array(stride(from: 1200.0, to: 4000.0, by: 50.0)), id: \.self) { value in
                            Text("\(Int(value)) kcal").tag(value)
                        }
                    }
                    .pickerStyle(.wheel)
                }
                
                Section {
                    Text("Your daily calorie goal should align with your health and fitness objectives. This represents your net calorie target (intake minus active energy burned).")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Edit Calorie Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        calorieViewModel.updateDailyGoal(goal)
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            goal = calorieViewModel.dailyGoal
        }
    }
}

#Preview {
    CalorieHistoryScreen()
        .environmentObject(CalorieIntakeViewModel.shared)
        .environmentObject(HealthKitViewModel.shared)
} 