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
    
    // Memory management constants
    private let maxRecommendations = 50 // Keep maximum 50 recipes in memory
    private let trimThreshold = 40 // Start cleanup when we reach this many
    
    func addRecommendations(_ recipes: [Recipe]) {
        recommendations.append(contentsOf: recipes)
        
        // Memory management: trim old recipes if we have too many
        if recommendations.count > maxRecommendations {
            trimOldRecommendations()
        }
    }
    
    func clearRecommendations() {
        recommendations.removeAll()
        currentRecommendationIndex = 0
    }
    
    func setIndex(_ index: Int) {
        currentRecommendationIndex = index
    }
    
    // MARK: - Memory Management
    private func trimOldRecommendations() {
        // Keep recipes around the current position and recent ones
        let keepStart = max(0, currentRecommendationIndex - 10)
        let keepEnd = min(recommendations.count, keepStart + 30)
        
        // Only keep recipes in the active window
        recommendations = Array(recommendations[keepStart..<keepEnd])
        
        // Adjust current index
        currentRecommendationIndex = max(0, currentRecommendationIndex - keepStart)
    }
    
    // Check if we should load more recommendations
    var shouldLoadMore: Bool {
        return currentRecommendationIndex >= recommendations.count - 5
    }
}
