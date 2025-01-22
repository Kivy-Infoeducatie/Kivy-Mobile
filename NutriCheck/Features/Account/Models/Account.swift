//
//  Account.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 22.01.2025.
//

import Foundation

struct Account: Codable {
    var id: Int
    var email: String
    var firstName: String
    var lastName: String
    var username: String
    var picture: String?
    var followers: Int
    var follows: Int
    
    var fullName: String {
        return "\(firstName) \(lastName)"
    }
    
    static var empty: Account {
        return Account(id: 0, email: "", firstName: "", lastName: "", username: "", picture: nil, followers: 0, follows: 0)
    }
}
