//
//  CloseButton.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 18.12.2024.
//

import SwiftUI

struct CloseButton: View {
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(systemName: "xmark")
                .resizable()
                .frame(width: 12, height: 12)
                .bold()
                .opacity(0.7)
                .padding(8)
                .background {
                    Circle()
                        .fill(.foreground.opacity(0.1))
                }
        }
    }
}
