//
//  RecipesTikTokScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 19.12.2024.
//

import CachedAsyncImage
import SwiftUI

struct RecipesTikTokScreen: View {
    let backAction: () -> Void
    let namespace: Namespace.ID
    let recipes: [Recipe]
    @ObservedObject var recommendationsViewModel: RecommendationsViewModel

    @Binding var offset: CGFloat
    @State private var scrollPosition: Int?
    @State private var lastScrollOffset: CGFloat = 0
    @State private var scrollTimer: Timer?

    @Namespace private var cardNamespace

    @StateObject private var recommend = RecipeQueries.getRecipeRecommendationsMutation()

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            backAction()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .stroke(.white.opacity(0.2), lineWidth: 1)
                            )
                    }

                    Spacer()

                    Text("Discover new recipes")
                        .font(.title3.bold())
                        .padding(.horizontal)
                        .matchedGeometryEffect(id: "text", in: namespace)

                    Spacer()

                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .padding(12)
                            .opacity(0)
                    }
                }
                .padding(.horizontal)

                GeometryReader { geo in
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 0) {
                            ForEach(Array(recipes.enumerated()), id: \.offset) { index, recipe in
                                OptimizedCardView(
                                    recipe: recipe, 
                                    index: index,
                                    geo: geo,
                                    currentScrollPosition: scrollPosition ?? 0
                                )
                                .frame(
                                    width: geo.size.width - 72,
                                    height: 500,
                                    alignment: .bottomLeading
                                )
                                .padding(.horizontal, 36)
                                .matchedGeometryEffect(id: "card\(index)", in: namespace)
                                .zIndex(Double(recipes.count - index))
                            }
                        }
                        .padding(.vertical)
                        .scrollTargetLayout()
                    }
                    .scrollPosition(id: $scrollPosition)
                    .scrollTargetBehavior(.paging)
                    .onChange(of: scrollPosition) { _, newPosition in
                        guard let position = newPosition else { return }
                        
                        // Update index immediately for smooth UI
                        recommendationsViewModel.setIndex(position)
                        
                        // Debounced loading of more recipes
                        if recommendationsViewModel.shouldLoadMore {
                            scrollTimer?.invalidate()
                            scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                                recommend.execute((), onSuccess: { newRecipes in
                                    recommendationsViewModel.addRecommendations(newRecipes)
                                })
                            }
                        }
                    }
                    .onAppear {
                        scrollPosition = recommendationsViewModel.currentRecommendationIndex
                    }
                }
                .frame(height: 500)
            }
        }
        .onDisappear {
            scrollTimer?.invalidate()
        }
    }
}

// Optimized CardView with reduced visual effects
struct OptimizedCardView: View {
    @Namespace private var namespace
    @State private var showRecipe: Bool = false

    let recipe: Recipe
    let index: Int
    let geo: GeometryProxy
    let currentScrollPosition: Int

    @EnvironmentObject private var savedRecipesViewModel: SavedRecipesViewModel

    // Cache expensive calculations
    private var isCurrentCard: Bool {
        index == currentScrollPosition
    }
    
    private var cardDistance: Int {
        abs(index - currentScrollPosition)
    }

    @State private var lineLimit: Int = 2

