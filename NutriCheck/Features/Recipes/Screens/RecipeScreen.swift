//
//  RecipeScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 11.01.2025.
//

import CachedAsyncImage
import SwiftUI

struct RecipeScreen: View {
    @State private var recipe: Recipe
    
    @State private var lineLimit: Int = 2
    @State private var servings: Int = 2
    @State private var aiPrompt: String = ""
    
    @State private var showOngoingRecipe: Bool = false
    @State private var showAddIngredients: Bool = false
    
    @EnvironmentObject private var ongoingRecipe: OngoingRecipeViewModel
    @EnvironmentObject private var savedRecipes: SavedRecipesViewModel
    @Environment(\.dismiss) var dismiss
    
    @StateObject private var detailedRecipe: Query<Recipe>
    
    private var recipeStarted: Bool {
        ongoingRecipe.recipe != nil && ongoingRecipe.recipe?.id == recipe.id
    }
    
    init(recipe: Recipe) {
        self._recipe = State(initialValue: recipe)
        self._detailedRecipe = StateObject(wrappedValue: RecipeQueries.getRecipe(recipe.id))
    }
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ScrollView {
                    switch detailedRecipe.state {
                    case .idle:
                        Text("Idle")
                    case .loading:
                        Text("Loading")
                    case .success(let t):
                        Text("Success")
                    case .error(let error):
                        Text("Error \(error.localizedDescription)")
                    }
                    VStack(spacing: 12) {
                        ZStack(alignment: .bottomLeading) {
                            CachedAsyncImage(url: URL(string: recipe.images.first ?? "")) { result in
                                switch result {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(
                                            width: max(geo.size.width - 40, 0),
                                            height: 400
                                            //                                        height: height
                                        )
                                        .clipped()
                                case .empty:
                                    ProgressView()
                                //                    FallbackImage(geo: geo, height: height, padding: padding)
                                case .failure:
                                    ProgressView()
                                default:
                                    ProgressView()
                                }
                            }
                            
                            VariableBlurView(direction: .blurredBottomClearTop)
                                .frame(height: 150)
                            LinearGradient(
                                colors: [.clear, .black.opacity(0.7)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 130)
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(recipe.name)
                                        .font(.title2.bold())
                                    Text("by \(recipe.authorUsername)")
                                        .font(.callout.bold())
                                        .opacity(0.9)
                                        .padding(.bottom, 4)
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
                                }
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Button {
                                    if savedRecipes.isSaved(recipe) {
                                        withAnimation {
                                            savedRecipes.removeRecipe(recipe)
                                        }
                                    } else {
                                        withAnimation {
                                            savedRecipes.saveRecipe(recipe)
                                        }
                                    }
                                } label: {
                                    Image(systemName: "bookmark.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 24, height: 24)
                                        .foregroundColor(
                                            savedRecipes.isSaved(recipe) ? .yellow : .white
                                        )
                                        .opacity(0.8)
                                }
                            }
                            .padding(16)
                        }
                        .clipShape(.rect(cornerRadius: 20))
                        .frame(height: 400)
                        .padding(.top, 24)
                        .clipped()
                        .background {
                            CachedAsyncImage(url: URL(string: recipe.images.first ?? "")) { result in
                                switch result {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(
                                            width: geo.size.width,
                                            height: 500
                                        )
                                        .clipped()
                                case .empty:
                                    ProgressView()
                                case .failure:
                                    ProgressView()
                                default:
                                    ProgressView()
                                }
                            }
                            .blur(radius: 50)
                            .offset(y: -15)
                            .opacity(0.5)
                        }
                        
                        HStack(spacing: 12) {
                            StatCard(
                                name: "Difficulty",
                                value: recipe.difficulty.title,
                                valueColor: recipe.difficulty.color
                            )
                            
                            StatCard(name: "Time", value: "\(recipe.totalTime) min")
                        }
                        
                        HStack(spacing: 12) {
                            StatCard(
                                name: "Calories",
                                value: "\((recipe.calories ?? 0).unwrappedToNA) kcal"
                            )
                            
                            StatCard(
                                name: "Ingredients",
                                value: "\(recipe.ingredientsCount ?? 0)"
                            )
                        }
                        
                        HStack {
                            if let servings = recipe.servings {
                                HStack(spacing: 0) {
//                                    Button {
//                                        servings -= 1
//                                    } label: {
//                                        Image(systemName: "minus")
//                                    }
//                                    .disabled(servings == 1)
//                                    .frame(maxWidth: .infinity, alignment: .center)
//
//                                    Divider()
                                    
                                    HStack(spacing: 4) {
                                        Image(systemName: "person.2.fill")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 16, height: 16)
                                        Text("\(servings)")
                                            .font(.callout.bold())
                                    }
                                    .frame(maxWidth: .infinity)
                                    
//                                    Divider()
//                                    
//                                    Button {
//                                        servings += 1
//                                    } label: {
//                                        Image(systemName: "plus")
//                                    }
//                                    .disabled(servings == 10)
//                                    .frame(maxWidth: .infinity, alignment: .center)
                                    //                                .background(Color.red)
                                }
                                //                            .frame(maxWidth: .infinity)
                                .frame(width: 50)
//                                .frame(width: 130)
                                .padding(.vertical)
                                .background(.thinMaterial)
                                .clipShape(Capsule())
                            }
                            
                            Button {
                                if !recipeStarted {
                                    print("started")
                                    ongoingRecipe.startRecipe(recipe)
                                }
                                
                                showOngoingRecipe = true
                            } label: {
                                HStack {
                                    Image(
                                        systemName: recipeStarted ? "timer" : "play.fill"
                                    )
                                    Text(recipeStarted ? "Recipe started" : "Start cooking")
                                        .font(.callout.bold())
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.green.opacity(0.2))
                                .foregroundStyle(.green)
                                .clipShape(Capsule())
                            }
                        }
                        .padding(.top, 12)
                        
                        VStack(alignment: .leading) {
                            Text("Cook AI")
                                .font(.title3.bold())
                                .padding(.top, 12)
                            AISearchBar(searchText: $aiPrompt, onSubmit: { _ in })
                                .padding(.top, 12)
                                .padding(.bottom, 6)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    AIChip(text: "Make it healthier", action: {})
                                    AIChip(text: "Make it match my goals", action: {})
                                    AIChip(text: "Make it vegan", action: {})
                                }
                            }
                            .scrollClipDisabled()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        VStack(alignment: .leading) {
                            NavigationLinkSectionHeader(
                                title: "Comments",
                                destination: CommentsScreen(comments: recipe.comments ?? [])
                            )
                            .padding(.bottom, 4)
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(recipe.comments ?? []) { comment in
                                        CommentCard(comment: comment)
                                            .frame(
                                                width: 250,
                                                height: 110,
                                                alignment: .topLeading
                                            )
                                    }
                                }
                            }
                            .scrollClipDisabled()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 12)

                        VStack(alignment: .leading) {
                            HStack(alignment: .center) {
                                Text("Ingredients")
                                    .font(.title3.bold())
                                    .padding(.bottom, 4)
                                Spacer()
                                Button {
                                    showAddIngredients = true
                                } label: {
                                    HStack {
                                        Image(systemName: "cart.fill")
                                            .font(.callout.bold())
                                        Text("Add")
                                            .font(.callout.bold())
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, 8)
                                    .background(.thinMaterial)
                                    .clipShape(Capsule())
                                }
                            }
                            
                            VStack(spacing: 14) {
                                ForEach(
                                    Array((recipe.ingredients ?? []).enumerated()),
                                    id: \.offset
                                ) { _, ingredient in
                                    HStack(spacing: 2) {
                                        if let quantity = ingredient.quantity {
                                            Text("\(quantity) \(ingredient.unit ?? "")")
                                                .font(.body.bold())
                                                .padding(4)
                                                .padding(.horizontal, 5)
                                                .background(Color.blue.opacity(0.2))
                                                .clipShape(.rect(cornerRadius: 10))
                                                .foregroundStyle(.blue)
                                        }
                                        Text(" \(ingredient.name)")
                                            .font(.body)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                            .padding()
                            .background(.thinMaterial)
                            .clipShape(.rect(cornerRadius: 20))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 12)

                        VStack(alignment: .leading) {
                            Text("Steps")
                                .font(.title3.bold())
                                .padding(.bottom, 4)
                            
                            ForEach(
                                Array((recipe.steps ?? []).enumerated()),
                                id: \.offset
                            ) { index, step in
                                HStack(alignment: .center, spacing: 8) {
                                    Text("\(index + 1)")
                                        .font(.body)
                                        .padding(8)
                                        .background(Color.accentColor.opacity(0.8))
                                        .foregroundStyle(.background)
                                        .clipShape(.circle)
                                    Text(step)
                                        .font(.body)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding()
                                .background(.thinMaterial)
                                .clipShape(.rect(cornerRadius: 20))
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 100)
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .navigationBarBackButtonHidden()
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            dismiss()
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .padding(12)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                    }
                }
            }
            .fullScreenCover(isPresented: $showOngoingRecipe) {
                OngoingRecipeScreen()
            }
            .sheet(isPresented: $showAddIngredients) {
                AddIngredientsSheet(ingredients: recipe.ingredients ?? [])
            }
            .onAppear {
                Task {
                    _ = detailedRecipe.onSuccess { recipe in
                        self.recipe = recipe
                        print("success")
                    }
                    await detailedRecipe.execute()
                }
            }
        }
    }
}

