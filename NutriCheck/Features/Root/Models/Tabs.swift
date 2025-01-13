//
//  Tabs.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 19.12.2024.
//

import Foundation

enum TabModel: CaseIterable {
    case home
    case ai
    case recipes
    case health
    
    var title: String {
        switch self {
        case .home:
            return "Home"
        case .ai:
            return "Cook AI"
        case .recipes:
            return "Recipes"
        case .health:
            return "Health"
        }
    }
    
    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .ai:
            return "sparkles"
        case .recipes:
            return "book.fill"
        case .health:
            return "heart.fill"
        }
    }
}
