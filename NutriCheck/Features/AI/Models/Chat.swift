//
//  Chat.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 27.01.2025.
//

import Foundation

struct Chat: Codable, Identifiable {
    var id: Int
    var name: String
    var createdAt: String
    var messages: [Message]?
}

struct Message: Codable {
    let id: Int?
    let role: Role
    let parts: [Part]
    let createdAt: Date
    
    enum Role: String, Codable {
        case user
        case model
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case role
        case parts
        case createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        role = try container.decode(Role.self, forKey: .role)
        parts = try container.decode([Part].self, forKey: .parts)
        
        let dateString = try container.decode(String.self, forKey: .createdAt)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = formatter.date(from: dateString) {
            createdAt = date
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .createdAt,
                in: container,
                debugDescription: "Date string does not match format: yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            )
        }
    }
}

struct Part: Codable {
    let text: TextContent
}

enum TextContent: Codable {
    case string(String)
    case response(Response)
    
    private enum CodingKeys: String, CodingKey {
        case response
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let responseValue = try? container.decode(Response.self) {
            self = .response(responseValue)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode TextContent")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .response(let response):
            try container.encode(response)
        }
    }
}

struct Response: Codable {
    let response: String
    let recipe: AIRecipe?
}

struct AIRecipe: Codable {
    let id: Int
    let name: String
    let fiber: Double?
    let steps: [String]
    let sugar: Double?
    let sodium: Double?
    let protein: Double?
    let calories: Double?
    let servings: Int
    let totalFat: Double?
    let difficulty: String
    let cholesterol: Double?
    let cookingTime: Int
    let ingredients: [AIIngredient]
    let servingSize: Int
    let saturatedFat: Double?
    let carbohydrates: Double?
    let preparationTime: Int
    let description: String
}

struct AIIngredient: Codable {
    let name: String
    let unit: String?
    let quantity: Double?
}

// Extension to convert AIRecipe to Recipe
extension AIRecipe {
    func toRecipe() -> Recipe {
        // Convert API ingredients array to Recipe ingredients array
        let ingredientsArray: [Ingredient] = self.ingredients.map { apiIngredient in
            Ingredient(
                name: apiIngredient.name,
                shortName: nil,
                quantity: apiIngredient.quantity != nil ? String(Int(apiIngredient.quantity!)) : "1",
                unit: apiIngredient.unit ?? "piece", // Default to "piece" if no unit provided
                unitQuantity: nil,
                unitUnit: nil
            )
        }
        
        return Recipe(
            id: self.id == -1 ? 0 : self.id, // Handle -1 id from API
            name: self.name,
            cookingTime: self.cookingTime,
            tags: ["AI Generated", "Modified"], // Default tags for AI-modified recipes
            description: self.description,
            ingredientsCount: ingredientsArray.count,
            calories: self.calories,
            likesCount: nil,
            authorName: "AI Assistant",
            images: [], // No images in AI response
            difficulty: Difficulty(rawValue: self.difficulty) ?? .easy,
            author: nil,
            createdAt: nil,
            preparationTime: self.preparationTime,
            steps: self.steps,
            ingredients: ingredientsArray,
            totalFat: self.totalFat,
            sugar: self.sugar,
            sodium: self.sodium,
            protein: self.protein,
            saturatedFat: self.saturatedFat,
            carbohydrates: self.carbohydrates,
            cholesterol: self.cholesterol,
            fiber: self.fiber,
            servings: self.servings,
            servingsSize: self.servingSize,
            posts: nil
        )
    }
}

struct CreateChatResponse: Codable {
    let message: Response
    let chatID: Int
    let userMessageID: Int
    let modelMessageID: Int
}

struct SendMessageResponse: Codable {
    let message: Response
    let userMessageID: Int
    let modelMessageID: Int
}
