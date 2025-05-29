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
            .responseData { response in
                if let data = response.data, let str = String(data: data, encoding: .utf8) {
                    print("CreateChat Raw Response: \(str)")
                }
            }
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
            .responseData { response in
                if let data = response.data, let str = String(data: data, encoding: .utf8) {
                    print("SendMessage Raw Response: \(str)")
                }
            }
            .validate()
            .serializingDecodable(
                SendMessageResponse.self
            )
            .value
        })
    }

    static func modifyRecipe() -> Mutation<(recipeID: Int, message: String), Recipe> {
        Mutation(mutationFn: { body in
            let response = try await api.request(
                Router.modifyRecipe(
                    recipeID: body.recipeID,
                    message: body.message
                )
            )
            .responseData { response in
                if let data = response.data, let str = String(data: data, encoding: .utf8) {
                    print("ModifyRecipe Raw Response: \(str)")
                }
            }
            .validate()
            
            // First try to decode as Recipe directly
            do {
                let recipe = try await response.serializingDecodable(Recipe.self).value
                print("✅ Successfully decoded directly as Recipe")
                return recipe
            } catch {
                print("❌ Failed to decode as Recipe directly: \(error)")
                
                // If that fails, try to decode the raw JSON to see the structure
                if let data = response.data {
                    do {
                        let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                        print("📝 JSON Structure: \(jsonObject)")
                        
                        // Try to decode as a wrapper that might contain the recipe
                        if let jsonDict = jsonObject as? [String: Any] {
                            print("🔍 Top-level keys: \(Array(jsonDict.keys))")
                            
                            // Check if it's a direct recipe object
                            if jsonDict.keys.contains("name") && jsonDict.keys.contains("ingredients") {
                                print("📋 Looks like a direct recipe object")
                                let aiRecipe = try JSONDecoder().decode(AIRecipe.self, from: data)
                                print("✅ Successfully decoded as AIRecipe: \(aiRecipe.name)")
                                return aiRecipe.toRecipe()
                            }
                        }
                    } catch {
                        print("❌ Failed to parse JSON: \(error)")
                    }
                }
                
                // If all else fails, rethrow the original error
                throw error
            }
        })
    }

    static func getChats() -> Query<[Chat]> {
        Query(
            queryKey: .init(["chats"]),
            queryFn: {
                try await api.request(
                    Router.getAllChats
                )
                .responseData { response in
                    if let data = response.data, let str = String(data: data, encoding: .utf8) {
                        print("GetChats Raw Response: \(str)")
                    }
                }
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
                .responseData { response in
                    if let data = response.data, let str = String(data: data, encoding: .utf8) {
                        print("GetChat Raw Response: \(str)")
                    }
                }
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
                .responseData { response in
                    if let data = response.data, let str = String(data: data, encoding: .utf8) {
                        print("GetChatMutation Raw Response: \(str)")
                    }
                }
                .validate()
                .serializingDecodable(
                    Chat.self
                )
                .value
            }
        )
    }
}
