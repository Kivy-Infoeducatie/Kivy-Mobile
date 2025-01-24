//
//  AccountQueries.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 22.01.2025.
//

import Foundation
import Alamofire

@MainActor
enum AccountQueries {
    static func getAccount() -> Query<Account> {
        Query(
            queryKey: .init("account"),
            queryFn: {
                try await api.request(
                    Router.getAccount
                )
                .validate()
                .serializingDecodable(
                    Account.self
                )
                .value
            },
            onSuccess: { res in
                print("succes: \(res)")
            },
            onError: { err in
                print("\(err.localizedDescription)")
            }
        )
    }
    
    static func updateAccount() -> Mutation<UpdateAccountDTO, Account> {
        Mutation(
            mutationFn: { body in
                try await api.request(
                    Router.updateAccount(
                        account: body
                    )
                )
                .validate()
                .serializingDecodable(
                    Account.self
                )
                .value
            }
        )
    }
}

@MainActor
enum PreferencesQueries {
    static func getPreferences() -> Query<Preferences> {
        Query(
            queryKey: .init("preferences"),
            queryFn: {
                try await api.request(
                    Router.getPreferences
                )
                .validate()
                .responseData { res in
                    switch res.result {
                    case .success(let preferences):
                        print("Preferences: \(String(data: preferences, encoding: .utf8) ?? "")")
                    case .failure(let error):
                        print("Error: \(error)")
                    }
                }
                .serializingDecodable(
                    Preferences.self
                )
                .value
            }
        )
    }
    
    static func updatePreferences() -> Mutation<Preferences, Empty> {
        Mutation(
            invalidateKeys: [.init("preferences")],
            mutationFn: { body in
                try await api.request(
                    Router.updatePreferences(
                        preferences: body
                    )
                )
                .validate()
                .serializingDecodable(
                    Empty.self,
                    emptyResponseCodes: [200]
                )
                .value
            }
        )
    }
}
