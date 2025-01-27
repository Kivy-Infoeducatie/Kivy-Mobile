//
//  LargeSuggestedRecipesWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 19.12.2024.
//

import CachedAsyncImage
import SwiftUI

struct LargeSuggestedRecipesWidget: View {
    @StateObject private var recipes = RecipeQueries.getRecipeRecommendations()

    var body: some View {
        withQueryProgress(recipes) { recipes in
            let recipes = recipes.prefix(3)

            VStack(spacing: 16) {
                ForEach(recipes) { recipe in
                    RecipeInlineView(recipe: recipe)
                }
            }
        }
    }
}

#Preview {
    LargeSuggestedRecipesWidget()
}

struct RecipeInlineView: View {
    let recipe: Recipe
    @State private var showRecipeDetails = false
    @Namespace var namespace

    var body: some View {
        Button(action: { showRecipeDetails.toggle() }) {
            HStack(spacing: 20) {
                CachedAsyncImage(
                    url: URL(
                        string: recipe.images.first ?? ""
                    )
                ) { result in
                    switch result {
                    case .empty:
                        Image(systemName: "photo")
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 60, height: 60)
                            .clipShape(.rect(cornerRadius: 12))
                    case .failure:
                        Image(systemName: "photo")
                    default:
                        Image(systemName: "photo")
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(recipe.name)
                        .font(.headline.bold())
                        .multilineTextAlignment(.leading)
                    Text("by \(recipe.authorUsername)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack {
                        Text("\(recipe.totalTime) m")
                            .font(.subheadline)
                        Divider()
                            .frame(height: 12)
                        Text(recipe.difficulty.title)
                            .font(.subheadline)
                            .foregroundStyle(recipe.difficulty.color)
                        //                                Divider()
                        //                                    .frame(height: 12)
                        //                                Text("30m")
                        //                                    .font(.subheadline)
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .matchedTransitionSource(id: "recipe\(recipe.id)", in: namespace)
        .fullScreenCover(isPresented: $showRecipeDetails) {
            RecipeScreen(recipe: recipe)
                .navigationTransition(.zoom(sourceID: "recipe\(recipe.id)", in: namespace))
        }
    }
}
