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
