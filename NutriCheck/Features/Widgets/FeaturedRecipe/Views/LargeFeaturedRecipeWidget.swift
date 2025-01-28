//
//  LargeFeaturedRecipeWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 18.12.2024.
//

import SwiftUI
import CachedAsyncImage

struct LargeFeaturedRecipeWidget: View {
    let widget: Widget
    
    @StateObject private var recipes = RecipeQueries.getFeaturedRecipes()
    @Namespace var namespace
    @State private var showRecipeDetails = false
    
    var body: some View {
        withQueryProgress(recipes) { recipes in
            let recipe = recipes.first ?? Recipe.EmptyRecipe
            
            Button(action: { showRecipeDetails.toggle() }) {
                ZStack(alignment: .bottomLeading) {
                    VariableBlurView(direction: .blurredBottomClearTop)
                        .frame(height: 100)
                    VStack(alignment: .leading) {
                        HStack(spacing: 4) {
                            Image(systemName: widget.type.icon)
                            Text(widget.type.title)
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .opacity(0.9)
                        Text(recipe.name)
                            .font(.title3.bold())
                            .lineLimit(1)
                        Text("by \(recipe.authorUsername)")
                            .font(.callout.bold())
                            .lineLimit(1)
                    }
                    .foregroundStyle(.white)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .frame(maxHeight: .infinity, alignment: .bottomLeading)
                .background {
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
                                .aspectRatio(contentMode: .fill)
                        case .failure:
                            Image(systemName: "photo")
                        default:
                            Image(systemName: "photo")
                        }
                    }
                }
            }
            .frame(height: 300)
            .matchedTransitionSource(id: "recipe\(recipe.id)", in: namespace)
            .fullScreenCover(isPresented: $showRecipeDetails) {
                RecipeScreen(recipe: recipe)
                    .navigationTransition(.zoom(sourceID: "recipe\(recipe.id)", in: namespace))
            }
        }
    }
}