    var body: some View {
        Button(action: {
            showRecipe.toggle()
        }) {
            ZStack(alignment: .bottomLeading) {
                // Optimized image loading - use CachedAsyncImage for better performance
                CachedAsyncImage(url: URL(string: recipe.images.first ?? "")) { result in
                    switch result {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(
                                width: max(0, geo.size.width - 72),
                                height: 500
                            )
                            .clipped()
                    case .empty, .failure:
                        OptimizedFallbackImage(width: max(0, geo.size.width - 72))
                    default:
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(
                                width: max(0, geo.size.width - 72),
                                height: 500
                            )
                    }
                }

                // Simple gradient overlay
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)

                // Card content - only render expensive content for nearby cards
                if cardDistance <= 3 {
                    CardContentView(
                        recipe: recipe, 
                        savedRecipesViewModel: savedRecipesViewModel,
                        lineLimit: $lineLimit
                    )
                } else {
                    // Simplified content for distant cards
                    VStack(alignment: .leading, spacing: 8) {
                        Text(recipe.name)
                            .font(.title2.bold())
                            .lineLimit(2)
                        Text("by \(recipe.authorUsername)")
                            .font(.callout.bold())
                            .opacity(0.9)
                            .lineLimit(1)
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                }
            }
        }
        .clipShape(.rect(cornerRadius: 20))
        .scaleEffect(isCurrentCard ? 1.0 : 0.95)
        .opacity(cardDistance <= 1 ? 1.0 : 0.8)
        .animation(.easeOut(duration: 0.15), value: isCurrentCard)
        .fullScreenCover(isPresented: $showRecipe) {
            RecipeScreen(recipe: recipe)
                .navigationTransition(
                    .zoom(sourceID: recipe.id, in: namespace)
                )
        }
        .matchedTransitionSource(id: recipe.id, in: namespace)
    }
}

// Separate content view to reduce complexity
struct CardContentView: View {
    let recipe: Recipe
    let savedRecipesViewModel: SavedRecipesViewModel
    @Binding var lineLimit: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(recipe.name)
                        .font(.title2.bold())
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    Text("by \(recipe.authorUsername)")
                        .font(.callout.bold())
                        .opacity(0.9)
                        .multilineTextAlignment(.leading)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Button {
                    if savedRecipesViewModel.isSaved(recipe) {
                        withAnimation(.spring(duration: 0.3)) {
                            savedRecipesViewModel.removeRecipe(recipe)
                        }
                    } else {
                        withAnimation(.spring(duration: 0.3)) {
                            savedRecipesViewModel.saveRecipe(recipe)
                        }
                    }
                } label: {
                    Image(systemName: "bookmark.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 24, height: 24)
                        .foregroundColor(
                            savedRecipesViewModel.isSaved(recipe) ? .yellow : .white
                        )
                        .opacity(0.8)
                }
            }
            
            Text(recipe.description)
                .font(.callout)
                .opacity(0.9)
                .lineLimit(lineLimit)
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        lineLimit = lineLimit == 2 ? 10 : 2
                    }
                }
                .multilineTextAlignment(.leading)

            // Simplified stats view
            RecipeStatsView(recipe: recipe)
        }
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}

// Optimized stats view
struct RecipeStatsView: View {
    let recipe: Recipe
    
    var body: some View {
        HStack(spacing: 0) {
            StatItemView(
                title: "Difficulty",
                value: recipe.difficulty.title,
                color: recipe.difficulty.color
            )
            
            Spacer()
            StatDivider()
            Spacer()
            
            StatItemView(
                title: "Time",
                value: "\(recipe.totalTime)m",
                color: .white
            )
            
            Spacer()
            StatDivider()
            Spacer()
            
            StatItemView(
                title: "Calories",
                value: "\(Int(recipe.calories ?? 0)) kcal",
                color: .white
            )
        }
    }
}

struct StatItemView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            Text(value)
                .font(.callout.bold())
                .foregroundStyle(color)
        }
        .frame(maxWidth: .infinity)
    }
}

struct StatDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.white.opacity(0.5))
            .frame(width: 1, height: 30)
    }
}

// Optimized fallback image
struct OptimizedFallbackImage: View {
    let width: CGFloat

    var body: some View {
        Image(systemName: "photo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding(40)
            .frame(width: width, height: 500)
            .background(Color.gray.opacity(0.3))
    }
}

// Original CardView for backward compatibility with RecipesScreen.swift
struct CardView: View {
    @Namespace private var namespace
    @State private var showRecipe: Bool = false

    let recipe: Recipe
    let geo: GeometryProxy

    let height: CGFloat
    let padding: CGFloat
    let showStats: Bool

    @EnvironmentObject private var savedRecipesViewModel: SavedRecipesViewModel

