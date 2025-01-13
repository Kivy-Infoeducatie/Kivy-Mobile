//
//  WidgetType.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 16.12.2024.
//

import Foundation
import SwiftUI

protocol WidgetTypeProtocol {
    var id: String { get }
    var name: String { get }
    var description: String { get }
    var supportedSizes: [WidgetSize] { get }
}

enum WidgetType: String, WidgetTypeProtocol, CaseIterable, Identifiable, Codable {
    case goals
    case featuredRecipe
    case suggestedRecipes
    case askAI
    case shoppingList
    case reminder
    case ongoingRecipe

    var id: String {
        switch self {
        case .goals: return "goals"
        case .featuredRecipe: return "featuredRecipe"
        case .suggestedRecipes: return "suggestedRecipes"
        case .askAI: return "askAI"
        case .shoppingList: return "shoppingList"
        case .reminder: return "reminder"
        case .ongoingRecipe: return "ongoingRecipe"
        }
    }
    
    var name: String {
        switch self {
        case .goals: return "Goals"
        case .featuredRecipe: return "Featured Recipe"
        case .suggestedRecipes: return "Suggested Recipes"
        case .askAI: return "Ask AI"
        case .shoppingList: return "Shopping List"
        case .reminder: return "Reminder"
        case .ongoingRecipe: return "Ongoing Recipe"
        }
    }
    
    var icon: String {
        switch self {
        case .goals: return "chart.pie.fill"
        case .featuredRecipe: return "star.circle.fill"
        case .suggestedRecipes: return "fork.knife"
        case .askAI: return "sparkles"
        case .shoppingList: return "cart.fill"
        case .reminder: return "exclamationmark.circle.fill"
        case .ongoingRecipe: return "timer"
        }
    }
    
    var title: String {
        switch self {
        case .goals: return "Your goals for today"
        case .reminder: return "Low consumned calories"
        case .askAI: return "Ask Cook AI"
        case .featuredRecipe, .suggestedRecipes, .shoppingList, .ongoingRecipe: return name
        }
    }
    
    var color: Color {
        switch self {
        case .goals: return .orange
        case .featuredRecipe: return .yellow
        case .suggestedRecipes: return .blue
        case .shoppingList: return .pink
        case .reminder: return .red
        case .askAI: return .purple
        case .ongoingRecipe: return .accent
        }
    }
    
    var description: String {
        switch self {
        case .goals: return "The goals widget shows your current activity goals at a glance, throughout the day."
        case .featuredRecipe: return "The featured recipe widget shows you a new recipe every day, handpicked by our team for guaranteed deliciousness."
        case .suggestedRecipes: return "The suggested recipe widget shows you a new recipe every day, based on your preferences and dietary restrictions."
        case .askAI: return "This widget will show you different recommendations for things you can ask Cook AI to do throughout the day."
        case .shoppingList: return "The shopping list widget shows you all the items you added to your list, at a glance."
        case .reminder: return ""
        case .ongoingRecipe: return ""
        }
    }
    
    var supportedSizes: [WidgetSize] {
        switch self {
        case .goals, .featuredRecipe, .suggestedRecipes, .askAI, .shoppingList:
            return [
                .small,
                .medium,
                .large
            ]
        case .ongoingRecipe: return [.large]
        case .reminder: return [.medium]
        }
    }
}
