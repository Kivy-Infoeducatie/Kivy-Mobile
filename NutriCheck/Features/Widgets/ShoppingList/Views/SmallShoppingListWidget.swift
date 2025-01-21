//
//  SmallShoppingListWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 17.01.2025.
//

import SwiftUI
import SwiftData

struct SmallShoppingListWidget: View {
    @Query private var shoppingListItems: [ShoppingListItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(shoppingListItems.count) items")
                .font(.headline)
            
            if !shoppingListItems.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(Array(shoppingListItems.prefix(3))) { item in
                        ShoppingListItemRow(item: item, showQuantity: false)
                    }
                    
                    if shoppingListItems.count > 3 {
                        Text("and \(shoppingListItems.count - 3) more items")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .padding(.top, 4)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.top, 0.1)
    }
}

#Preview {
    SmallShoppingListWidget()
}
