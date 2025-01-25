//
//  SavedRecipesViewModel.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 25.01.2025.
//

import Foundation

class SavedRecipesViewModel: ObservableObject {
    static let shared = SavedRecipesViewModel()
    
    // MARK: - Published Properties
    @Published private(set) var recipes: [Recipe] = []
    
    // MARK: - Storage Keys
    private let recipesKey = "saved_recipe"
    private let storage = UserDefaults.standard
    
    init() {
        loadState()
    }
    
    // MARK: - Public Methods
    func saveRecipe(_ recipe: Recipe) {
        recipes.append(recipe)
        saveState()
    }
    
    func removeRecipe(_ recipe: Recipe) {
        recipes.removeAll { $0.id == recipe.id }
        saveState()
    }
    
    func isSaved(_ recipe: Recipe) -> Bool {
        recipes.contains { $0.id == recipe.id }
    }

    // MARK: - Private Methods
    private func loadState() {
        if let data = storage.data(forKey: recipesKey),
           let savedRecipes = try? JSONDecoder().decode([Recipe].self, from: data) {
            recipes = savedRecipes
        }
    }
    
    private func saveState() {
        if let data = try? JSONEncoder().encode(recipes) {
            storage.set(data, forKey: recipesKey)
        }
    }
}
