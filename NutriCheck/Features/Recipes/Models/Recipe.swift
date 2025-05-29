//
//  Recipe.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 19.12.2024.
//

import Foundation
import SwiftData
import SwiftUI

struct Recipe: Codable, Identifiable, Equatable {
    var id: Int
    var name: String
    var cookingTime: Int?
    var tags: [String]
    var description: String
    var ingredientsCount: Int?
    var calories: Double?
    var likesCount: Int?
    var authorName: String?
    var images: [String]
    var difficulty: Difficulty
    var author: Author?
    
    var createdAt: String?
    var preparationTime: Int?
    var steps: [String]?
    var ingredients: [Ingredient]?
    var totalFat: Double?
    var sugar: Double?
    var sodium: Double?
    var protein: Double?
    var saturatedFat: Double?
    var carbohydrates: Double?
    var cholesterol: Double?
    var fiber: Double?
    var servings: Int?
    var servingsSize: Int?
    var posts: [Comment]?
}

extension Recipe {
    var authorUsername: String {
        return author?.username ?? authorName ?? "User"
    }
    
    var totalTime: Int {
        return (preparationTime ?? 0) + (cookingTime ?? 0)
    }
    
    var stepsCount: Int {
        return steps?.count ?? 0
    }
    
    static var EmptyRecipe: Recipe {
        return Recipe(
            id: 0,
            name: "",
            cookingTime: 0,
            tags: [],
            description: "No recipe available",
            ingredientsCount: 0,
            calories: 0,
            likesCount: 0,
            authorName: "",
            images: [],
            difficulty: .easy,
            author: nil
        )
    }
}

struct Author: Codable, Identifiable, Equatable {
    var id: Int?
    var username: String?
    var picture: String?
}

struct Comment: Codable, Identifiable, Equatable {
    var id: Int?
    var author: Author?
    var content: String
    var rating: Int?
    var likesCount: Int?
    var source: String?
    var authorName: String?
    var createdAt: String
}

extension Comment {
    var authorUsername: String {
        return author?.username ?? authorName ?? "User"
    }
}

let recipeMocks: [Recipe] = [ Recipe.EmptyRecipe ]
