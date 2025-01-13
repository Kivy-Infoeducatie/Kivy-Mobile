//
//  AuthMutations.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 11.01.2025.
//

import Foundation
import SwiftUI

@MainActor
enum AuthMutations {
    static func login() -> Mutation<LoginDTO, LoginResponseDTO> {
        Mutation(
            mutationFn: { body in
                try await api.request(
                    Router.login(email: body.email, password: body.password)
                )
                .validate()
                .serializingDecodable(
                    LoginResponseDTO.self
                )
                .value
            }
        )
        .onSuccess { res in
            withAnimation {
                Auth.shared.setToken(res.token)
            }
        }
    }

    static func signUp() -> Mutation<SignUpDTO, String> {
        Mutation(
            mutationFn: { body in
                try await api.request(
                    Router.signUp(
                        firstName: body.firstName,
                        lastName: body.lastName,
                        username: body.username,
                        email: body.email,
                        password: body.password
                    )
                )
                .validate()
                .serializingDecodable(
                    String.self,
                    emptyResponseCodes: [200]
                )
                .value
            }
        )
    }
}
