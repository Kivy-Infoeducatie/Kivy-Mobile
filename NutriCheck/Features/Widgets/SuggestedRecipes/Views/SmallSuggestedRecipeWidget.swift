//
//  SmallSuggestedRecipeWidget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 27.01.2025.
//

import SwiftUI
import CachedAsyncImage

struct SmallSuggestedRecipeWidget: View {
    let widget: Widget
    let height: CGFloat?
    
    init(widget: Widget, height: CGFloat? = nil) {
        self.widget = widget
        self.height = height
    }
    
    @StateObject private var recipes = RecipeQueries.getRecipeRecommendations()
    @Namespace var namespace
    @State private var showRecipeDetails = false

    var body: some View {
        withQueryProgress(recipes) { recipes in
            let recipe = recipes.first ?? Recipe.EmptyRecipe
            
            Button(action: { showRecipeDetails.toggle() }) {
                ZStack(alignment: .bottomLeading) {
                    VariableBlurView(direction: .blurredBottomClearTop)
                        .frame(height: 80)
                    VStack(alignment: .leading) {
                        HStack(spacing: 4) {
                            Image(systemName: widget.type.icon)
                            Text(widget.type.title)
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .opacity(0.9)
                        Text(recipe.name)
                            .font(.callout.bold())
                            .lineLimit(1)
                        Text("by \(recipe.authorUsername)")
                            .font(.caption.bold())
                            .lineLimit(1)
                    }
                    .foregroundStyle(.white)
                    .padding(12)
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
            .frame(maxHeight: .infinity)
            .matchedTransitionSource(id: "recipe\(recipe.id)", in: namespace)
            .fullScreenCover(isPresented: $showRecipeDetails) {
                RecipeScreen(recipe: recipe)
                    .navigationTransition(.zoom(sourceID: "recipe\(recipe.id)", in: namespace))
            }
        }
    }
}


//#Preview {
//    SmallSuggestedRecipeWidget()
//}
