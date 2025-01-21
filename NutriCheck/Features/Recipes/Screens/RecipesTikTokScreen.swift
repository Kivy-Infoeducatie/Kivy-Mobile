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
    @State private var scrollPosition: Int?
    @Binding var offset: CGFloat

    @Namespace private var cardNamespace

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        withAnimation {
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
                        HStack(spacing: 0) {
                            ForEach(
                                Array(recipes.enumerated()),
                                id: \.offset
                            ) { index, recipe in
//                                NavigationLink(
//                                    destination: RecipeScreen(recipe: recipe)
//                                        .navigationTransition(
//                                            .zoom(sourceID: recipe.id, in: namespace)
//                                        )
//                                ) {
                                CardView(recipe: recipe, geo: geo)
//                                }
//                                .matchedTransitionSource(id: recipe.id, in: namespace)
                                    .frame(
                                        width: geo.size.width - 72,
                                        height: 500,
                                        alignment: .bottomLeading
                                    )
                                    .padding(.horizontal, 36)
                                    .visualEffect { content, geoProxy in
                                        content
                                            .scaleEffect(
                                                scale(geoProxy),
                                                anchor: .trailing
                                            )
                                            .rotationEffect(rotation(geoProxy, rotation: 3))
                                            .offset(x: minX(geoProxy))
                                            .offset(x: excessMinX(geoProxy, offset: 4))
                                    }
                                    .matchedGeometryEffect(id: "card\(index)", in: namespace)
                                    .zIndex(recipes.zIndex(recipe))
                            }
                        }
                        .padding(.vertical)
                        .scrollTargetLayout()
                    }
                    .scrollPosition(id: $scrollPosition)
                    .scrollTargetBehavior(.paging)
                    .onScrollGeometryChange(for: CGFloat.self) { scrollGeo in
                        scrollGeo.contentOffset.x / geo.size.width
                    } action: { _, newValue in
                        let maxValue = CGFloat(recipes.count - 1)
                        offset = min(max(newValue, 0), maxValue)
                    }
                }
                .frame(height: 500)
            }
        }
    }

    nonisolated func minX(_ proxy: GeometryProxy) -> CGFloat {
        let minX = proxy.frame(in: .scrollView(axis: .horizontal)).minX
        return minX < 0 ? 0 : -minX
    }

    nonisolated func progress(_ proxy: GeometryProxy, limit: CGFloat = 2) -> CGFloat {
        let maxX = proxy.frame(in: .scrollView(axis: .horizontal)).maxX
        let width = proxy.bounds(of: .scrollView(axis: .horizontal))?.width ?? 0

        let progress = (maxX / width) - 1
        let cappedProgress = min(progress, limit)

        return cappedProgress
    }

    nonisolated func scale(_ proxy: GeometryProxy, scale: CGFloat = 0.1) -> CGFloat {
        let progress = progress(proxy)
        return 1 - (progress * scale)
    }

    nonisolated func excessMinX(_ proxy: GeometryProxy, offset: CGFloat = 10) -> CGFloat {
        let progress = progress(proxy)
        return progress * offset
    }

    nonisolated func rotation(_ proxy: GeometryProxy, rotation: CGFloat = 5) -> Angle {
        let progress = progress(proxy)
        return .degrees(Double(progress * rotation))
    }
}

#Preview {
    RecipesTikTokScreen(backAction: {}, namespace: Namespace().wrappedValue, offset: .constant(0))
}

private extension [Recipe] {
    func zIndex(_ item: Recipe) -> CGFloat {
        if let index = firstIndex(where: { $0.id == item.id }) {
            return CGFloat(count) - CGFloat(index)
        }

        return 0
    }
}

struct CardView: View {
    @Namespace private var namespace
    @State private var showRecipe: Bool = false

    let recipe: Recipe
    let geo: GeometryProxy

    let height: CGFloat
    let padding: CGFloat
    let showStats: Bool

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
                CachedAsyncImage(url: URL(string: recipe.images[0])) { result in
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

                VariableBlurView(direction: .blurredBottomClearTop)
                    .frame(height: showStats ? 180 : 80)
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: showStats ? 180 : 80)
                VStack(alignment: .leading) {
                    Text(recipe.name)
                        .font(.title2.bold())
                        .multilineTextAlignment(.leading)
                    Text("by \(recipe.authorUsername)")
                        .font(.callout.bold())
                        .opacity(0.9)
                        .padding(.bottom, 4)
                        .multilineTextAlignment(.leading)
                    Text(recipe.recipeDescription)
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

                                Text(recipe.difficulty.rawValue)
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
                                Text("Cooking time")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)

                                Text("\(recipe.cookingTime)m")
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

                                Text("\(recipe.calories ?? 0, format: .number) kcal")
                                    .font(.callout.bold())
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        //                    .padding(.horizontal, 10)
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
