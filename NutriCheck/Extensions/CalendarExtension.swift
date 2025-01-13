//
//  CalendarExtension.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 18.12.2024.
//

import Foundation

extension Calendar {
    var startOfToday: Date {
        return Calendar.current.startOfDay(for: .now)
    }
    
    var endOfToday: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: startOfToday)!
    }
}
