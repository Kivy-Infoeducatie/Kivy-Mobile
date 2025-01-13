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
    
    var baseURL: String {
        return "http://localhost:3000"
    }
    
    var path: String {
        switch self {
        case .login:
            return "/auth/login"
        case .signUp:
            return "/auth/register"
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .login, .signUp:
            return .post
        }
    }
    
    var parameters: Encodable? {
        switch self {
        case .login(let email, let password):
            return ["email": email, "password": password]
        case .signUp(let firstName, let lastName, let username, let email, let password):
            return ["firstName": firstName, "lastName": lastName, "username": username, "email": email, "password": password]
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
