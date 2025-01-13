//
//  Auth.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 10.01.2025.
//

import Foundation

final class Auth: ObservableObject {
    static let shared = Auth()
    private let keychain = KeychainSwift()
    
    @Published private(set) var isAuthenticated: Bool
    
    private init() {
        self.isAuthenticated = keychain.get("token") != nil
    }
    
    var token: String? {
        keychain.get("token")
    }
    
    @MainActor
    func setToken(_ token: String) {
        keychain.set(token, forKey: "token")
        isAuthenticated = true
    }
    
    @MainActor
    func clearToken() {
        keychain.delete("token")
        isAuthenticated = false
    }
}
