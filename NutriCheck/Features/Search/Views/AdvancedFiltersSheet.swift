//
//  AdvancedFiltersSheet.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 26.01.2025.
//

import SwiftUI

struct AdvancedFiltersSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var filters: SearchRecipeDTO
    let onApply: (SearchRecipeDTO) -> Void
    
    @State private var tempFilters: SearchRecipeDTO
    
    init(filters: Binding<SearchRecipeDTO>, onApply: @escaping (SearchRecipeDTO) -> Void) {
        self._filters = filters
        self.onApply = onApply
        self._tempFilters = State(initialValue: filters.wrappedValue)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Nutrition Filters
                Section("Nutrition (per serving)") {
                    NutritionRangeRow(
                        title: "Calories",
                        min: $tempFilters.minCalories,
                        max: $tempFilters.maxCalories,
                        unit: "kcal"
                    )
                    
                    NutritionRangeRow(
                        title: "Protein",
                        min: $tempFilters.minProtein,
                        max: $tempFilters.maxProtein,
                        unit: "g"
                    )
                    
                    NutritionRangeRow(
                        title: "Carbohydrates",
                        min: $tempFilters.minCarbohydrates,
                        max: $tempFilters.maxCarbohydrates,
                        unit: "g"
                    )
                    
                    NutritionRangeRow(
                        title: "Total Fat",
                        min: $tempFilters.minTotalFat,
                        max: $tempFilters.maxTotalFat,
                        unit: "g"
                    )
                    
                    NutritionRangeRow(
                        title: "Saturated Fat",
                        min: $tempFilters.minSaturatedFat,
                        max: $tempFilters.maxSaturatedFat,
                        unit: "g"
                    )
                    
                    NutritionRangeRow(
                        title: "Sugar",
                        min: $tempFilters.minSugar,
                        max: $tempFilters.maxSugar,
                        unit: "g"
                    )
                    
                    NutritionRangeRow(
                        title: "Fiber",
                        min: $tempFilters.minFiber,
                        max: $tempFilters.maxFiber,
                        unit: "g"
                    )
                    
                    NutritionRangeRow(
                        title: "Sodium",
                        min: $tempFilters.minSodium,
                        max: $tempFilters.maxSodium,
                        unit: "mg"
                    )
                    
                    NutritionRangeRow(
                        title: "Cholesterol",
                        min: $tempFilters.minCholesterol,
                        max: $tempFilters.maxCholesterol,
                        unit: "mg"
                    )
                }
                
                // Time and Complexity Filters
                Section("Recipe Details") {
                    TimeRangeRow(
                        title: "Preparation Time",
                        min: $tempFilters.minPreparationTime,
                        max: $tempFilters.maxPreparationTime,
                        unit: "min"
                    )
                    
                    TimeRangeRow(
                        title: "Cooking Time",
                        min: $tempFilters.minCookingTime,
                        max: $tempFilters.maxCookingTime,
                        unit: "min"
                    )
                    
                    TimeRangeRow(
                        title: "Number of Steps",
                        min: $tempFilters.minSteps,
                        max: $tempFilters.maxSteps,
                        unit: "steps"
                    )
                    
                    // Difficulty Picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Difficulty")
                            .font(.headline)
                        
                        HStack {
                            ForEach(["easy", "medium", "hard"], id: \.self) { difficulty in
                                Button {
                                    toggleDifficulty(difficulty)
                                } label: {
                                    HStack {
                                        Image(systemName: isDifficultySelected(difficulty) ? "checkmark.circle.fill" : "circle")
                                        Text(difficulty.capitalized)
                                    }
                                    .foregroundColor(isDifficultySelected(difficulty) ? .blue : .primary)
                                }
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
                
                // Tags Section
                Section("Tags") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Common tags:")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(commonTags, id: \.self) { tag in
                                Button {
                                    toggleTag(tag)
                                } label: {
                                    Text(tag)
                                        .font(.caption)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(isTagSelected(tag) ? .blue : .gray.opacity(0.2))
                                        )
                                        .foregroundColor(isTagSelected(tag) ? .white : .primary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Advanced Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        applyFilters()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    private let commonTags = [
        "vegetarian", "vegan", "gluten-free", "dairy-free", "low-carb", "keto",
        "paleo", "healthy", "quick", "easy", "comfort-food", "spicy"
    ]
    
    private func toggleDifficulty(_ difficulty: String) {
        var currentDifficulties = tempFilters.difficulty ?? []
        
        if let index = currentDifficulties.firstIndex(of: difficulty) {
            currentDifficulties.remove(at: index)
        } else {
            currentDifficulties.append(difficulty)
        }
        
        tempFilters = SearchRecipeDTO(
            minCalories: tempFilters.minCalories,
            maxCalories: tempFilters.maxCalories,
            minTotalFat: tempFilters.minTotalFat,
            maxTotalFat: tempFilters.maxTotalFat,
            minSugar: tempFilters.minSugar,
            maxSugar: tempFilters.maxSugar,
            minSodium: tempFilters.minSodium,
            maxSodium: tempFilters.maxSodium,
            minProtein: tempFilters.minProtein,
            maxProtein: tempFilters.maxProtein,
            minSaturatedFat: tempFilters.minSaturatedFat,
            maxSaturatedFat: tempFilters.maxSaturatedFat,
            minCarbohydrates: tempFilters.minCarbohydrates,
            maxCarbohydrates: tempFilters.maxCarbohydrates,
            minFiber: tempFilters.minFiber,
            maxFiber: tempFilters.maxFiber,
            minCholesterol: tempFilters.minCholesterol,
            maxCholesterol: tempFilters.maxCholesterol,
            minSteps: tempFilters.minSteps,
            maxSteps: tempFilters.maxSteps,
            minPreparationTime: tempFilters.minPreparationTime,
            maxPreparationTime: tempFilters.maxPreparationTime,
            minCookingTime: tempFilters.minCookingTime,
            maxCookingTime: tempFilters.maxCookingTime,
            minDate: tempFilters.minDate,
            maxDate: tempFilters.maxDate,
            tags: tempFilters.tags,
            difficulty: currentDifficulties.isEmpty ? nil : currentDifficulties,
            offset: tempFilters.offset,
            search: tempFilters.search
        )
    }
    
    private func isDifficultySelected(_ difficulty: String) -> Bool {
        tempFilters.difficulty?.contains(difficulty) ?? false
    }
    
    private func toggleTag(_ tag: String) {
        var currentTags = tempFilters.tags ?? []
        
        if let index = currentTags.firstIndex(of: tag) {
            currentTags.remove(at: index)
        } else {
            currentTags.append(tag)
        }
        
        tempFilters = SearchRecipeDTO(
            minCalories: tempFilters.minCalories,
            maxCalories: tempFilters.maxCalories,
            minTotalFat: tempFilters.minTotalFat,
            maxTotalFat: tempFilters.maxTotalFat,
            minSugar: tempFilters.minSugar,
            maxSugar: tempFilters.maxSugar,
            minSodium: tempFilters.minSodium,
            maxSodium: tempFilters.maxSodium,
            minProtein: tempFilters.minProtein,
            maxProtein: tempFilters.maxProtein,
            minSaturatedFat: tempFilters.minSaturatedFat,
            maxSaturatedFat: tempFilters.maxSaturatedFat,
            minCarbohydrates: tempFilters.minCarbohydrates,
            maxCarbohydrates: tempFilters.maxCarbohydrates,
            minFiber: tempFilters.minFiber,
            maxFiber: tempFilters.maxFiber,
            minCholesterol: tempFilters.minCholesterol,
            maxCholesterol: tempFilters.maxCholesterol,
            minSteps: tempFilters.minSteps,
            maxSteps: tempFilters.maxSteps,
            minPreparationTime: tempFilters.minPreparationTime,
            maxPreparationTime: tempFilters.maxPreparationTime,
            minCookingTime: tempFilters.minCookingTime,
            maxCookingTime: tempFilters.maxCookingTime,
            minDate: tempFilters.minDate,
            maxDate: tempFilters.maxDate,
            tags: currentTags.isEmpty ? nil : currentTags,
            difficulty: tempFilters.difficulty,
            offset: tempFilters.offset,
            search: tempFilters.search
        )
    }
    
    private func isTagSelected(_ tag: String) -> Bool {
        tempFilters.tags?.contains(tag) ?? false
    }
    
    private func resetFilters() {
        tempFilters = SearchRecipeDTO(search: tempFilters.search)
    }
    
    private func applyFilters() {
        filters = tempFilters
        onApply(tempFilters)
        dismiss()
    }
}

struct NutritionRangeRow: View {
    let title: String
    @Binding var min: Double?
    @Binding var max: Double?
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Min")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack {
                        TextField("0", value: $min, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text(unit)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Max")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack {
                        TextField("∞", value: $max, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text(unit)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

struct TimeRangeRow: View {
    let title: String
    @Binding var min: Int?
    @Binding var max: Int?
    let unit: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Min")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack {
                        TextField("0", value: $min, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text(unit)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Max")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack {
                        TextField("∞", value: $max, format: .number)
                            .keyboardType(.numberPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        Text(unit)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    @State var filters = SearchRecipeDTO(search: "chicken")
    
    return AdvancedFiltersSheet(
        filters: $filters,
        onApply: { _ in }
    )
} 