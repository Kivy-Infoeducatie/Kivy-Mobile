//
//  RootScreen.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 14.12.2024.
//

import SwiftUI

struct RootScreen: View {
    @State private var selectedTab: TabModel = .home
    @ObservedObject private var keyboardManager = KeyboardManager()
    @StateObject private var auth = Auth.shared

    var body: some View {
        if auth.isAuthenticated {
            TabView(selection: $selectedTab) {
                Tab(value: .home) {
                    NavigationWrapper(title: "Home") {
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
                Tab(value: .goals) {
                    NavigationWrapper(title: "Goals") {
                        GoalsScreen()
                    }
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
