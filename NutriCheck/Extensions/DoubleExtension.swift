//
//  DoubleExtension.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 12.01.2025.
//

import Foundation

extension Double? {
    var unwrappedToNA: String {
        guard let self = self else { return "N/A" }
        return String(self)
    }
}
