//
//  RecipesScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 19.12.2024.
//

import CachedAsyncImage
import SwiftData
import SwiftUI

struct RecipesScreen: View {
    @State private var showTikTok = false
    @Namespace private var namespace
    @Environment(\.colorScheme) var colorScheme
    @State private var scrollOffset: CGFloat = 0
    @State private var showShoppingList = false

    @StateObject private var recipes = RecipeQueries.getRecipeRecommendations()
    @StateObject private var recommendationsViewModel = RecommendationsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                if showTikTok {
                    GeometryReader { geo in
                        withQueryError(recipes, loading: {
                            RecipesHeroPlaceHolder(namespace: namespace, geo: geo, showTikTok: $showTikTok)
                        }, success: { _ in
                            ForEach(
                                Array(recommendationsViewModel.recommendations.reversed().enumerated()),
                                id: \.offset
                            ) { index, recipe in
                                CachedAsyncImage(
                                    url: URL(string: recipe.images.first ?? "")
                                ) { result in
                                    switch result {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(
                                                width: geo.size.width
                                            )
                                            .frame(maxHeight: .infinity)
                                            .ignoresSafeArea()
                                            .blur(radius: 100, opaque: true)
                                            .opacity(Double(
                                                CGFloat(recommendationsViewModel.recommendations.count - index) - scrollOffset)
                                            )
                                    case .empty:
                                        Color.black
                                    case .failure:
                                        Color.black
                                    default:
                                        Color.black
                                    }
                                }
                            }
                        })
                    }
                    .opacity(0.5)
                } else {
                    if colorScheme == .dark {
                        CustomMeshGradientView()
                            .ignoresSafeArea()
                            .zIndex(0)
                    } else {
                        LightMeshGradientView()
                            .ignoresSafeArea()
                            .zIndex(0)
                    }
                }

                if !showTikTok {
                    GeometryReader { geo in
                        ScrollView {
                            withQuery(recipes, loading: {
                                RecipesHeroPlaceHolder(namespace: namespace, geo: geo, showTikTok: $showTikTok)
                            }, success: { _ in
                                let upperBound = min(
                                    recommendationsViewModel.currentRecommendationIndex + 3,
                                    recommendationsViewModel.recommendations.count
                                )
                                let lowerBound = upperBound - 3
                                let heroRecipes = Array(recommendationsViewModel.recommendations[lowerBound ..< upperBound])

                                VStack(alignment: .leading) {
                                    Text("Discover new recipes")
                                        .font(.title3.bold())
                                        .padding(.horizontal)
                                        .matchedGeometryEffect(id: "text", in: namespace)

                                    Button {
                                        withAnimation {
//                                            recommendationsViewModel
//                                                .addRecommendations(recipes)
                                            showTikTok.toggle()
                                        }
                                    } label: {
                                        ZStack {
                                            ForEach(
                                                Array(heroRecipes.enumerated()),
                                                id: \.offset
                                            ) { index, recipe in
                                                CardView(
                                                    recipe: recipe,
                                                    geo: geo,
                                                    height: 350,
                                                    padding: 60,
                                                    showStats: false
                                                )
                                                .frame(
                                                    width: geo.size.width - 120 < 0 ? 0 : geo.size.width - 120,
                                                    height: 350,
                                                    alignment: .bottomLeading
                                                )
                                                .padding(.horizontal, 60)
                                                .padding(.leading, CGFloat(index - 1) * 60)
                                                .rotationEffect(.degrees(5.0 * Double(index - 1)))
                                                .zIndex(index == 1 ? 10 : 0)
                                                .opacity(index == 1 ? 1 : 0.7)
                                                .matchedGeometryEffect(id: "card\(lowerBound + index)", in: namespace)
                                            }
                                        }
                                        .frame(width: geo.size.width, alignment: .center)
                                    }
                                    .padding(.top)
                                }
                                .padding(.top, 60)
                            }, error: { _ in
                                RecipesHeroPlaceHolder(namespace: namespace, geo: geo, showTikTok: $showTikTok)
                            })
                            VStack(alignment: .leading) {
                                Text("Shopping List")
                                    .font(.title3.bold())

                                Button(
                                    action: {
                                        showShoppingList.toggle()
                                    }
                                ) {
                                    ShoppingListPreview()
                                }
                                .matchedTransitionSource(id: "shopping_list", in: namespace)

                                SavedRecipesCarousel()
                                SuggestedRecipesCarousel()
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                            .padding(.bottom, 80)
                            .padding(.top, 24)
                        }
                    }
                    .transition(.opacity)
                    .zIndex(1)
                    .fullScreenCover(isPresented: $showShoppingList) {
                        ShoppingListScreen()
                            .navigationTransition(.zoom(sourceID: "shopping_list", in: namespace))
                    }
                    .refreshable {
                        await recipes.invalidate()
                    }
                }

                if showTikTok {
                    withQueryError(
                        recipes,
                        loading: {
                            ProgressView()
                        }, success: { _ in
                            RecipesTikTokScreen(
                                backAction: {
                                    showTikTok.toggle()
                                },
                                namespace: namespace,
                                recipes: recommendationsViewModel.recommendations,
                                recommendationsViewModel: recommendationsViewModel,
                                offset: $scrollOffset
                            )
                            .padding(.bottom, 40)
                            .frame(maxHeight: .infinity)
                            .transition(.opacity)
                            .zIndex(1)
                        }
                    )
                }
            }
        }
        .onAppear {
            _ = recipes.onSuccess { _ in
                recommendationsViewModel
                    .addRecommendations(recipes.state.value ?? [])
            }
        }
    }
}

