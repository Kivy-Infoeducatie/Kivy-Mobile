//
//  Router.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 10.01.2025.
//

import Alamofire
import Foundation

enum Router: URLRequestConvertible {
    case login(email: String, password: String)
    case signUp(firstName: String, lastName: String, username: String, email: String, password: String)
    
    case getAccount
    case updateAccount(account: UpdateAccountDTO)
    
    case searchRecipes(query: SearchRecipeDTO)
    case createRecipe(recipe: Recipe)
    case getRecipeRecommendations
    case getLikedRecipes
    case getRecipe(id: String)
    case updateRecipe(id: String, recipe: Recipe)
    case deleteRecipe(id: String)
    
    case createPost(post: CreatePostDTO)
    case updatePost(id: String, post: UpdateRecipeDTO)
    case deletePost(id: String)
    
    case likeRecipe(id: String)
    case unlikeRecipe(id: String)
    
    case likePost(id: String)
    case unlikePost(id: String)
    
    case getPreferences
    case updatePreferences(preferences: Preferences)
    
    case followUser(id: String)
    case unfollowUser(id: String)
    
    
    var baseURL: String {
        return "http://localhost:3000"
    }
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .signUp:
            return "/auth/register"
        case .getAccount:
            return "/account"
        case .updateAccount:
            return "/account"
        case .searchRecipes:
            return "/recipe/search"
        case .createRecipe:
            return "/recipe"
        case .getRecipeRecommendations:
            return "/recipe/recommend"
        case .getLikedRecipes:
            return "/recipe/liked"
        case .getRecipe(let id):
            return "/recipe/\(id)"
        case .updateRecipe(let id, _):
            return "/recipe/\(id)"
        case .deleteRecipe(let id):
            return "/recipe/\(id)"
        case .createPost:
            return "/post"
        case .updatePost(let id, _):
            return "/post/\(id)"
        case .deletePost(let id):
            return "/post/\(id)"
        case .likeRecipe(let id):
            return "/recipe/\(id)/like"
        case .unlikeRecipe(let id):
            return "/recipe/\(id)/like"
        case .likePost(let id):
            return "/post/\(id)/like"
        case .unlikePost(let id):
            return "/post/\(id)/like"
        case .getPreferences:
            return "/preferences"
        case .updatePreferences:
            return "/preferences"
        case .followUser(let id):
            return "/user/\(id)/follow"
        case .unfollowUser(let id):
            return "/user/\(id)/follow"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .signUp, .createRecipe, .createPost, .likeRecipe, .likePost, .followUser:
            return .post
        case .updateAccount, .updateRecipe, .updatePost, .updatePreferences:
            return .patch
        case .deleteRecipe, .deletePost, .unlikeRecipe, .unlikePost, .unfollowUser:
            return .delete
        default:
            return .get
        }
    }
    
    var parameters: Encodable? {
        switch self {
        case .login(let email, let password):
            return ["email": email, "password": password]
        case .signUp(let firstName, let lastName, let username, let email, let password):
            return ["firstName": firstName, "lastName": lastName, "username": username, "email": email, "password": password]
        case .updateAccount(let account):
            return account
        case .searchRecipes(let query):
            return query
        case .createRecipe(let recipe):
            return recipe
        case .createPost(let post):
            return post
        case .updateRecipe(_, let recipe):
            return recipe
        case .updatePost(_, let post):
            return post
        case .updatePreferences(let preferences):
            return preferences
        default:
            return nil
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try baseURL.asURL()
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.method = method
        
        if let parameters {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let parameterEncoder = JSONParameterEncoder(encoder: encoder)
            
            return try parameterEncoder.encode(
                parameters,
                into: request
            )
        }
        
        return request
    }
}