    init(
        recipe: Recipe,
        geo: GeometryProxy,
        height: CGFloat = 500,
        padding: CGFloat = 36,
        showStats: Bool = true
    ) {
        self.recipe = recipe
        self.geo = geo
        self.height = height
        self.padding = padding
        self.showStats = showStats
    }

    @State private var lineLimit: Int = 2

    var body: some View {
        Button(action: {
            showRecipe.toggle()
        }) {
            ZStack(alignment: .bottomLeading) {
                CachedAsyncImage(
                    url: URL(string: recipe.images.first ?? "")
                ) { result in
                    switch result {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(
                                width: (geo.size.width - padding * 2) > 0 ? geo.size.width - padding * 2 : 0,
                                height: height
                            )
                            .clipped()
                    case .empty:
                        FallbackImage(geo: geo, height: height, padding: padding)
                    case .failure:
                        FallbackImage(geo: geo, height: height, padding: padding)
                    default:
                        FallbackImage(geo: geo, height: height, padding: padding)
                    }
                }

                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: showStats ? 220 : 120)
                
                VStack(alignment: .leading) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text(recipe.name)
                                .font(.title2.bold())
                                .multilineTextAlignment(.leading)
                            Text("by \(recipe.authorUsername)")
                                .font(.callout.bold())
                                .opacity(0.9)
                                .padding(.bottom, 4)
                                .multilineTextAlignment(.leading)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        if showStats {
                            Button {
                                if savedRecipesViewModel.isSaved(recipe) {
                                    withAnimation {
                                        savedRecipesViewModel.removeRecipe(recipe)
                                    }
                                } else {
                                    withAnimation {
                                        savedRecipesViewModel.saveRecipe(recipe)
                                    }
                                }
                            } label: {
                                Image(systemName: "bookmark.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(
                                        savedRecipesViewModel.isSaved(recipe) ? .yellow : .white
                                    )
                                    .opacity(0.8)
                            }
                        }
                    }
                    Text(recipe.description)
                        .font(.callout)
                        .opacity(0.9)
                        .lineLimit(lineLimit)
                        .onTapGesture {
                            withAnimation {
                                lineLimit = lineLimit == 2 ? 10 : 2
                            }
                        }
                        .multilineTextAlignment(.leading)
                        .padding(.bottom, 10)

                    if showStats {
                        HStack(spacing: 0) {
                            VStack {
                                Text("Difficulty")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)

                                Text(recipe.difficulty.title)
                                    .font(.callout.bold())
                                    .foregroundStyle(recipe.difficulty.color)
                            }
                            .frame(maxWidth: .infinity)

                            Spacer()

                            Divider()
                                .frame(height: 30)
                                .overlay(Color.white.opacity(0.5))

                            Spacer()

                            VStack {
                                Text("Time")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)

                                Text("\(recipe.totalTime)m")
                                    .font(.callout.bold())
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity)

                            Spacer()

                            Divider()
                                .frame(height: 30)
                                .overlay(Color.white.opacity(0.5))

                            Spacer()

                            VStack {
                                Text("Calories")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)

                                Text("\(Int(recipe.calories ?? 0)) kcal")
                                    .font(.callout.bold())
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
        }
        .disabled(!showStats)
        .clipShape(.rect(cornerRadius: 20))
        .fullScreenCover(isPresented: $showRecipe) {
            RecipeScreen(recipe: recipe)
                .navigationTransition(
                    .zoom(sourceID: recipe.id, in: namespace)
                )
        }
        .matchedTransitionSource(id: recipe.id, in: namespace)
    }
}

struct FallbackImage: View {
    let geo: GeometryProxy
    let height: CGFloat
    let padding: CGFloat

    init(geo: GeometryProxy, height: CGFloat = 500, padding: CGFloat = 36) {
        self.geo = geo
        self.height = height
        self.padding = padding
    }

    var body: some View {
        Image(systemName: "photo")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .padding()
            .frame(
                width: geo.size.width - padding * 2 < 0 ? 0 : geo.size.width - padding * 2,
                height: height
            )
            .background(Color.gray)
    }
}
