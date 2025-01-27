//
//  Ingredient.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 19.12.2024.
//

import Foundation

struct Ingredient: Codable, Equatable, Hashable {
    var name: String
    var shortName: String?
    var quantity: String?
    var unit: String?
    var unitQuantity: String?
    var unitUnit: String?
}

extension Ingredient: Identifiable {
    var id: UUID {
        return UUID()
    }
}
