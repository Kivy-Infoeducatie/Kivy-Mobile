//
//  RootScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 14.12.2024.
//

import SwiftUI

struct NavigationWrapper<Content: View>: View {
    let title: String
    let content: Content
    
    @State private var showAccount = false

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        NavigationStack {
            content
                .overlay(alignment: .top) {
                    GeometryReader { geo in
                        ZStack(alignment: .topLeading) {
                            VariableBlurView(
                                maxBlurRadius: 10,
                                direction: .blurredTopClearBottom
                            )
                            .frame(height: geo.safeAreaInsets.top + 70)
                            HStack {
                                Text(title)
                                    .font(
                                        .title2
                                            .weight(.bold)
                                            .width(.init(0.16))
                                    )
                                Spacer()
                                Button {} label: {
                                    Image(systemName: "magnifyingglass")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                        .bold()
                                        .padding(8)
                                        .opacity(0.9)
                                        .background {
                                            Circle()
                                                .fill(.thinMaterial)
                                        }
                                }
                                Button {
                                    showAccount.toggle()
                                } label: {
                                    Image(systemName: "person.fill")
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                        .padding(8)
                                        .opacity(0.9)
                                        .background {
                                            Circle()
                                                .fill(.thinMaterial)
                                        }
                                }
                            }
                            .padding(.bottom, 12)
                            .padding(.horizontal)
                            .padding(.top, geo.safeAreaInsets.top + 12)
                        }
                        .ignoresSafeArea()
                    }
                }
        }
        .sheet(isPresented: $showAccount) {
            AccountScreen()
        }
    }
}

struct RootScreen: View {
    @State private var selectedTab: TabModel = .home
    @ObservedObject private var keyboardManager = KeyboardManager()
    @StateObject private var auth = Auth.shared

    var body: some View {
        if auth.isAuthenticated {
            TabView(selection: $selectedTab) {
                Tab(value: .home) {
                    NavigationWrapper(title: "Good morning, Alex") {
                        HomeScreen()
                    }
                    .toolbarVisibility(.hidden, for: .tabBar)
                }
                Tab(value: .ai) {
                    NavigationWrapper(title: "Cook AI") {
                        AIScreen()
                    }
                    .toolbarVisibility(.hidden, for: .tabBar)
                }
                Tab(value: .recipes) {
                    NavigationWrapper(title: "Recipes") {
                        RecipesScreen()
                    }
                    .toolbarVisibility(.hidden, for: .tabBar)
                }
                Tab(value: .health) {
                    Text("Profile")
                        .toolbarVisibility(.hidden, for: .tabBar)
                }
            }
            .overlay(alignment: .bottom) {
                if !keyboardManager.isKeyboardVisible {
                    ZStack {
                        VariableBlurView(
                            maxBlurRadius: 10, direction: .blurredBottomClearTop
                        )
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                    .ignoresSafeArea()
                    .frame(height: 72)
                }
            }
            .overlay(alignment: .bottom) {
                if !keyboardManager.isKeyboardVisible {
                    CustomTabBar(selectedTab: $selectedTab)
                }
            }
        } else {
            LoginScreen()
        }
    }
}

#Preview {
    RootScreen()
}
