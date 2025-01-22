//
//  SearchRecipeDTO.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 22.01.2025.
//

import Foundation

struct SearchRecipeDTO: Codable {
    // Calories
    let minCalories: Double?
    let maxCalories: Double?
    
    // Total Fat
    let minTotalFat: Double?
    let maxTotalFat: Double?
    
    // Sugar
    let minSugar: Double?
    let maxSugar: Double?
    
    // Sodium
    let minSodium: Double?
    let maxSodium: Double?
    
    // Protein
    let minProtein: Double?
    let maxProtein: Double?
    
    // Saturated Fat
    let minSaturatedFat: Double?
    let maxSaturatedFat: Double?
    
    // Carbohydrates
    let minCarbohydrates: Double?
    let maxCarbohydrates: Double?
    
    // Fiber
    let minFiber: Double?
    let maxFiber: Double?
    
    // Cholesterol
    let minCholesterol: Double?
    let maxCholesterol: Double?
    
    // Steps
    let minSteps: Int?
    let maxSteps: Int?
    
    // Preparation Time
    let minPreparationTime: Int?
    let maxPreparationTime: Int?
    
    // Cooking Time
    let minCookingTime: Int?
    let maxCookingTime: Int?
    
    // Dates
    let minDate: String?
    let maxDate: String?
    
    // Tags and Difficulty
    let tags: [String]?
    let difficulty: [String]?
    
    // Search and Offset
    let offset: Int?
    let search: String?
    
    enum DifficultyLevel: String, Codable {
        case easy
        case medium
        case hard
    }
}
