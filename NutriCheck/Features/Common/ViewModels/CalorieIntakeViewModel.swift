//
//  CalorieIntakeViewModel.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 26.01.2025.
//

import Foundation
import SwiftData
import SwiftUI

@MainActor
class CalorieIntakeViewModel: ObservableObject {
    static let shared = CalorieIntakeViewModel()
    
    @Published var dailyGoal: Double = 2000.0 // Default goal in calories
    
    private init() {}
    
    /// Calculate total intake for today from calorie intakes array
    func getTodayIntake(from calorieIntakes: [CalorieIntake]) -> Double {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        return calorieIntakes
            .filter { $0.date >= today && $0.date < tomorrow }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// Calculate net calories (intake - active energy burnt)
    func getNetCalories(intake: Double, activeEnergyBurnt: Double) -> Double {
        return intake - activeEnergyBurnt
    }
    
    /// Calculate remaining calories for the day (goal - net calories)
    func getRemainingCalories(intake: Double, activeEnergyBurnt: Double) -> Double {
        let netCalories = getNetCalories(intake: intake, activeEnergyBurnt: activeEnergyBurnt)
        return dailyGoal - netCalories
    }
    
    /// Calculate total intake for a specific date from calorie intakes array
    func getIntakeForDate(_ date: Date, from calorieIntakes: [CalorieIntake]) -> Double {
        let startOfDay = Calendar.current.startOfDay(for: date)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        return calorieIntakes
            .filter { $0.date >= startOfDay && $0.date < endOfDay }
            .reduce(0) { $0 + $1.amount }
    }
    
    /// Get daily calorie intake history grouped by day
    func getDailyIntakeHistory(from calorieIntakes: [CalorieIntake]) -> [(date: Date, amount: Double)] {
        let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let startOfThirtyDaysAgo = Calendar.current.startOfDay(for: thirtyDaysAgo)
        
        let recentIntakes = calorieIntakes.filter { $0.date >= startOfThirtyDaysAgo }
        
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
    
    /// Get progress percentage for today (net calories / goal)
    func getTodayProgress(intake: Double, activeEnergyBurnt: Double) -> Double {
        let netCalories = getNetCalories(intake: intake, activeEnergyBurnt: activeEnergyBurnt)
        return max(0, netCalories / dailyGoal) // Ensure non-negative
    }
    
    /// Update daily goal
    func updateDailyGoal(_ newGoal: Double) {
        dailyGoal = newGoal
        UserDefaults.standard.set(newGoal, forKey: "calorieDailyGoal")
    }
    
    /// Load saved daily goal
    func loadDailyGoal() {
        let savedGoal = UserDefaults.standard.double(forKey: "calorieDailyGoal")
        if savedGoal > 0 {
            dailyGoal = savedGoal
        }
    }
    
    /// Get intake entries by source type for today
    func getTodayIntakesBySource(from calorieIntakes: [CalorieIntake]) -> [IntakeSourceType: [CalorieIntake]] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        
        let todayIntakes = calorieIntakes.filter { $0.date >= today && $0.date < tomorrow }
        return Dictionary(grouping: todayIntakes) { $0.sourceType }
    }
} 