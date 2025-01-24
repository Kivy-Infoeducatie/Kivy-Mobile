//
//  RecipeQueries.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 24.01.2025.
//

import Foundation

@MainActor
enum RecipeQueries {
    static func getRecipeRecommendations() -> Query<[Recipe]> {
        Query(queryKey: .init("recipeRecommendations")) {
            try await api.request(
                Router.getRecipeRecommendations
            )
            .validate()
            .responseData { res in
                switch res.result {
                case .success(let data):
//                    print("Data recipe: \(String(data: data, encoding: .utf8) ?? "")")
                    
                    do {
                        let decoder = JSONDecoder()
                        let recipes = try decoder.decode([Recipe].self, from: data)
                        print("Successfully decoded \(recipes.count) recipes")
                    } catch DecodingError.keyNotFound(let key, let context) {
                        print("Missing key: \(key.stringValue) - \(context.debugDescription)")
                    } catch DecodingError.typeMismatch(let type, let context) {
                        print("Type mismatch: \(type) - \(context.debugDescription)")
                    } catch DecodingError.valueNotFound(let type, let context) {
                        print("Value not found: \(type) - \(context.debugDescription)")
                    } catch DecodingError.dataCorrupted(let context) {
                        print("Data corrupted: \(context.debugDescription)")
                    } catch {
                        print("Other decoding error: \(error)")
                    }
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
            .serializingDecodable(
                [Recipe].self
            )
            .value
        }
    }
    
    static func getRecipe(_ id: String) -> Query<Recipe> {
        Query(queryKey: .init("recipeById")) {
            try await api.request(
                Router.getRecipe(id: id)
            )
            .validate()
            .serializingDecodable(
                Recipe.self
            )
            .value
        }
    }
}
