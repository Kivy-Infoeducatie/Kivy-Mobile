//
//  GoalsScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 26.01.2025.
//

import Charts
import HealthKit
import SwiftUI

struct GoalsScreen: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var health: HealthKitViewModel
    @EnvironmentObject var goals: GoalsViewModel

    @State private var steps: Double = 0
    @State private var calories: Double = 0
    @State private var distance: Double = 0

    @State private var calorieSamples: [(date: Date, value: Double)] = []
    @State private var stepSamples: [(date: Date, value: Double)] = []
    @State private var distanceSamples: [(date: Date, value: Double)] = []
    
    @StateObject private var targetCalories = GoalsQueries.getTargetCalories()

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
                    VStack(alignment: .leading) {
                        Text("Daily Calorie Goal")
                            .font(.title3.bold())
                        withQueryProgress(targetCalories) { calories in
                            SectionWrapper(title: "Daily Calories", icon: "carrot.fill") {
                                VStack(spacing: 20) {
                                    VStack(alignment: .leading, spacing: 12) {
                                        Text("\(Int(calories.consumed))")
                                            .font(.title2.bold())
                                            +
                                        Text(" out of \(Int(calories.target + self.calories))kcal")
                                            .font(.body)
                                            .fontWeight(.medium)

                                        Gauge(value: 0.4) {}
                                    }
                                    
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("\(Int(calories.target))kcal")
                                                .font(.headline)
                                            Text("base goal")
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Divider()
                                            .overlay(Color.accentColor.opacity(0.3))
                                        Spacer()
                                        VStack(alignment: .leading) {
                                            Text("\(Int(calories.consumed))kcal")
                                                .font(.headline)
                                            Text("consumed")
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Divider()
                                            .overlay(Color.accentColor.opacity(0.3))
                                        Spacer()
                                        VStack(alignment: .leading) {
                                            Text("\(Int(self.calories))kcal")
                                                .font(.headline)
                                            Text("active energy")
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                                .padding(.top, 2)
                            }
                        }

                        Text("Your Goals")
                            .font(.title3.bold())
                            .padding(.top)
                        GoalSectionWrapper(
                            title: "Active Energy",
                            icon: "flame.fill",
                            color: .blue,
                            current: calories,
                            target: goals.activeEnergyGoal,
                            unit: "kcal",
                            samples: calorieSamples,
                            destination: { EditActiveEnergyGoalScreen() }
                        )
                        
                        GoalSectionWrapper(
                            title: "Steps",
                            icon: "figure.walk",
                            color: .orange,
                            current: steps,
                            target: goals.stepsGoal,
                            unit: "steps",
                            samples: stepSamples,
                            destination: { EditStepsGoalScreen() }
                        )
                        
                        GoalSectionWrapper(
                            title: "Distance",
                            icon: "figure.run",
                            color: .purple,
                            current: distance,
                            target: goals.distanceGoal,
                            unit: "m",
                            samples: distanceSamples,
                            destination: { EditDistanceGoalScreen() }
                        )
                    }
                    .padding(.top, 70)
                    .padding(.bottom, 80)
                    .padding(.horizontal)
                }
                .onAppear {
                    health.readActiveEnergyBurnedRecordsToday { samples in
                        calorieSamples = health.groupRecordsByHalfHour(
                            samples,
                            unit: .kilocalorie()
                        )
                    }
                    health.readStepsRecordsToday { samples in
                        stepSamples = health.groupRecordsByHalfHour(
                            samples,
                            unit: .count()
                        )
                    }
                    health.readDistanceWalkingRunningRecordsToday { samples in
                        distanceSamples = health.groupRecordsByHalfHour(
                            samples,
                            unit: .meter()
                        )
                    }

                    health.readStepsCountToday { steps in
                        self.steps = round(steps)
                    }
                    health.readActiveEnergyBurnedToday { calories in
                        self.calories = round(calories)
                    }
                    health.readDistanceWalkingRunningToday { distance in
                        self.distance = round(distance)
                    }
                }
            }
        }
    }
}

#Preview {
    GoalsScreen()
}

struct SectionWrapper<Content: View>: View {
    let title: String
    let icon: String
    let content: Content
    let moreOptions: (() -> Void)?
    
    init(
        title: String, icon: String,
        @ViewBuilder content: @escaping () -> Content,
        moreOptions: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.content = content()
        self.moreOptions = moreOptions
    }
    
