//
//  GoalWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 16.12.2024.
//

import SwiftUI

struct GoalsWidget: View {
    let widget: Widget

    var body: some View {
        WidgetWrapper(widget: widget, showTitle: widget.size != .small) {
            switch widget.size {
            case .small:
                SmallGoalsWidget()
            case .medium:
                MediumGoalsWidget()
            case .large:
                LargeGoalsWidget()
            }
        }
    }
}
