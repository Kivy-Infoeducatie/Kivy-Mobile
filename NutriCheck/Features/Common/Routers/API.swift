//
//  API.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 10.01.2025.
//

import Alamofire
import Foundation

final class Interceptor: RequestInterceptor {
    func adapt(
        _ urlRequest: URLRequest,
        for session: Session,
        completion: @escaping (Result<URLRequest, any Error>) -> Void
    ) {
        var request = urlRequest
        if let token = Auth.shared.token {
            request.headers = .init([.authorization(bearerToken: token)])
        }
        completion(.success(request))
    }

    func retry(
        _ request: Request,
        for session: Session,
        dueTo error: any Error,
        completion: @escaping (RetryResult) -> Void
    ) {
        let statusCode = request.response?.statusCode
        if statusCode == 401 {
            DispatchQueue.main.async {
                Auth.shared.clearToken()
            }
            completion(.doNotRetry)
        } else {
            completion(.doNotRetry)
        }
    }
}

let api = Session(interceptor: Interceptor())
