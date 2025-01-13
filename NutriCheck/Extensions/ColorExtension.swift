//
//  ColorExtension.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 15.12.2024.
//

import Foundation
import SwiftUI

extension Color {
    func lighter(by percentage: CGFloat = 30.0) -> Color {
        return self.adjust(by: abs(percentage))
    }
    
    func darker(by percentage: CGFloat = 30.0) -> Color {
        return self.adjust(by: -1 * abs(percentage))
    }
    
    func adjust(by percentage: CGFloat = 30.0) -> Color {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 1.0
#if canImport(UIKit)
        UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
#elseif canImport(AppKit)
        NSColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha)
#endif
        return Color(red: min(red + percentage / 100, 1.0),
                     green: min(green + percentage / 100, 1.0),
                     blue: min(blue + percentage / 100, 1.0),
                     opacity: alpha)
    }
}
