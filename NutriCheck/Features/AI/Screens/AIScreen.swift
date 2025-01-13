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
    var isAnimated: Bool = false
    
    init(text: String, isUser: Bool, timestamp: Date = Date()) {
        self.text = text
        self.isUser = isUser
        self.timestamp = timestamp
    }
}

struct MessageBubble: View {
    let message: ChatMessage
    @State private var isVisible = false
    
    var body: some View {
        HStack {
            if message.isUser { Spacer() }
            
            Text(message.text)
                .padding()
                .background(message.isUser ? Color.gray.opacity(0.3) : Color.white.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 16))
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
    @State private var isTyping = false
    
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var keyboardManager = KeyboardManager()
    
    func simulateResponse(to message: String) {
        isTyping = true
        
        // Simulate AI thinking time
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            isTyping = false
            withAnimation {
                messages.append(ChatMessage(text: "This is a sample response to: \(message)", isUser: false))
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let localOrigin = origin
            
            ZStack(alignment: .top) {
                // Background stays the same
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
                        return view.layerEffect(
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
                    
                if isChatActive {
                    // Chat Layout
                    VStack(spacing: 0) {
                        ScrollViewReader { _ in
                            ScrollView {
                                LazyVStack(spacing: 12) {
                                    ForEach(messages) { message in
                                        MessageBubble(message: message)
                                            .id(message.id)
                                    }
                                        
                                    if isTyping {
                                        TypingIndicator()
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .id("typing")
                                    }
                                }
                                .padding()
                                .padding(.top, 50)
                            }
                            .scrollDismissesKeyboard(.interactively)
                            .onChange(of: messages) {
                                withAnimation {
                                    //                                        proxy.scrollTo(messages.last?.id ?? "typing", anchor: .bottom)
                                }
                            }
                        }
                            
                        HStack(spacing: 12) {
                            // Back button
                            Button(action: {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                    isChatActive = false
                                    messages = []
                                    isTyping = false
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
                                
                            // Search bar
                            AISearchBar(searchText: $searchText) { text in
                                messages.append(ChatMessage(text: text, isUser: true))
                                simulateResponse(to: text)
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal)
                        .padding(.bottom, keyboardManager.isKeyboardVisible ? 0 : 60)
                    }
                    .transition(.opacity)
                }
                    
                // Initial Layout with suggestions
                if !isChatActive {
                    VStack(spacing: 0) {
                        // Fixed search bar at top
                        AISearchBar(searchText: $searchText) { text in
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                isChatActive = true
                                messages.append(ChatMessage(text: text, isUser: true))
                                simulateResponse(to: text)
                            }
                        }
                        .padding(.vertical, 16)
                        .padding(.horizontal)
                            
                        // Scrollable suggestions
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
                            LazyVStack(alignment: .leading) {
                                Text("Chats")
                                    .font(.title3.bold())
                            }
                            .padding()
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
