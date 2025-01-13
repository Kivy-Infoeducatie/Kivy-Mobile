//
//  ActiveRecipeViewModel.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 12.01.2025.
//

import Foundation

class OngoingRecipeViewModel: ObservableObject {
    static let shared = OngoingRecipeViewModel()
    
    // MARK: - Published Properties
    @Published private(set) var recipe: Recipe?
    @Published private(set) var currentStepIndex: Int = 0
    
    // MARK: - Storage Keys
    private let recipeKey = "ongoing_recipe"
    private let stepIndexKey = "current_step_index"
    private let storage = UserDefaults.standard
    
    init() {
        loadState()
    }
    
    // MARK: - Public Methods
    func startRecipe(_ recipe: Recipe) {
        self.recipe = recipe
        self.currentStepIndex = 0
        saveState()
    }
    
    func nextStep() {
        guard let recipe = recipe,
              currentStepIndex < recipe.steps.count - 1 else { return }
        currentStepIndex += 1
        saveState()
    }
    
    func previousStep() {
        guard currentStepIndex > 0 else { return }
        currentStepIndex -= 1
        saveState()
    }
    
    func endRecipe() {
        recipe = nil
        currentStepIndex = 0
        storage.removeObject(forKey: recipeKey)
        storage.removeObject(forKey: stepIndexKey)
    }
    
    // MARK: - Helper Properties
    var currentStep: String? {
        guard let recipe = recipe,
              currentStepIndex < recipe.steps.count else { return nil }
        return recipe.steps[currentStepIndex]
    }
    
    var progress: Double {
        guard let recipe = recipe,
              !recipe.steps.isEmpty else { return 0 }
        return Double(currentStepIndex + 1) / Double(recipe.steps.count)
    }
    
    var isLastStep: Bool {
        guard let recipe = recipe else { return false }
        return currentStepIndex == recipe.steps.count - 1
    }
    
    // MARK: - Private Methods
    private func loadState() {
        if let data = storage.data(forKey: recipeKey),
           let savedRecipe = try? JSONDecoder().decode(Recipe.self, from: data) {
            recipe = savedRecipe
            currentStepIndex = storage.integer(forKey: stepIndexKey)
        }
    }
    
    private func saveState() {
        if let recipe = recipe,
           let data = try? JSONEncoder().encode(recipe) {
            storage.set(data, forKey: recipeKey)
            storage.set(currentStepIndex, forKey: stepIndexKey)
        }
    }
}
