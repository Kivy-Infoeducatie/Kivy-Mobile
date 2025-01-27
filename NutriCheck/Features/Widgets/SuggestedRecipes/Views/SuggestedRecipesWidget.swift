//
//  SuggestedRecipesWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 19.12.2024.
//

import SwiftUI

struct SuggestedRecipesWidget: View {
    let widget: Widget

    var body: some View {
        switch widget.size {
        case .small:
            SmallSuggestedRecipeWidget(widget: widget)
        case .medium:
            WidgetWrapper(widget: widget) {
                MediumSuggestedRecipesWidget()
            }
        case .large:
            WidgetWrapper(widget: widget) {
                LargeSuggestedRecipesWidget()
            }
        }
    }
}

#Preview {
    SuggestedRecipesWidget(
        widget: .init(type: .suggestedRecipes, size: .small, order: 0)
    )
}
