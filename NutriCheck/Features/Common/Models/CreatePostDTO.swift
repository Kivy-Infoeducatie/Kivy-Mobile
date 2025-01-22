//
//  CreatePostDTO.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 22.01.2025.
//

import Foundation

struct CreatePostDTO: Codable {
    let rating: Int
    let recipeID: Int
    let content: String
}
