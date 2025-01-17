//
//  OnInstallMessageHandler.swift
//  CardliftKit
//
//  Created by Ray Nirola on 16/01/25.
//

import Foundation

struct AccountTokenResponse: Codable {
    var success: Bool
}

/*
 A handler responsible for processing messages related to saving and retrieving account info / token
 Conforms to the `MessageHandler` protocol.
 */
struct OnInstallMessageHandler: MessageHandler {
    static let name = "sendAccountToken"
    
    typealias MessageResponse = AccountTokenResponse
    
    struct MessageData: Codable {
        var token: String
    }
    
    func handle(data: MessageData) throws -> MessageResponse {
        guard !data.token.isEmpty else {
            throw NSError(domain: "OnInstallMessageHandler", code: 400, userInfo: [NSLocalizedDescriptionKey: "Token cannot be empty"])
        }
        
        SharedData.accountInfo = AccountInfo(token: data.token)
        return AccountTokenResponse(success: true)
    }
}
