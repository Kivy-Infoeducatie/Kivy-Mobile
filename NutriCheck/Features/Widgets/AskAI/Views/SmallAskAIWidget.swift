//
//  SmallAskAIWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 19.12.2024.
//

import SwiftUI

struct SmallAskAIWidget: View {
    let widget: Widget

    var body: some View {
        ZStack {
            LighterMeshGradientView()
            VStack(alignment: .leading) {
                HStack(spacing: 4) {
                    Image(systemName: widget.type.icon)
                    Text(widget.type.title)
                        .font(.system(size: 14, weight: .semibold))
                }
                .opacity(0.9)
                Spacer()
                Text("Suggest a low calorie dinner for today")
                    .bold()
            }
            .foregroundStyle(.black)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
        }
    }
}

#Preview {
    SmallAskAIWidget(widget: .init(type: .askAI, size: .small, order: 0))
}
