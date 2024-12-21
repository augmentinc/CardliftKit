//
//  GetCardMetaDataHandler.swift
//

import Foundation

/// A handler responsible for processing messages related to retrieving card metadata.
/// Conforms to the `MessageHandler` protocol.
struct GetCardMetaDataHandler: MessageHandler {
    static let name = "getCardMetaData"

    struct MessageData: Codable {}

    typealias MessageResponse = CardMetaData

    func handle(data: MessageData) throws -> MessageResponse {
        guard let cardMetaData = SharedData.cardMetaData else {
            throw "Card meta data not found"
        }
        return cardMetaData
    }
}
