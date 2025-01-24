//
//  UpdatePreferencesDTO.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 22.01.2025.
//

import Foundation

enum Gender: String, Codable, CaseIterable {
    case male
    case female
}

enum DietType: String, Codable {
    case noDiet = "no_diet"
    case vegetarian
    case vegan
    case pescatarian
}

struct Preferences: Codable {
    let id: Int?;
    let activityLevel: Double?
    let gender: Gender
    let age: Int
    let weight: Double?
    let height: Double?
    let diet: DietType
    let allergens: [String]
    
    init(
        id: Int? = nil,
        activityLevel: Double?,
        gender: Gender,
        age: Int,
        weight: Double?,
        height: Double?,
        diet: DietType,
        allergens: [String]
    ) {
        self.id = id
        self.activityLevel = activityLevel
        self.gender = gender
        self.age = age
        self.weight = weight
        self.height = height
        self.diet = diet
        self.allergens = allergens
    }
}
