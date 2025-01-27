//
//  ShoppingListWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 17.01.2025.
//

import SwiftUI

struct ShoppingListWidget: View {
    let widget: Widget

    @State private var showShoppingList = false
    @Namespace var namespace

    var body: some View {
        Button(action: {
            showShoppingList.toggle()
        }) {
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
        .matchedTransitionSource(id: "shopping_list", in: namespace)
        .fullScreenCover(isPresented: $showShoppingList) {
            ShoppingListScreen()
                .navigationTransition(.zoom(sourceID: "shopping_list", in: namespace))
        }
    }
}

#Preview {
    ShoppingListWidget(widget: .init(type: .shoppingList, size: .medium, order: 0))
}
