//
//  WaterIntakeViewModel.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 26.01.2025.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class WaterIntakeViewModel: ObservableObject {
    static let shared = WaterIntakeViewModel()
    
    @Published var dailyGoal: Double = 1800.0 // Default goal in ml
    
    private init() {}
    
    /// Calculate total intake for today from water intakes array
    func getTodayIntake(from waterIntakes: [WaterIntake]) -> Double {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        return waterIntakes
            .filter { $0.date >= today && $0.date < tomorrow }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// Calculate total intake for a specific date from water intakes array
    func getIntakeForDate(_ date: Date, from waterIntakes: [WaterIntake]) -> Double {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return waterIntakes
            .filter { $0.date >= startOfDay && $0.date < endOfDay }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// Get daily water intake history grouped by day
    func getDailyIntakeHistory(from waterIntakes: [WaterIntake]) -> [(date: Date, amount: Double)] {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let startOfThirtyDaysAgo = Calendar.current.startOfDay(for: thirtyDaysAgo)
        
        let recentIntakes = waterIntakes.filter { $0.date >= startOfThirtyDaysAgo }
        
        // Group by day
        let grouped = Dictionary(grouping: recentIntakes) { intake in
            Calendar.current.startOfDay(for: intake.date)
        }
        
        // Convert to array with daily totals
        return grouped.map { (date, intakes) in
            let total = intakes.reduce(0) { $0 + $1.amount }
            return (date: date, amount: total)
        }.sorted { $0.date < $1.date }
    }
    
    /// Update daily goal
    func updateDailyGoal(_ newGoal: Double) {
        dailyGoal = newGoal
        // In a real app, you might want to persist this to UserDefaults or API
        UserDefaults.standard.set(newGoal, forKey: "waterDailyGoal")
    }
    
    /// Load saved daily goal
    func loadDailyGoal() {
        let savedGoal = UserDefaults.standard.double(forKey: "waterDailyGoal")
        if savedGoal > 0 {
            dailyGoal = savedGoal
        }
    }
    
    /// Get progress percentage for today
    func getTodayProgress(from waterIntakes: [WaterIntake]) -> Double {
        let todayIntake = getTodayIntake(from: waterIntakes)
        return todayIntake / dailyGoal
    }
} 