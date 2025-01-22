//
//  UpdateAccountDTO.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 22.01.2025.
//

import Foundation

struct UpdateAccountDTO: Codable {
    let email: String
    let firstName: String
    let lastName: String
    let username: String
}
