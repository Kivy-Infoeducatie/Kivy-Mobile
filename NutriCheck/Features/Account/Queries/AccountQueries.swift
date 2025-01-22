//
//  AccountQueries.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 22.01.2025.
//

import Foundation

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
