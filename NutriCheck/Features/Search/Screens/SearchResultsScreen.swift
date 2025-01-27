//
//  SearchResultsScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 26.01.2025.
//

import SwiftUI

struct SearchResultsScreen: View {
    let query: String
    @StateObject private var searchResults = SearchQueries.searchRecipes()
    @EnvironmentObject private var recents: RecentSearchesViewModel

    init(query: String) {
        self.query = query
    }
    
    var body: some View {
        NavigationStack {
            withMutationProgress(searchResults) { results in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(results) { recipe in
                            SmallRecipeCard(recipe: recipe, isExpanded: true)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Search results")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                recents.saveSearch(query)
                searchResults.execute(.init(search: query))
            }
        }
    }
}
