//
//  MediumGoalsWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 16.12.2024.
//

import SwiftUI

struct MediumGoalsWidget: View {
    @State private var outterRingValue: CGFloat = 0.5
    @State private var middleRingValue: CGFloat = 0.7
    @State private var innerRingValue: CGFloat = 0.9

    var body: some View {
        HStack(spacing: 24) {
            StackedActivityRingView(
                outterRingValue: $outterRingValue,
                middleRingValue: $middleRingValue,
                innerRingValue: $innerRingValue,
                config: .init(lineWidth: 14)
            )
            .frame(width: 80, height: 80)
            VStack(alignment: .leading, spacing: 6) {
                Text("7546/10000")
                    .font(.system(.title3, design: .rounded))
                    .bold()
                    + Text(" steps")
                    .font(.system(.callout, design: .rounded))

                Text("30/60")
                    .font(.system(.title3, design: .rounded))
                    .bold()
                    + Text(" minutes")
                    .font(.system(.callout, design: .rounded))

                Text("2/3")
                    .font(.system(.title3, design: .rounded))
                    .bold()
                    + Text(" meals")
                    .font(.system(.callout, design: .rounded))
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
    }
}
