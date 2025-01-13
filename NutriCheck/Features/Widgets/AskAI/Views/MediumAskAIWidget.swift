//
//  MediumAskAIWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 19.12.2024.
//

import SwiftUI

struct MediumAskAIWidget: View {
    let limit: Int
    
    var body: some View {
        VStack {
            ForEach(0..<limit, id: \.self) { _ in
                HStack {
                    VStack(alignment: .leading) {
                        Text("Suggest a low calorie dinner")
                            .bold()
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Spacer()
                    
                    Image(systemName: "arrow.right")
                        .bold()
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                        .background {
                            Capsule()
                                .fill(.thinMaterial)
                        }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background {
                    LighterMeshGradientView()
                        .clipShape(.rect(cornerRadius: 20))
                }
            }
        }
    }
}

#Preview {
    MediumAskAIWidget(limit: 2)
}
