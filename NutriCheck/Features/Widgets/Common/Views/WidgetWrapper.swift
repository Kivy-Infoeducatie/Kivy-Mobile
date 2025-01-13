//
//  WidgetWrapper.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 18.12.2024.
//

import SwiftUI

struct WidgetWrapper<Content: View>: View {
    let widget: Widget
    let showTitle: Bool
    let content: () -> Content

    init(widget: Widget, showTitle: Bool = true, @ViewBuilder content: @escaping () -> Content) {
        self.widget = widget
        self.showTitle = showTitle
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading) {
            if showTitle {
                HStack {
                    Image(systemName: widget.type.icon)
                    Text(widget.type.title)
                        .font(.system(.callout, design: .rounded))
                        .bold()
                }
                .opacity(0.8)
            }

            content()
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    WidgetWrapper(widget: .init(type: .goals, size: .small, order: 0)) {}
}
