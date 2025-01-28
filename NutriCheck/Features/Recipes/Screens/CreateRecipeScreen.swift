//
//  CreateRecipe.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 27.01.2025.
//

import SwiftUI

struct CreateRecipeScreen: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.presentToast) var presentToast
    @State private var recipe: Recipe = Recipe.EmptyRecipe
    @StateObject private var createRecipe = RecipeQueries.createRecipe()
    
    var body: some View {
        NavigationStack {
            RecipeForm(recipe: $recipe)
                .navigationTitle("Create Recipe")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Create") {
                            createRecipe
                                .execute(
                                    recipe,
                                    presenting: presentToast,
                                    successMessage: "Recipe created successfully",
                                    onSuccess: { _ in
                                        dismiss()
                                    }
                                )
                        }
                    }
                }
        }
    }
}

struct RecipeForm: View {
    @Binding var recipe: Recipe
    @State private var newIngredient = Ingredient(
        name: "",
        quantity: "",
        unit: ""
    )
    @State private var newTag = ""
    @State private var newStep = ""
    
    var body: some View {
        Form {
            Section(header: Text("Basic Information")) {
                TextField("Recipe Name", text: $recipe.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                TextEditor(text: $recipe.description)
                    .frame(height: 100)
                
                Picker("Difficulty", selection: $recipe.difficulty) {
                    ForEach(Difficulty.allCases, id: \.self) { difficulty in
                        Text(difficulty.title).tag(difficulty)
                    }
                }
            }
            
            Section(header: Text("Times & Servings")) {
                HStack {
                    Text("Preparation Time (min)")
                    TextField("", value: $recipe.preparationTime, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                HStack {
                    Text("Cooking Time (min)")
                    TextField("", value: $recipe.cookingTime, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
                
                HStack {
                    Text("Servings")
                    TextField("", value: $recipe.servings, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                }
            }
            
            Section(header: Text("Nutritional Information (per serving)")) {
                HStack {
                    Text("Calories")
                    TextField("", value: $recipe.calories, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                HStack {
                    Text("Total Fat (g)")
                    TextField("", value: $recipe.totalFat, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                HStack {
                    Text("Sugar (g)")
                    TextField("", value: $recipe.sugar, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                HStack {
                    Text("Sodium (mg)")
                    TextField("", value: $recipe.sodium, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                HStack {
                    Text("Protein (g)")
                    TextField("", value: $recipe.protein, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                HStack {
                    Text("Saturated Fat (g)")
                    TextField("", value: $recipe.saturatedFat, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                HStack {
                    Text("Carbohydrates (g)")
                    TextField("", value: $recipe.carbohydrates, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                HStack {
                    Text("Fiber (g)")
                    TextField("", value: $recipe.fiber, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
                
                HStack {
                    Text("Cholesterol (mg)")
                    TextField("", value: $recipe.cholesterol, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.decimalPad)
                }
            }
            
            Section(header: Text("Tags")) {
                ForEach(recipe.tags, id: \.self) { tag in
                    Text(tag)
                }
                HStack {
                    TextField("New Tag", text: $newTag)
                    Button("Add") {
                        if !newTag.isEmpty {
                            recipe.tags.append(newTag)
                            newTag = ""
                        }
                    }
                }
            }
            
            Section(header: Text("Ingredients")) {
                ForEach(recipe.ingredients ?? [], id: \.name) { ingredient in
                    VStack(alignment: .leading) {
                        Text(ingredient.name)
                        Text("\(ingredient.quantity ?? "") \(ingredient.unit ?? "")")
                            .font(.caption)
                    }
                }
                
                VStack {
                    @State var quantity: String = ""
                    @State var unit: String = ""
                    
                    TextField("Name", text: $newIngredient.name)
                    TextField("Quantity", text: $quantity)
                    TextField("Unit", text: $unit)
                    
                    Button("Add Ingredient") {
                        if !newIngredient.name.isEmpty {
                            newIngredient.quantity = quantity
                            newIngredient.unit = unit
                            recipe.ingredients = (recipe.ingredients ?? []) + [newIngredient]
                            newIngredient = Ingredient(name: "",  quantity: "", unit: "")
                        }
                    }
                }
            }
            
            Section(header: Text("Steps")) {
                ForEach(recipe.steps ?? [], id: \.self) { step in
                    Text(step)
                }
                
                HStack {
                    TextField("New Step", text: $newStep)
                    Button("Add") {
                        if !newStep.isEmpty {
                            recipe.steps = (recipe.steps ?? []) + [newStep]
                            newStep = ""
                        }
                    }
                }
            }
        }
    }
}
