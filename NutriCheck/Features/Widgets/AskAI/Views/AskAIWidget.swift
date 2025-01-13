//
//  AskAIWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 19.12.2024.
//

import SwiftUI

struct AskAIWidget: View {
    let widget: Widget

    var body: some View {
        switch widget.size {
        case .small:
            SmallAskAIWidget(widget: widget)
        case .medium:
            WidgetWrapper(widget: widget) {
                MediumAskAIWidget(limit: 2)
            }
        case .large:
            WidgetWrapper(widget: widget) {
                MediumAskAIWidget(limit: 3)
            }
        }
    }
}

#Preview {
    AskAIWidget(widget: .init(type: .askAI, size: .medium, order: 0))
}
