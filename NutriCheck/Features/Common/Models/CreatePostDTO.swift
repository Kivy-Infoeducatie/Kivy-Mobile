//
//  CreatePostDTO.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 22.01.2025.
//

import Foundation

struct CreatePostDTO: Codable {
    var rating: Int
    var recipeID: Int
    var content: String
}
