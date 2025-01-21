//
//  MediumShoppingList.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 17.01.2025.
//

import SwiftData
import SwiftUI

struct MediumShoppingListWidget: View {
    @Query private var shoppingListItems: [ShoppingListItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("\(shoppingListItems.count) items")
                .font(.title3.bold())

            if !shoppingListItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(shoppingListItems.prefix(3))) { item in
                        ShoppingListItemRow(item: item)
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
        .padding(.vertical, 4)
    }
}

#Preview {
    MediumShoppingListWidget()
}
