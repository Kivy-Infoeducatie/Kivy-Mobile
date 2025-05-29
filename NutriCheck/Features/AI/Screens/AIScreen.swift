//
//  AIScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 15.12.2024.
//

import SwiftUI

struct AISearchBar: View {
    @Binding var searchText: String
    @State private var isAnimating = false
    @State private var colorIndex = 0
    @State private var searchScale: CGFloat = 0.8
    @FocusState var isFocused: Bool
    var onSubmit: (String) -> Void
    
    let colorPairs: [(Color, Color)] = [
        (Color(red: 0.48, green: 0.45, blue: 0.80), Color(red: 0.63, green: 0.60, blue: 0.80)),
        (Color(red: 0.63, green: 0.60, blue: 0.80), Color(red: 0.85, green: 0.45, blue: 0.45)),
        (Color(red: 0.85, green: 0.45, blue: 0.45), Color(red: 0.85, green: 0.70, blue: 0.45)),
        (Color(red: 0.85, green: 0.70, blue: 0.45), Color(red: 0.48, green: 0.45, blue: 0.80))
    ]
    
    var currentGradient: LinearGradient {
        LinearGradient(
            colors: isAnimating ?
                [colorPairs[colorIndex].0.opacity(isFocused ? 1 : 1),
                 colorPairs[colorIndex].1.opacity(isFocused ? 1 : 1)] :
                [.white, .white],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Main search bar
            ZStack {
                RoundedRectangle(cornerRadius: 28)
                    .fill(.ultraThinMaterial)
                
                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(currentGradient, lineWidth: 7)
                        .blur(radius: 8)
                    
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(currentGradient, lineWidth: 2)
                        .blur(radius: 2)
                        .opacity(0.5)
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "magnifyingglass")
                        .resizable()
                        .frame(width: 24, height: 24)
                        .foregroundColor(isAnimating ? colorPairs[colorIndex].0.opacity(0.7) : .white.opacity(0.7))
                    
                    TextField("Ask for anything...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .focused($isFocused)
                        .onSubmit {
                            if !searchText.isEmpty {
                                onSubmit(searchText)
                                searchText = ""
                                isFocused = false
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
            .frame(height: 56)
            
            // Send button
            if !searchText.isEmpty {
                Button(action: {
                    onSubmit(searchText)
                    searchText = ""
                    isFocused = false
                }) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                        
                        Circle()
                            .stroke(currentGradient, lineWidth: 7)
                            .blur(radius: 8)
                        
                        Circle()
                            .stroke(currentGradient, lineWidth: 2)
                            .blur(radius: 2)
                            .opacity(0.5)
                        
                        Image(systemName: "arrow.up")
                            .font(.system(size: 20, weight: .semibold))
                    }
                    .frame(width: 56, height: 56)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3), value: searchText.isEmpty)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                searchScale = 1
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    searchScale = 1.0
                }
                
                withAnimation {
                    isAnimating = true
                }
                
                startColorCycling()
            }
        }
    }
    
    private func startColorCycling() {
        Timer.scheduledTimer(withTimeInterval: 1.25, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 1.25)) {
                colorIndex = (colorIndex + 1) % colorPairs.count
            }
        }
    }
}

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let text: String
    let isUser: Bool
    let timestamp: Date
    let recipe: Recipe?
    var isAnimated: Bool = false
    
    init(text: String, isUser: Bool, timestamp: Date = Date(), recipe: Recipe? = nil) {
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
        self.recipe = recipe
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    @State private var isVisible = false
    @State private var showFullRecipe = false
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            VStack(alignment: message.isUser ? .trailing : .leading, spacing: 12) {
                // Text message
                if !message.text.isEmpty {
                    Text(message.text)
                        .font(.body)
                        .padding()
                        .background(message.isUser ? Color.blue.opacity(0.2) : Color.gray.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                
                // Recipe display
                if let recipe = message.recipe {
                    VStack(alignment: .leading, spacing: 16) {
                        // Recipe header
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "fork.knife")
                                    .foregroundColor(.orange)
                                Text("Recipe Generated")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Button {
                                    showFullRecipe.toggle()
                                } label: {
                                    Image(systemName: showFullRecipe ? "chevron.up" : "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                            
                            Text(recipe.name)
                                .font(.title2.bold())
                                .multilineTextAlignment(.leading)
                        }
                        
                        // Recipe stats
                        HStack(spacing: 16) {
                            VStack(alignment: .leading) {
                                Text("Difficulty")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text(recipe.difficulty.title)
                                    .font(.subheadline.bold())
                                    .foregroundColor(recipe.difficulty.color)
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Total Time")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(recipe.totalTime) min")
                                    .font(.subheadline.bold())
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Servings")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(recipe.servings ?? 1)")
                                    .font(.subheadline.bold())
                            }
                            
                            VStack(alignment: .leading) {
                                Text("Calories")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(Int(recipe.calories ?? 0))")
                                    .font(.subheadline.bold())
                            }
                            
                            Spacer()
                        }
                        
                        // Expandable content
                        if showFullRecipe {
                            VStack(alignment: .leading, spacing: 16) {
                                // Description
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Description")
                                        .font(.headline)
                                    Text(recipe.description)
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                }
                                
                                // Ingredients
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Ingredients")
                                        .font(.headline)
                                    
                                    ForEach(recipe.ingredients ?? [], id: \.name) { ingredient in
                                        HStack {
                                            Circle()
                                                .fill(Color.blue.opacity(0.3))
                                                .frame(width: 6, height: 6)
                                            
                                            if let quantity = ingredient.quantity, let unit = ingredient.unit {
                                                Text("\(quantity) \(unit)")
                                                    .font(.body.bold())
                                                    .padding(.horizontal, 8)
                                                    .padding(.vertical, 4)
                                                    .background(Color.blue.opacity(0.1))
                                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                                                    .foregroundColor(.blue)
                                            }
                                            
                                            Text(ingredient.name)
                                                .font(.body)
                                            
                                            Spacer()
                                        }
                                    }
                                }
                                
                                // Steps
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Instructions")
                                        .font(.headline)
                                    
                                    ForEach(Array((recipe.steps ?? []).enumerated()), id: \.offset) { index, step in
                                        HStack(alignment: .top, spacing: 12) {
                                            Text("\(index + 1)")
                                                .font(.caption.bold())
                                                .frame(width: 24, height: 24)
                                                .background(Color.orange.opacity(0.2))
                                                .clipShape(Circle())
                                                .foregroundColor(.orange)
                                            
                                            Text(step)
                                                .font(.body)
                                                .multilineTextAlignment(.leading)
                                            
                                            Spacer()
                                        }
                                    }
                                }
                                
                                // Nutrition info
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Nutrition (per serving)")
                                        .font(.headline)
                                    
                                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                                        if let protein = recipe.protein {
                                            NutritionItem(name: "Protein", value: "\(Int(protein))g")
                                        }
                                        if let carbs = recipe.carbohydrates {
                                            NutritionItem(name: "Carbs", value: "\(Int(carbs))g")
                                        }
                                        if let fat = recipe.totalFat {
                                            NutritionItem(name: "Fat", value: "\(Int(fat))g")
                                        }
                                        if let fiber = recipe.fiber {
                                            NutritionItem(name: "Fiber", value: "\(Int(fiber))g")
                                        }
                                        if let sodium = recipe.sodium {
                                            NutritionItem(name: "Sodium", value: "\(Int(sodium))mg")
                                        }
                                        if let sugar = recipe.sugar {
                                            NutritionItem(name: "Sugar", value: "\(Int(sugar))g")
                                        }
                                    }
                                }
                            }
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .top)),
                                removal: .opacity.combined(with: .move(edge: .top))
                            ))
                        }
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 20)
            .onAppear {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isVisible = true
                }
            }
            
            if !message.isUser { Spacer() }
        }
    }
}

