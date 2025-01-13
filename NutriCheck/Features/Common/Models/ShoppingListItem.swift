//
//  ShoppingListItem.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 12.01.2025.
//

import Foundation
import SwiftData

@Model
class ShoppingListItem {
    var name: String
    var quantity: String
    var unit: String
    
    init(name: String, quantity: String, unit: String) {
        self.name = name
        self.quantity = quantity
        self.unit = unit
    }
}