    init(
        title: String, icon: String,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.content = content()
        self.moreOptions = nil
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                Text(title)
                    .font(.system(.callout, design: .rounded))
                    .bold()
                
                Spacer()
                
                if let moreOptions {
                    Button(action: moreOptions) {
                        Image(systemName: "ellipsis")
                    }
                }
            }
            .opacity(0.8)
            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(RoundedRectangle(cornerRadius: 20).fill(.thinMaterial))
        .clipShape(.rect(cornerRadius: 20))
    }
}

struct GoalSectionWrapper<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    let current: Double
    let target: Double
    let unit: String
    let samples: [(date: Date, value: Double)]
    let destination: Content
    
    @State private var isDestinationPresented = false
    
    init(
        title: String,
        icon: String,
        color: Color,
        current: Double,
        target: Double,
        unit: String,
        samples: [(date: Date, value: Double)],
        @ViewBuilder destination: @escaping () -> Content
    ) {
        self.title = title
        self.icon = icon
        self.color = color
        self.current = current
        self.target = target
        self.unit = unit
        self.samples = samples
        self.destination = destination()
    }
    
    var body: some View {
        SectionWrapper(title: title, icon: icon) {
            HStack(spacing: 20) {
                ActivityRingView(
                    progress: current / target,
                    mainColor: color,
                    lineWidth: 14
                )
                .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(Int(current))/\(Int(target))")
                        .font(.system(.body, design: .rounded))
                        .bold()
                        + Text(" \(unit)")
                        .font(.system(.callout, design: .rounded))
                    
                    Chart(samples, id: \.date) {
                        RuleMark(
                            x: .value("Start", Calendar.current.startOfToday)
                        )
                        .opacity(0)
                        
                        BarMark(
                            x: .value("Time", $0.date, unit: .minute),
                            y: .value("Value", $0.value),
                            width: 3
                        )
                        .foregroundStyle(color)
                        
                        RuleMark(
                            x: .value("End", Calendar.current.endOfToday)
                        )
                        .opacity(0)
                    }
                    .chartYAxis(.hidden)
                    .frame(height: 40)
                }
            }
            .padding(.horizontal)
        } moreOptions: {
            isDestinationPresented.toggle()
        }
        .sheet(isPresented: $isDestinationPresented) {
            destination
        }
    }
}

struct EditActiveEnergyGoalScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var goals: GoalsViewModel
    @State private var goal: Double = 0
    
    var body: some View {
        NavigationStack {
            Form {
                Text("Goal (kcal)")
                Picker("Goal (kcal)", selection: $goal) {
                    ForEach(Array(stride(from: 5.0, to: 1000.0, by: 5.0)), id: \.self) { value in
                        Text("\(Int(value))").tag(value)
                    }
                }
                .pickerStyle(.wheel)
            }
            .navigationTitle("Edit Active Energy Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        goals.updateActiveEnergyGoal(goal)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            goal = goals.activeEnergyGoal
        }
    }
}

struct EditStepsGoalScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var goals: GoalsViewModel
    @State private var goal: Double = 0
    
    var body: some View {
        NavigationStack {
            Form {
                Text("Goal (steps)")
                Picker("Goal (steps)", selection: $goal) {
                    ForEach(Array(stride(from: 500.0, to: 20000.0, by: 500.0)), id: \.self) { value in
                        Text("\(Int(value))").tag(value)
                    }
                }
                .pickerStyle(.wheel)
            }
            .navigationTitle("Edit Steps Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        goals.updateStepsGoal(goal)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            goal = goals.stepsGoal
        }
    }
}

struct EditDistanceGoalScreen: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var goals: GoalsViewModel
    @State private var goal: Double = 0
    
    var body: some View {
        NavigationStack {
            Form {
                Text("Goal (meters)")
                Picker("Goal (meters)", selection: $goal) {
                    ForEach(Array(stride(from: 500.0, to: 20000.0, by: 500.0)), id: \.self) { value in
                        Text("\(Int(value))").tag(value)
                    }
                }
                .pickerStyle(.wheel)
            }
            .navigationTitle("Edit Distance Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        goals.updateDistanceGoal(goal)
                        dismiss()
                    }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            goal = goals.distanceGoal
        }
    }
}
