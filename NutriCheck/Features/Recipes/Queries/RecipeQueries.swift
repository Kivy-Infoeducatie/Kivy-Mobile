//
//  RecipeQueries.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 24.01.2025.
//

import Alamofire
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

    static func getFeaturedRecipes() -> Query<[Recipe]> {
        Query(queryKey: .init("featuredRecipes")) {
            try await api.request(
                Router.getFeaturedRecipes
            )
            .validate()
            .serializingDecodable(
                [Recipe].self
            )
            .value
        }
    }

    static func getRecipe(_ id: Int) -> Query<Recipe> {
        Query(queryKey: .init("recipe", id)) {
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
    
    static func createRecipe() -> Mutation<Recipe, Empty> {
        Mutation(
            mutationFn: { body in
                try await api.request(
                    Router.createRecipe(recipe: body)
                )
                .validate()
                .serializingDecodable(
                    Empty.self,
                    emptyResponseCodes: [200, 201]
                )
                .value
            }
        )
    }
}

@MainActor
enum PostsMutations {
    static func createPost() -> Mutation<CreatePostDTO, Empty> {
        Mutation(
            invalidateKeysFromInput: { body in
                [.init("recipe", body.recipeID)]
            },
            mutationFn: { body in
                try await api.request(
                    Router.createPost(post: body)
                )
                .validate()
                .serializingDecodable(
                    Empty.self,
                    emptyResponseCodes: [200, 201]
                )
                .value
            }
        )
    }
}
