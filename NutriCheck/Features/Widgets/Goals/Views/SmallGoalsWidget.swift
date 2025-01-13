//
//  SmallGoalWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 16.12.2024.
//

import SwiftUI

struct SmallGoalsWidget: View {
    @State private var outterRingValue: CGFloat = 0.5
    @State private var middleRingValue: CGFloat = 0.7
    @State private var innerRingValue: CGFloat = 0.9
    
    var body: some View {
        StackedActivityRingView(
            outterRingValue: $outterRingValue,
            middleRingValue: $middleRingValue,
            innerRingValue: $innerRingValue,
            config: .init(lineWidth: 10)
        )
        .frame(width: 50, height: 50)
        .padding(.vertical, 8)
        Spacer()
        Text("7546/10000")
            .font(.system(.callout, design: .rounded))
            .bold()
            + Text(" steps")
            .font(.system(.caption, design: .rounded))
            
        Text("30/60")
            .font(.system(.callout, design: .rounded))
            .bold()
            + Text(" minutes")
            .font(.system(.caption, design: .rounded))
            
        Text("2/3")
            .font(.system(.callout, design: .rounded))
            .bold()
            + Text(" meals")
            .font(.system(.caption, design: .rounded))
    }
}

struct StackedActivityRingViewConfig {
    var lineWidth: CGFloat = 10.0
    var outterRingColor: Color = .blue
    var middleRingColor: Color = .purple
    var innerRingColor: Color = .orange
}

struct StackedActivityRingView: View {
    @Binding var outterRingValue: CGFloat
    @Binding var middleRingValue: CGFloat
    @Binding var innerRingValue: CGFloat
    
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