struct NutritionItem: View {
    let name: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(name)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body.bold())
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(8)
        .background(Color.white.opacity(0.3))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct TypingIndicator: View {
    @State private var animationOffset: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0 ..< 3) { index in
                Circle()
                    .fill(Color.gray.opacity(0.5))
                    .frame(width: 8, height: 8)
                    .offset(y: animationOffset)
                    .animation(
                        Animation.easeInOut(duration: 0.6)
                            .repeatForever()
                            .delay(0.2 * Double(index)),
                        value: animationOffset
                    )
            }
        }
        .padding()
        .onAppear {
            animationOffset = -5
        }
    }
}

struct SuggestionCard: View {
    let item: SuggestionItem
    let delay: Double
    @Binding var appeared: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 40, height: 40)
                
                Image(systemName: item.icon)
                    .foregroundStyle(.primary.opacity(0.7))
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 16, weight: .semibold))
                
                Text(item.description)
                    .font(.system(size: 14))
                    .foregroundStyle(.primary.opacity(0.7))
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.primary.opacity(0.7))
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
        )
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : -200)
        .animation(
            .spring(
                response: 0.5,
                dampingFraction: 0.7,
                blendDuration: 0
            )
            .delay(delay),
            value: appeared
        )
    }
}

struct SuggestionItem: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
}

