//
//  LargeShoppingListWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 17.01.2025.
//

import SwiftData
import SwiftUI

struct LargeShoppingListWidget: View {
    @Query private var shoppingListItems: [ShoppingListItem]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("\(shoppingListItems.count) items")
                .font(.title3.bold())
            
            if !shoppingListItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(shoppingListItems.prefix(5))) { item in
                        ShoppingListItemRow(item: item)
                    }
                    
                    if shoppingListItems.count > 5 {
                        Text("and \(shoppingListItems.count - 5) more items")
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
    LargeShoppingListWidget()
}
