//
//  LargeGoalsWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 18.12.2024.
//

import Charts
import SwiftUI

struct LargeGoalsWidget: View {
    @EnvironmentObject var health: HealthKitViewModel
    @EnvironmentObject var goals: GoalsViewModel
    
    @State private var steps: Double = 0
    @State private var calories: Double = 0
    @State private var distance: Double = 0
    
    @State private var calorieSamples: [(date: Date, value: Double)] = []
    @State private var stepSamples: [(date: Date, value: Double)] = []
    @State private var distanceSamples: [(date: Date, value: Double)] = []

    var body: some View {
        VStack(spacing: 16) {
            RingAndChartGoalView(
                current: calories,
                target: goals.activeEnergyGoal,
                color: .blue,
                unit: "kcal",
                samples: calorieSamples
            )
            
            RingAndChartGoalView(
                current: steps,
                target: goals.stepsGoal,
                color: .orange,
                unit: "steps",
                samples: stepSamples
            )
            
            RingAndChartGoalView(
                current: distance,
                target: goals.distanceGoal,
                color: .purple,
                unit: "m",
                samples: distanceSamples
            )
        }
        .padding(.horizontal)
        .padding(.top, 6)
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

#Preview {
    LargeGoalsWidget()
}

struct RingAndChartGoalView: View {
    let current: Double
    let target: Double
    let color: Color
    let unit: String
    let samples: [(date: Date, value: Double)]
    
    var body: some View {
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
    }
}
