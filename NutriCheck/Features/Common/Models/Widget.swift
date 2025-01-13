//
//  Widget.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 16.12.2024.
//

import Foundation
import SwiftData

@Model
class Widget: Identifiable, Equatable {
    @Attribute(.unique) var id: UUID = UUID()
    var type: WidgetType
    var size: WidgetSize
    var order: Int
    
    init(type: WidgetType, size: WidgetSize, order: Int) {
        self.type = type
        self.size = size
        self.order = order
    }
}
