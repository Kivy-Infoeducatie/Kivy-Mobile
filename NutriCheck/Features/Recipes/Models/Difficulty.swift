//
//  Difficulty.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 19.12.2024.
//

import Foundation
import SwiftUI

enum Difficulty: String, CaseIterable, Codable {
    case easy
    case medium
    case hard
    
    var title: String {
        switch self {
        case .easy:
            return "Easy"
        case .medium:
            return "Medium"
        case .hard:
            return "Hard"
        }
    }

    var color: Color {
        switch self {
        case .easy:
            return .green
        case .medium:
            return .yellow
        case .hard:
            return .red
        }
    }
}
