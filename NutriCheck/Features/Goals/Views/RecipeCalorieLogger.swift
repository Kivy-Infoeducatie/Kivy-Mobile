//
//  RecipeCalorieLogger.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 26.01.2025.
//

import SwiftUI
import SwiftData
import Toasts

@MainActor
struct RecipeCalorieLogger {
    static func logRecipe(
        _ recipe: Recipe,
        modelContext: ModelContext,
        presentToast: PresentToastAction,
        showToast: Bool = false
    ) {
        guard let calories = recipe.calories, calories > 0 else {
            let toast = ToastValue(
                icon: Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red),
                message: "Recipe has no calorie information"
            )
            presentToast(toast)
            return
        }
        
        let calorieIntake = CalorieIntake(
            amount: calories,
            source: recipe.name,
            sourceType: .recipe,
            recipeId: recipe.id,
            notes: "Recipe: \(recipe.name)"
        )
        
        modelContext.insert(calorieIntake)
        
        do {
            try modelContext.save()
            
            if showToast {
                let toast = ToastValue(
                    icon: Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.orange),
                    message: "\(Int(calories)) calories logged from \(recipe.name)"
                )
                presentToast(toast)
            }
        } catch {
            print("Failed to save recipe calorie intake: \(error)")
            
            let toast = ToastValue(
                icon: Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.red),
                message: "Failed to log recipe calories"
            )
            presentToast(toast)
        }
    }
} 
