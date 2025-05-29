//
//  SearchRecipeDTO.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 22.01.2025.
//

import Foundation

struct SearchRecipeDTO: Codable {
    // Calories
    var minCalories: Double?
    var maxCalories: Double?
    
    // Total Fat
    var minTotalFat: Double?
    var maxTotalFat: Double?
    
    // Sugar
    var minSugar: Double?
    var maxSugar: Double?
    
    // Sodium
    var minSodium: Double?
    var maxSodium: Double?
    
    // Protein
    var minProtein: Double?
    var maxProtein: Double?
    
    // Saturated Fat
    var minSaturatedFat: Double?
    var maxSaturatedFat: Double?
    
    // Carbohydrates
    var minCarbohydrates: Double?
    var maxCarbohydrates: Double?
    
    // Fiber
    var minFiber: Double?
    var maxFiber: Double?
    
    // Cholesterol
    var minCholesterol: Double?
    var maxCholesterol: Double?
    
    // Steps
    var minSteps: Int?
    var maxSteps: Int?
    
    // Preparation Time
    var minPreparationTime: Int?
    var maxPreparationTime: Int?
    
    // Cooking Time
    var minCookingTime: Int?
    var maxCookingTime: Int?
    
    // Dates
    var minDate: String?
    var maxDate: String?
    
    // Tags and Difficulty
    var tags: [String]?
    var difficulty: [String]?
    
    // Search and Offset
    var offset: Int?
    var search: String?
    
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
