//
//  SearchResultsScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 26.01.2025.
//

import SwiftUI
import CachedAsyncImage

struct SearchResultsScreen: View {
    let query: String
    @StateObject private var searchResults = SearchQueries.searchRecipes()
    @EnvironmentObject private var recents: RecentSearchesViewModel
    
    @State private var showFilters = false
    @State private var filters = SearchRecipeDTO()
    @State private var hasActiveFilters = false

    init(query: String) {
        self.query = query
    }
    
    var body: some View {
        NavigationStack {
            withMutationProgress(searchResults) { results in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Active filters indicator
                        if hasActiveFilters {
                            ActiveFiltersView(filters: filters, onClear: clearFilters)
                        }
                        
                        ForEach(results) { recipe in
                            SmallRecipeCard(recipe: recipe, isExpanded: true)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Search results")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showFilters = true
                    } label: {
                        Image(systemName: hasActiveFilters ? "line.3.horizontal.decrease.circle.fill" : "line.3.horizontal.decrease.circle")
                            .foregroundColor(hasActiveFilters ? .blue : .primary)
                    }
                }
            }
            .onAppear {
                recents.saveSearch(query)
                // Initialize filters with the search query
                filters = SearchRecipeDTO(search: query)
                searchResults.execute(filters)
            }
            .sheet(isPresented: $showFilters) {
                AdvancedFiltersSheet(
                    filters: $filters,
                    onApply: applyFilters
                )
                .presentationDetents([.large])
                .presentationBackground(.thinMaterial)
            }
        }
    }
    
    private func applyFilters(_ newFilters: SearchRecipeDTO) {
        filters = newFilters
        searchResults.execute(filters)
        updateActiveFiltersState()
    }
    
    private func clearFilters() {
        filters = SearchRecipeDTO(search: query)
        searchResults.execute(filters)
        updateActiveFiltersState()
    }
    
    private func updateActiveFiltersState() {
        hasActiveFilters = filters.minCalories != nil ||
                          filters.maxCalories != nil ||
                          filters.minTotalFat != nil ||
                          filters.maxTotalFat != nil ||
                          filters.minSugar != nil ||
                          filters.maxSugar != nil ||
                          filters.minSodium != nil ||
                          filters.maxSodium != nil ||
                          filters.minProtein != nil ||
                          filters.maxProtein != nil ||
                          filters.minSaturatedFat != nil ||
                          filters.maxSaturatedFat != nil ||
                          filters.minCarbohydrates != nil ||
                          filters.maxCarbohydrates != nil ||
                          filters.minFiber != nil ||
                          filters.maxFiber != nil ||
                          filters.minCholesterol != nil ||
                          filters.maxCholesterol != nil ||
                          filters.minSteps != nil ||
                          filters.maxSteps != nil ||
                          filters.minPreparationTime != nil ||
                          filters.maxPreparationTime != nil ||
                          filters.minCookingTime != nil ||
                          filters.maxCookingTime != nil ||
                          filters.tags?.isEmpty == false ||
                          filters.difficulty?.isEmpty == false
    }
}

struct ActiveFiltersView: View {
    let filters: SearchRecipeDTO
    let onClear: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Active Filters")
                    .font(.headline)
                Spacer()
                Button("Clear All") {
                    onClear()
                }
                .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(activeFilterTags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.blue.opacity(0.1))
                            )
                            .foregroundColor(.blue)
                    }
                }
                .padding(.horizontal, 1)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
        )
    }
    
    private var activeFilterTags: [String] {
        var tags: [String] = []
        
        if let min = filters.minCalories, let max = filters.maxCalories {
            tags.append("Calories: \(Int(min))-\(Int(max))")
        } else if let min = filters.minCalories {
            tags.append("Calories: >\(Int(min))")
        } else if let max = filters.maxCalories {
            tags.append("Calories: <\(Int(max))")
        }
        
        if let min = filters.minProtein, let max = filters.maxProtein {
            tags.append("Protein: \(Int(min))-\(Int(max))g")
        } else if let min = filters.minProtein {
            tags.append("Protein: >\(Int(min))g")
        } else if let max = filters.maxProtein {
            tags.append("Protein: <\(Int(max))g")
        }
        
        if let min = filters.minPreparationTime, let max = filters.maxPreparationTime {
            tags.append("Prep: \(min)-\(max)min")
        } else if let min = filters.minPreparationTime {
            tags.append("Prep: >\(min)min")
        } else if let max = filters.maxPreparationTime {
            tags.append("Prep: <\(max)min")
        }
        
        if let difficulties = filters.difficulty, !difficulties.isEmpty {
            tags.append("Difficulty: \(difficulties.joined(separator: ", "))")
        }
        
        if let filterTags = filters.tags, !filterTags.isEmpty {
            tags.append("Tags: \(filterTags.joined(separator: ", "))")
        }
        
        return tags
    }
}
