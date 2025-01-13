//
//  DateExtension.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 12.01.2025.
//

import Foundation

extension Date {
    func formattedRelative() -> String {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM"
        
        if calendar.isDateInToday(self) {
            return "Today"
        } else if calendar.isDateInYesterday(self) {
            return "Yesterday"
        } else {
            return formatter.string(from: self)
        }
    }
}