struct AIScreen: View {
    let suggestions = [
        SuggestionItem(
            icon: "camera.viewfinder",
            title: "Scan to create a recipe",
            description: "Use your camera to scan ingredients"
        ),
        SuggestionItem(
            icon: "plus.viewfinder",
            title: "Scan to log a meal",
            description: "Quickly log what you ate"
        ),
        SuggestionItem(
            icon: "note.text.badge.plus",
            title: "Generate a new recipe",
            description: "Create something new"
        ),
        SuggestionItem(
            icon: "pencil.and.outline",
            title: "Modify a recipe",
            description: "Adjust existing recipes"
        )
    ]
    
    @State private var suggestionsAppeared = false
    @State private var counter = 0
    @State private var origin = CGPoint(x: 0, y: 0)
    @State private var isChatActive = false
    @State private var messages: [ChatMessage] = []
    @State private var searchText = ""
    @State private var currentChatID: Int?
    
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var keyboardManager = KeyboardManager()
    
    // Queries and Mutations
    @StateObject private var chatsQuery = AIQueries.getChats()
    @StateObject private var chatMutation = AIQueries.getChatMutation()
    @StateObject private var createChatMutation = AIQueries.createChat()
    @StateObject private var sendMessageMutation = AIQueries.sendMessage()
    
    private func handleNewMessage(_ text: String) {
        if let chatID = currentChatID {
            // Send message in existing chat
            messages.append(ChatMessage(text: text, isUser: true))
            sendMessageMutation.execute((chatID: chatID, message: text)) { response in
                print("send message response: \(response)")
                withAnimation {
                    let responseText = response.message.response
                    let recipe = response.message.recipe?.toRecipe()
                    if let recipe = recipe {
                        print("Converted recipe: \(recipe.name)")
                        print("Recipe ingredients count: \(recipe.ingredients?.count ?? 0)")
                        print("Recipe steps count: \(recipe.steps?.count ?? 0)")
                    }
                    messages.append(ChatMessage(text: responseText, isUser: false, recipe: recipe))
                }
            }
        } else {
            // Create new chat
            messages.append(ChatMessage(text: text, isUser: true))
            createChatMutation.execute(text) { response in
                print("create chat response: \(response)")
                currentChatID = response.chatID
                withAnimation {
                    let responseText = response.message.response
                    let recipe = response.message.recipe?.toRecipe()
                    if let recipe = recipe {
                        print("Converted recipe: \(recipe.name)")
                        print("Recipe ingredients count: \(recipe.ingredients?.count ?? 0)")
                        print("Recipe steps count: \(recipe.steps?.count ?? 0)")
                    }
                    messages.append(ChatMessage(text: responseText, isUser: false, recipe: recipe))
                }
            }
        }
    }
    
    private func getResponseText(from response: Response) -> String? {
        return response.response
    }
    
    private func getMessageText(from message: Message) -> String {
        if case let .string(text) = message.parts.first?.text {
            return text
        }
        if case let .response(response) = message.parts.first?.text {
            return response.response
        }
        return ""
    }
    
