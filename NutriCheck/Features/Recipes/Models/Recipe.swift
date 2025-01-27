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
    
    // Optional properties that aren't in the JSON should be declared without default values
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
    var source: String
    var authorName: String?
    var createdAt: String
}

extension Comment {
    var authorUsername: String {
        return author?.username ?? authorName ?? "User"
    }
}

let recipeMocks: [Recipe] = [ Recipe.EmptyRecipe
//    Recipe(
//        id: 1,
//        name: "Sarmale (Romanian Stuffed Cabbage Rolls)",
//        createdAt: Date(timeIntervalSince1970: 1736745517), // 2025-01-12 09:58:37 UTC
//        preparationTime: 90,
//        cookingTime: 180,
//        tags: ["Romanian", "Traditional", "Main Course", "Holiday", "Comfort Food"],
//        steps: [
//            "Prepare the cabbage leaves by removing the hard stems",
//            "Mix ground pork with rice, onions, and seasonings",
//            "Roll the meat mixture in cabbage leaves",
//            "Layer sauerkraut in the bottom of a large pot",
//            "Arrange the cabbage rolls in layers",
//            "Cook slowly on low heat for 3-4 hours"
//        ],
//        description: "Traditional Romanian stuffed cabbage rolls (Sarmale) made with sour cabbage leaves, filled with ground pork, rice, and aromatic herbs",
//        ingredients: [
//            Ingredient(name: "Sour Cabbage", shortName: "Cabbage", quantity: "1", unit: "head", unitQuantity: "2", unitUnit: "kg"),
//            Ingredient(name: "Ground Pork", shortName: "Pork", quantity: "1", unit: "kg"),
//            Ingredient(name: "Rice", shortName: "Rice", quantity: "200", unit: "g"),
//            Ingredient(name: "Onions", shortName: "Onions", quantity: "3", unit: "large"),
//            Ingredient(name: "Tomato Paste", shortName: "Tom. Paste", quantity: "200", unit: "g"),
//            Ingredient(name: "Black Pepper", shortName: "Pepper", quantity: "1", unit: "tsp"),
//            Ingredient(name: "Thyme", shortName: "Thyme", quantity: "2", unit: "tsp"),
//            Ingredient(name: "Bay Leaves", shortName: "Bay", quantity: "3", unit: "leaves")
//        ],
//        calories: 320,
//        totalFat: 18.5,
//        sugar: 2.1,
//        sodium: 780,
//        protein: 25.3,
//        saturatedFat: 6.8,
//        carbohydrates: 19.4,
//        cholesterol: 65.2,
//        fiber: 3.2,
//        likesCount: 3456,
//        authorName: "Alex-Simedrea",
//        images: [
//            "https://retete-thermomix.ro/wp-content/uploads/2021/12/Sarmale.webp",
//            "https://simonacallas.com/wp-content/uploads/2017/07/Sarmale-romanesti-in-foi-de-varza-1.jpg",
//            "https://cdn-content-prod.freshful.ro/prod/Sarmale_in_foi_de_varza_720_x_360_d21982cc02.jpg"
//        ],
//        difficulty: .medium,
//        servings: 8,
//        servingsSize: 250,
//        comments: [
//            Comment(
//                id: 1,
//                author: Author(
//                    id: 2,
//                    username: "Jamila Cuisine",
//                    picture: "https://cdn.shopify.com/s/files/1/0496/2454/7481/articles/sarmale-traditionale-romanesti.jpg?v=1724688561"
//                ),
//                content: "This is a great recipe! I love the traditional flavors and the step-by-step instructions.",
//                rating: 5,
//                likesCount: 12,
//                source: "https://www.jamilacuisine.ro/sarmale-cu-mamaliguta/",
//                createdAt: Date(timeIntervalSince1970: 1736745517) // 2025-01-12 09:58:37 UTC
//            )
//        ]
//    ),
//
//    Recipe(
//        id: 2,
//        name: "Festive Sarmale",
//        createdAt: Date(timeIntervalSince1970: 1736745517), // 2025-01-12 09:58:37 UTC
//        preparationTime: 120,
//        cookingTime: 240,
//        tags: ["Romanian", "Christmas", "Easter", "Traditional", "Family Recipe"],
//        steps: [
//            "Soak rice in warm water for 30 minutes",
//            "Prepare the meat mixture with seasonings",
//            "Carefully separate and prepare cabbage leaves",
//            "Form small, tight rolls with the meat mixture",
//            "Layer with smoked meat and sauerkraut",
//            "Slow cook for best results"
//        ],
//        description: "A festive version of Romanian cabbage rolls, perfect for holiday celebrations and family gatherings",
//        ingredients: [
//            Ingredient(name: "Sour Cabbage", shortName: "Cabbage", quantity: "1", unit: "large head"),
//            Ingredient(name: "Mixed Ground Meat", shortName: "Meat", quantity: "1.5", unit: "kg"),
//            Ingredient(name: "Round Grain Rice", shortName: "Rice", quantity: "250", unit: "g"),
//            Ingredient(name: "Smoked Bacon", shortName: "Bacon", quantity: "200", unit: "g"),
//            Ingredient(name: "Dill", shortName: "Dill", quantity: "1", unit: "bunch"),
//            Ingredient(name: "Tomato Sauce", shortName: "Sauce", quantity: "500", unit: "ml")
//        ],
//        calories: 285,
//        totalFat: 16.8,
//        sugar: 1.9,
//        sodium: 820,
//        protein: 23.5,
//        saturatedFat: 7.2,
//        carbohydrates: 17.6,
//        cholesterol: 58.5,
//        fiber: 2.8,
//        likesCount: 2891,
//        authorName: "Alex-Simedrea",
//        images: [
//            "https://cdn.shopify.com/s/files/1/0496/2454/7481/articles/sarmale-traditionale-romanesti.jpg?v=1724688561",
//            "https://retete-thermomix.ro/wp-content/uploads/2021/12/Sarmale.webp"
//        ],
//        difficulty: .hard,
//        servings: 12,
//        servingsSize: 200,
//        comments: []
//    ),
//    Recipe(
//        id: 3,
//        name: "Cozonac Traditional",
//        createdAt: Date(timeIntervalSince1970: 1736745601), // 2025-01-12 10:00:01 UTC
//        preparationTime: 180,
//        cookingTime: 60,
//        tags: ["Romanian", "Dessert", "Holiday", "Christmas", "Easter", "Sweet"],
//        steps: [
//            "Prepare the yeast mixture with warm milk",
//            "Mix flour with eggs and butter for the dough",
//            "Let the dough rise for 1 hour",
//            "Prepare walnut and cocoa filling",
//            "Braid the dough with filling",
//            "Bake until golden brown"
//        ],
//        description: "Traditional Romanian sweet bread filled with a rich walnut and cocoa mixture, perfect for holidays",
//        ingredients: [
//            Ingredient(name: "All-Purpose Flour", shortName: "Flour", quantity: "1", unit: "kg"),
//            Ingredient(name: "Fresh Yeast", shortName: "Yeast", quantity: "50", unit: "g"),
//            Ingredient(name: "Milk", shortName: "Milk", quantity: "400", unit: "ml"),
//            Ingredient(name: "Ground Walnuts", shortName: "Walnuts", quantity: "400", unit: "g"),
//            Ingredient(name: "Cocoa Powder", shortName: "Cocoa", quantity: "50", unit: "g"),
//            Ingredient(name: "Eggs", shortName: "Eggs", quantity: "6", unit: "whole")
//        ],
//        calories: 385,
//        totalFat: 18.2,
//        sugar: 22.5,
//        sodium: 230,
//        protein: 9.8,
//        saturatedFat: 6.4,
//        carbohydrates: 48.5,
//        cholesterol: 85.2,
//        fiber: 2.8,
//        likesCount: 2156,
//        authorName: "Alex-Simedrea",
//        images: [
//            "https://retete-thermomix.ro/wp-content/uploads/2021/12/Sarmale.webp",
//            "https://simonacallas.com/wp-content/uploads/2017/07/Sarmale-romanesti-in-foi-de-varza-1.jpg"
//        ],
//        difficulty: .hard,
//        servings: 12,
//        servingsSize: 150,
//        comments: []
//    ),
//
//    Recipe(
//        id: 4,
//        name: "Mici (Romanian Grilled Meat Rolls)",
//        createdAt: Date(timeIntervalSince1970: 1736745601), // 2025-01-12 10:00:01 UTC
//        preparationTime: 45,
//        cookingTime: 15,
//        tags: ["Romanian", "Grill", "Meat", "Street Food", "Summer"],
//        steps: [
//            "Mix all meats together with spices",
//            "Add garlic and sodium bicarbonate",
//            "Form small rolls by hand",
//            "Let rest in refrigerator for 2 hours",
//            "Grill on high heat",
//            "Serve with mustard and bread"
//        ],
//        description: "Classic Romanian grilled meat rolls made with a mix of beef, lamb, and pork, seasoned with garlic and spices",
//        ingredients: [
//            Ingredient(name: "Ground Beef", shortName: "Beef", quantity: "500", unit: "g"),
//            Ingredient(name: "Ground Lamb", shortName: "Lamb", quantity: "250", unit: "g"),
//            Ingredient(name: "Ground Pork", shortName: "Pork", quantity: "250", unit: "g"),
//            Ingredient(name: "Garlic", shortName: "Garlic", quantity: "6", unit: "cloves"),
//            Ingredient(name: "Sodium Bicarbonate", shortName: "Bicarb", quantity: "1/2", unit: "tsp")
//        ],
//        calories: 245,
//        totalFat: 18.5,
//        sugar: 0.5,
//        sodium: 480,
//        protein: 22.3,
//        saturatedFat: 7.8,
//        carbohydrates: 1.2,
//        cholesterol: 72.5,
//        fiber: 0.3,
//        likesCount: 1876,
//        authorName: "Alex-Simedrea",
//        images: [
//            "https://cdn.shopify.com/s/files/1/0496/2454/7481/articles/sarmale-traditionale-romanesti.jpg?v=1724688561"
//        ],
//        difficulty: .medium,
//        servings: 8,
//        servingsSize: 100,
//        comments: []
//    ),
//
//    Recipe(
//        id: 5,
//        name: "Zacuscă",
//        createdAt: Date(timeIntervalSince1970: 1736745601), // 2025-01-12 10:00:01 UTC
//        preparationTime: 120,
//        cookingTime: 180,
//        tags: ["Romanian", "Vegetarian", "Spread", "Autumn", "Preservation"],
//        steps: [
//            "Roast eggplants and peppers",
//            "Remove skins and chop vegetables",
//            "Sauté onions until translucent",
//            "Cook all ingredients together",
//            "Sterilize jars",
//            "Can while hot"
//        ],
//        description: "Traditional Romanian vegetable spread made with roasted eggplants, peppers, and mushrooms",
//        ingredients: [
//            Ingredient(name: "Eggplants", shortName: "Eggplant", quantity: "2", unit: "kg"),
//            Ingredient(name: "Red Peppers", shortName: "Peppers", quantity: "1", unit: "kg"),
//            Ingredient(name: "Mushrooms", shortName: "Mushrooms", quantity: "500", unit: "g"),
//            Ingredient(name: "Onions", shortName: "Onions", quantity: "500", unit: "g"),
//            Ingredient(name: "Tomato Paste", shortName: "Tom.Paste", quantity: "200", unit: "g")
//        ],
//        calories: 85,
//        totalFat: 5.2,
//        sugar: 6.8,
//        sodium: 320,
//        protein: 2.4,
//        saturatedFat: 0.8,
//        carbohydrates: 9.5,
//        cholesterol: 0,
//        fiber: 4.2,
//        likesCount: 1543,
//        authorName: "Alex-Simedrea",
//        images: [
//            "https://cdn-content-prod.freshful.ro/prod/Sarmale_in_foi_de_varza_720_x_360_d21982cc02.jpg"
//        ],
//        difficulty: .medium,
//        servings: 10,
//        servingsSize: 100,
//        comments: []
//    ),
//
//    Recipe(
//        id: 6,
//        name: "Colivă",
//        createdAt: Date(timeIntervalSince1970: 1736745601), // 2025-01-12 10:00:01 UTC
//        preparationTime: 60,
//        cookingTime: 45,
//        tags: ["Romanian", "Traditional", "Dessert", "Religious", "Memorial"],
//        steps: [
//            "Cook wheat berries until soft",
//            "Grind nuts and mix with sugar",
//            "Layer wheat with nut mixture",
//            "Decorate with cocoa powder",
//            "Create traditional cross pattern",
//            "Garnish with candy decorations"
//        ],
//        description: "Traditional Romanian memorial wheat berry pudding, decorated with ground nuts and cocoa",
//        ingredients: [
//            Ingredient(name: "Wheat Berries", shortName: "Wheat", quantity: "500", unit: "g"),
//            Ingredient(name: "Ground Walnuts", shortName: "Walnuts", quantity: "300", unit: "g"),
//            Ingredient(name: "Powdered Sugar", shortName: "Sugar", quantity: "200", unit: "g"),
//            Ingredient(name: "Vanilla Extract", shortName: "Vanilla", quantity: "2", unit: "tsp"),
//            Ingredient(name: "Cocoa Powder", shortName: "Cocoa", quantity: "50", unit: "g")
//        ],
//        calories: 285,
//        totalFat: 12.4,
//        sugar: 18.5,
//        sodium: 15,
//        protein: 8.2,
//        saturatedFat: 1.2,
//        carbohydrates: 38.5,
//        cholesterol: 0,
//        fiber: 4.8,
//        likesCount: 987,
//        authorName: "Alex-Simedrea",
//        images: [
//            "https://retete-thermomix.ro/wp-content/uploads/2021/12/Sarmale.webp",
//            "https://simonacallas.com/wp-content/uploads/2017/07/Sarmale-romanesti-in-foi-de-varza-1.jpg"
//        ],
//        difficulty: .medium,
//        servings: 15,
//        servingsSize: 100,
//        comments: []
//    )
]
