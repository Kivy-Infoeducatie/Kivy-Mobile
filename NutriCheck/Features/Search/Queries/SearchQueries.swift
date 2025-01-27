//
//  SearchQueries.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 25.01.2025.
//

import Foundation

@MainActor
enum SearchQueries {
    static func searchRecipes() -> Mutation<SearchRecipeDTO, [Recipe]> {
        Mutation(mutationFn: { data in
            try await api.request(
                Router.searchRecipes(query: data)
            )
            .validate()
            .serializingDecodable(
                [Recipe].self
            )
            .value
        })
    }
}
