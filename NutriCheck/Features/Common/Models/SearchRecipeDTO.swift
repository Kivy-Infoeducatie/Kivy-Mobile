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
    
    init(
        minCalories: Double? = nil,
        maxCalories: Double? = nil,
        minTotalFat: Double? = nil,
        maxTotalFat: Double? = nil,
        minSugar: Double? = nil,
        maxSugar: Double? = nil,
        minSodium: Double? = nil,
        maxSodium: Double? = nil,
        minProtein: Double? = nil,
        maxProtein: Double? = nil,
        minSaturatedFat: Double? = nil,
        maxSaturatedFat: Double? = nil,
        minCarbohydrates: Double? = nil,
        maxCarbohydrates: Double? = nil,
        minFiber: Double? = nil,
        maxFiber: Double? = nil,
        minCholesterol: Double? = nil,
        maxCholesterol: Double? = nil,
        minSteps: Int? = nil,
        maxSteps: Int? = nil,
        minPreparationTime: Int? = nil,
        maxPreparationTime: Int? = nil,
        minCookingTime: Int? = nil,
        maxCookingTime: Int? = nil,
        minDate: String? = nil,
        maxDate: String? = nil,
        tags: [String]? = nil,
        difficulty: [String]? = nil,
        offset: Int? = nil,
        search: String? = nil
    ) {
        self.minCalories = minCalories
        self.maxCalories = maxCalories
        self.minTotalFat = minTotalFat
        self.maxTotalFat = maxTotalFat
        self.minSugar = minSugar
        self.maxSugar = maxSugar
        self.minSodium = minSodium
        self.maxSodium = maxSodium
        self.minProtein = minProtein
        self.maxProtein = maxProtein
        self.minSaturatedFat = minSaturatedFat
        self.maxSaturatedFat = maxSaturatedFat
        self.minCarbohydrates = minCarbohydrates
        self.maxCarbohydrates = maxCarbohydrates
        self.minFiber = minFiber
        self.maxFiber = maxFiber
        self.minCholesterol = minCholesterol
        self.maxCholesterol = maxCholesterol
        self.minSteps = minSteps
        self.maxSteps = maxSteps
        self.minPreparationTime = minPreparationTime
        self.maxPreparationTime = maxPreparationTime
        self.minCookingTime = minCookingTime
        self.maxCookingTime = maxCookingTime
        self.minDate = minDate
        self.maxDate = maxDate
        self.tags = tags
        self.difficulty = difficulty
        self.offset = offset
        self.search = search
    }
}
