//
//  LargeGoalsWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 18.12.2024.
//

import Charts
import SwiftUI

struct LargeGoalsWidget: View {
    @State private var calories: CGFloat = 0.8

    private let data: [(date: Date, value: Double)] = [
        (
            date: Date.now,
            value: 10
        ),
        (
            date: Date.now.addingTimeInterval(60 * 30),
            value: 7
        ),
        (
            date: Date.now.addingTimeInterval(60 * 60),
            value: 9
        ),
        (
            date: Date.now.addingTimeInterval(60 * 90),
            value: 5
        ),
        (
            date: Date.now.addingTimeInterval(60 * 120),
            value: 8
        ),
        (
            date: Date.now.addingTimeInterval(60 * 150),
            value: 3
        ),
        (
            date: Date.now.addingTimeInterval(60 * 180),
            value: 6
        ),
        (
            date: Date.now.addingTimeInterval(60 * 210),
            value: 4
        ),
        (
            date: Date.now.addingTimeInterval(60 * 240),
            value: 7
        ),
        (
            date: Date.now.addingTimeInterval(60 * 270),
            value: 5
        ),
        (
            date: Date.now.addingTimeInterval(60 * 300),
            value: 8
        ),
        (
            date: Date.now.addingTimeInterval(60 * 120),
            value: 8
        ),
        (
            date: Date.now.addingTimeInterval(60 * 150),
            value: 3
        ),
        (
            date: Date.now.addingTimeInterval(60 * 180),
            value: 6
        ),
        (
            date: Date.now.addingTimeInterval(60 * 210),
            value: 4
        ),
        (
            date: Date.now.addingTimeInterval(60 * 240),
            value: 7
        ),
        (
            date: Date.now.addingTimeInterval(60 * 270),
            value: 5
        ),
        (
            date: Date.now.addingTimeInterval(60 * 300),
            value: 8
        )
    ]

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 20) {
                ActivityRingView(
                    progress: calories,
                    mainColor: .blue,
                    lineWidth: 14
                )
                .frame(width: 40, height: 40)
                        
                VStack(alignment: .leading, spacing: 6) {
                    Text("7546/10000")
                        .font(.system(.body, design: .rounded))
                        .bold()
                        + Text(" steps")
                        .font(.system(.callout, design: .rounded))
                            
                    Chart(data, id: \.date) {
                        RuleMark(
                            x: .value("test", Calendar.current.startOfToday)
                        )
                        .opacity(0)
                                
                        BarMark(
                            x: .value("Day", $0.date, unit: .minute),
                            y: .value("Sales", $0.value),
                            width: 3
                        )
                        .foregroundStyle(.blue)
                                
                        RuleMark(
                            x: .value("test", Calendar.current.endOfToday)
                        )
                        .opacity(0)
                    }
                    .chartYAxis(.hidden)
                    .frame(height: 40)
                }
            }
                    
            HStack(spacing: 20) {
                ActivityRingView(
                    progress: calories,
                    mainColor: .orange,
                    lineWidth: 14
                )
                .frame(width: 40, height: 40)
                        
                VStack(alignment: .leading, spacing: 6) {
                    Text("7546/10000")
                        .font(.system(.body, design: .rounded))
                        .bold()
                        + Text(" steps")
                        .font(.system(.callout, design: .rounded))
                            
                    Chart(data, id: \.date) {
                        RuleMark(
                            x: .value("test", Calendar.current.startOfToday)
                        )
                        .opacity(0)
                                
                        BarMark(
                            x: .value("Day", $0.date, unit: .minute),
                            y: .value("Sales", $0.value),
                            width: 3
                        )
                        .foregroundStyle(.orange)
                                
                        RuleMark(
                            x: .value("test", Calendar.current.endOfToday)
                        )
                        .opacity(0)
                    }
                    .chartYAxis(.hidden)
                    .frame(height: 40)
                }
            }
                    
            HStack(spacing: 20) {
                ActivityRingView(
                    progress: calories,
                    mainColor: .purple,
                    lineWidth: 14
                )
                .frame(width: 40, height: 40)
                        
                VStack(alignment: .leading, spacing: 6) {
                    Text("7546/10000")
                        .font(.system(.body, design: .rounded))
                        .bold()
                        + Text(" steps")
                        .font(.system(.callout, design: .rounded))
                            
                    Chart(data, id: \.date) {
                        RuleMark(
                            x: .value("test", Calendar.current.startOfToday)
                        )
                        .opacity(0)
                                
                        BarMark(
                            x: .value("Day", $0.date, unit: .minute),
                            y: .value("Sales", $0.value),
                            width: 3
                        )
                        .foregroundStyle(.purple)
                                
                        RuleMark(
                            x: .value("test", Calendar.current.endOfToday)
                        )
                        .opacity(0)
                    }
                    .chartYAxis(.hidden)
                    .frame(height: 40)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 6)
    }
}

#Preview {
    LargeGoalsWidget()
}
