//
//  MediumGoalsWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 16.12.2024.
//

import SwiftUI

struct MediumGoalsWidget: View {
    @EnvironmentObject var health: HealthKitViewModel
    @EnvironmentObject var goals: GoalsViewModel
    
    @State private var steps: Double = 0
    @State private var calories: Double = 0
    @State private var distance: Double = 0
    
    @State private var calorieSamples: [(date: Date, value: Double)] = []
    @State private var stepSamples: [(date: Date, value: Double)] = []
    @State private var distanceSamples: [(date: Date, value: Double)] = []

    var body: some View {
        HStack(spacing: 24) {
            StackedActivityRingView(
                outterRingValue: calories / goals.activeEnergyGoal,
                middleRingValue: steps / goals.stepsGoal,
                innerRingValue: distance / goals.distanceGoal,
                config: .init(lineWidth: 14)
            )
            .frame(width: 80, height: 80)
            VStack(alignment: .leading, spacing: 6) {
                Text("\(Int(calories)) / \(Int(goals.activeEnergyGoal))")
                    .font(.system(.title3, design: .rounded))
                    .bold()
                    + Text(" kcal")
                    .font(.system(.callout, design: .rounded))

                Text("\(Int(steps)) / \(Int(goals.stepsGoal))")
                    .font(.system(.title3, design: .rounded))
                    .bold()
                    + Text(" steps")
                    .font(.system(.callout, design: .rounded))

                Text("\(Int(distance)) / \(Int(goals.distanceGoal))")
                    .font(.system(.title3, design: .rounded))
                    .bold()
                    + Text(" m")
                    .font(.system(.callout, design: .rounded))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
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
