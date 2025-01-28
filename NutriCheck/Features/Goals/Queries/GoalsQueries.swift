//
//  GoalsQueries.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 27.01.2025.
//

import Alamofire
import Foundation

struct CalorieLog: Codable {
    var target: Double
    var consumed: Double
}

@MainActor
enum GoalsQueries {
    static func getTargetCalories() -> Query<CalorieLog> {
        Query(
            queryKey: .init("targetCalories"),
            queryFn: {
                try await api.request(
                    Router.getTargetCalories
                )
                .validate()
                .serializingDecodable(
                    CalorieLog.self
                )
                .value
            }
        )
    }
    
    
    
    static func logCalories() -> Mutation<Double, Empty> {
        Mutation(
            invalidateKeys: [.init("targetCalories")],
            mutationFn: { body in
                try await api.request(
                    Router.logCalories(calories: body)
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
    
    static func logRecipe() -> Mutation<Int, Empty> {
        Mutation(
            invalidateKeys: [.init("targetCalories")],
            mutationFn: { body in
                try await api.request(
                    Router.logRecipe(recipeID: body)
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
