//
//  Step.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 19.12.2024.
//

import Foundation

struct Step: Codable {
    var text: String
    var ingredients: [Ingredient]
}
