//
//  ShoppingListWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 17.01.2025.
//

import SwiftUI

struct ShoppingListWidget: View {
    let widget: Widget
    
    var body: some View {
        WidgetWrapper(widget: widget) {
            switch widget.size {
            case .small:
                SmallShoppingListWidget()
            case .medium:
                MediumShoppingListWidget()
            case .large:
                LargeShoppingListWidget()
            }
        }
    }
}

#Preview {
    ShoppingListWidget(widget: .init(type: .shoppingList, size: .medium, order: 0))
}
