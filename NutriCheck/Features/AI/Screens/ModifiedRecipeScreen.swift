//
//  ModifiedRecipeScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 27.01.2025.
//

import SwiftUI

struct ModifiedRecipeScreen: View {
    let originalRecipe: Recipe
    let modifiedRecipe: Recipe
    let prompt: String
    
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var savedRecipes: SavedRecipesViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header with prompt
//                    VStack(alignment: .leading, spacing: 12) {
//                        Text("Recipe Modified")
//                            .font(.title2.bold())
//                        
//                        Text("Your request:")
//                            .font(.headline)
//                            .foregroundColor(.secondary)
//                        
//                        Text(prompt)
//                            .font(.body)
//                            .padding()
//                            .background(Color.blue.opacity(0.1))
//                            .clipShape(RoundedRectangle(cornerRadius: 12))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
//                            )
//                    }
//                    .frame(maxWidth: .infinity, alignment: .leading)
//                    
//                    Divider()
                    
                    // Modified Recipe Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text(modifiedRecipe.name)
                            .font(.title.bold())
                        
                        if !modifiedRecipe.description.isEmpty {
                            Text(modifiedRecipe.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        // Recipe stats
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                            StatCard(
                                name: "Difficulty", 
                                value: modifiedRecipe.difficulty.title,
                                valueColor: modifiedRecipe.difficulty.color
                            )
                            
                            StatCard(name: "Total Time", value: "\(modifiedRecipe.totalTime) min")
                            
                            StatCard(
                                name: "Calories",
                                value: "\(Int(modifiedRecipe.calories ?? 0))"
                            )
                            
                            StatCard(
                                name: "Servings",
                                value: "\(modifiedRecipe.servings ?? 1)"
                            )
                        }
                        
                        // Nutrition info
                        if hasNutritionInfo {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Nutrition (per serving)")
                                    .font(.headline)
                                
                                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                    if let protein = modifiedRecipe.protein {
                                        ModifiedNutritionItem(name: "Protein", value: "\(String(format: "%.1f", protein))g")
                                    }
                                    if let carbs = modifiedRecipe.carbohydrates {
                                        ModifiedNutritionItem(name: "Carbs", value: "\(String(format: "%.1f", carbs))g")
                                    }
                                    if let fat = modifiedRecipe.totalFat {
                                        ModifiedNutritionItem(name: "Fat", value: "\(String(format: "%.1f", fat))g")
                                    }
                                    if let fiber = modifiedRecipe.fiber {
                                        ModifiedNutritionItem(name: "Fiber", value: "\(String(format: "%.1f", fiber))g")
                                    }
                                    if let sodium = modifiedRecipe.sodium {
                                        ModifiedNutritionItem(name: "Sodium", value: "\(Int(sodium))mg")
                                    }
                                    if let sugar = modifiedRecipe.sugar {
                                        ModifiedNutritionItem(name: "Sugar", value: "\(String(format: "%.1f", sugar))g")
                                    }
                                }
                            }
                            .padding()
                            .background(Color.orange.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Ingredients
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Ingredients")
                                .font(.headline)
                            
                            ForEach(modifiedRecipe.ingredients ?? [], id: \.name) { ingredient in
                                HStack(alignment: .top, spacing: 12) {
                                    Circle()
                                        .fill(Color.blue.opacity(0.3))
                                        .frame(width: 6, height: 6)
                                        .padding(.top, 6)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(ingredient.name)
                                            .font(.body)
                                        
                                        if let quantity = ingredient.quantity, let unit = ingredient.unit {
                                            Text("\(quantity) \(unit)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    
                                    Spacer()
                                }
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        
                        // Steps
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Instructions")
                                .font(.headline)
                            
                            ForEach(Array((modifiedRecipe.steps ?? []).enumerated()), id: \.offset) { index, step in
                                HStack(alignment: .top, spacing: 12) {
                                    Text("\(index + 1)")
                                        .font(.caption.bold())
                                        .frame(width: 24, height: 24)
                                        .background(Color.orange.opacity(0.8))
                                        .foregroundColor(.white)
                                        .clipShape(Circle())
                                    
                                    Text(step)
                                        .font(.body)
                                        .multilineTextAlignment(.leading)
                                    
                                    Spacer()
                                }
                                .padding(.bottom, 8)
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        if savedRecipes.isSaved(modifiedRecipe) {
                            savedRecipes.removeRecipe(modifiedRecipe)
                        } else {
                            savedRecipes.saveRecipe(modifiedRecipe)
                        }
                    } label: {
                        Image(systemName: savedRecipes.isSaved(modifiedRecipe) ? "bookmark.fill" : "bookmark")
                            .foregroundColor(savedRecipes.isSaved(modifiedRecipe) ? .yellow : .primary)
                    }
                }
            }
        }
    }
    
    private var hasNutritionInfo: Bool {
        modifiedRecipe.protein != nil || 
        modifiedRecipe.carbohydrates != nil || 
        modifiedRecipe.totalFat != nil || 
        modifiedRecipe.fiber != nil || 
        modifiedRecipe.sodium != nil || 
        modifiedRecipe.sugar != nil
    }
}

struct ModifiedNutritionItem: View {
    let name: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body.bold())
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color.white.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

#Preview {
    ModifiedRecipeScreen(
        originalRecipe: recipeMocks[0],
        modifiedRecipe: recipeMocks[0],
        prompt: "Make this recipe healthier and reduce the calories"
    )
    .environmentObject(SavedRecipesViewModel())
} 
