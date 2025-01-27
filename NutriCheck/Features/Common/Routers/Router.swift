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
    case getFeaturedRecipes
    case getUserRecipes
    case getRecipe(id: Int)
    case updateRecipe(id: Int, recipe: Recipe)
    case deleteRecipe(id: Int)
    
    case createPost(post: CreatePostDTO)
    case updatePost(id: Int, post: UpdateRecipeDTO)
    case deletePost(id: Int)
    
    case likeRecipe(id: Int)
    case unlikeRecipe(id: Int)
    
    case likePost(id: Int)
    case unlikePost(id: Int)
    
    case getPreferences
    case updatePreferences(preferences: Preferences)
    
    case followUser(id: Int)
    case unfollowUser(id: Int)
    
    case createChat(message: String)
    case sendMessage(chatID: Int, message: String)
    case getAllChats
    case getChat(id: Int)
    case regenerateResponse(id: Int)
    case renameChat(id: Int, name: String)
    case editMessage(id: Int, message: String)
    case deleteChat(id: Int)
    case scanToCreateRecipe(image: String)
    case scanToLogMeal(image: String)
    case modifyRecipe(recipeID: Int, message: String)
    
    var baseURL: String {
        return "http://172.20.10.2:3000"
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
        case .getFeaturedRecipes:
            return "/recipe/featured"
        case .getUserRecipes:
            return "/recipe"
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
        case .createChat:
            return "/intelligence/chat"
        case .sendMessage(let chatID, _):
            return "/intelligence/chat/\(chatID)"
        case .getAllChats:
            return "/intelligence/chat"
        case .getChat(let id):
            return "/intelligence/chat/\(id)"
        case .regenerateResponse(let id):
            return "/intelligence/chat/regenerate/\(id)"
        case .renameChat(let id, _):
            return "/intelligence/chat/rename/\(id)"
        case .editMessage(let id, _):
            return "/intelligence/chat/edit/\(id)"
        case .deleteChat(let id):
            return "/intelligence/chat/\(id)"
        case .scanToCreateRecipe:
            return "/intelligence/scan-to-create"
        case .scanToLogMeal:
            return "/intelligence/scan-to-log"
        case .modifyRecipe(let id, _):
            return "/intelligence/modify-recipe/\(id)"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .signUp, .createRecipe, .createPost, .likeRecipe, .likePost, .followUser,
             .searchRecipes, .createChat, .sendMessage, .scanToCreateRecipe, .scanToLogMeal,
             .modifyRecipe:
            return .post
        case .updateAccount, .updateRecipe, .updatePost, .updatePreferences,
             .regenerateResponse, .editMessage, .renameChat:
            return .patch
        case .deleteRecipe, .deletePost, .unlikeRecipe, .unlikePost, .unfollowUser, .deleteChat:
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
        case .createChat(let message):
            return ["message": message]
        case .sendMessage(_, let message):
            return ["message": message]
        case .editMessage(_, let message):
            return ["message": message]
        case .renameChat(_, let name):
            return ["name": name]
        case .scanToCreateRecipe(let image):
            return ["image": image]
        case .scanToLogMeal(let image):
            return ["image": image]
        case .modifyRecipe(_, let message):
            return ["message": message]
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
