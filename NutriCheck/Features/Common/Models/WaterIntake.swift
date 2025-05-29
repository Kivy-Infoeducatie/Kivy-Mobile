//
//  WaterIntake.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 26.01.2025.
//

import Foundation
import SwiftData

@Model
class WaterIntake {
    var amount: Double // in milliliters
    var date: Date
    
    init(amount: Double, date: Date = Date()) {
        self.amount = amount
        self.date = date
    }
}

extension WaterIntake {
    /// Helper to check if this water intake is from today
    var isToday: Bool {
        Calendar.current.isDate(date, inSameDayAs: Date())
    }
    
    /// Helper to get the day component for grouping
    var dayComponent: Date {
        Calendar.current.startOfDay(for: date)
    }
} 