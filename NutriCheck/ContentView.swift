//
//  ContentView.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 15.12.2024.
//

import SwiftUI
import SwiftData
import Toasts

struct ContentView: View {
    @StateObject private var ongoingRecipeViewModel = OngoingRecipeViewModel.shared
    @StateObject private var savedRecipesViewModel = SavedRecipesViewModel.shared
    @StateObject private var recentSearchesViewModel = RecentSearchesViewModel.shared
    @StateObject private var healthKitViewModel = HealthKitViewModel.shared
    @StateObject private var goalsViewModel = GoalsViewModel.shared
    @StateObject private var waterIntakeViewModel = WaterIntakeViewModel.shared
    @StateObject private var calorieIntakeViewModel = CalorieIntakeViewModel.shared
    
    var body: some View {
        RootScreen()
            .modelContainer(
                for: [Widget.self, ShoppingListItem.self, WaterIntake.self, CalorieIntake.self]
            )
            .installToast(position: .bottom)
            .environmentObject(ongoingRecipeViewModel)
            .environmentObject(savedRecipesViewModel)
            .environmentObject(recentSearchesViewModel)
            .environmentObject(healthKitViewModel)
            .environmentObject(goalsViewModel)
            .environmentObject(waterIntakeViewModel)
            .environmentObject(calorieIntakeViewModel)
            .onAppear {
                waterIntakeViewModel.loadDailyGoal()
                calorieIntakeViewModel.loadDailyGoal()
            }
    }
}

#Preview {
    ContentView()
}
