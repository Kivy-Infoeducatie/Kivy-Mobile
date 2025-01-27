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
            .serializingDecodable(
                [Recipe].self
            )
            .value
        }
    }
    
    static func getRecipeRecommendationsMutation() -> Mutation<Void, [Recipe]> {
        Mutation(
            mutationFn: {
                try await api.request(
                    Router.getRecipeRecommendations
                )
                .validate()
                .serializingDecodable(
                    [Recipe].self
                )
                .value
            }
        )
    }
    
    static func getRecipe(_ id: Int) -> Query<Recipe> {
        Query(queryKey: .init("recipeById", id)) {
            try await api.request(
                Router.getRecipe(id: id)
            )
            .validate()
            .responseData { res in
                switch res.result {
                case .success(let data):
                    do {
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let recipe = try decoder.decode(Recipe.self, from: data)
                        print("Successfully decoded recipe")
                    } catch {
                        print("Decoding error: \(error)")
                        if let decodingError = error as? DecodingError {
                            switch decodingError {
                            case .keyNotFound(let key, let context):
                                print("Key '\(key)' not found:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                            case .typeMismatch(let type, let context):
                                print("Type '\(type)' mismatch:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                            case .valueNotFound(let type, let context):
                                print("Value '\(type)' not found:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                            case .dataCorrupted(let context):
                                print("Data corrupted:", context.debugDescription)
                                print("codingPath:", context.codingPath)
                            @unknown default:
                                print("Unknown decoding error")
                            }
                        }
                    }
                    print("data: \(String(data: data, encoding: .utf8))")
                case .failure(let error):
                    print("error :\(error.localizedDescription)")
                }
            }
            .serializingDecodable(
                Recipe.self
            )
            .value
        }
    }
}
