//
//  OnInstallMessageHandler.swift
//  CardliftKit
//
//  Created by Ray Nirola on 16/01/25.
//

import Foundation

/*
 A handler responsible for processing messages related to saving and retriving account info / token
 Conforms to the `MessageHandler` protocol.
 */
struct OnInstallMessageHandler: MessageHandler {
    static let name = "account-on-install"
    
    struct MessageData: Codable {
        public let token : String
    }
    
    typealias MessageResponse = Bool
    
    func handle(data: MessageData) throws -> MessageResponse {
        SharedData.accountInfo = AccountInfo(token: data.token)
        return true
    }
}
