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

    var body: some View {
        NavigationStack {
            ZStack {
                if showTikTok {
                    GeometryReader { geo in
                        ForEach(
                            Array(recipes.reversed().enumerated()),
                            id: \.offset
                        ) { index, recipe in
                            CachedAsyncImage(
                                url: URL(string: recipe.images[0])
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
                                            CGFloat(recipes.count - index) - scrollOffset)
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
                            VStack(alignment: .leading) {
                                Text("Discover new recipes")
                                    .font(.title3.bold())
                                    .padding(.horizontal)
                                    .matchedGeometryEffect(id: "text", in: namespace)

                                Button {
                                    withAnimation {
                                        showTikTok.toggle()
                                    }
                                } label: {
                                    ZStack {
                                        ForEach(
                                            Array(recipes.prefix(3).enumerated()),
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
                                            .matchedGeometryEffect(id: "card\(index)", in: namespace)
                                        }
                                    }
                                    .frame(width: geo.size.width, alignment: .center)
                                }
                                .padding(.top)
                            }
                            .padding(.top, 60)
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

                                NavigationLinkSectionHeader(
                                    title: "Liked Recipes",
                                    destination: Text("ceva")
                                )
                                .padding(.top)
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(recipes) { recipe in
                                            SmallRecipeCard(recipe: recipe)
                                        }
                                    }
                                }
                                .scrollClipDisabled()

                                NavigationLinkSectionHeader(
                                    title: "Suggestions for you",
                                    destination: Text("ceva")
                                )
                                .padding(.top)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(recipes) { recipe in
                                            SmallRecipeCard(recipe: recipe)
                                        }
                                    }
                                }
                                .scrollClipDisabled()

                                NavigationLinkSectionHeader(
                                    title: "Featured recipes",
                                    destination: Text("ceva")
                                )
                                .padding(.top)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(recipes) { recipe in
                                            SmallRecipeCard(recipe: recipe)
                                        }
                                    }
                                }
                                .scrollClipDisabled()

                                NavigationLinkSectionHeader(
                                    title: "Recipes for the season",
                                    destination: Text("ceva")
                                )
                                .padding(.top)

                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(recipes) { recipe in
                                            SmallRecipeCard(recipe: recipe)
                                        }
                                    }
                                }
                                .scrollClipDisabled()
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
                }

                if showTikTok {
                    RecipesTikTokScreen(
                        backAction: {
                            showTikTok.toggle()
                        },
                        namespace: namespace,
                        offset: $scrollOffset
                    )
                    .padding(.bottom, 40)
                    .frame(maxHeight: .infinity)
                    .transition(.opacity)
                    .zIndex(1)
                }
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
                VStack(spacing: 8) {
                    ForEach(Array(shoppingListItems.prefix(3))) { item in
                        ShoppingListItemRow(item: item)
                    }

                    if shoppingListItems.count > 3 {
                        Text("and \(shoppingListItems.count - 3) more items")
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
    @Namespace private var namespace
    @State private var showRecipe = false

    var body: some View {
        Button(action: {
            showRecipe.toggle()
        }) {
            HStack {
                CachedAsyncImage(url: URL(string: recipe.images[0])) { result in
                    switch result {
                    case .empty:
                        Image(systemName: "photo")
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 80, height: 100)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                    default:
                        Image(systemName: "photo")
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
                        Text("\(recipe.cookingTime)m")
                    }
                    .font(.system(size: 13, weight: .semibold))
                    .opacity(0.7)
                }
                .padding(.vertical)
            }
            .frame(width: 250, height: 80, alignment: .leading)
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