    private func getMessageRecipe(from message: Message) -> Recipe? {
        if case let .response(response) = message.parts.first?.text {
            return response.recipe?.toRecipe()
        }
        return nil
    }
    
    var chatView: some View {
        VStack(spacing: 0) {
            ScrollViewReader { _ in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubble(message: message)
                                .id(message.id)
                        }
                        
                        if createChatMutation.state.isLoading || sendMessageMutation.state.isLoading {
                            TypingIndicator()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id("typing")
                        }
                    }
                    .padding()
                    .padding(.top, 50)
                }
                .onChange(of: messages) { _ in
                    withAnimation {
//                        proxy.scrollTo(messages.last?.id ?? "typing", anchor: .bottom)
                    }
                }
            }
            
            HStack(spacing: 12) {
                Button(action: {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                        isChatActive = false
                        messages = []
                        currentChatID = nil
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
                
                AISearchBar(searchText: $searchText) { text in
                    handleNewMessage(text)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal)
            .padding(.bottom, keyboardManager.isKeyboardVisible ? 0 : 60)
        }
        .transition(.opacity)
    }
    
    var suggestionsList: some View {
        VStack(spacing: 0) {
            AISearchBar(searchText: $searchText) { text in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    isChatActive = true
                    handleNewMessage(text)
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(Array(suggestions.enumerated()), id: \.element.id) { index, item in
                        SuggestionCard(
                            item: item,
                            delay: Double(index) * 0.1,
                            appeared: $suggestionsAppeared
                        )
                    }
                }
                .padding(.horizontal)
                
                withQueryProgress(chatsQuery) { chats in
                    LazyVStack(alignment: .leading) {
                        Text("Recent Chats")
                            .font(.title3.bold())
                            .padding(.horizontal)
                        
                        ForEach(chats) { chat in
                            Button {
                                chatMutation.execute(chat.id) { chat in
                                    
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        isChatActive = true
                                        currentChatID = chat.id
                                        messages = (chat.messages ?? []).map { message in
                                            ChatMessage(
                                                text: getMessageText(from: message),
                                                isUser: message.role == .user,
                                                timestamp: message.createdAt,
                                                recipe: getMessageRecipe(from: message)
                                            )
                                        }
                                    }
                                } onError: { error in
                                    print("error: \(error)")
                                }
                            } label: {
                                HStack {
                                    Text(chat.name)
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                    .padding(.bottom, 100)
                }
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .padding(.top, 50)
        .transition(.asymmetric(
            insertion: .opacity,
            removal: .opacity
        ))
    }
    
    var body: some View {
        GeometryReader { geometry in
            let localOrigin = origin
            
            ZStack(alignment: .top) {
                // Background
                VStack(spacing: 0) {
                    if colorScheme == .dark {
                        DarkMeshGradientView()
                            .ignoresSafeArea()
                            .opacity(0.8)
                        Rectangle()
                            .frame(height: 70)
                            .foregroundStyle(.black)
                    } else {
                        LightMeshGradientView()
                            .ignoresSafeArea()
                            .opacity(0.8)
                    }
                }
                .background(.black)
                .keyframeAnimator(
                    initialValue: 0,
                    trigger: counter
                ) { view, elapsedTime in
                    view.visualEffect { view, _ in
                        view.layerEffect(
                            ShaderLibrary.Ripple(
                                .float2(localOrigin),
                                .float(elapsedTime),
                                .float(12),
                                .float(15),
                                .float(8),
                                .float(1600)
                            ),
                            maxSampleOffset: CGSize(width: 12, height: 12),
                            isEnabled: elapsedTime > 0 && elapsedTime < 3
                        )
                    }
                } keyframes: { _ in
                    MoveKeyframe(0)
                    LinearKeyframe(3, duration: 3)
                }
                
                // Content
                if isChatActive {
                    chatView
                } else {
                    suggestionsList
                }
            }
            .task {
                origin = CGPoint(x: geometry.size.width / 2, y: 0)
                counter += 1
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    withAnimation {
                        suggestionsAppeared = true
                    }
                }
            }
            .onDisappear {
                suggestionsAppeared = false
            }
        }
    }
}

#Preview {
    AIScreen()
}
