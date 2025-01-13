//
//  Difficulty.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 19.12.2024.
//

import Foundation
import SwiftUI

enum Difficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"

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
