//
//  AuthDTO.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 11.01.2025.
//

import Foundation

struct LoginDTO {
    let email: String
    let password: String
}

struct SignUpDTO {
    let firstName: String
    let lastName: String
    let username: String
    let email: String
    let password: String
}

struct LoginResponseDTO: Decodable {
    let token: String
}
