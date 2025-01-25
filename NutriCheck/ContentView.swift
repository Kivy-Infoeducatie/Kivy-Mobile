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
    @StateObject private var ongoingRecipeViewModel = OngoingRecipeViewModel()
    @StateObject private var savedRecipesViewModel = SavedRecipesViewModel()
    
    var body: some View {
        RootScreen()
            .modelContainer(
                for: [Widget.self, ShoppingListItem.self]
            )
            .installToast(position: .bottom)
            .environmentObject(ongoingRecipeViewModel)
            .environmentObject(savedRecipesViewModel)
    }
}

#Preview {
    ContentView()
}
