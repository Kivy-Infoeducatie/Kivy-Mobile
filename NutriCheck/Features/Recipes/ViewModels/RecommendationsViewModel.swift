//
//  RecommendationsViewModel.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 25.01.2025.
//

import Foundation

class RecommendationsViewModel: ObservableObject {
    @Published var recommendations: [Recipe] = []
    @Published var currentRecommendationIndex: Int = 0
    
    func addRecommendations(_ recipes: [Recipe]) {
        recommendations.append(contentsOf: recipes)
    }
    
    func clearRecommendations() {
        recommendations.removeAll()
    }
    
    func setIndex(_ index: Int) {
        currentRecommendationIndex = index
    }
}
