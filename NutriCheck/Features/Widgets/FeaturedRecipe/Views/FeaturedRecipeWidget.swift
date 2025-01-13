//
//  FeaturedRecipeWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 18.12.2024.
//

import SwiftUI

struct FeaturedRecipeWidget: View {
    let widget: Widget

    var body: some View {
        switch widget.size {
        case .small:
            SmallFeaturedRecipeWidget(widget: widget)
        case .medium:
            SmallFeaturedRecipeWidget(widget: widget, height: 150)
        case .large:
            LargeFeaturedRecipeWidget(widget: widget)
        }
    }
}

#Preview {
    FeaturedRecipeWidget(
        widget: .init(type: .featuredRecipe, size: .small, order: 0)
    )
}
