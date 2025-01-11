//
//  Tenant.swift
//  CardliftKit
//
//  Created by Ray Nirola on 11/01/25.
//

import Foundation


struct Tenant: Codable, Identifiable {
    let id, slug: String
    let name, card: String
    // let foreground_color, background_color: String
    // let app_store_url: String

    enum CodingKeys: String, CodingKey {
        case id, slug, name, card
    }
}

class JSONNull: Codable, Hashable {

    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
            return true
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(0)
    }

    public init() {}

    public required init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if !container.decodeNil() {
                    throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
            }
    }

    public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            try container.encodeNil()
    }
}