#Preview {
    RecipeScreen(recipe: recipeMocks[0])
        .environmentObject(OngoingRecipeViewModel())
}

struct StatCard: View {
    let name: String
    let value: String
    let valueColor: Color
    
    init(name: String, value: String, valueColor: Color = .primary) {
        self.name = name
        self.value = value
        self.valueColor = valueColor
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(valueColor)
            
            Text(name)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(.rect(cornerRadius: 20))
    }
}

struct AIChip: View {
    let text: String
    let action: () -> Void
    let icon: String
    
    init(text: String, action: @escaping () -> Void, icon: String = "wand.and.stars") {
        self.text = text
        self.action = action
        self.icon = icon
    }
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.callout.bold())
                Text(text)
            }
            .padding(.horizontal)
            .padding(.vertical, 6)
            .background(.thinMaterial)
            .clipShape(Capsule())
        }
    }
}

struct AddIngredientsSheet: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    let ingredients: [Ingredient]
    @State private var selectedIngredients: Set<Ingredient> = []
    
    var body: some View {
        NavigationView {
            List(
                ingredients,
                id: \.self,
                selection: $selectedIngredients
            ) { ingredient in
                IngredientRow(ingredient: ingredient)
            }
            .navigationTitle("Add Ingredients")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add Selected") {
                        addSelectedIngredients()
                        dismiss()
                    }
                    .disabled(selectedIngredients.isEmpty)
                }
                
                ToolbarItem(placement: .principal) {
                    Text("\(selectedIngredients.count) selected")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .environment(\.editMode, .constant(.active))
        }
    }
    
    private func addSelectedIngredients() {
        for ingredient in selectedIngredients {
            let shoppingItem = ShoppingListItem(
                name: ingredient.name,
                quantity: ingredient.quantity ?? "",
                unit: ingredient.unit ?? ""
            )
            modelContext.insert(shoppingItem)
        }
    }
}

struct IngredientRow: View {
    let ingredient: Ingredient
    
    private var quantityText: String {
        ingredient.quantity ?? ""
    }
    
    var body: some View {
        HStack {
            Text(ingredient.name)
            Spacer()
            Text("\(quantityText) \(ingredient.unit ?? "")")
                .foregroundColor(.secondary)
        }
    }
}

struct CommentCard: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(comment.authorUsername)
                    .font(.callout.bold())
                Spacer()
                Text("\(comment.createdAt.formattedRelative())")
                    .font(.caption)
            }
            Text(comment.content)
                .font(.body)
        }
        .padding()
        .background(.thinMaterial)
        .clipShape(.rect(cornerRadius: 20))
    }
}

struct CommentsScreen: View {
    let comments: [Comment]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                ForEach(comments) { comment in
                    CommentCard(comment: comment)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal)
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
