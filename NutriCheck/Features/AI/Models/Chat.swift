//
//  Chat.swift
//  NutriCheck
//
//  Created by Alexandru Simedrea on 27.01.2025.
//

import Foundation

struct Chat: Codable, Identifiable {
    var id: Int
    var name: String
    var createdAt: String
    var messages: [Message]?
}

struct Message: Codable {
    let id: Int?
    let role: Role
    let parts: [Part]
    let createdAt: Date
    
    enum Role: String, Codable {
        case user
        case model
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case role
        case parts
        case createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decodeIfPresent(Int.self, forKey: .id)
        role = try container.decode(Role.self, forKey: .role)
        parts = try container.decode([Part].self, forKey: .parts)
        
        let dateString = try container.decode(String.self, forKey: .createdAt)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        
        if let date = formatter.date(from: dateString) {
            createdAt = date
        } else {
            throw DecodingError.dataCorruptedError(
                forKey: .createdAt,
                in: container,
                debugDescription: "Date string does not match format: yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            )
        }
    }
}

struct Part: Codable {
    let text: TextContent
}

enum TextContent: Codable {
    case string(String)
    case response(Response)
    
    private enum CodingKeys: String, CodingKey {
        case response
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
        } else if let responseValue = try? container.decode(Response.self) {
            self = .response(responseValue)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode TextContent")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .response(let response):
            try container.encode(response)
        }
    }
}

struct Response: Codable {
    let response: String
    let recipe: Recipe?
}

struct CreateChatResponse: Codable {
    let message: Response
    let chatID: Int
    let userMessageID: Int
    let modelMessageID: Int
}

struct SendMessageResponse: Codable {
    let message: Response
    let userMessageID: Int
    let modelMessageID: Int
}
