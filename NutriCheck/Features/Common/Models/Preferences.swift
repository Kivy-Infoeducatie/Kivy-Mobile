//
//  UpdatePreferencesDTO.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 22.01.2025.
//

import Foundation

enum Gender: String, Codable {
    case male
    case female
}

enum DietType: String, Codable {
    case noDiet = "no diet"
    case vegetarian
    case vegan
    case pescatarian
}

struct Preferences: Codable {
    let activityLevel: Double?
    let gender: Gender
    let age: Int
    let weight: Double?
    let height: Double?
    let diet: DietType
    let allergens: [String]
}
