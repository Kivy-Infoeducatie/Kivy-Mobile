//
//  CalorieIntake.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 26.01.2025.
//

import Foundation
import SwiftData

@Model
class CalorieIntake {
    var amount: Double // in calories
    var date: Date
    var source: String // "manual" or recipe name
    var sourceType: IntakeSourceType
    var recipeId: Int? // if logged from a recipe
    var notes: String? // additional details
    
    init(
        amount: Double,
        date: Date = Date(),
        source: String = "Manual entry",
        sourceType: IntakeSourceType = .manual,
        recipeId: Int? = nil,
        notes: String? = nil
    ) {
        self.amount = amount
        self.date = date
        self.source = source
        self.sourceType = sourceType
        self.recipeId = recipeId
        self.notes = notes
    }
}

enum IntakeSourceType: String, Codable, CaseIterable {
    case manual = "manual"
    case recipe = "recipe"
    
    var displayName: String {
        switch self {
        case .manual:
            return "Manual Entry"
        case .recipe:
            return "Recipe"
        }
    }
    
    var icon: String {
        switch self {
        case .manual:
            return "pencil.circle.fill"
        case .recipe:
            return "fork.knife.circle.fill"
        }
    }
}

extension CalorieIntake {
    /// Helper to check if this calorie intake is from today
    var isToday: Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    /// Helper to get the day component for grouping
    var dayComponent: Date {
        Calendar.current.startOfDay(for: date)
    }
} 