#Preview {
    RecipesScreen()
}

struct ShoppingListPreview: View {
    @Query private var shoppingListItems: [ShoppingListItem]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("\(shoppingListItems.count) items")
                .font(.title3.bold())

            if !shoppingListItems.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(Array(shoppingListItems.prefix(5))) { item in
                        ShoppingListItemRow(item: item)
                    }

                    if shoppingListItems.count > 5 {
                        Text("and \(shoppingListItems.count - 5) more items")
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .padding(.top, 4)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(.thinMaterial)
        }
    }
}

struct SmallRecipeCard: View {
    let recipe: Recipe
    let isExpanded: Bool

    init(recipe: Recipe, isExpanded: Bool = false) {
        self.recipe = recipe
        self.isExpanded = isExpanded
    }

    @Namespace private var namespace
    @State private var showRecipe = false

    var body: some View {
        Button(action: {
            showRecipe.toggle()
        }) {
            HStack {
                CachedAsyncImage(url: URL(string: recipe.images.first ?? "")) { result in
                    switch result {
                    case .empty:
                        Image(systemName: "photo")
                            .frame(width: 80, height: 100)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 100)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .frame(width: 80, height: 100)
                    default:
                        Image(systemName: "photo")
                            .frame(width: 80, height: 100)
                    }
                }

                VStack(alignment: .leading) {
                    Text(recipe.name)
                        .font(.callout.bold())
                        .lineLimit(2)
                    Text(recipe.authorUsername)
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    HStack {
                        Text("\(recipe.calories.unwrappedToNA)kcal")
                        Divider()
                            .frame(height: 12)
                        Text("\(recipe.totalTime)m")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .opacity(0.7)
                }
                .padding(.vertical)
                .padding(.trailing, 4)
            }
            .frame(width: isExpanded ? nil : 250, height: 80, alignment: .leading)
            .frame(maxWidth: isExpanded ? .infinity : nil, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.thinMaterial)
            }
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .matchedTransitionSource(id: recipe.id, in: namespace)
        .fullScreenCover(isPresented: $showRecipe) {
            RecipeScreen(recipe: recipe)
                .navigationTransition(.zoom(sourceID: recipe.id, in: namespace))
        }
    }
}

struct NavigationLinkSectionHeader<Destination: View>: View {
    let title: String
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Text(title)
                    .font(.title3.bold())
                Spacer()
                Image(systemName: "chevron.right")
            }
        }
    }
}

struct RecipesHeroPlaceHolder: View {
    let namespace: Namespace.ID
    let geo: GeometryProxy
    @Binding var showTikTok: Bool

    var body: some View {
        VStack(alignment: .leading) {
            Text("Discover new recipes")
                .font(.title3.bold())
                .padding(.horizontal)
                .matchedGeometryEffect(id: "text", in: namespace)

            ZStack {
                ForEach(
                    Array([Recipe.EmptyRecipe, Recipe.EmptyRecipe, Recipe.EmptyRecipe].enumerated()),
                    id: \.offset
                ) { index, _ in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.regularMaterial)
                        .frame(
                            width: geo.size.width - 120 < 0 ? 0 : geo.size.width - 120,
                            height: 350,
                            alignment: .bottomLeading
                        )
                        .padding(.horizontal, 60)
                        .padding(.leading, CGFloat(index - 1) * 60)
                        .rotationEffect(.degrees(5.0 * Double(index - 1)))
                        .zIndex(index == 1 ? 10 : 0)
                        .opacity(index == 1 ? 1 : 0.7)
                }
            }
            .frame(width: geo.size.width, alignment: .center)
            .padding(.top)
        }
        .padding(.top, 60)
    }
}

struct SuggestedRecipesCarousel: View {
    @StateObject private var recipes = RecipeQueries.getRecipeRecommendations()

    var body: some View {
        NavigationLinkSectionHeader(
            title: "Suggestions for you",
            destination: SuggestedRecipesExpandedScreen()
        )
        .padding(.top)
        withQueryProgress(recipes) { recipes in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(recipes) { recipe in
                        SmallRecipeCard(recipe: recipe)
                    }
                }
            }
            .scrollClipDisabled()
        }
    }
}

struct SuggestedRecipesExpandedScreen: View {
    @StateObject private var recipes = RecipeQueries.getRecipeRecommendations()

    var body: some View {
        NavigationStack {
            withQueryProgress(recipes) { recipes in
                ScrollView {
                    VStack(spacing: 12) {
                        ForEach(recipes) { recipe in
                            SmallRecipeCard(recipe: recipe, isExpanded: true)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                }
                .scrollClipDisabled()
                .safeAreaPadding(.bottom, 60)
            }
            .navigationTitle("Suggested recipes")
        }
    }
}

struct SavedRecipesCarousel: View {
    @EnvironmentObject private var savedRecipes: SavedRecipesViewModel

    var body: some View {
        NavigationLinkSectionHeader(
            title: "Saved recipes",
            destination: SavedRecipesExpandedScreen()
        )
        .padding(.top)
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(savedRecipes.recipes) { recipe in
                    SmallRecipeCard(recipe: recipe)
                }
            }
        }
        .scrollClipDisabled()
    }
}

struct SavedRecipesExpandedScreen: View {
    @EnvironmentObject private var savedRecipes: SavedRecipesViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(savedRecipes.recipes) { recipe in
                        SmallRecipeCard(recipe: recipe, isExpanded: true)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
            }
            .scrollClipDisabled()
            .safeAreaPadding(.bottom, 60)
        }
        .navigationTitle("Saved recipes")
    }
}
