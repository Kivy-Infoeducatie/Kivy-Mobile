//
//  LargeButton.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 09.01.2025.
//

import SwiftUI

struct LargeButton: View {
    let title: String
    let icon: String?
    let background: Color
    let action: () -> Void
    
    init(
        title: String,
        icon: String? = nil,
        background: Color = .accentColor,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.background = background
        self.action = action
    }
    
    var body: some View {
        Button {
            action()
        } label: {
            HStack {
                if let icon {
                    Image(systemName: icon)
                }
                Text(title)
                    .bold()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(background)
            .foregroundStyle(.background)
            .clipShape(.rect(cornerRadius: 20))
        }
    }
}
