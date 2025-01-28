//
//  AIQueries.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 27.01.2025.
//

import Alamofire
import Foundation

@MainActor
enum AIQueries {
    static func createChat() -> Mutation<String, CreateChatResponse> {
        Mutation(mutationFn: { body in
            try await api.request(
                Router.createChat(
                    message: body
                )
            )
            .validate()
            .serializingDecodable(
                CreateChatResponse.self
            )
            .value
        })
    }

    static func sendMessage() -> Mutation<(chatID: Int, message: String), SendMessageResponse> {
        Mutation(mutationFn: { body in
            try await api.request(
                Router.sendMessage(
                    chatID: body.chatID,
                    message: body.message
                )
            )
            .validate()
            .serializingDecodable(
                SendMessageResponse.self
            )
            .value
        })
    }

    static func getChats() -> Query<[Chat]> {
        Query(
            queryKey: .init(["chats"]),
            queryFn: {
                try await api.request(
                    Router.getAllChats
                )
                .validate()
                .serializingDecodable(
                    [Chat].self
                )
                .value
            }
        )
    }

    static func getChat(id: Int) -> Query<Chat> {
        Query(
            queryKey: .init(["chat", "\(id)"]),
            queryFn: {
                try await api.request(
                    Router.getChat(id: id)
                )
                .validate()
                .serializingDecodable(
                    Chat.self
                )
                .value
            }
        )
    }

    static func getChatMutation() -> Mutation<Int, Chat> {
        Mutation(
            mutationFn: { id in
                try await api.request(
                    Router.getChat(id: id)
                )
                .validate()
                .serializingDecodable(
                    Chat.self
                )
                .value
            }
        )
    }
}
