//
//  WidgetView.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 16.12.2024.
//

import SwiftUI

struct WidgetView: View {
    @Bindable var widget: Widget
    let geometry: GeometryProxy

    var body: some View {
        Group {
            switch widget.type {
            case .goals:
                GoalsWidget(widget: widget)
            case .featuredRecipe:
                FeaturedRecipeWidget(widget: widget)
            case .suggestedRecipes:
                SuggestedRecipesWidget(widget: widget)
            case .askAI:
                AskAIWidget(widget: widget)
            case .shoppingList:
                ShoppingListWidget(widget: widget)
            case .reminder:
                EmptyView()
            case .ongoingRecipe:
                OngoingRecipeWidget(widget: widget)
            }
        }
        .frame(width: widgetWidth, alignment: .bottomLeading)
        .frame(height: widget.size == .small ? widgetWidth : nil)
        .background(RoundedRectangle(cornerRadius: 20).fill(.thinMaterial))
        .clipShape(.rect(cornerRadius: 20))
    }

    private var widgetWidth: CGFloat {
        let totalWidth = geometry.size.width - 32
        let columnWidth = (totalWidth - 12) / 2
        return widget.size == .small
            ? (columnWidth < 0 ? 0 : columnWidth)
            : (totalWidth < 0 ? 0 : totalWidth)
    }
}
