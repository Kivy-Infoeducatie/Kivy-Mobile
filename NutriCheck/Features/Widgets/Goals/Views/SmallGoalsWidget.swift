//
//  SmallGoalWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 16.12.2024.
//

import SwiftUI

struct SmallGoalsWidget: View {
    @EnvironmentObject var health: HealthKitViewModel
    @EnvironmentObject var goals: GoalsViewModel
    
    @State private var steps: Double = 0
    @State private var calories: Double = 0
    @State private var distance: Double = 0
    
    @State private var calorieSamples: [(date: Date, value: Double)] = []
    @State private var stepSamples: [(date: Date, value: Double)] = []
    @State private var distanceSamples: [(date: Date, value: Double)] = []
    
    var body: some View {
        VStack(alignment: .leading) {
            StackedActivityRingView(
                outterRingValue: calories / goals.activeEnergyGoal,
                middleRingValue: steps / goals.stepsGoal,
                innerRingValue: distance / goals.distanceGoal,
                config: .init(lineWidth: 10)
            )
            .frame(width: 50, height: 50)
            .padding(.vertical, 8)
            Spacer()
            Text("\(Int(calories)) / \(Int(goals.activeEnergyGoal))")
                .font(.system(.callout, design: .rounded))
                .bold()
            + Text(" kcal")
                .font(.system(.caption, design: .rounded))
            
            Text("\(Int(steps)) / \(Int(goals.stepsGoal))")
                .font(.system(.callout, design: .rounded))
                .bold()
            + Text(" steps")
                .font(.system(.caption, design: .rounded))
            
            Text("\(Int(distance)) / \(Int(goals.distanceGoal))")
                .font(.system(.callout, design: .rounded))
                .bold()
            + Text(" m")
                .font(.system(.caption, design: .rounded))
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

struct StackedActivityRingViewConfig {
    var lineWidth: CGFloat = 10.0
    var outterRingColor: Color = .blue
    var middleRingColor: Color = .purple
    var innerRingColor: Color = .orange
}

struct StackedActivityRingView: View {
    var outterRingValue: CGFloat
    var middleRingValue: CGFloat
    var innerRingValue: CGFloat
    
    var config: StackedActivityRingViewConfig = .init()
    var width: CGFloat = 80.0
    var height: CGFloat = 80.0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                ActivityRingView(progress: outterRingValue, mainColor: config.outterRingColor, lineWidth: config.lineWidth)
                    .frame(width: geo.size.width, height: geo.size.height)
                ActivityRingView(progress: middleRingValue, mainColor: config.middleRingColor, lineWidth: config.lineWidth)
                    .frame(width: geo.size.width - (2*config.lineWidth), height: geo.size.height - (2*config.lineWidth))
                ActivityRingView(progress: innerRingValue, mainColor: config.innerRingColor, lineWidth: config.lineWidth)
                    .frame(width: geo.size.width - (4*config.lineWidth), height: geo.size.height - (4*config.lineWidth))
            }
        }
    }
}
    
#Preview {
    SmallGoalsWidget()
}
