//
//  ActivityRingView.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 15.12.2024.
//

import SwiftUI

struct ActivityRingView: View {
    let progress: CGFloat
    
    var mainColor: Color = .red
    var lineWidth: CGFloat = 20
    
    var endColor: Color {
        mainColor.darker(by: 15.0)
    }
    
    var startColor: Color {
        mainColor.lighter(by: 15.0)
    }
    
    var backgroundColor: Color {
        return mainColor.opacity(0.15)
    }
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                Circle()
                    .stroke(backgroundColor, lineWidth: lineWidth)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(
                        AngularGradient(
                            gradient: Gradient(colors: [startColor, endColor]),
                            center: .center,
                            startAngle: .degrees(0),
                            endAngle: .degrees(360)
                        ),
                        style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                
                Circle()
                    .frame(width: lineWidth, height: lineWidth)
                    .foregroundColor(startColor)
                    .offset(y: -1 * (geo.size.height / 2))
                
            }
            .rotationEffect(overlapRotation())
            .frame(idealWidth: 300, idealHeight: 300, alignment: .center)
            .animation(.spring(.smooth, blendDuration: 0.5), value: progress)
            .rotation3DEffect(
                .degrees(180),
                axis: (x: 0, y: 1, z: 0)
            )
        }
    }
    
    func overlapRotation() -> Angle {
        let overlapProgress = progress - 1.0
        let degrees = overlapProgress * 360.0
        return .degrees(-1 * degrees)
    }
}
