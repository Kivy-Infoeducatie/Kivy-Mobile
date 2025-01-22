//
//  Account.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 22.01.2025.
//

import Foundation

struct Account: Codable {
    let id: Int
    let email: String
    let firstName: String
    let lastName: String
    let username: String
    let picture: String?
    let followers: Int
    let follows: Int
}
